-- ============================================================
-- V034__item_recreation_over_max.sql
-- ESTADO: CERRADA (2026-09-30) - no modificar. Produccion en v033 -> v034.
--
-- Recreacion de armaduras ("Over max."): cada pieza equipada de
-- HELMET TOP PANTS GLOVES BOOTS lleva, opcionalmente, una de 2 modalidades.
-- La modalidad fija HP / MP / SP y los 3 valores de stat; el jugador solo
-- elige a que stat primario (STR DEX REC INT WIS LUC) va cada valor.
-- No se mezclan modalidades (6400 HP con 98/69/44 no existe).
--
--   Over max. 1 : HP +4400                    | valores 98, 69, 44
--   Over max. 2 : HP +6400, MP +2000, SP +2000 | valores 88, 44, 44
--
--   1) catalog.RecreationBuild / RecreationBuildValue / RecreationApplicableItemType
--   2) catalog.ClassRecreationPreference (3 stats por clase, orden de valor)
--      y catalog.ClassRecreationConfig (modalidad sugerida por clase).
--      Tabla aparte de ClassStatPreference: esa la usan el auto-linkeo y el
--      set recomendado; sumarle un 3er stat cambiaria las sugerencias de lapis.
--   3) equipment.EquippedItemRecreation / EquippedItemRecreationStat
--      Solo se guarda la modalidad y el stat de cada posicion (1..3);
--      HP/MP/SP y los valores salen de la modalidad (no se pueden falsear).
--   4) Datos: modalidades, piezas, sugeridas por clase
--   5) equipment.sp_GetRecreationSuggestion
--   6) equipment.sp_SaveRecreationConfig
--   7) equipment.sp_GetCharacterScreenByUser — V033 + result sets 6, 7 y 8
--   8) catalog.Item.RecStat* -> NULL en todos los items. Eran una recreacion fija
--      por item (V005 / V027) que la app mostraba como si fuera del jugador.
--      Desde V034 nadie tiene recreacion hasta que la guarde. Las columnas se
--      conservan (el SP de pantalla las sigue devolviendo; la app ya no las usa).
-- ============================================================


-- ------------------------------------------------------------
-- 1) Catalogo de modalidades
-- ------------------------------------------------------------
IF OBJECT_ID('catalog.RecreationBuild', 'U') IS NULL
BEGIN
    CREATE TABLE [catalog].[RecreationBuild] (
        [RecreationBuildId] INT IDENTITY(1,1) NOT NULL,
        [BuildCode]         NVARCHAR(30)  NOT NULL,
        [BuildName]         NVARCHAR(100) NOT NULL,
        [StatMaxHP]         INT NOT NULL CONSTRAINT [DF_catalog_RecreationBuild_StatMaxHP] DEFAULT ((0)),
        [StatMaxMP]         INT NOT NULL CONSTRAINT [DF_catalog_RecreationBuild_StatMaxMP] DEFAULT ((0)),
        [StatMaxSP]         INT NOT NULL CONSTRAINT [DF_catalog_RecreationBuild_StatMaxSP] DEFAULT ((0)),
        [SortOrder]         INT NOT NULL,
        [IsActive]          BIT NOT NULL CONSTRAINT [DF_catalog_RecreationBuild_IsActive] DEFAULT ((1)),
        CONSTRAINT [PK_catalog_RecreationBuild] PRIMARY KEY ([RecreationBuildId]),
        CONSTRAINT [UQ_catalog_RecreationBuild_BuildCode] UNIQUE ([BuildCode])
    );
END
GO

-- ValueSlot 1..3: 1 = valor mas alto. Los stats del jugador se guardan por ValueSlot.
IF OBJECT_ID('catalog.RecreationBuildValue', 'U') IS NULL
BEGIN
    CREATE TABLE [catalog].[RecreationBuildValue] (
        [RecreationBuildId] INT     NOT NULL,
        [ValueSlot]         TINYINT NOT NULL,
        [StatValue]         INT     NOT NULL,
        CONSTRAINT [PK_catalog_RecreationBuildValue] PRIMARY KEY ([RecreationBuildId], [ValueSlot]),
        CONSTRAINT [CK_RecreationBuildValue_ValueSlot] CHECK ([ValueSlot] BETWEEN 1 AND 3),
        CONSTRAINT [CK_RecreationBuildValue_StatValue] CHECK ([StatValue] > 0),
        CONSTRAINT [FK_RecreationBuildValue_Build] FOREIGN KEY ([RecreationBuildId])
            REFERENCES [catalog].[RecreationBuild] ([RecreationBuildId])
    );
