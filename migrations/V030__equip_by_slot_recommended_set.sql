-- ============================================================
-- V030__equip_by_slot_recommended_set.sql
-- El personaje nace SIN set. El jugador equipa pieza por pieza
-- (o varias) desde Mi Personaje usando el set de su clase como
-- REFERENCIA.
--
--   1) equipment.fn_ClassSetPieces (@ClassId, @Level)            [NUEVA]
--      La pieza del set de la clase por cada EquipmentSlot activo,
--      con encanto / absorcion como el auto-linkeo (V028).
--   2) equipment.fn_RecommendedLapisForItem (@ClassId, @ItemId)  [NUEVA]
--      Los lapis de referencia de una pieza: SocketNumber, LapisId.
--      Misma regla que el auto-linkeo de V028 (extraida aqui).
--   3) equipment.sp_AutoLinkCharacter: reescrito sobre 1) y 2).
--      Misma firma y MISMO resultado que V028 (verificado clase por
--      clase contra la version anterior).
--   4) equipment.sp_GetRecommendedSet @CharacterId         [NUEVO]
--      Solo lectura. 2 result sets: slots / lapis sugeridos.
--   5) equipment.sp_EquipSlots @CharacterId, @SlotCodes, @WithRecommendedLapis [NUEVO]
--      Equipa en los slots pedidos que esten vacios la pieza del set.
--   6) auth.sp_RegisterPlayerWithCharacter: deja de llamar al
--      auto-linkeo (el personaje nace sin equipo). Misma firma y
--      mismo result set que V025/V028.
--
-- El recomendado es solo una REFERENCIA: nada de esto restringe lo
-- que el jugador linkee despues (sp_SaveCharacterLapisConfig sigue
-- igual).
-- ============================================================


-- ------------------------------------------------------------
-- 1) equipment.fn_ClassSetPieces
--    Por cada slot activo, el item permitido para la clase de ese
--    tipo (RequiredLevel <= nivel). Si hay varios slots del mismo
--    tipo (anillos, brazaletes) se reparten por orden:
--    slot k -> item k (por ItemId); si hay menos items que slots se
--    repite. Encanto [20] + absorcion 240 igual que NazgulKash:
--      armadura (5) y escudo -> 20 / 240 ; arma -> 20 / NULL
--    Un slot sin item para la clase no aparece.
-- ------------------------------------------------------------
CREATE OR ALTER FUNCTION equipment.fn_ClassSetPieces
(
    @ClassId INT,
    @Level   INT
)
RETURNS TABLE
AS
RETURN
(
    WITH Slots AS (
        SELECT
            ES.EquipmentSlotId,
            ES.ItemTypeId,
            ES.SlotCode,
            ES.SlotName,
            ES.SortOrder,
            ROW_NUMBER() OVER (PARTITION BY ES.ItemTypeId ORDER BY ES.SortOrder) AS SlotRank
        FROM catalog.EquipmentSlot ES
        WHERE ES.IsActive = 1
    ),
    ClassItems AS (
        SELECT
            I.ItemId,
            I.ItemTypeId,
            I.ItemName,
            I.MaxSockets,
            ROW_NUMBER() OVER (PARTITION BY I.ItemTypeId ORDER BY I.ItemId) AS ItemRank,
            COUNT(*)     OVER (PARTITION BY I.ItemTypeId)                   AS ItemCount
        FROM catalog.Item I
        JOIN catalog.ItemAllowedClass IAC
            ON IAC.ItemId  = I.ItemId
           AND IAC.ClassId = @ClassId
        WHERE I.IsActive = 1
          AND I.RequiredLevel <= @Level
    )
    SELECT
        S.EquipmentSlotId,
        S.SlotCode,
        S.SlotName,
        S.SortOrder,
        S.ItemTypeId,
        CI.ItemId,
        CI.ItemName,
        CI.MaxSockets,
        CASE WHEN S.SlotCode IN ('HELMET', 'TOP', 'PANTS', 'GLOVES', 'BOOTS', 'SHIELD', 'WEAPON') THEN 20 END  AS EnchantLevel,
        CASE WHEN S.SlotCode IN ('HELMET', 'TOP', 'PANTS', 'GLOVES', 'BOOTS', 'SHIELD')           THEN 240 END AS DamageAbsorption
    FROM Slots S
    JOIN ClassItems CI
        ON CI.ItemTypeId = S.ItemTypeId
       AND CI.ItemRank   = ((S.SlotRank - 1) % CI.ItemCount) + 1
    JOIN catalog.ItemTypeSlot ITS
        ON ITS.ItemTypeId      = S.ItemTypeId
       AND ITS.EquipmentSlotId = S.EquipmentSlotId
);
GO


