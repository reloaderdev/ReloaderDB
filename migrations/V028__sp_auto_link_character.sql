-- ============================================================
-- V028__sp_auto_link_character.sql
-- Personaje equipado al nacer.
--
--   1) equipment.sp_AutoLinkCharacter @CharacterId [, @Silent, @Applied OUTPUT]
--      Si el personaje NO tiene equipo: equipa el set de su clase en todos
--      los EquipmentSlot (incluidos RING_LEFT/RIGHT y BRACELET_LEFT/RIGHT),
--      encanto [20] y absorcion 240 como el set de NazgulKash, crea los
--      sockets 1..MaxSockets y los llena con lapis de REFERENCIA.
--      Si ya tiene equipo no hace nada (Applied = 0).
--   2) auth.sp_RegisterPlayerWithCharacter: llama al auto-linkeo dentro de
--      la misma transaccion (misma firma y mismo result set que V025)
--   3) equipment.sp_GetCharacterScreenByUser: result set 5 NUEVO al final
--      con los stats base de la clase (StatCode, StatValue). Los result
--      sets 1..4 quedan iguales que en V012.
--
-- Reglas del auto-linkeo (es solo una referencia inicial: el jugador
-- luego saca / pone / cambia lapis a su gusto):
--   - Un lapis es candidato para una pieza solo si: LapisApplicableItemType
--     acepta el tipo de pieza, Lapis.RequiredLevel <= Item.RequiredLevel,
--     Lapis.IsActive = 1 y no esta ya en la misma pieza. NUNCA por clase.
--   - Orden por pieza:
--       0) lapis de arma (tipo WEAPON) en el arma, si suman o son utilitarios
--       1) AbsorptionSockets lapis de absorcion de mayor nivel
--          (solo si la clase usa absorcion y la pieza lo acepta)
--       2) el resto por puntaje = stats preferidos ponderados
--          (prioridad 1 x3, 2 x2, 3 x1) + HP / 100 (desempate)
--   - No se usan lapis de absorcion en clases de dano, ni lapis con puntaje
--     0 que tengan stats (ej. INT en un Guerrero). Los lapis sin ningun
--     stat (utilitarios: Max Flash, Sonic) si se aceptan al final.
-- ============================================================