END
GO

IF OBJECT_ID('catalog.RecreationApplicableItemType', 'U') IS NULL
BEGIN
    CREATE TABLE [catalog].[RecreationApplicableItemType] (
        [ItemTypeId] INT NOT NULL,
        CONSTRAINT [PK_catalog_RecreationApplicableItemType] PRIMARY KEY ([ItemTypeId]),
        CONSTRAINT [FK_RecreationApplicableItemType_ItemType] FOREIGN KEY ([ItemTypeId])
            REFERENCES [catalog].[ItemType] ([ItemTypeId])
    );
END
GO


-- ------------------------------------------------------------
-- 2) Sugerida por clase
-- ------------------------------------------------------------
-- Priority 1..3 = ValueSlot al que va el stat en la sugerida
IF OBJECT_ID('catalog.ClassRecreationPreference', 'U') IS NULL
BEGIN
    CREATE TABLE [catalog].[ClassRecreationPreference] (
        [ClassId]    INT     NOT NULL,
        [Priority]   TINYINT NOT NULL,
        [StatTypeId] INT     NOT NULL,
        CONSTRAINT [PK_catalog_ClassRecreationPreference] PRIMARY KEY ([ClassId], [Priority]),
        CONSTRAINT [UQ_ClassRecreationPreference_Stat] UNIQUE ([ClassId], [StatTypeId]),
        CONSTRAINT [CK_ClassRecreationPreference_Priority] CHECK ([Priority] BETWEEN 1 AND 3),
        CONSTRAINT [FK_ClassRecreationPreference_Class] FOREIGN KEY ([ClassId]) REFERENCES [core].[Class] ([ClassId]),
        CONSTRAINT [FK_ClassRecreationPreference_StatType] FOREIGN KEY ([StatTypeId]) REFERENCES [catalog].[StatType] ([StatTypeId])
    );
END
GO

IF OBJECT_ID('catalog.ClassRecreationConfig', 'U') IS NULL
BEGIN
    CREATE TABLE [catalog].[ClassRecreationConfig] (
        [ClassId]                    INT NOT NULL,
        [SuggestedRecreationBuildId] INT NOT NULL,
        CONSTRAINT [PK_catalog_ClassRecreationConfig] PRIMARY KEY ([ClassId]),
        CONSTRAINT [FK_ClassRecreationConfig_Class] FOREIGN KEY ([ClassId]) REFERENCES [core].[Class] ([ClassId]),
        CONSTRAINT [FK_ClassRecreationConfig_Build] FOREIGN KEY ([SuggestedRecreationBuildId])
            REFERENCES [catalog].[RecreationBuild] ([RecreationBuildId])
    );
END
GO


-- ------------------------------------------------------------
-- 3) Recreacion de cada pieza equipada
-- ------------------------------------------------------------
IF OBJECT_ID('equipment.EquippedItemRecreation', 'U') IS NULL
BEGIN
    CREATE TABLE [equipment].[EquippedItemRecreation] (
        [CharacterEquipmentId] BIGINT    NOT NULL,
        [RecreationBuildId]    INT       NOT NULL,
        [UpdatedAt]            DATETIME2 NOT NULL CONSTRAINT [DF_equipment_EquippedItemRecreation_UpdatedAt] DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT [PK_equipment_EquippedItemRecreation] PRIMARY KEY ([CharacterEquipmentId]),
        CONSTRAINT [FK_EquippedItemRecreation_CharacterEquipment] FOREIGN KEY ([CharacterEquipmentId])
            REFERENCES [equipment].[CharacterEquipment] ([CharacterEquipmentId]) ON DELETE CASCADE,
        CONSTRAINT [FK_EquippedItemRecreation_Build] FOREIGN KEY ([RecreationBuildId])
            REFERENCES [catalog].[RecreationBuild] ([RecreationBuildId])
    );
END
GO

