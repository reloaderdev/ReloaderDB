-- ============================================================
-- V027__catalog_sets_and_class_master.sql
-- Sets de las 11 clases que faltan + tablas maestras por clase
-- (fuente: dbreadme/SETS_RECIBIDOS.txt)
--
--   1) Items de las 11 clases sin set (el Cazador ya tiene Luminous Tyrant's):
--      HELMET <X> Helm | TOP <X> Mail | PANTS <X> Gaiters |
--      GLOVES <X> Bracers | BOOTS <X> Boots  -> stats base del casco de la
--      clase en las 5 piezas (provisorio), MaxSockets 6, RequiredLevel 80.
--      Arma y escudo PROVISORIOS "<X> Weapon" / "<X> Shield": copian stats,
--      sockets e imagen del arma (Emberstone Annihilation Javelin) y del
--      escudo (Ethereal Quiver) del set del Cazador.
--   2) catalog.ItemStat (BASE) de las piezas nuevas
--   3) catalog.ItemAllowedClass: cada pieza a su clase; al Cazador el set
--      existente que no tenia clase (Mail, Quiver); accesorios Bonespike,
--      mascota, capa, alas y traje a las 12 clases
--   4) catalog.ClassBaseStat      — stats con los que nace cada clase.
--      SE CONSULTA por ClassId, NO se copia al personaje.
--      VALORES PROVISORIOS (principal 150, secundarios 90, resto 30)
--   5) catalog.ClassStatPreference — stats preferidos (Priority 1..3)
--   6) catalog.ClassAutoLinkConfig — AbsorptionSockets por clase
--      (0 clases de dano, 2 Pagano/Mago/Oraculo/Cura)
--   Las tablas 5 y 6 solo las usa el auto-linkeo: NUNCA bloquean un linkeo.
-- ============================================================


-- ------------------------------------------------------------
-- 1) Items por clase
-- ------------------------------------------------------------
DECLARE @Sets TABLE (
    ClassCode NVARCHAR(30)  NOT NULL PRIMARY KEY,
    SetKey    NVARCHAR(40)  NOT NULL,   -- parte del ItemCode
    SetName   NVARCHAR(100) NOT NULL,   -- prefijo del ItemName
    DEF INT NULL, RES INT NULL, HP INT NULL, SP INT NULL, MP INT NULL,
    STR INT NULL, DEX INT NULL, REC INT NULL, LUC INT NULL, [INT] INT NULL, WIS INT NULL
);