-- ------------------------------------------------------------
-- 2) equipment.fn_RecommendedLapisForItem
--    Lapis de REFERENCIA para una pieza (regla de V028):
--    - Candidato solo si LapisApplicableItemType acepta el tipo de la
--      pieza, Lapis.RequiredLevel <= Item.RequiredLevel,
--      Lapis.IsActive = 1. Nunca por clase. Sin repetir en la pieza.
--    - Orden:
--        0) lapis de arma (tipo WEAPON)
--        1) AbsorptionSockets lapis de absorcion de mayor nivel
--           (ClassAutoLinkConfig; 0 = la clase no usa absorcion)
--        2) el resto por puntaje = stats preferidos ponderados
--           (prioridad 1 x3, 2 x2, 3 x1) + HP / 100
--    - No entran lapis con puntaje 0 que tengan stats; los utilitarios
--      (sin ningun stat) si, al final.
--    Devuelve SocketNumber (1..MaxSockets) y LapisId.
-- ------------------------------------------------------------
CREATE OR ALTER FUNCTION equipment.fn_RecommendedLapisForItem
(
    @ClassId INT,
    @ItemId  BIGINT
)
RETURNS TABLE
AS
RETURN
(
    WITH Weights AS (
        SELECT
            ISNULL(MAX(CASE WHEN ST.StatCode = 'STR' THEN 4 - P.Priority ELSE 0 END), 0) AS wSTR,
            ISNULL(MAX(CASE WHEN ST.StatCode = 'DEX' THEN 4 - P.Priority ELSE 0 END), 0) AS wDEX,
            ISNULL(MAX(CASE WHEN ST.StatCode = 'REC' THEN 4 - P.Priority ELSE 0 END), 0) AS wREC,
            ISNULL(MAX(CASE WHEN ST.StatCode = 'INT' THEN 4 - P.Priority ELSE 0 END), 0) AS wINT,
            ISNULL(MAX(CASE WHEN ST.StatCode = 'WIS' THEN 4 - P.Priority ELSE 0 END), 0) AS wWIS,
            ISNULL(MAX(CASE WHEN ST.StatCode = 'LUC' THEN 4 - P.Priority ELSE 0 END), 0) AS wLUC,
            ISNULL((SELECT MAX(CFG.AbsorptionSockets)
                    FROM catalog.ClassAutoLinkConfig CFG
                    WHERE CFG.ClassId = @ClassId), 0)                                     AS AbsorptionSockets
        FROM catalog.ClassStatPreference P
        JOIN catalog.StatType ST ON ST.StatTypeId = P.StatTypeId
        WHERE P.ClassId = @ClassId
    ),
    Piece AS (
        SELECT
            I.ItemTypeId,
            I.RequiredLevel AS ItemLevel,
            I.MaxSockets
        FROM catalog.Item I
        WHERE I.ItemId     = @ItemId
          AND I.MaxSockets > 0
    ),
    Candidates AS (
        SELECT
            P.MaxSockets,
            W.AbsorptionSockets,
            L.LapisId,
            L.LapisLevel,
            CASE WHEN ISNULL(L.StatDamageAbsorption, 0) > 0 THEN 1 ELSE 0 END AS IsAbsorption,
            CASE WHEN LT.LapisTypeCode = 'WEAPON' THEN 1 ELSE 0 END            AS IsWeaponLapis,
            CASE WHEN ISNULL(L.StatSTR, 0) = 0 AND ISNULL(L.StatDEX, 0) = 0
                  AND ISNULL(L.StatREC, 0) = 0 AND ISNULL(L.StatINT, 0) = 0
                  AND ISNULL(L.StatWIS, 0) = 0 AND ISNULL(L.StatLUC, 0) = 0
                  AND ISNULL(L.StatMaxHP, 0) = 0 AND ISNULL(L.StatDamageAbsorption, 0) = 0
                 THEN 1 ELSE 0 END                                             AS IsUtility,
              ISNULL(L.StatSTR, 0) * W.wSTR
            + ISNULL(L.StatDEX, 0) * W.wDEX
            + ISNULL(L.StatREC, 0) * W.wREC
            + ISNULL(L.StatINT, 0) * W.wINT
            + ISNULL(L.StatWIS, 0) * W.wWIS
            + ISNULL(L.StatLUC, 0) * W.wLUC
            + ISNULL(L.StatMaxHP, 0) / 100.0                                   AS Score
        FROM Piece P
        CROSS JOIN Weights W
        JOIN catalog.LapisApplicableItemType A ON A.ItemTypeId = P.ItemTypeId
        JOIN catalog.Lapis L
            ON L.LapisId        = A.LapisId
           AND L.IsActive       = 1
           AND L.RequiredLevel <= P.ItemLevel
        JOIN catalog.LapisType LT ON LT.LapisTypeId = L.LapisTypeId
    ),
    AbsRanked AS (
        SELECT
            C.*,
            ROW_NUMBER() OVER (
                PARTITION BY C.IsAbsorption
                ORDER BY C.LapisLevel DESC, C.LapisId
            ) AS AbsRank
        FROM Candidates C
    ),
    Eligible AS (
        SELECT
            R.*,
            CASE
                WHEN R.IsWeaponLapis = 1 THEN 0
                WHEN R.IsAbsorption  = 1 THEN 1
                ELSE 2
            END AS Grp
        FROM AbsRanked R
        WHERE (R.IsAbsorption = 1 AND R.AbsRank <= R.AbsorptionSockets)
           OR (R.IsAbsorption = 0 AND (R.Score > 0 OR R.IsUtility = 1))
    ),
    Ordered AS (
        SELECT
            E.MaxSockets,
            E.LapisId,
            ROW_NUMBER() OVER (
                ORDER BY E.Grp, E.Score DESC, E.LapisLevel DESC, E.LapisId
            ) AS SocketNumber
        FROM Eligible E
    )
    SELECT
        CAST(O.SocketNumber AS INT) AS SocketNumber,
        O.LapisId
    FROM Ordered O
    WHERE O.SocketNumber <= O.MaxSockets
);
GO