-- UQ (pieza, stat): no se repite stat en la misma pieza
IF OBJECT_ID('equipment.EquippedItemRecreationStat', 'U') IS NULL
BEGIN
    CREATE TABLE [equipment].[EquippedItemRecreationStat] (
        [CharacterEquipmentId] BIGINT  NOT NULL,
        [ValueSlot]            TINYINT NOT NULL,
        [StatTypeId]           INT     NOT NULL,
        CONSTRAINT [PK_equipment_EquippedItemRecreationStat] PRIMARY KEY ([CharacterEquipmentId], [ValueSlot]),
        CONSTRAINT [UQ_EquippedItemRecreationStat_Stat] UNIQUE ([CharacterEquipmentId], [StatTypeId]),
        CONSTRAINT [CK_EquippedItemRecreationStat_ValueSlot] CHECK ([ValueSlot] BETWEEN 1 AND 3),
        CONSTRAINT [FK_EquippedItemRecreationStat_Recreation] FOREIGN KEY ([CharacterEquipmentId])
            REFERENCES [equipment].[EquippedItemRecreation] ([CharacterEquipmentId]) ON DELETE CASCADE,
        CONSTRAINT [FK_EquippedItemRecreationStat_StatType] FOREIGN KEY ([StatTypeId])
            REFERENCES [catalog].[StatType] ([StatTypeId])
    );
END
GO


-- ------------------------------------------------------------
-- 4) Datos (re-ejecutable: se recalcula completo)
-- ------------------------------------------------------------
-- a) Modalidades
MERGE catalog.RecreationBuild AS T
USING (VALUES
    ('OVER_MAX_1', N'Over max. 1', 4400,    0,    0, 1),
    ('OVER_MAX_2', N'Over max. 2', 6400, 2000, 2000, 2)
) AS S (BuildCode, BuildName, StatMaxHP, StatMaxMP, StatMaxSP, SortOrder)
ON T.BuildCode = S.BuildCode
WHEN MATCHED THEN
    UPDATE SET BuildName = S.BuildName, StatMaxHP = S.StatMaxHP, StatMaxMP = S.StatMaxMP,
               StatMaxSP = S.StatMaxSP, SortOrder = S.SortOrder, IsActive = 1
WHEN NOT MATCHED THEN
    INSERT (BuildCode, BuildName, StatMaxHP, StatMaxMP, StatMaxSP, SortOrder, IsActive)
    VALUES (S.BuildCode, S.BuildName, S.StatMaxHP, S.StatMaxMP, S.StatMaxSP, S.SortOrder, 1);

-- b) Valores de cada modalidad
MERGE catalog.RecreationBuildValue AS T
USING (
    SELECT B.RecreationBuildId, V.ValueSlot, V.StatValue
    FROM (VALUES
        ('OVER_MAX_1', 1, 98), ('OVER_MAX_1', 2, 69), ('OVER_MAX_1', 3, 44),
        ('OVER_MAX_2', 1, 88), ('OVER_MAX_2', 2, 44), ('OVER_MAX_2', 3, 44)
    ) AS V (BuildCode, ValueSlot, StatValue)
    JOIN catalog.RecreationBuild B ON B.BuildCode = V.BuildCode
) AS S
ON T.RecreationBuildId = S.RecreationBuildId AND T.ValueSlot = S.ValueSlot
WHEN MATCHED THEN UPDATE SET StatValue = S.StatValue
WHEN NOT MATCHED THEN INSERT (RecreationBuildId, ValueSlot, StatValue) VALUES (S.RecreationBuildId, S.ValueSlot, S.StatValue);

-- c) Piezas recreables
INSERT INTO catalog.RecreationApplicableItemType (ItemTypeId)
SELECT IT.ItemTypeId
FROM catalog.ItemType IT
WHERE IT.ItemTypeCode IN ('HELMET', 'TOP', 'PANTS', 'GLOVES', 'BOOTS')
  AND NOT EXISTS (SELECT 1 FROM catalog.RecreationApplicableItemType X WHERE X.ItemTypeId = IT.ItemTypeId);

DELETE X
FROM catalog.RecreationApplicableItemType X
JOIN catalog.ItemType IT ON IT.ItemTypeId = X.ItemTypeId
WHERE IT.ItemTypeCode NOT IN ('HELMET', 'TOP', 'PANTS', 'GLOVES', 'BOOTS');

-- d) Stats sugeridos por clase (orden = valor: 1 el mas alto)
--    Oraculo sigue a ClassStatPreference de V033 (REC 1, WIS 2)
DECLARE @Pref TABLE (ClassCode NVARCHAR(30) NOT NULL, Priority TINYINT NOT NULL, StatCode NVARCHAR(30) NOT NULL);