INSERT INTO @Sets (ClassCode, SetKey, SetName, DEF, RES, HP, SP, MP, STR, DEX, REC, LUC, [INT], WIS)
VALUES
-- Luchador / Guerrero / Defensor / Guardian
('WARRIOR_LUZ',    'EMPERORS',  N'Luminous Emperor''s', 254, 125, 2933,  733, NULL, 52, 52, 59, NULL, NULL, NULL),
('WARRIOR_FURIA',  'VENDETTA',  N'Luminous Vendetta',   254, 125, 2933,  733, NULL, 52, 52, 59, NULL, NULL, NULL),
('DEFENDER_LUZ',   'IMPERIAL',  N'Luminous Imperial',   254, 125, 2933,  733, NULL, 52, 52, 59, NULL, NULL, NULL),
('GUARDIAN_FURIA', 'GRUDGE',    N'Luminous Grudge',     254, 125, 2933,  733, NULL, 52, 52, 59, NULL, NULL, NULL),
-- Ranger / Asesino
('ASSASSIN_LUZ',   'AUTHORITY', N'Luminous Authority',  181, 157, 1951, 2933, NULL, 52, 59, NULL, 52, NULL, NULL),
('ASSASSIN_FURIA', 'SLAYERS',   N'Luminous Slayer''s',  181, 157, 1951, 2933, NULL, 52, 59, NULL, 52, NULL, NULL),
-- Arquero (el Cazador ya tiene Luminous Tyrant's)
('HUNTER_LUZ',     'SUPREMACY', N'Luminous Supremacy',  181, 157, 1951, 2933, NULL, 52, 52, NULL, 59, NULL, NULL),
-- Mago / Pagano
('PAGAN_LUZ',      'SAGES',     N'Luminous Sage''s',    181, 157, 1466, NULL, 2933, NULL, NULL, NULL, 52, 59, 52),
('PAGAN_FURIA',    'CORRUPT',   N'Luminous Corrupt',    181, 157, 1466, NULL, 2933, NULL, NULL, NULL, 52, 59, 52),
-- Cura / Oraculo
('ORACLE_LUZ',     'CLERICS',   N'Luminous Cleric''s',  121, 211, 1466, NULL, 2933, NULL, NULL, NULL, 52, 52, 59),
('ORACLE_FURIA',   'PROFANE',   N'Luminous Profane',    121, 211, 1466, NULL, 2933, NULL, NULL, NULL, 52, 52, 59);

IF EXISTS (SELECT 1 FROM @Sets S LEFT JOIN core.Class C ON C.ClassCode = S.ClassCode WHERE C.ClassId IS NULL)
    THROW 50270, 'V027: falta alguna clase en core.Class.', 1;

-- Nivel requerido = el del set existente del Cazador
DECLARE @SetLevel INT = (SELECT RequiredLevel FROM catalog.Item WHERE ItemCode = 'ITEM_LUMINOUS_TYRANTS_HELM');
DECLARE @BindTypeId INT = (SELECT BindTypeId FROM catalog.Item WHERE ItemCode = 'ITEM_LUMINOUS_TYRANTS_HELM');

IF @SetLevel IS NULL
    THROW 50271, 'V027: no se encontro el set Luminous Tyrant''s (referencia).', 1;

-- 1.1) Armadura: 5 piezas con las stats del casco de la clase
DECLARE @ArmorPieces TABLE (
    ItemTypeCode   NVARCHAR(30)  NOT NULL PRIMARY KEY,
    CodeSuffix     NVARCHAR(20)  NOT NULL,
    NameSuffix     NVARCHAR(20)  NOT NULL,
    PieceDesc      NVARCHAR(100) NOT NULL,
    RefItemCode    NVARCHAR(100) NOT NULL   -- pieza del Cazador para la imagen
);

INSERT INTO @ArmorPieces (ItemTypeCode, CodeSuffix, NameSuffix, PieceDesc, RefItemCode)
VALUES
('HELMET', 'HELM',    N'Helm',    N'Casco',              'ITEM_LUMINOUS_TYRANTS_HELM'),
('TOP',    'MAIL',    N'Mail',    N'Armadura superior',  'ITEM_LUMINOUS_TYRANTS_MAIL'),
('PANTS',  'GAITERS', N'Gaiters', N'Armadura inferior',  'ITEM_LUMINOUS_TYRANTS_GAITERS'),
('GLOVES', 'BRACERS', N'Bracers', N'Guantelete',         'ITEM_LUMINOUS_TYRANTS_BRACERS'),
('BOOTS',  'BOOTS',   N'Boots',   N'Botas',              'ITEM_LUMINOUS_TYRANTS_BOOTS');

INSERT INTO catalog.Item (
    ItemTypeId, BindTypeId, ItemCode, ItemName, RequiredLevel, Description, FlavorText,
    MaxSockets, CanDye, IsActive, ImageUrl,
    StatDefensePower, StatResistence, StatBaseMaxHP, StatBaseMaxSP, StatBaseMaxMP,
    StatBaseSTR, StatBaseDEX, StatBaseREC, StatBaseLUC, StatBaseINT, StatBaseWIS
)
SELECT
    IT.ItemTypeId,
    @BindTypeId,
    'ITEM_LUMINOUS_' + S.SetKey + '_' + P.CodeSuffix,
    S.SetName + N' ' + P.NameSuffix,
    @SetLevel,
    P.PieceDesc + N' de la serie ' + S.SetName + N'. Stats provisorias (las del casco).',
    NULL,
    6, 0, 1,
    REF.ImageUrl,
    S.DEF, S.RES, S.HP, S.SP, S.MP,
    S.STR, S.DEX, S.REC, S.LUC, S.[INT], S.WIS
FROM @Sets S
CROSS JOIN @ArmorPieces P
JOIN catalog.ItemType IT ON IT.ItemTypeCode = P.ItemTypeCode
LEFT JOIN catalog.Item REF ON REF.ItemCode = P.RefItemCode
WHERE NOT EXISTS (
    SELECT 1 FROM catalog.Item I
    WHERE I.ItemCode = 'ITEM_LUMINOUS_' + S.SetKey + '_' + P.CodeSuffix
);