-- ------------------------------------------------------------
-- 1) equipment.sp_AutoLinkCharacter
--    @Silent = 1 -> no devuelve result set (lo usa el registro)
--    Result set (si @Silent = 0):
--      CharacterId, Applied, Status, ItemsEquipped, SocketsCreated, LapisLinked
--    Status: LINKED | ALREADY_EQUIPPED
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE equipment.sp_AutoLinkCharacter
    @CharacterId BIGINT,
    @Silent      BIT = 0,
    @Applied     BIT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ClassId           INT;
    DECLARE @Level             INT;
    DECLARE @AbsorptionSockets INT = 0;
    DECLARE @ItemsEquipped     INT = 0;
    DECLARE @SocketsCreated    INT = 0;
    DECLARE @LapisLinked       INT = 0;
    DECLARE @OwnTran           BIT = 0;

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

    SELECT @AbsorptionSockets = AbsorptionSockets
    FROM catalog.ClassAutoLinkConfig
    WHERE ClassId = @ClassId;

    SET @AbsorptionSockets = ISNULL(@AbsorptionSockets, 0);

    -- Pesos por stat segun preferencias de la clase (1 -> 3, 2 -> 2, 3 -> 1)
    DECLARE @wSTR INT = 0, @wDEX INT = 0, @wREC INT = 0, @wINT INT = 0, @wWIS INT = 0, @wLUC INT = 0;

    SELECT
        @wSTR = ISNULL(MAX(CASE WHEN ST.StatCode = 'STR' THEN 4 - P.Priority ELSE 0 END), 0),
        @wDEX = ISNULL(MAX(CASE WHEN ST.StatCode = 'DEX' THEN 4 - P.Priority ELSE 0 END), 0),
        @wREC = ISNULL(MAX(CASE WHEN ST.StatCode = 'REC' THEN 4 - P.Priority ELSE 0 END), 0),
        @wINT = ISNULL(MAX(CASE WHEN ST.StatCode = 'INT' THEN 4 - P.Priority ELSE 0 END), 0),
        @wWIS = ISNULL(MAX(CASE WHEN ST.StatCode = 'WIS' THEN 4 - P.Priority ELSE 0 END), 0),
        @wLUC = ISNULL(MAX(CASE WHEN ST.StatCode = 'LUC' THEN 4 - P.Priority ELSE 0 END), 0)
    FROM catalog.ClassStatPreference P
    JOIN catalog.StatType ST ON ST.StatTypeId = P.StatTypeId
    WHERE P.ClassId = @ClassId;

    IF @@TRANCOUNT = 0
    BEGIN
        BEGIN TRANSACTION;
        SET @OwnTran = 1;
    END

    BEGIN TRY
        -- --------------------------------------------------------
        -- a) Equipo: por cada slot activo, el item permitido para la clase
        --    de ese tipo. Si hay varios slots del mismo tipo (anillos,
        --    brazaletes) se reparten por orden: slot k -> item k (por ItemId);
        --    si hay menos items que slots se repite.
        --    Encanto [20] + absorcion 240 igual que NazgulKash:
        --      armadura (5) y escudo -> 20 / 240 ; arma -> 20 / NULL
        -- --------------------------------------------------------
        ;WITH Slots AS (
            SELECT
                ES.EquipmentSlotId,
                ES.ItemTypeId,
                ES.SlotCode,
                ROW_NUMBER() OVER (PARTITION BY ES.ItemTypeId ORDER BY ES.SortOrder) AS SlotRank
            FROM catalog.EquipmentSlot ES
            WHERE ES.IsActive = 1
        ),
        ClassItems AS (
            SELECT
                I.ItemId,
                I.ItemTypeId,
                ROW_NUMBER() OVER (PARTITION BY I.ItemTypeId ORDER BY I.ItemId) AS ItemRank,
                COUNT(*)     OVER (PARTITION BY I.ItemTypeId)                   AS ItemCount
            FROM catalog.Item I
            JOIN catalog.ItemAllowedClass IAC
                ON IAC.ItemId  = I.ItemId
               AND IAC.ClassId = @ClassId
            WHERE I.IsActive = 1
              AND I.RequiredLevel <= @Level
        )
        INSERT INTO equipment.CharacterEquipment (
            CharacterId, EquipmentSlotId, ItemId, ItemTypeId,
            DisplayNameOverride, DescriptionOverride, EnchantLevel, DamageAbsorption
        )
        SELECT
            @CharacterId,
            S.EquipmentSlotId,
            CI.ItemId,
            S.ItemTypeId,
            NULL,
            NULL,
            CASE WHEN S.SlotCode IN ('HELMET', 'TOP', 'PANTS', 'GLOVES', 'BOOTS', 'SHIELD', 'WEAPON') THEN 20 END,
            CASE WHEN S.SlotCode IN ('HELMET', 'TOP', 'PANTS', 'GLOVES', 'BOOTS', 'SHIELD')           THEN 240 END
        FROM Slots S
        JOIN ClassItems CI
            ON CI.ItemTypeId = S.ItemTypeId
           AND CI.ItemRank   = ((S.SlotRank - 1) % CI.ItemCount) + 1
        JOIN catalog.ItemTypeSlot ITS
            ON ITS.ItemTypeId      = S.ItemTypeId
           AND ITS.EquipmentSlotId = S.EquipmentSlotId;

        SET @ItemsEquipped = @@ROWCOUNT;

        -- --------------------------------------------------------
        -- b) Sockets 1..MaxSockets (abiertos, como el resto del equipo)
        -- --------------------------------------------------------
        INSERT INTO equipment.EquippedItemSocket (CharacterEquipmentId, ItemTypeId, SocketNumber, IsOpen)
        SELECT CE.CharacterEquipmentId, CE.ItemTypeId, N.SocketNumber, 1
        FROM equipment.CharacterEquipment CE
        JOIN catalog.Item I ON I.ItemId = CE.ItemId
        JOIN (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS N(SocketNumber)
            ON N.SocketNumber <= I.MaxSockets
        WHERE CE.CharacterId = @CharacterId;

        SET @SocketsCreated = @@ROWCOUNT;

        -- --------------------------------------------------------
        -- c) Lapis de referencia por pieza
        -- --------------------------------------------------------
        ;WITH Pieces AS (
            SELECT
                CE.CharacterEquipmentId,
                CE.ItemTypeId,
                I.RequiredLevel AS ItemLevel,
                I.MaxSockets
            FROM equipment.CharacterEquipment CE
            JOIN catalog.Item I ON I.ItemId = CE.ItemId
            WHERE CE.CharacterId = @CharacterId
              AND I.MaxSockets   > 0
        ),
        Candidates AS (
            SELECT
                P.CharacterEquipmentId,
                P.ItemTypeId,
                P.MaxSockets,
                L.LapisId,
                L.LapisLevel,
                CASE WHEN ISNULL(L.StatDamageAbsorption, 0) > 0 THEN 1 ELSE 0 END AS IsAbsorption,
                CASE WHEN LT.LapisTypeCode = 'WEAPON' THEN 1 ELSE 0 END            AS IsWeaponLapis,
                CASE WHEN ISNULL(L.StatSTR, 0) = 0 AND ISNULL(L.StatDEX, 0) = 0
                      AND ISNULL(L.StatREC, 0) = 0 AND ISNULL(L.StatINT, 0) = 0
                      AND ISNULL(L.StatWIS, 0) = 0 AND ISNULL(L.StatLUC, 0) = 0
                      AND ISNULL(L.StatMaxHP, 0) = 0 AND ISNULL(L.StatDamageAbsorption, 0) = 0
                     THEN 1 ELSE 0 END                                             AS IsUtility,
                  ISNULL(L.StatSTR, 0) * @wSTR
                + ISNULL(L.StatDEX, 0) * @wDEX
                + ISNULL(L.StatREC, 0) * @wREC
                + ISNULL(L.StatINT, 0) * @wINT
                + ISNULL(L.StatWIS, 0) * @wWIS
                + ISNULL(L.StatLUC, 0) * @wLUC
                + ISNULL(L.StatMaxHP, 0) / 100.0                                   AS Score
            FROM Pieces P
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
                    PARTITION BY C.CharacterEquipmentId, C.IsAbsorption
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
            WHERE (R.IsAbsorption = 1 AND R.AbsRank <= @AbsorptionSockets)
               OR (R.IsAbsorption = 0 AND (R.Score > 0 OR R.IsUtility = 1))
        ),
        Ordered AS (
            SELECT
                E.*,
                ROW_NUMBER() OVER (
                    PARTITION BY E.CharacterEquipmentId
                    ORDER BY E.Grp, E.Score DESC, E.LapisLevel DESC, E.LapisId
                ) AS SocketNumber
            FROM Eligible E
        )
        INSERT INTO equipment.EquippedItemLapis (EquippedItemSocketId, CharacterEquipmentId, ItemTypeId, LapisId)
        SELECT S.EquippedItemSocketId, O.CharacterEquipmentId, O.ItemTypeId, O.LapisId
        FROM Ordered O
        JOIN equipment.EquippedItemSocket S
            ON S.CharacterEquipmentId = O.CharacterEquipmentId
           AND S.SocketNumber         = O.SocketNumber
        WHERE O.SocketNumber <= O.MaxSockets;

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
-- 2) auth.sp_RegisterPlayerWithCharacter — igual a V025 + auto-linkeo
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

        -- V028: el personaje nace equipado (set de su clase + lapis de referencia)
        EXEC equipment.sp_AutoLinkCharacter
            @CharacterId = @CharacterId,
            @Silent      = 1;

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