INSERT INTO @Pref (ClassCode, Priority, StatCode)
VALUES
('HUNTER_FURIA',   1, 'LUC'), ('HUNTER_FURIA',   2, 'DEX'), ('HUNTER_FURIA',   3, 'STR'),
('HUNTER_LUZ',     1, 'LUC'), ('HUNTER_LUZ',     2, 'DEX'), ('HUNTER_LUZ',     3, 'STR'),
('WARRIOR_FURIA',  1, 'STR'), ('WARRIOR_FURIA',  2, 'DEX'), ('WARRIOR_FURIA',  3, 'REC'),
('WARRIOR_LUZ',    1, 'STR'), ('WARRIOR_LUZ',    2, 'DEX'), ('WARRIOR_LUZ',    3, 'REC'),
('GUARDIAN_FURIA', 1, 'STR'), ('GUARDIAN_FURIA', 2, 'DEX'), ('GUARDIAN_FURIA', 3, 'REC'),
('DEFENDER_LUZ',   1, 'STR'), ('DEFENDER_LUZ',   2, 'DEX'), ('DEFENDER_LUZ',   3, 'REC'),
('ASSASSIN_FURIA', 1, 'DEX'), ('ASSASSIN_FURIA', 2, 'STR'), ('ASSASSIN_FURIA', 3, 'LUC'),
('ASSASSIN_LUZ',   1, 'DEX'), ('ASSASSIN_LUZ',   2, 'STR'), ('ASSASSIN_LUZ',   3, 'LUC'),
('PAGAN_FURIA',    1, 'INT'), ('PAGAN_FURIA',    2, 'WIS'), ('PAGAN_FURIA',    3, 'REC'),
('PAGAN_LUZ',      1, 'INT'), ('PAGAN_LUZ',      2, 'WIS'), ('PAGAN_LUZ',      3, 'REC'),
('ORACLE_FURIA',   1, 'REC'), ('ORACLE_FURIA',   2, 'WIS'), ('ORACLE_FURIA',   3, 'DEX'),
('ORACLE_LUZ',     1, 'REC'), ('ORACLE_LUZ',     2, 'WIS'), ('ORACLE_LUZ',     3, 'DEX');

DELETE P
FROM catalog.ClassRecreationPreference P
JOIN core.Class C ON C.ClassId = P.ClassId
WHERE C.ClassCode IN (SELECT ClassCode FROM @Pref);

INSERT INTO catalog.ClassRecreationPreference (ClassId, Priority, StatTypeId)
SELECT C.ClassId, P.Priority, ST.StatTypeId
FROM @Pref P
JOIN core.Class C        ON C.ClassCode  = P.ClassCode
JOIN catalog.StatType ST ON ST.StatCode  = P.StatCode;

-- e) Modalidad sugerida: Over max. 1 para todas las clases
DECLARE @Build1Id INT = (SELECT RecreationBuildId FROM catalog.RecreationBuild WHERE BuildCode = 'OVER_MAX_1');

MERGE catalog.ClassRecreationConfig AS T
USING (SELECT ClassId FROM core.Class) AS S
ON T.ClassId = S.ClassId
WHEN MATCHED THEN UPDATE SET SuggestedRecreationBuildId = @Build1Id
WHEN NOT MATCHED THEN INSERT (ClassId, SuggestedRecreationBuildId) VALUES (S.ClassId, @Build1Id);
GO