-- ------------------------------------------------------------
-- 3) equipment.sp_AutoLinkCharacter — misma firma y resultado que V028
--    @Silent = 1 -> no devuelve result set
--    Result set (si @Silent = 0):
--      CharacterId, Applied, Status, ItemsEquipped, SocketsCreated, LapisLinked
--    Status: LINKED | ALREADY_EQUIPPED
--    Desde V030 ya no se llama en el registro; queda disponible para
--    equipar un personaje completo (demos, soporte).
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE equipment.sp_AutoLinkCharacter
    @CharacterId BIGINT,
    @Silent      BIT = 0,
    @Applied     BIT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ClassId        INT;
    DECLARE @Level          INT;
    DECLARE @ItemsEquipped  INT = 0;
    DECLARE @SocketsCreated INT = 0;
    DECLARE @LapisLinked    INT = 0;
    DECLARE @OwnTran        BIT = 0;

    SET @Applied = 0;

    SELECT
        @ClassId = C.ClassId,
        @Level   = C.Level
    FROM core.Character C
    WHERE C.CharacterId = @CharacterId
      AND C.IsActive    = 1;

    IF @ClassId IS NULL
        THROW 50280, 'Active character not found.', 1;

    -- Ya tiene equipo: no se toca nada
    IF EXISTS (SELECT 1 FROM equipment.CharacterEquipment WHERE CharacterId = @CharacterId)
    BEGIN
        IF @Silent = 0
            SELECT
                @CharacterId                       AS CharacterId,
                CAST(0 AS BIT)                     AS Applied,
                CAST('ALREADY_EQUIPPED' AS NVARCHAR(30)) AS Status,
                0                                  AS ItemsEquipped,
                0                                  AS SocketsCreated,
                0                                  AS LapisLinked;
        RETURN;
    END

    IF @@TRANCOUNT = 0
    BEGIN
        BEGIN TRANSACTION;
        SET @OwnTran = 1;
    END

    BEGIN TRY
        -- a) Equipo: el set de la clase en todos los slots
        INSERT INTO equipment.CharacterEquipment (
            CharacterId, EquipmentSlotId, ItemId, ItemTypeId,
            DisplayNameOverride, DescriptionOverride, EnchantLevel, DamageAbsorption
        )
        SELECT
            @CharacterId,
            SP.EquipmentSlotId,
            SP.ItemId,
            SP.ItemTypeId,
            NULL,
            NULL,
            SP.EnchantLevel,
            SP.DamageAbsorption
        FROM equipment.fn_ClassSetPieces(@ClassId, @Level) SP;

        SET @ItemsEquipped = @@ROWCOUNT;

        -- b) Sockets 1..MaxSockets (abiertos, como el resto del equipo)
        INSERT INTO equipment.EquippedItemSocket (CharacterEquipmentId, ItemTypeId, SocketNumber, IsOpen)
        SELECT CE.CharacterEquipmentId, CE.ItemTypeId, N.SocketNumber, 1
        FROM equipment.CharacterEquipment CE
        JOIN catalog.Item I ON I.ItemId = CE.ItemId
        JOIN (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS N(SocketNumber)
            ON N.SocketNumber <= I.MaxSockets
        WHERE CE.CharacterId = @CharacterId;

        SET @SocketsCreated = @@ROWCOUNT;

        -- c) Lapis de referencia por pieza
        INSERT INTO equipment.EquippedItemLapis (EquippedItemSocketId, CharacterEquipmentId, ItemTypeId, LapisId)
        SELECT S.EquippedItemSocketId, CE.CharacterEquipmentId, CE.ItemTypeId, R.LapisId
        FROM equipment.CharacterEquipment CE
        CROSS APPLY equipment.fn_RecommendedLapisForItem(@ClassId, CE.ItemId) R
        JOIN equipment.EquippedItemSocket S
            ON S.CharacterEquipmentId = CE.CharacterEquipmentId
           AND S.SocketNumber         = R.SocketNumber
        WHERE CE.CharacterId = @CharacterId;

        SET @LapisLinked = @@ROWCOUNT;

        IF @OwnTran = 1
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @OwnTran = 1 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH

    SET @Applied = 1;

    IF @Silent = 0
        SELECT
            @CharacterId                   AS CharacterId,
            CAST(1 AS BIT)                 AS Applied,
            CAST('LINKED' AS NVARCHAR(30)) AS Status,
            @ItemsEquipped                 AS ItemsEquipped,
            @SocketsCreated                AS SocketsCreated,
            @LapisLinked                   AS LapisLinked;