-- 1.2) Arma y escudo provisorios: copia del arma / escudo del Cazador
DECLARE @CopyPieces TABLE (
    CodeSuffix  NVARCHAR(20)  NOT NULL PRIMARY KEY,
    NameSuffix  NVARCHAR(20)  NOT NULL,
    PieceDesc   NVARCHAR(100) NOT NULL,
    RefItemCode NVARCHAR(100) NOT NULL
);

INSERT INTO @CopyPieces (CodeSuffix, NameSuffix, PieceDesc, RefItemCode)
VALUES
('WEAPON', N'Weapon', N'Arma provisoria',    'ITEM_EMBERSTONE_JAVELIN'),
('SHIELD', N'Shield', N'Escudo provisorio',  'ITEM_ETHEREAL_QUIVER');

IF (SELECT COUNT(*) FROM catalog.Item WHERE ItemCode IN ('ITEM_EMBERSTONE_JAVELIN', 'ITEM_ETHEREAL_QUIVER')) <> 2
    THROW 50272, 'V027: no se encontro el arma / escudo de referencia del Cazador.', 1;

INSERT INTO catalog.Item (
    ItemTypeId, BindTypeId, ItemCode, ItemName, RequiredLevel, Description, FlavorText,
    MaxSockets, CanDye, IsActive, ImageUrl,
    StatDefensePower, StatResistence, StatBaseMaxHP, StatBaseMaxSP, StatBaseMaxMP,
    StatBaseSTR, StatBaseDEX, StatBaseREC, StatBaseLUC, StatBaseINT, StatBaseWIS,
    StatAttackPowerMin, StatAttackPowerMax, StatCriticalDamageBonus, StatElement,
    RecStatHP, RecStatSTR, RecStatDEX, RecStatREC, RecStatLUC, RecStatINT, RecStatWIS
)
SELECT
    REF.ItemTypeId,
    REF.BindTypeId,
    'ITEM_LUMINOUS_' + S.SetKey + '_' + P.CodeSuffix,
    S.SetName + N' ' + P.NameSuffix,
    REF.RequiredLevel,
    P.PieceDesc + N' de la serie ' + S.SetName + N' (copia de ' + REF.ItemName + N').',
    NULL,
    REF.MaxSockets, REF.CanDye, 1, REF.ImageUrl,
    REF.StatDefensePower, REF.StatResistence, REF.StatBaseMaxHP, REF.StatBaseMaxSP, REF.StatBaseMaxMP,
    REF.StatBaseSTR, REF.StatBaseDEX, REF.StatBaseREC, REF.StatBaseLUC, REF.StatBaseINT, REF.StatBaseWIS,
    REF.StatAttackPowerMin, REF.StatAttackPowerMax, REF.StatCriticalDamageBonus, REF.StatElement,
    REF.RecStatHP, REF.RecStatSTR, REF.RecStatDEX, REF.RecStatREC, REF.RecStatLUC, REF.RecStatINT, REF.RecStatWIS
FROM @Sets S
CROSS JOIN @CopyPieces P
JOIN catalog.Item REF ON REF.ItemCode = P.RefItemCode
WHERE NOT EXISTS (
    SELECT 1 FROM catalog.Item I
    WHERE I.ItemCode = 'ITEM_LUMINOUS_' + S.SetKey + '_' + P.CodeSuffix
);


-- ------------------------------------------------------------
-- 2) catalog.ItemStat de las piezas nuevas
-- ------------------------------------------------------------
-- 2.1) Armadura: BASE desde las stats del casco de la clase
INSERT INTO catalog.ItemStat (ItemId, StatTypeId, StatValue, ValueSource)
SELECT I.ItemId, ST.StatTypeId, V.StatValue, 'BASE'
FROM @Sets S
CROSS JOIN @ArmorPieces P
JOIN catalog.Item I ON I.ItemCode = 'ITEM_LUMINOUS_' + S.SetKey + '_' + P.CodeSuffix
CROSS APPLY (VALUES
    ('DEF', S.DEF), ('RES', S.RES), ('HP', S.HP), ('SP', S.SP), ('MP', S.MP),
    ('STR', S.STR), ('DEX', S.DEX), ('REC', S.REC), ('LUC', S.LUC), ('INT', S.[INT]), ('WIS', S.WIS)
) AS V(StatCode, StatValue)
JOIN catalog.StatType ST ON ST.StatCode = V.StatCode
WHERE V.StatValue IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM catalog.ItemStat X
      WHERE X.ItemId = I.ItemId AND X.StatTypeId = ST.StatTypeId AND X.ValueSource = 'BASE'
  );