-- ------------------------------------------------------------
-- 5) equipment.sp_GetRecreationSuggestion
--    Sugerida de la clase para cada slot recreable (5 slots x 3 filas),
--    este o no equipado. Personaje inexistente -> result set vacio.
--    Result: SlotCode, SlotName, SortOrder, CharacterEquipmentId (NULL si
--            vacio), BuildCode, BuildName, StatMaxHP, StatMaxMP, StatMaxSP,
--            ValueSlot, StatCode, StatValue
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE equipment.sp_GetRecreationSuggestion
    @CharacterId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ES.SlotCode,
        ES.SlotName,
        ES.SortOrder,
        CE.CharacterEquipmentId,
        B.BuildCode,
        B.BuildName,
        B.StatMaxHP,
        B.StatMaxMP,
        B.StatMaxSP,
        BV.ValueSlot,
        ST.StatCode,
        BV.StatValue
    FROM core.Character C
    JOIN catalog.ClassRecreationConfig CRC     ON CRC.ClassId           = C.ClassId
    JOIN catalog.RecreationBuild B             ON B.RecreationBuildId   = CRC.SuggestedRecreationBuildId
    JOIN catalog.RecreationBuildValue BV       ON BV.RecreationBuildId  = B.RecreationBuildId
    JOIN catalog.ClassRecreationPreference CRP ON CRP.ClassId           = C.ClassId
                                              AND CRP.Priority          = BV.ValueSlot
    JOIN catalog.StatType ST                   ON ST.StatTypeId         = CRP.StatTypeId
    CROSS JOIN catalog.EquipmentSlot ES
    JOIN catalog.ItemType IT                   ON IT.ItemTypeCode       = ES.SlotCode
    JOIN catalog.RecreationApplicableItemType RA ON RA.ItemTypeId       = IT.ItemTypeId
    LEFT JOIN equipment.CharacterEquipment CE  ON CE.CharacterId        = C.CharacterId
                                              AND CE.EquipmentSlotId    = ES.EquipmentSlotId
    WHERE C.CharacterId = @CharacterId
      AND C.IsActive    = 1
      AND ES.IsActive   = 1
    ORDER BY ES.SortOrder, BV.ValueSlot;
END
GO


