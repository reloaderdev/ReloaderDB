-- ============================================================
-- V026__catalog_lapis_complete.sql
-- Catalogo de lapis completo (fuente: dbreadme/LAPIS_RECIBIDOS.txt)
--
--   1) catalog.StatType DAMAGE_ABSORPTION
--   2) catalog.Lapis.StatDamageAbsorption int NULL
--   3) catalog.LapisType WEAPON ('Lapis de arma')
--   4) Correcciones: Chaotic / Max Flash -> WEAPON,
--      Ultimate Triple Craft -> TRIPLE (ULTIMATE queda sin uso, no se borra),
--      Dual Craft Lv7 / Dual Fortune Lv7 -> RequiredLevel 75
--   5) 21 lapis nuevos + LapisEffect + LapisApplicableItemType
--      (idempotente por LapisCode / LapisName)
--   6) Limpieza de V025: usuarios SUPPLIER sin personajes pierden
--      el rol PLAYER y su core.Player (el backfill se los habia dado)
--
-- Nombres de lapis EN INGLES tal cual el juego; los valores son los de
-- la descripcion del juego aunque no coincidan con el nombre
-- (ej. Dual Mystic = WIS 40 / INT 35).
-- Regla de linkeo: solo tipo de pieza + nivel del item + socket libre
-- + no repetir en la pieza. Nunca por clase.
-- ============================================================


-- ------------------------------------------------------------
-- 1) Stat DAMAGE_ABSORPTION (resta dano recibido por golpe; va aparte
--    de los stats: base del encanto [20] = 240 por pieza + lapis)
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM catalog.StatType WHERE StatCode = 'DAMAGE_ABSORPTION')
    INSERT INTO catalog.StatType (StatCode, StatName, ValueType, IsPrimary, IsDerived, IsActive)
    VALUES ('DAMAGE_ABSORPTION', N'Damage Absorption', 'INTEGER', 0, 1, 1);
GO


-- ------------------------------------------------------------
-- 2) catalog.Lapis.StatDamageAbsorption
-- ------------------------------------------------------------
IF COL_LENGTH('catalog.Lapis', 'StatDamageAbsorption') IS NULL
    ALTER TABLE [catalog].[Lapis]
        ADD [StatDamageAbsorption] INT NULL;
GO


-- ------------------------------------------------------------
-- 3) LapisType WEAPON — lapis exclusivos de arma
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM catalog.LapisType WHERE LapisTypeCode = 'WEAPON')
    INSERT INTO catalog.LapisType (LapisTypeCode, LapisTypeName)
    VALUES ('WEAPON', N'Lapis de arma');
GO


-- ------------------------------------------------------------
-- 4) Correcciones confirmadas por el usuario
-- ------------------------------------------------------------
DECLARE @WeaponTypeId INT = (SELECT LapisTypeId FROM catalog.LapisType WHERE LapisTypeCode = 'WEAPON');
DECLARE @TripleTypeId INT = (SELECT LapisTypeId FROM catalog.LapisType WHERE LapisTypeCode = 'TRIPLE');

IF @WeaponTypeId IS NULL OR @TripleTypeId IS NULL
    THROW 50260, 'V026: no se encontraron los tipos de lapis WEAPON / TRIPLE.', 1;

-- Chaotic y Max Flash: exclusivos de arma (Chaotic no es dual)
UPDATE catalog.Lapis
SET LapisTypeId = @WeaponTypeId
WHERE LapisCode IN ('CHAOTIC_LAPIS', 'MAX_FLASH_LAPIS')
  AND LapisTypeId <> @WeaponTypeId;

-- Ultimate Triple Craft: es TRIPLE (estaba como ULTIMATE)
UPDATE catalog.Lapis
SET LapisTypeId = @TripleTypeId
WHERE LapisCode = 'LAPIS_CRAFT_TRIPLE_DEF'
  AND LapisTypeId <> @TripleTypeId;

-- Duales Lv7: nivel minimo del item 75 (estaban en 65)
UPDATE catalog.Lapis
SET RequiredLevel = 75,
    Description   = CASE LapisCode
                        WHEN 'DUAL_CRAFT_LV7'   THEN N'STR +40, DEX +35. Cascos, Armadura superior, Armadura inferior, Guantelete. Item nivel 75+.'
                        WHEN 'DUAL_FORTUNE_LV7' THEN N'DEX +35, LUC +40. Cascos, Armadura superior, Armadura inferior, Guantelete. Item nivel 75+.'
                    END
WHERE LapisCode IN ('DUAL_CRAFT_LV7', 'DUAL_FORTUNE_LV7');
GO