END
GO


-- ------------------------------------------------------------
-- 4) equipment.sp_GetRecommendedSet @CharacterId — solo lectura
--    Result 1 (slots, todos los EquipmentSlot activos, por SortOrder):
--      SlotCode, SlotName, SortOrder, ItemId, ItemName, MaxSockets,
--      Equipped, EquippedItemName
--      ItemId/ItemName/MaxSockets = pieza del set de la clase para el
--      slot (NULL si la clase no tiene pieza para ese slot).
--      Equipped = 1 si el personaje ya tiene algo en ese slot;
--      EquippedItemName = nombre de lo equipado (NULL si vacio).
--    Result 2 (lapis sugeridos):
--      SlotCode, SocketNumber, LapisId, LapisName, LapisTypeCode
--      Slot vacio    -> sugeridos para la pieza del set.
--      Slot equipado -> sugeridos para la pieza que TIENE equipada
--                       (sirve para "Linkear sugerido").
--    Personaje inexistente o inactivo -> los 2 result sets vacios.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE equipment.sp_GetRecommendedSet
    @CharacterId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ClassId INT;
    DECLARE @Level   INT;

    SELECT
        @ClassId = C.ClassId,
        @Level   = C.Level
    FROM core.Character C
    WHERE C.CharacterId = @CharacterId
      AND C.IsActive    = 1;

    DECLARE @Slots TABLE (
        EquipmentSlotId  INT           NOT NULL PRIMARY KEY,
        SlotCode         NVARCHAR(30)  NOT NULL,
        SlotName         NVARCHAR(100) NOT NULL,
        SortOrder        INT           NOT NULL,
        ItemId           BIGINT        NULL,
        ItemName         NVARCHAR(200) NULL,
        MaxSockets       INT           NULL,
        Equipped         BIT           NOT NULL,
        EquippedItemId   BIGINT        NULL,
        EquippedItemName NVARCHAR(200) NULL
    );

    IF @ClassId IS NOT NULL
        INSERT INTO @Slots (
            EquipmentSlotId, SlotCode, SlotName, SortOrder, ItemId, ItemName, MaxSockets,
            Equipped, EquippedItemId, EquippedItemName
        )
        SELECT
            ES.EquipmentSlotId,
            ES.SlotCode,
            ES.SlotName,
            ES.SortOrder,
            SP.ItemId,
            SP.ItemName,
            SP.MaxSockets,
            CAST(CASE WHEN CE.CharacterEquipmentId IS NULL THEN 0 ELSE 1 END AS BIT),
            CE.ItemId,
            COALESCE(CE.DisplayNameOverride, EI.ItemName)
        FROM catalog.EquipmentSlot ES
        LEFT JOIN equipment.fn_ClassSetPieces(@ClassId, @Level) SP
            ON SP.EquipmentSlotId = ES.EquipmentSlotId
        LEFT JOIN equipment.CharacterEquipment CE
            ON CE.EquipmentSlotId = ES.EquipmentSlotId
           AND CE.CharacterId     = @CharacterId
        LEFT JOIN catalog.Item EI
            ON EI.ItemId = CE.ItemId
        WHERE ES.IsActive = 1;

    -- Result 1: slots
    SELECT
        SlotCode,
        SlotName,
        SortOrder,
        ItemId,
        ItemName,
        MaxSockets,
        Equipped,
        EquippedItemName
    FROM @Slots
    ORDER BY SortOrder;

    -- Result 2: lapis sugeridos por slot
    SELECT
        S.SlotCode,
        R.SocketNumber,
        L.LapisId,
        L.LapisName,
        LT.LapisTypeCode
    FROM @Slots S
    CROSS APPLY equipment.fn_RecommendedLapisForItem(@ClassId, COALESCE(S.EquippedItemId, S.ItemId)) R
    JOIN catalog.Lapis L      ON L.LapisId      = R.LapisId
    JOIN catalog.LapisType LT ON LT.LapisTypeId = L.LapisTypeId
    ORDER BY S.SortOrder, R.SocketNumber;