-- ------------------------------------------------------------
-- 6) equipment.sp_SaveRecreationConfig
--    @ConfigXml:
--      <config><piece>
--        <CharacterEquipmentId>1</CharacterEquipmentId>
--        <BuildCode>OVER_MAX_1</BuildCode>   (vacio = quitar la recreacion)
--        <Stat1>LUC</Stat1><Stat2>DEX</Stat2><Stat3>STR</Stat3>
--      </piece>...</config>
--    StatN va al ValueSlot N de la modalidad (Over max. 1: 98 / 69 / 44).
--    Solo toca las piezas enviadas. Con error no se escribe nada.
--    Result (1 fila): Success, ErrorCode, SavedCount, RemovedCount
--    ErrorCode: CHARACTER_NOT_FOUND | EMPTY_CONFIG | DUPLICATE_PIECE |
--               EQUIPMENT_NOT_OWNED | ITEM_NOT_RECREATABLE | INVALID_BUILD |
--               INVALID_STAT (vacio, no existe o no es STR/DEX/REC/INT/WIS/LUC) |
--               DUPLICATE_STAT
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE equipment.sp_SaveRecreationConfig
    @CharacterId BIGINT,
    @ConfigXml   NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ErrorCode    NVARCHAR(50) = NULL;
    DECLARE @SavedCount   INT = 0;
    DECLARE @RemovedCount INT = 0;
    DECLARE @OwnTran      BIT = 0;
    DECLARE @xml          XML = CAST(ISNULL(@ConfigXml, N'<config/>') AS XML);

    DECLARE @Pieces TABLE (
        CharacterEquipmentId BIGINT       NOT NULL,
        BuildCode            NVARCHAR(30) NULL,
        RecreationBuildId    INT          NULL
    );
    DECLARE @Stats TABLE (
        CharacterEquipmentId BIGINT       NOT NULL,
        ValueSlot            TINYINT      NOT NULL,
        StatCode             NVARCHAR(30) NULL,
        StatTypeId           INT          NULL
    );

    IF NOT EXISTS (SELECT 1 FROM core.Character WHERE CharacterId = @CharacterId AND IsActive = 1)
        SET @ErrorCode = 'CHARACTER_NOT_FOUND';

    IF @ErrorCode IS NULL
    BEGIN
        INSERT INTO @Pieces (CharacterEquipmentId, BuildCode)
        SELECT
            p.value('(CharacterEquipmentId)[1]', 'bigint'),
            NULLIF(UPPER(LTRIM(RTRIM(p.value('(BuildCode)[1]', 'nvarchar(30)')))), N'')
        FROM @xml.nodes('/config/piece') AS t(p);

        IF NOT EXISTS (SELECT 1 FROM @Pieces)
            SET @ErrorCode = 'EMPTY_CONFIG';
    END

    IF @ErrorCode IS NULL
       AND EXISTS (SELECT CharacterEquipmentId FROM @Pieces GROUP BY CharacterEquipmentId HAVING COUNT(*) > 1)
        SET @ErrorCode = 'DUPLICATE_PIECE';

    IF @ErrorCode IS NULL AND EXISTS (
        SELECT 1
        FROM @Pieces X
        LEFT JOIN equipment.CharacterEquipment CE
            ON CE.CharacterEquipmentId = X.CharacterEquipmentId
           AND CE.CharacterId          = @CharacterId
        WHERE CE.CharacterEquipmentId IS NULL
    )
        SET @ErrorCode = 'EQUIPMENT_NOT_OWNED';

    IF @ErrorCode IS NULL AND EXISTS (
        SELECT 1
        FROM @Pieces X
        JOIN equipment.CharacterEquipment CE ON CE.CharacterEquipmentId = X.CharacterEquipmentId
        WHERE X.BuildCode IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM catalog.RecreationApplicableItemType RA WHERE RA.ItemTypeId = CE.ItemTypeId)
    )
        SET @ErrorCode = 'ITEM_NOT_RECREATABLE';

    IF @ErrorCode IS NULL
    BEGIN
        UPDATE X
        SET RecreationBuildId = B.RecreationBuildId
        FROM @Pieces X
        JOIN catalog.RecreationBuild B ON B.BuildCode = X.BuildCode AND B.IsActive = 1;

        IF EXISTS (SELECT 1 FROM @Pieces WHERE BuildCode IS NOT NULL AND RecreationBuildId IS NULL)
            SET @ErrorCode = 'INVALID_BUILD';
    END

    IF @ErrorCode IS NULL
    BEGIN
        INSERT INTO @Stats (CharacterEquipmentId, ValueSlot, StatCode)
        SELECT
            p.value('(CharacterEquipmentId)[1]', 'bigint'),
            N.ValueSlot,
            NULLIF(UPPER(LTRIM(RTRIM(
                CASE N.ValueSlot
                    WHEN 1 THEN p.value('(Stat1)[1]', 'nvarchar(30)')
                    WHEN 2 THEN p.value('(Stat2)[1]', 'nvarchar(30)')
                    WHEN 3 THEN p.value('(Stat3)[1]', 'nvarchar(30)')
                END))), N'')
        FROM @xml.nodes('/config/piece') AS t(p)
        CROSS JOIN (VALUES (1), (2), (3)) AS N(ValueSlot)
        WHERE NULLIF(LTRIM(RTRIM(p.value('(BuildCode)[1]', 'nvarchar(30)'))), N'') IS NOT NULL;

        -- Solo stats primarios: HP / MP / SP y derivados no se aceptan
        UPDATE S
        SET StatTypeId = ST.StatTypeId
        FROM @Stats S
        JOIN catalog.StatType ST
            ON ST.StatCode  = S.StatCode
           AND ST.IsPrimary = 1
           AND ST.IsActive  = 1;

        IF EXISTS (SELECT 1 FROM @Stats WHERE StatTypeId IS NULL)
            SET @ErrorCode = 'INVALID_STAT';
        ELSE IF EXISTS (
            SELECT CharacterEquipmentId FROM @Stats
            GROUP BY CharacterEquipmentId, StatTypeId HAVING COUNT(*) > 1
        )
            SET @ErrorCode = 'DUPLICATE_STAT';
    END

    IF @ErrorCode IS NOT NULL
    BEGIN
        SELECT
            CAST(0 AS BIT)                   AS Success,
            CAST(@ErrorCode AS NVARCHAR(50)) AS ErrorCode,
            0                                AS SavedCount,
            0                                AS RemovedCount;
        RETURN;
    END

    IF @@TRANCOUNT = 0
    BEGIN
        BEGIN TRANSACTION;
        SET @OwnTran = 1;
    END

    BEGIN TRY
        -- Se reemplaza completa la recreacion de cada pieza enviada
        DELETE R
        FROM equipment.EquippedItemRecreation R
        JOIN @Pieces X ON X.CharacterEquipmentId = R.CharacterEquipmentId;

        SELECT @RemovedCount = COUNT(*)
        FROM @Pieces
        WHERE RecreationBuildId IS NULL;

        INSERT INTO equipment.EquippedItemRecreation (CharacterEquipmentId, RecreationBuildId, UpdatedAt)
        SELECT CharacterEquipmentId, RecreationBuildId, SYSUTCDATETIME()
        FROM @Pieces
        WHERE RecreationBuildId IS NOT NULL;

        SET @SavedCount = @@ROWCOUNT;

        INSERT INTO equipment.EquippedItemRecreationStat (CharacterEquipmentId, ValueSlot, StatTypeId)
        SELECT CharacterEquipmentId, ValueSlot, StatTypeId
        FROM @Stats;

        IF @OwnTran = 1
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @OwnTran = 1 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH

    SELECT
        CAST(1 AS BIT)             AS Success,
        CAST(NULL AS NVARCHAR(50)) AS ErrorCode,
        @SavedCount                AS SavedCount,
        @RemovedCount              AS RemovedCount;