-- ------------------------------------------------------------
-- 5) Lapis nuevos
--    Piezas: Upper Armor = TOP, Lower Armor = PANTS, Gauntlet = GLOVES,
--            Shoes = BOOTS, Necklaces = AMULET
-- ------------------------------------------------------------
DECLARE @NewLapis TABLE (
    LapisCode     NVARCHAR(100) NOT NULL PRIMARY KEY,
    LapisName     NVARCHAR(200) NOT NULL,
    LapisTypeCode NVARCHAR(30)  NOT NULL,
    LapisLevel    INT           NOT NULL,
    RequiredLevel INT           NOT NULL,
    StatSTR       INT NULL,
    StatDEX       INT NULL,
    StatREC       INT NULL,
    StatLUC       INT NULL,
    StatINT       INT NULL,
    StatWIS       INT NULL,
    StatMaxHP     INT NULL,
    StatAbs       INT NULL,
    Pieces        NVARCHAR(200) NOT NULL,   -- ItemTypeCode separados por espacio
    Description   NVARCHAR(1000) NOT NULL
);

INSERT INTO @NewLapis (LapisCode, LapisName, LapisTypeCode, LapisLevel, RequiredLevel,
                       StatSTR, StatDEX, StatREC, StatLUC, StatINT, StatWIS, StatMaxHP, StatAbs,
                       Pieces, Description)
VALUES
-- INT
('MYSTIC_LV9', N'Mystic Lapis Lv9', 'SINGLE', 9, 75, NULL,NULL,NULL,NULL, 75,NULL,NULL,NULL,
    'WEAPON HELMET PANTS SHIELD GLOVES',            N'INT +75. Armas, Cascos, Armadura inferior, Escudos, Guantelete.'),
('MYSTIC_LV8', N'Mystic Lapis Lv8', 'SINGLE', 8, 71, NULL,NULL,NULL,NULL, 65,NULL,NULL,NULL,
    'WEAPON HELMET TOP PANTS SHIELD GLOVES BOOTS',  N'INT +65. Armas, Cascos, Armadura superior, Armadura inferior, Escudos, Guantelete, Zapatos.'),
('MYSTIC_LV7', N'Mystic Lapis Lv7', 'SINGLE', 7, 31, NULL,NULL,NULL,NULL, 50,NULL,NULL,NULL,
    'WEAPON TOP PANTS GLOVES BOOTS',                N'INT +50. Armas, Armadura superior, Armadura inferior, Guantelete, Zapatos.'),
-- WIS
('WISE_LV9',   N'Wise Lapis Lv9',   'SINGLE', 9, 75, NULL,NULL,NULL,NULL,NULL, 75,NULL,NULL,
    'WEAPON HELMET PANTS SHIELD GLOVES',            N'WIS +75. Armas, Cascos, Armadura inferior, Escudos, Guantelete.'),
('WISE_LV8',   N'Wise Lapis Lv8',   'SINGLE', 8, 71, NULL,NULL,NULL,NULL,NULL, 65,NULL,NULL,
    'WEAPON HELMET TOP PANTS SHIELD GLOVES BOOTS',  N'WIS +65. Armas, Cascos, Armadura superior, Armadura inferior, Escudos, Guantelete, Zapatos.'),
('WISE_LV7',   N'Wise Lapis Lv7',   'SINGLE', 7, 31, NULL,NULL,NULL,NULL,NULL, 50,NULL,NULL,
    'WEAPON PANTS GLOVES BOOTS',                    N'WIS +50. Armas, Armadura inferior, Guantelete, Zapatos.'),
-- REC
('SAFE_LV9',   N'Safe Lapis Lv9',   'SINGLE', 9, 75, NULL,NULL, 75,NULL,NULL,NULL,NULL,NULL,
    'WEAPON HELMET PANTS SHIELD GLOVES',            N'REC +75. Armas, Cascos, Armadura inferior, Escudos, Guantelete.'),
('SAFE_LV8',   N'Safe Lapis Lv8',   'SINGLE', 8, 71, NULL,NULL, 65,NULL,NULL,NULL,NULL,NULL,
    'WEAPON HELMET TOP PANTS SHIELD GLOVES BOOTS',  N'REC +65. Armas, Cascos, Armadura superior, Armadura inferior, Escudos, Guantelete, Zapatos.'),
('SAFE_LV7',   N'Safe Lapis Lv7',   'SINGLE', 7, 31, NULL,NULL, 50,NULL,NULL,NULL,NULL,NULL,
    'WEAPON PANTS SHIELD GLOVES BOOTS',             N'REC +50. Armas, Armadura inferior, Escudos, Guantelete, Zapatos.'),
-- ABSORCION (no suma stat: resta dano recibido por golpe)
('ABSORPTION_LV10', N'Absorption Lapis Lv10', 'SINGLE', 10, 80, NULL,NULL,NULL,NULL,NULL,NULL,NULL, 250,
    'TOP PANTS SHIELD GLOVES BOOTS',                N'Damage Absorption +250. Armadura superior, Armadura inferior, Escudos, Guantelete, Zapatos.'),