-- 2.2) Arma y escudo: copia de las filas del item de referencia
INSERT INTO catalog.ItemStat (ItemId, StatTypeId, StatValue, ValueSource)
SELECT I.ItemId, RS.StatTypeId, RS.StatValue, RS.ValueSource
FROM @Sets S
CROSS JOIN @CopyPieces P
JOIN catalog.Item I   ON I.ItemCode   = 'ITEM_LUMINOUS_' + S.SetKey + '_' + P.CodeSuffix
JOIN catalog.Item REF ON REF.ItemCode = P.RefItemCode
JOIN catalog.ItemStat RS ON RS.ItemId = REF.ItemId
WHERE NOT EXISTS (
    SELECT 1 FROM catalog.ItemStat X
    WHERE X.ItemId = I.ItemId AND X.StatTypeId = RS.StatTypeId AND X.ValueSource = RS.ValueSource
);


-- ------------------------------------------------------------
-- 3) catalog.ItemAllowedClass
-- ------------------------------------------------------------
-- 3.1) Cada pieza nueva a su clase
INSERT INTO catalog.ItemAllowedClass (ItemId, ClassId)
SELECT I.ItemId, C.ClassId
FROM @Sets S
JOIN core.Class C ON C.ClassCode = S.ClassCode
JOIN catalog.Item I ON I.ItemCode LIKE 'ITEM[_]LUMINOUS[_]' + S.SetKey + '[_]%'
WHERE NOT EXISTS (
    SELECT 1 FROM catalog.ItemAllowedClass X
    WHERE X.ItemId = I.ItemId AND X.ClassId = C.ClassId
);

-- 3.2) Cazador: set existente que hoy no tiene clase
INSERT INTO catalog.ItemAllowedClass (ItemId, ClassId)
SELECT I.ItemId, C.ClassId
FROM catalog.Item I
CROSS JOIN core.Class C
WHERE C.ClassCode = 'HUNTER_FURIA'
  AND I.ItemCode IN (
      'ITEM_LUMINOUS_TYRANTS_HELM', 'ITEM_LUMINOUS_TYRANTS_MAIL', 'ITEM_LUMINOUS_TYRANTS_GAITERS',
      'ITEM_LUMINOUS_TYRANTS_BRACERS', 'ITEM_LUMINOUS_TYRANTS_BOOTS',
      'ITEM_EMBERSTONE_JAVELIN', 'ITEM_ETHEREAL_QUIVER'
  )
  AND NOT EXISTS (
      SELECT 1 FROM catalog.ItemAllowedClass X
      WHERE X.ItemId = I.ItemId AND X.ClassId = C.ClassId
  );

-- 3.3) Accesorios Bonespike + mascota, capa, alas y traje: las 12 clases
INSERT INTO catalog.ItemAllowedClass (ItemId, ClassId)
SELECT I.ItemId, C.ClassId
FROM catalog.Item I
CROSS JOIN core.Class C
WHERE C.IsActive = 1
  AND I.ItemCode IN (
      'ITEM_ETERNAL_BONESPIKE_AMULET', 'ITEM_ETERNAL_BONESPIKE_RING', 'ITEM_ETERNAL_BONESPIKE_BAND',
      'ITEM_ETERNAL_BONESPIKE_LOOP', 'ITEM_ETERNAL_BONESPIKE_BRACELET',
      'ITEM_PUDLE_CHUM', 'ITEM_MION_MANTLE', 'ITEM_WINGS_ICY_SPLENDOR', 'ITEM_CRITICAL_ROYAL_AVENGER'
  )
  AND NOT EXISTS (
      SELECT 1 FROM catalog.ItemAllowedClass X
      WHERE X.ItemId = I.ItemId AND X.ClassId = C.ClassId
  );
GO