END
GO


-- ------------------------------------------------------------
-- 7) equipment.sp_GetCharacterScreenByUser — V033 + recreacion
--    Result 1..5 sin cambios.
--    Result 6: modalidades (BuildCode, BuildName, StatMaxHP, StatMaxMP,
--              StatMaxSP, SortOrder, ValueSlot, StatValue)
--    Result 7: tipos de item recreables (ItemTypeId, ItemTypeCode)
--    Result 8: recreacion de cada pieza del personaje (CharacterEquipmentId,
--              SlotCode, BuildCode, StatMaxHP, StatMaxMP, StatMaxSP,
--              ValueSlot, StatCode, StatValue)
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
        L.StatMaxHP AS LapisStatMaxHP,
        L.IconUrl   AS LapisIconUrl
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
        L.StatMaxHP,
        L.IconUrl
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

    -- Result 6 (V034): modalidades de recreacion y sus valores
    SELECT
        B.BuildCode,
        B.BuildName,
        B.StatMaxHP,
        B.StatMaxMP,
        B.StatMaxSP,
        B.SortOrder,
        BV.ValueSlot,
        BV.StatValue
    FROM catalog.RecreationBuild B
    JOIN catalog.RecreationBuildValue BV ON BV.RecreationBuildId = B.RecreationBuildId
    WHERE B.IsActive = 1
    ORDER BY B.SortOrder, BV.ValueSlot;

    -- Result 7 (V034): tipos de item recreables
    SELECT IT.ItemTypeId, IT.ItemTypeCode
    FROM catalog.RecreationApplicableItemType RA
    JOIN catalog.ItemType IT ON IT.ItemTypeId = RA.ItemTypeId
    ORDER BY IT.ItemTypeId;

    -- Result 8 (V034): recreacion de cada pieza del personaje
    SELECT
        CE.CharacterEquipmentId,
        ES.SlotCode,
        B.BuildCode,
        B.StatMaxHP,
        B.StatMaxMP,
        B.StatMaxSP,
        RS.ValueSlot,
        ST.StatCode,
        BV.StatValue
    FROM equipment.CharacterEquipment CE
    JOIN catalog.EquipmentSlot ES                ON ES.EquipmentSlotId      = CE.EquipmentSlotId
    JOIN equipment.EquippedItemRecreation R      ON R.CharacterEquipmentId  = CE.CharacterEquipmentId
    JOIN catalog.RecreationBuild B               ON B.RecreationBuildId     = R.RecreationBuildId
    JOIN equipment.EquippedItemRecreationStat RS ON RS.CharacterEquipmentId = CE.CharacterEquipmentId
    JOIN catalog.RecreationBuildValue BV         ON BV.RecreationBuildId    = R.RecreationBuildId
                                                AND BV.ValueSlot            = RS.ValueSlot
    JOIN catalog.StatType ST                     ON ST.StatTypeId           = RS.StatTypeId
    WHERE CE.CharacterId = @CharacterId
    ORDER BY ES.SortOrder, RS.ValueSlot;
END;
GO


-- ------------------------------------------------------------
-- 8) Sin recreacion fija en el catalogo: nadie tiene recreacion
--    hasta que el jugador la guarde (equipment.EquippedItemRecreation)
-- ------------------------------------------------------------
UPDATE catalog.Item
SET RecStatHP  = NULL,
    RecStatSTR = NULL,
    RecStatDEX = NULL,
    RecStatREC = NULL,
    RecStatLUC = NULL,
    RecStatINT = NULL,
    RecStatWIS = NULL
WHERE COALESCE(RecStatHP, RecStatSTR, RecStatDEX, RecStatREC, RecStatLUC, RecStatINT, RecStatWIS) IS NOT NULL;
GO