('ABSORPTION_LV9',  N'Absorption Lapis Lv9',  'SINGLE',  9, 75, NULL,NULL,NULL,NULL,NULL,NULL,NULL, 200,
    'TOP PANTS SHIELD GLOVES BOOTS',                N'Damage Absorption +200. Armadura superior, Armadura inferior, Escudos, Guantelete, Zapatos.'),
('ABSORPTION_LV8',  N'Absorption Lapis Lv8',  'SINGLE',  8, 71, NULL,NULL,NULL,NULL,NULL,NULL,NULL, 150,
    'TOP PANTS SHIELD GLOVES BOOTS',                N'Damage Absorption +150. Armadura superior, Armadura inferior, Escudos, Guantelete, Zapatos.'),
('ABSORPTION_LV7',  N'Absorption Lapis Lv7',  'SINGLE',  7, 45, NULL,NULL,NULL,NULL,NULL,NULL,NULL, 100,
    'TOP PANTS SHIELD GLOVES BOOTS',                N'Damage Absorption +100. Armadura superior, Armadura inferior, Escudos, Guantelete, Zapatos.'),
-- HP
('LIFE_LV10',  N'Life Lapis Lv10',  'SINGLE', 10, 80, NULL,NULL,NULL,NULL,NULL,NULL, 3000,NULL,
    'TOP BOOTS AMULET',                             N'Max HP +3000. Armadura superior, Zapatos, Collares.'),
('LIFE_LV9',   N'Life Lapis Lv9',   'SINGLE',  9, 75, NULL,NULL,NULL,NULL,NULL,NULL, 2500,NULL,
    'TOP BOOTS AMULET',                             N'Max HP +2500. Armadura superior, Zapatos, Collares.'),
('LIFE_LV8',   N'Life Lapis Lv8',   'SINGLE',  8, 71, NULL,NULL,NULL,NULL,NULL,NULL, 2200,NULL,
    'HELMET TOP PANTS SHIELD GLOVES BOOTS AMULET',  N'Max HP +2200. Cascos, Armadura superior, Armadura inferior, Escudos, Guantelete, Zapatos, Collares.'),
('LIFE_LV7',   N'Life Lapis Lv7',   'SINGLE',  7, 31, NULL,NULL,NULL,NULL,NULL,NULL, 2000,NULL,
    'TOP PANTS SHIELD GLOVES BOOTS',                N'Max HP +2000. Armadura superior, Armadura inferior, Escudos, Guantelete, Zapatos.'),
-- TRIPLES ULTIMATE
('ULTIMATE_TRIPLE_WISE', N'Ultimate Triple Wise Lapis', 'TRIPLE', 10, 75, NULL,NULL,NULL,NULL, 30, 35, 1500,NULL,
    'HELMET TOP PANTS SHIELD GLOVES',               N'Agrega Max HP +1500, INT +30, WIS +35. Cascos, Armadura superior, Armadura inferior, Escudos, Guantelete.'),
('ULTIMATE_TRIPLE_SAFE', N'Ultimate Triple Safe Lapis', 'TRIPLE', 10, 75, NULL,NULL, 35,NULL,NULL, 30, 1500,NULL,
    'HELMET TOP PANTS GLOVES',                      N'Agrega Max HP +1500, REC +35, WIS +30. Cascos, Armadura superior, Armadura inferior, Guantelete.'),
-- DUALES Lv7
('DUAL_SAFE_LV7',   N'Dual Safe Lapis Lv7',   'DUAL', 7, 75, NULL,NULL, 40,NULL,NULL, 35,NULL,NULL,
    'HELMET TOP PANTS GLOVES',                      N'REC +40, WIS +35. Cascos, Armadura superior, Armadura inferior, Guantelete. Item nivel 75+.'),
('DUAL_MYSTIC_LV7', N'Dual Mystic Lapis Lv7', 'DUAL', 7, 75, NULL,NULL,NULL,NULL, 35, 40,NULL,NULL,
    'HELMET TOP PANTS GLOVES',                      N'WIS +40, INT +35. Cascos, Armadura superior, Armadura inferior, Guantelete. Item nivel 75+.'),
('DUAL_WISE_LV7',   N'Dual Wise Lapis Lv7',   'DUAL', 7, 75, NULL,NULL,NULL,NULL, 40, 35,NULL,NULL,
    'HELMET TOP PANTS GLOVES',                      N'INT +40, WIS +35. Cascos, Armadura superior, Armadura inferior, Guantelete. Item nivel 75+.'),