-- ------------------------------------------------------------
-- 4) catalog.ClassBaseStat
--    Stats con los que nace cada clase (nivel 80, sin equipo).
--    SE CONSULTA por ClassId (no se copia al personaje): un UPDATE aqui
--    rebalancea a todos los personajes de la clase.
--    Stat total = ClassBaseStat + build.CharacterAssignedStat
--               + items equipados + lapis linkeados (absorcion aparte)
-- ------------------------------------------------------------
IF OBJECT_ID('catalog.ClassBaseStat', 'U') IS NULL
BEGIN
    CREATE TABLE [catalog].[ClassBaseStat] (
        [ClassBaseStatId] INT IDENTITY(1,1) NOT NULL,
        [ClassId]         INT NOT NULL,
        [StatTypeId]      INT NOT NULL,
        [StatValue]       INT NOT NULL,
        [UpdatedAt]       DATETIME2 NOT NULL CONSTRAINT [DF_catalog_ClassBaseStat_UpdatedAt] DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT [PK_catalog_ClassBaseStat] PRIMARY KEY ([ClassBaseStatId]),
        CONSTRAINT [UQ_ClassBaseStat_Class_StatType] UNIQUE ([ClassId], [StatTypeId]),
        CONSTRAINT [FK_ClassBaseStat_Class]    FOREIGN KEY ([ClassId])    REFERENCES [core].[Class] ([ClassId]),
        CONSTRAINT [FK_ClassBaseStat_StatType] FOREIGN KEY ([StatTypeId]) REFERENCES [catalog].[StatType] ([StatTypeId])
    );
END
GO


-- ------------------------------------------------------------
-- 5) catalog.ClassStatPreference — stats preferidos (1 = principal)
--    Solo para el auto-linkeo (peso: prioridad 1 x3, 2 x2, 3 x1).
-- ------------------------------------------------------------
IF OBJECT_ID('catalog.ClassStatPreference', 'U') IS NULL
BEGIN
    CREATE TABLE [catalog].[ClassStatPreference] (
        [ClassStatPreferenceId] INT IDENTITY(1,1) NOT NULL,
        [ClassId]               INT NOT NULL,
        [StatTypeId]            INT NOT NULL,
        [Priority]              TINYINT NOT NULL,
        CONSTRAINT [PK_catalog_ClassStatPreference] PRIMARY KEY ([ClassStatPreferenceId]),
        CONSTRAINT [UQ_ClassStatPreference_Class_StatType] UNIQUE ([ClassId], [StatTypeId]),
        CONSTRAINT [UQ_ClassStatPreference_Class_Priority] UNIQUE ([ClassId], [Priority]),
        CONSTRAINT [CK_ClassStatPreference_Priority] CHECK ([Priority] BETWEEN 1 AND 3),
        CONSTRAINT [FK_ClassStatPreference_Class]    FOREIGN KEY ([ClassId])    REFERENCES [core].[Class] ([ClassId]),
        CONSTRAINT [FK_ClassStatPreference_StatType] FOREIGN KEY ([StatTypeId]) REFERENCES [catalog].[StatType] ([StatTypeId])
    );
END
GO


-- ------------------------------------------------------------
-- 6) catalog.ClassAutoLinkConfig — sockets de absorcion por pieza
-- ------------------------------------------------------------
IF OBJECT_ID('catalog.ClassAutoLinkConfig', 'U') IS NULL
BEGIN
    CREATE TABLE [catalog].[ClassAutoLinkConfig] (
        [ClassId]           INT NOT NULL,
        [AbsorptionSockets] INT NOT NULL CONSTRAINT [DF_catalog_ClassAutoLinkConfig_AbsorptionSockets] DEFAULT ((0)),
        CONSTRAINT [PK_catalog_ClassAutoLinkConfig] PRIMARY KEY ([ClassId]),
        CONSTRAINT [CK_ClassAutoLinkConfig_AbsorptionSockets] CHECK ([AbsorptionSockets] BETWEEN 0 AND 6),
        CONSTRAINT [FK_ClassAutoLinkConfig_Class] FOREIGN KEY ([ClassId]) REFERENCES [core].[Class] ([ClassId])
    );
END
GO


-- ------------------------------------------------------------
-- 7) Datos de las tablas maestras (por ClassCode, sin hardcodear ClassId)
-- ------------------------------------------------------------
DECLARE @Pref TABLE (ClassCode NVARCHAR(30) NOT NULL, StatCode NVARCHAR(30) NOT NULL, Priority TINYINT NOT NULL);