END
GO


-- ------------------------------------------------------------
-- 5) equipment.sp_EquipSlots
--    @SlotCodes: SlotCode separados por coma ('BOOTS,GLOVES'),
--                sin distinguir mayusculas; se ignoran espacios y
--                repetidos.
--    Equipa en los slots pedidos que esten VACIOS la pieza del set de
--    la clase (encanto / absorcion como el auto-linkeo), crea sus
--    sockets 1..MaxSockets (abiertos) y, si @WithRecommendedLapis = 1,
--    los llena con los lapis sugeridos. Slots ya equipados (o sin
--    pieza para la clase) se saltan.
--    Result (1 fila):
--      Success, ErrorCode, EquippedCount, SkippedCount, LapisLinked
--    ErrorCode: CHARACTER_NOT_FOUND | INVALID_SLOT (algun codigo no
--               existe / no esta activo, o la lista esta vacia).
--    Con error no se escribe nada.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE equipment.sp_EquipSlots
    @CharacterId          BIGINT,
    @SlotCodes            NVARCHAR(MAX),
    @WithRecommendedLapis BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ClassId       INT;
    DECLARE @Level         INT;
    DECLARE @ErrorCode     NVARCHAR(50) = NULL;
    DECLARE @Requested     INT = 0;
    DECLARE @Matched       INT = 0;
    DECLARE @EquippedCount INT = 0;
    DECLARE @LapisLinked   INT = 0;
    DECLARE @OwnTran       BIT = 0;

    DECLARE @Codes TABLE (SlotCode NVARCHAR(30) NOT NULL PRIMARY KEY);
    DECLARE @Wanted TABLE (EquipmentSlotId INT NOT NULL PRIMARY KEY);
    DECLARE @New TABLE (
        CharacterEquipmentId BIGINT NOT NULL PRIMARY KEY,
        ItemId               BIGINT NOT NULL,
        ItemTypeId           INT    NOT NULL
    );

    SELECT
        @ClassId = C.ClassId,
        @Level   = C.Level
    FROM core.Character C
    WHERE C.CharacterId = @CharacterId
      AND C.IsActive    = 1;

    IF @ClassId IS NULL
        SET @ErrorCode = 'CHARACTER_NOT_FOUND';

    IF @ErrorCode IS NULL
    BEGIN
        INSERT INTO @Codes (SlotCode)
        SELECT DISTINCT UPPER(LTRIM(RTRIM(value)))
        FROM STRING_SPLIT(ISNULL(@SlotCodes, N''), N',')
        WHERE LTRIM(RTRIM(value)) <> N'';

        SET @Requested = @@ROWCOUNT;

        INSERT INTO @Wanted (EquipmentSlotId)
        SELECT ES.EquipmentSlotId
        FROM @Codes X
        JOIN catalog.EquipmentSlot ES
            ON ES.SlotCode = X.SlotCode
           AND ES.IsActive = 1;

        SET @Matched = @@ROWCOUNT;

        IF @Requested = 0 OR @Matched <> @Requested
            SET @ErrorCode = 'INVALID_SLOT';
    END

    IF @ErrorCode IS NOT NULL
    BEGIN
        SELECT
            CAST(0 AS BIT)                   AS Success,
            CAST(@ErrorCode AS NVARCHAR(50)) AS ErrorCode,
            0                                AS EquippedCount,
            0                                AS SkippedCount,
            0                                AS LapisLinked;
        RETURN;
    END

    IF @@TRANCOUNT = 0
    BEGIN
        BEGIN TRANSACTION;
        SET @OwnTran = 1;
    END

    BEGIN TRY
        -- a) Piezas del set solo en los slots pedidos que esten vacios
        INSERT INTO equipment.CharacterEquipment (
            CharacterId, EquipmentSlotId, ItemId, ItemTypeId,
            DisplayNameOverride, DescriptionOverride, EnchantLevel, DamageAbsorption
        )
        OUTPUT inserted.CharacterEquipmentId, inserted.ItemId, inserted.ItemTypeId
        INTO @New (CharacterEquipmentId, ItemId, ItemTypeId)
        SELECT
            @CharacterId,
            SP.EquipmentSlotId,
            SP.ItemId,
            SP.ItemTypeId,
            NULL,
            NULL,
            SP.EnchantLevel,
            SP.DamageAbsorption
        FROM equipment.fn_ClassSetPieces(@ClassId, @Level) SP
        JOIN @Wanted W ON W.EquipmentSlotId = SP.EquipmentSlotId
        WHERE NOT EXISTS (
            SELECT 1
            FROM equipment.CharacterEquipment CE WITH (UPDLOCK, HOLDLOCK)
            WHERE CE.CharacterId     = @CharacterId
              AND CE.EquipmentSlotId = SP.EquipmentSlotId
        );

        SET @EquippedCount = @@ROWCOUNT;

        -- b) Sockets 1..MaxSockets (abiertos y vacios)
        INSERT INTO equipment.EquippedItemSocket (CharacterEquipmentId, ItemTypeId, SocketNumber, IsOpen)
        SELECT NW.CharacterEquipmentId, NW.ItemTypeId, N.SocketNumber, 1
        FROM @New NW
        JOIN catalog.Item I ON I.ItemId = NW.ItemId
        JOIN (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS N(SocketNumber)
            ON N.SocketNumber <= I.MaxSockets;

        -- c) Lapis sugeridos (opcional)
        IF @WithRecommendedLapis = 1
        BEGIN
            INSERT INTO equipment.EquippedItemLapis (EquippedItemSocketId, CharacterEquipmentId, ItemTypeId, LapisId)
            SELECT S.EquippedItemSocketId, NW.CharacterEquipmentId, NW.ItemTypeId, R.LapisId
            FROM @New NW
            CROSS APPLY equipment.fn_RecommendedLapisForItem(@ClassId, NW.ItemId) R
            JOIN equipment.EquippedItemSocket S
                ON S.CharacterEquipmentId = NW.CharacterEquipmentId
               AND S.SocketNumber         = R.SocketNumber;

            SET @LapisLinked = @@ROWCOUNT;
        END

        IF @OwnTran = 1
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @OwnTran = 1 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH

    SELECT
        CAST(1 AS BIT)               AS Success,
        CAST(NULL AS NVARCHAR(50))   AS ErrorCode,
        @EquippedCount               AS EquippedCount,
        @Requested - @EquippedCount  AS SkippedCount,
        @LapisLinked                 AS LapisLinked;