('DUAL_SHREWD_LV7', N'Dual Shrewd Lapis Lv7', 'DUAL', 7, 75, NULL, 40, 35,NULL,NULL,NULL,NULL,NULL,
    'HELMET TOP PANTS GLOVES',                      N'DEX +40, REC +35. Cascos, Armadura superior, Armadura inferior, Guantelete. Item nivel 75+.');

IF EXISTS (
    SELECT 1 FROM @NewLapis N
    LEFT JOIN catalog.LapisType LT ON LT.LapisTypeCode = N.LapisTypeCode
    WHERE LT.LapisTypeId IS NULL
)
    THROW 50261, 'V026: tipo de lapis inexistente en la lista de lapis nuevos.', 1;

-- 5.1) Lapis (se saltea si ya existe por codigo o por nombre)
INSERT INTO catalog.Lapis (
    LapisTypeId, LapisCode, LapisName, LapisLevel, RequiredLevel, Description, RiskNote, IsActive,
    StatSTR, StatDEX, StatREC, StatLUC, StatINT, StatWIS, StatMaxHP, StatDamageAbsorption
)
SELECT
    LT.LapisTypeId, N.LapisCode, N.LapisName, N.LapisLevel, N.RequiredLevel, N.Description,
    CASE WHEN N.LapisLevel >= 10 THEN N'Puede romper el equipo si falla.'
         ELSE N'Si falla, el lapis se rompe.' END,
    1,
    N.StatSTR, N.StatDEX, N.StatREC, N.StatLUC, N.StatINT, N.StatWIS, N.StatMaxHP, N.StatAbs
FROM @NewLapis N
JOIN catalog.LapisType LT ON LT.LapisTypeCode = N.LapisTypeCode
WHERE NOT EXISTS (
    SELECT 1 FROM catalog.Lapis L
    WHERE L.LapisCode = N.LapisCode
       OR L.LapisName = N.LapisName
);

-- 5.2) LapisEffect (misma informacion que las columnas Stat*, una fila por stat)
INSERT INTO catalog.LapisEffect (LapisId, StatTypeId, EffectValue)
SELECT L.LapisId, ST.StatTypeId, V.EffectValue
FROM @NewLapis N
JOIN catalog.Lapis L ON L.LapisCode = N.LapisCode OR L.LapisName = N.LapisName
CROSS APPLY (VALUES
    ('STR',               N.StatSTR),
    ('DEX',               N.StatDEX),
    ('REC',               N.StatREC),
    ('LUC',               N.StatLUC),
    ('INT',               N.StatINT),
    ('WIS',               N.StatWIS),
    ('HP',                N.StatMaxHP),
    ('DAMAGE_ABSORPTION', N.StatAbs)
) AS V(StatCode, EffectValue)
JOIN catalog.StatType ST ON ST.StatCode = V.StatCode
WHERE V.EffectValue IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM catalog.LapisEffect LE
      WHERE LE.LapisId    = L.LapisId
        AND LE.StatTypeId = ST.StatTypeId
  );

-- 5.3) Piezas donde se puede linkear cada lapis
INSERT INTO catalog.LapisApplicableItemType (LapisId, ItemTypeId)
SELECT DISTINCT L.LapisId, IT.ItemTypeId
FROM @NewLapis N
JOIN catalog.Lapis L ON L.LapisCode = N.LapisCode OR L.LapisName = N.LapisName
JOIN catalog.ItemType IT
    ON CHARINDEX(' ' + IT.ItemTypeCode + ' ', ' ' + N.Pieces + ' ') > 0
WHERE NOT EXISTS (
    SELECT 1 FROM catalog.LapisApplicableItemType A
    WHERE A.LapisId    = L.LapisId
      AND A.ItemTypeId = IT.ItemTypeId
);
GO


-- ------------------------------------------------------------
-- 6) Limpieza de V025: los proveedores (RegistrationSource = SUPPLIER)
--    no son jugadores. Si no tienen personajes, se les quita el rol
--    PLAYER y su core.Player (UserProfile se conserva).
-- ------------------------------------------------------------
DECLARE @Suppliers TABLE (UserId BIGINT PRIMARY KEY);

INSERT INTO @Suppliers (UserId)
SELECT U.UserId
FROM auth.Users U
WHERE U.RegistrationSource = 'SUPPLIER'
  AND NOT EXISTS (
      SELECT 1
      FROM core.Player P
      JOIN core.Character C ON C.PlayerId = P.PlayerId
      WHERE P.UserId = U.UserId
  );

DELETE UR
FROM auth.UserRole UR
JOIN auth.Role R    ON R.RoleId = UR.RoleId AND R.RoleCode = 'PLAYER'
JOIN @Suppliers S   ON S.UserId = UR.UserId;

DELETE P
FROM core.Player P
JOIN @Suppliers S ON S.UserId = P.UserId;
GO