-- ------------------------------------------------------------
-- 3) equipment.sp_GetCharacterScreenByUser — V012 + result set 5
--    Result 1..4: SIN CAMBIOS (mismas columnas y orden que V012)
--    Result 5 (nuevo): stats base de la clase del personaje
--      StatCode NVARCHAR(30), StatValue INT  (catalog.ClassBaseStat)
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE equipment.sp_GetCharacterScreenByUser
    @UserId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CharacterId BIGINT;
    SELECT @CharacterId = C.CharacterId
    FROM core.Player P
    JOIN core.Character C ON C.PlayerId = P.PlayerId
    WHERE P.UserId = @UserId
      AND C.IsPrimary = 1
      AND C.IsActive = 1;
    IF @CharacterId IS NULL
    BEGIN
        SELECT @CharacterId = C.CharacterId
        FROM core.Player P
        JOIN core.Character C ON C.PlayerId = P.PlayerId
        WHERE P.UserId = @UserId
          AND C.IsActive = 1
        ORDER BY C.CreatedAt ASC
        OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;
    END;

    -- Result 1: Info del personaje
    SELECT
        C.CharacterId,
        C.CharacterName,
        C.Level,
        C.Title,
        C.Mode,
        C.Element,
        F.FactionCode,
        F.FactionName,
        CL.ClassCode,
        CL.ClassName
    FROM core.Character C
    JOIN core.Faction F  ON F.FactionId  = C.FactionId
    JOIN core.Class CL   ON CL.ClassId   = C.ClassId
    WHERE C.CharacterId = @CharacterId;

    -- Result 2: Slots equipados + stats del item + enchant + sockets + stats del lapis + imagen
    SELECT
        ES.SlotCode,
        ES.SlotName,
        ES.SortOrder,
        CE.CharacterEquipmentId,
        CE.ItemTypeId,
        CE.EnchantLevel,
        CE.DamageAbsorption,
        I.ItemId,
        I.ItemCode,
        COALESCE(CE.DisplayNameOverride, I.ItemName) AS ItemName,
        I.ImageUrl,
        I.MaxSockets,
        I.StatDefensePower,
        I.StatResistence,
        I.StatBaseMaxHP,
        I.StatBaseMaxSP,
        I.StatBaseMaxMP,
        I.StatBaseSTR,
        I.StatBaseDEX,
        I.StatBaseREC,
        I.StatBaseLUC,
        I.StatBaseINT,
        I.StatBaseWIS,
        I.StatAttackPowerMin,
        I.StatAttackPowerMax,
        I.StatCriticalDamageBonus,
        I.StatElement,
        I.RecStatHP,
        I.RecStatSTR,
        I.RecStatDEX,
        I.RecStatREC,
        I.RecStatLUC,
        S.EquippedItemSocketId,
        S.SocketNumber,
        S.IsOpen,
        L.LapisId,
        L.LapisCode,
        L.LapisName,
        L.LapisLevel,
        LT.LapisTypeCode,
        L.StatSTR   AS LapisStatSTR,
        L.StatDEX   AS LapisStatDEX,
        L.StatREC   AS LapisStatREC,
        L.StatLUC   AS LapisStatLUC,
        L.StatINT   AS LapisStatINT,
        L.StatWIS   AS LapisStatWIS,
        L.StatMaxHP AS LapisStatMaxHP
    FROM catalog.EquipmentSlot ES
    LEFT JOIN equipment.CharacterEquipment CE
        ON CE.EquipmentSlotId = ES.EquipmentSlotId
       AND CE.CharacterId = @CharacterId
    LEFT JOIN catalog.Item I
        ON I.ItemId = CE.ItemId
    LEFT JOIN equipment.EquippedItemSocket S
        ON S.CharacterEquipmentId = CE.CharacterEquipmentId
    LEFT JOIN equipment.EquippedItemLapis EIL
        ON EIL.EquippedItemSocketId = S.EquippedItemSocketId
    LEFT JOIN catalog.Lapis L
        ON L.LapisId = EIL.LapisId
    LEFT JOIN catalog.LapisType LT
        ON LT.LapisTypeId = L.LapisTypeId
    ORDER BY ES.SortOrder, S.SocketNumber;

    -- Result 3: Catalogo de lapis con stats calculables
    SELECT
        L.LapisId,
        L.LapisCode,
        L.LapisName,
        L.LapisLevel,
        L.RequiredLevel,
        L.Description,
        L.RiskNote,
        LT.LapisTypeCode,
        LT.LapisTypeName,
        L.StatSTR,
        L.StatDEX,
        L.StatREC,
        L.StatLUC,
        L.StatINT,
        L.StatWIS,
        L.StatMaxHP
    FROM catalog.Lapis L
    JOIN catalog.LapisType LT ON LT.LapisTypeId = L.LapisTypeId
    WHERE L.IsActive = 1
    ORDER BY L.LapisLevel, L.LapisCode;

    -- Result 4: Aplicabilidad de lapis por tipo de item
    SELECT LapisId, ItemTypeId
    FROM catalog.LapisApplicableItemType
    ORDER BY LapisId, ItemTypeId;

    -- Result 5 (V028): stats base de la clase del personaje
    -- (se consultan de catalog.ClassBaseStat, no se copian al personaje)
    SELECT
        ST.StatCode,
        CBS.StatValue
    FROM core.Character C
    JOIN catalog.ClassBaseStat CBS ON CBS.ClassId    = C.ClassId
    JOIN catalog.StatType ST       ON ST.StatTypeId  = CBS.StatTypeId
    WHERE C.CharacterId = @CharacterId
    ORDER BY ST.StatTypeId;
END;
GO