INSERT INTO @Pref (ClassCode, StatCode, Priority)
VALUES
-- Cazador / Arquero: LUC, DEX, STR (sin absorcion)
('HUNTER_FURIA',   'LUC', 1), ('HUNTER_FURIA',   'DEX', 2), ('HUNTER_FURIA',   'STR', 3),
('HUNTER_LUZ',     'LUC', 1), ('HUNTER_LUZ',     'DEX', 2), ('HUNTER_LUZ',     'STR', 3),
-- Guerrero / Luchador: STR, DEX, REC (sin absorcion)
('WARRIOR_FURIA',  'STR', 1), ('WARRIOR_FURIA',  'DEX', 2), ('WARRIOR_FURIA',  'REC', 3),
('WARRIOR_LUZ',    'STR', 1), ('WARRIOR_LUZ',    'DEX', 2), ('WARRIOR_LUZ',    'REC', 3),
-- Guardian / Defensor: STR, DEX (no busca REC, sin absorcion)
('GUARDIAN_FURIA', 'STR', 1), ('GUARDIAN_FURIA', 'DEX', 2),
('DEFENDER_LUZ',   'STR', 1), ('DEFENDER_LUZ',   'DEX', 2),
-- Asesino / Ranger: DEX, STR (sin absorcion)
('ASSASSIN_FURIA', 'DEX', 1), ('ASSASSIN_FURIA', 'STR', 2),
('ASSASSIN_LUZ',   'DEX', 1), ('ASSASSIN_LUZ',   'STR', 2),
-- Pagano / Mago: INT, WIS, REC (con absorcion)
('PAGAN_FURIA',    'INT', 1), ('PAGAN_FURIA',    'WIS', 2), ('PAGAN_FURIA',    'REC', 3),
('PAGAN_LUZ',      'INT', 1), ('PAGAN_LUZ',      'WIS', 2), ('PAGAN_LUZ',      'REC', 3),
-- Oraculo / Cura: WIS, REC (con absorcion)
('ORACLE_FURIA',   'WIS', 1), ('ORACLE_FURIA',   'REC', 2),
('ORACLE_LUZ',     'WIS', 1), ('ORACLE_LUZ',     'REC', 2);

INSERT INTO catalog.ClassStatPreference (ClassId, StatTypeId, Priority)
SELECT C.ClassId, ST.StatTypeId, P.Priority
FROM @Pref P
JOIN core.Class C       ON C.ClassCode = P.ClassCode
JOIN catalog.StatType ST ON ST.StatCode = P.StatCode
WHERE NOT EXISTS (
    SELECT 1 FROM catalog.ClassStatPreference X
    WHERE X.ClassId = C.ClassId AND X.StatTypeId = ST.StatTypeId
);

-- AbsorptionSockets: 2 para los casters, 0 para las clases de dano
INSERT INTO catalog.ClassAutoLinkConfig (ClassId, AbsorptionSockets)
SELECT C.ClassId,
       CASE WHEN C.ClassCode IN ('PAGAN_FURIA', 'PAGAN_LUZ', 'ORACLE_FURIA', 'ORACLE_LUZ') THEN 2 ELSE 0 END
FROM core.Class C
WHERE NOT EXISTS (SELECT 1 FROM catalog.ClassAutoLinkConfig X WHERE X.ClassId = C.ClassId);

-- ClassBaseStat PROVISORIO: stat principal (prioridad 1) = 150,
-- secundarios (prioridad 2 y 3) = 90, resto = 30.
-- Pendiente: reemplazar por los stats reales por clase (nivel 80 sin equipo).
INSERT INTO catalog.ClassBaseStat (ClassId, StatTypeId, StatValue)
SELECT
    C.ClassId,
    ST.StatTypeId,
    CASE
        WHEN P.Priority = 1        THEN 150
        WHEN P.Priority IN (2, 3)  THEN 90
        ELSE 30
    END
FROM core.Class C
CROSS JOIN catalog.StatType ST
LEFT JOIN catalog.ClassStatPreference P
    ON P.ClassId    = C.ClassId
   AND P.StatTypeId = ST.StatTypeId
WHERE ST.StatCode IN ('STR', 'DEX', 'REC', 'INT', 'WIS', 'LUC')
  AND NOT EXISTS (
      SELECT 1 FROM catalog.ClassBaseStat X
      WHERE X.ClassId = C.ClassId AND X.StatTypeId = ST.StatTypeId
  );
GO