END
GO


-- ------------------------------------------------------------
-- 6) auth.sp_RegisterPlayerWithCharacter — igual a V028 SIN el
--    auto-linkeo: el personaje nace sin equipo.
--    Misma firma y mismo result set:
--      Success, ErrorCode, UserId, CharacterId, Email
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE auth.sp_RegisterPlayerWithCharacter
    @Username      NVARCHAR(50),
    @PasswordHash  VARBINARY(256),
    @Salt          VARBINARY(128),
    @CharacterName NVARCHAR(100),
    @FactionId     INT,
    @ClassId       INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ErrorCode    NVARCHAR(50)  = NULL;
    DECLARE @Email        NVARCHAR(255) = NULL;
    DECLARE @UserId       BIGINT        = NULL;
    DECLARE @PlayerId     BIGINT        = NULL;
    DECLARE @CharacterId  BIGINT        = NULL;
    DECLARE @PlayerRoleId INT;

    -- Formato ^[A-Za-z0-9_]{3,20}$ — collation binaria para que [A-Z]
    -- no acepte letras con tilde ni la Ñ; DATALENGTH cuenta espacios finales
    IF @CharacterName IS NULL
       OR DATALENGTH(@CharacterName) / 2 NOT BETWEEN 3 AND 20
       OR @CharacterName COLLATE Latin1_General_BIN2 LIKE N'%[^A-Za-z0-9_]%'
        SET @ErrorCode = 'INVALID_CHARACTER_NAME';
    ELSE
        SET @Email = LOWER(@CharacterName) + N'@reloader.dev';

    IF @ErrorCode IS NULL AND EXISTS (SELECT 1 FROM auth.Users WHERE Username = @Username)
        SET @ErrorCode = 'USERNAME_TAKEN';

    IF @ErrorCode IS NULL AND EXISTS (SELECT 1 FROM core.Character WHERE CharacterName = @CharacterName)
        SET @ErrorCode = 'CHARACTER_NAME_TAKEN';

    IF @ErrorCode IS NULL AND EXISTS (SELECT 1 FROM auth.Users WHERE Email = @Email)
        SET @ErrorCode = 'EMAIL_TAKEN';

    IF @ErrorCode IS NULL AND NOT EXISTS (
        SELECT 1
        FROM core.Class
        WHERE ClassId   = @ClassId
          AND FactionId = @FactionId
          AND IsActive  = 1
    )
        SET @ErrorCode = 'INVALID_CLASS';

    IF @ErrorCode IS NOT NULL
    BEGIN
        SELECT
            CAST(0 AS BIT)                  AS Success,
            CAST(@ErrorCode AS NVARCHAR(50)) AS ErrorCode,
            CAST(NULL AS BIGINT)            AS UserId,
            CAST(NULL AS BIGINT)            AS CharacterId,
            CAST(NULL AS NVARCHAR(255))     AS Email;
        RETURN;
    END

    SELECT @PlayerRoleId = RoleId
    FROM auth.Role
    WHERE RoleCode = 'PLAYER'
      AND IsActive = 1;

    IF @PlayerRoleId IS NULL
        THROW 50252, 'Default PLAYER role was not found.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO auth.Users (
            Username, Email, PasswordHash, Salt, IsActive, FailedAttempts,
            RegistrationSource, EmailCreated, CreatedAt, UpdatedAt
        )
        VALUES (
            @Username, @Email, @PasswordHash, @Salt, 1, 0,
            'PUBLIC', 0, SYSUTCDATETIME(), SYSUTCDATETIME()
        );
        SET @UserId = CAST(SCOPE_IDENTITY() AS BIGINT);

        INSERT INTO auth.UserProfile (UserId, DisplayName)
        VALUES (@UserId, @CharacterName);

        INSERT INTO auth.UserRole (UserId, RoleId, IsActive)
        VALUES (@UserId, @PlayerRoleId, 1);

        INSERT INTO core.Player (UserId, DisplayName, IsActive)
        VALUES (@UserId, @CharacterName, 1);
        SET @PlayerId = CAST(SCOPE_IDENTITY() AS BIGINT);

        INSERT INTO core.Character (
            PlayerId, FactionId, ClassId, CharacterName, Level, IsPrimary, IsActive
        )
        VALUES (
            @PlayerId, @FactionId, @ClassId, @CharacterName, 80, 1, 1
        );
        SET @CharacterId = CAST(SCOPE_IDENTITY() AS BIGINT);

        -- V030: el personaje nace SIN equipo. Lo equipa el jugador desde
        -- Mi Personaje (equipment.sp_EquipSlots / sp_GetRecommendedSet).

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        -- Carrera entre dos registros simultaneos: el indice/constraint unico
        -- gana y se traduce al mismo ErrorCode de negocio
        IF ERROR_NUMBER() IN (2601, 2627)
        BEGIN
            DECLARE @Msg NVARCHAR(4000) = ERROR_MESSAGE();
            SET @ErrorCode = CASE
                WHEN @Msg LIKE N'%UX_core_Character_CharacterName%' THEN 'CHARACTER_NAME_TAKEN'
                WHEN @Msg LIKE N'%UQ_Users_Username%'               THEN 'USERNAME_TAKEN'
                WHEN @Msg LIKE N'%UQ_Users_Email%'                  THEN 'EMAIL_TAKEN'
                ELSE NULL
            END;

            IF @ErrorCode IS NOT NULL
            BEGIN
                SELECT
                    CAST(0 AS BIT)                  AS Success,
                    CAST(@ErrorCode AS NVARCHAR(50)) AS ErrorCode,
                    CAST(NULL AS BIGINT)            AS UserId,
                    CAST(NULL AS BIGINT)            AS CharacterId,
                    CAST(NULL AS NVARCHAR(255))     AS Email;
                RETURN;
            END
        END;

        THROW;
    END CATCH

    SELECT
        CAST(1 AS BIT)              AS Success,
        CAST(NULL AS NVARCHAR(50))  AS ErrorCode,
        @UserId                     AS UserId,
        @CharacterId                AS CharacterId,
        @Email                      AS Email;
END
GO
