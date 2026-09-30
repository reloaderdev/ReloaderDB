-- ============================================================
-- V036__lapis_levels_and_lv10.sql
-- ESTADO: CERRADA (2026-09-30) - no modificar. Pendiente de produccion (produccion en v035).
--
-- Correccion del catalogo de lapis (definida por el usuario, 2026-09-30):
--   1) catalog.Lapis.LapisLevel admite NULL = lapis sin nivel. La app
--      mostraba "Lv10" en lapis que no tienen nivel.
--   2) Sin nivel: Chaotic Lapis (STR +45 DEX +45, solo armas) y los
--      Ultimate Triple (Craft, Fortune, Mystic, Safe, Shrewd, Wise).
--   3) Max Flash Lapis -> Flash Lapis Lv3 (nivel 3, solo armas): Radiant
--      Lapis que sube la velocidad de ataque 3 niveles. El LapisCode no
--      cambia (MAX_FLASH_LAPIS) para no romper icono ni equipos guardados.
--   4) Ultimate Triple Wise: Max HP 1500, INT 30, WIS 35; Casco, Armadura
--      superior, Armadura inferior, Escudo y Guantelete (se reafirma).
--   5) Lapis nuevos Lv10 (+85, RequiredLevel 80): Fortune (LUC), Craft
--      (STR), Shrewd (DEX), Wise (WIS), Safe (REC), Mystic (INT). Armas,
--      Casco, Armadura inferior, Escudo y Guantelete. Icono = el de su
--      familia (mismo IconUrl que su Lv9 / Lv8, regla de V033).
--      Life Lv10 y Absorption Lv10 ya existian con los valores correctos.
--      Stats que el lapis no usa van en NULL (como el resto del catalogo): la app
--      muestra todo stat con valor, un 0 saldria como "+0".
--
--   6) Linkeo sugerido: Sonic Lapis Lv2 siempre en botas (socket 1).
--
-- El resto del linkeo sugerido (equipment.fn_RecommendedLapisForItem) sigue igual: elige
-- del catalogo por puntaje y RequiredLevel <= nivel de la pieza (todas 80),
-- asi que toma los Lv10 nuevos sola. Los NULL de LapisLevel ordenan al final
-- en el desempate (ORDER BY LapisLevel DESC).
-- ============================================================


-- ------------------------------------------------------------
-- 1) LapisLevel admite NULL
-- ------------------------------------------------------------
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('catalog.Lapis') AND name = 'LapisLevel' AND is_nullable = 0
)
    ALTER TABLE catalog.Lapis ALTER COLUMN LapisLevel INT NULL;
GO


-- ------------------------------------------------------------
-- 2) Sin nivel: Chaotic y Ultimate Triple
-- ------------------------------------------------------------
UPDATE L
SET L.LapisLevel = NULL
FROM catalog.Lapis L
JOIN catalog.LapisType LT ON LT.LapisTypeId = L.LapisTypeId
WHERE L.LapisCode = 'CHAOTIC_LAPIS'
   OR LT.LapisTypeCode = 'TRIPLE';

UPDATE catalog.Lapis
SET LapisName = N'Chaotic Lapis',
    StatSTR = 45, StatDEX = 45,
    Description = N'STR +45, DEX +45. Solo aplicable a Armas.'
WHERE LapisCode = 'CHAOTIC_LAPIS';
GO


-- ------------------------------------------------------------
-- 3) Max Flash Lapis -> Flash Lapis Lv3
-- ------------------------------------------------------------
UPDATE catalog.Lapis
SET LapisName   = N'Flash Lapis Lv3',
    LapisLevel  = 3,
    Description = N'Radiant Lapis: aumenta la velocidad de ataque 3 niveles. Solo aplicable a Armas.'
WHERE LapisCode = 'MAX_FLASH_LAPIS';
GO


-- ------------------------------------------------------------
-- 4) Ultimate Triple Wise (valores y piezas)
-- ------------------------------------------------------------
UPDATE catalog.Lapis
SET StatMaxHP = 1500, StatINT = 30, StatWIS = 35,
    StatSTR = NULL, StatDEX = NULL, StatREC = NULL, StatLUC = NULL, StatDamageAbsorption = NULL,
    Description = N'Max HP +1500, INT +30, WIS +35. Casco, Armadura superior, Armadura inferior, Escudo, Guantelete.'
WHERE LapisCode = 'ULTIMATE_TRIPLE_WISE';

DELETE A
FROM catalog.LapisApplicableItemType A
JOIN catalog.Lapis L ON L.LapisId = A.LapisId
WHERE L.LapisCode = 'ULTIMATE_TRIPLE_WISE';

INSERT INTO catalog.LapisApplicableItemType (LapisId, ItemTypeId)
SELECT L.LapisId, IT.ItemTypeId
FROM catalog.Lapis L
JOIN catalog.ItemType IT ON IT.ItemTypeCode IN ('HELMET', 'TOP', 'PANTS', 'SHIELD', 'GLOVES')
WHERE L.LapisCode = 'ULTIMATE_TRIPLE_WISE';
GO


-- ------------------------------------------------------------
-- 5) Lapis nuevos Lv10 (+85). Re-ejecutable: se insertan si faltan y
--    se recalcula todo (valores, icono y piezas).
-- ------------------------------------------------------------
DECLARE @SingleId INT = (SELECT LapisTypeId FROM catalog.LapisType WHERE LapisTypeCode = 'SINGLE');
IF @SingleId IS NULL
    THROW 50360, 'V036: no se encontro el LapisType SINGLE.', 1;

DECLARE @Nuevos TABLE (
    LapisCode   NVARCHAR(50),
    LapisName   NVARCHAR(100),
    Stat        NVARCHAR(10),
    IconFrom    NVARCHAR(50),   -- LapisCode de la misma familia (su IconUrl)
    Descripcion NVARCHAR(255)
);
INSERT INTO @Nuevos VALUES
    ('FORTUNE_LV10', N'Fortune Lapis Lv10', 'LUC', 'LAPIS_FORTUNA_LV9',   N'LUC +85. Armas, Casco, Armadura inferior, Escudo, Guantelete. Solo en items nivel 80 o superior.'),
    ('CRAFT_LV10',   N'Craft Lapis Lv10',   'STR', 'LAPIS_ARTESANAL_LV9', N'STR +85. Armas, Casco, Armadura inferior, Escudo, Guantelete. Solo en items nivel 80 o superior.'),
    ('SHREWD_LV10',  N'Shrewd Lapis Lv10',  'DEX', 'LAPIS_SHREWD_LV8',    N'DEX +85. Armas, Casco, Armadura inferior, Escudo, Guantelete. Solo en items nivel 80 o superior.'),
    ('WISE_LV10',    N'Wise Lapis Lv10',    'WIS', 'WISE_LV9',            N'WIS +85. Armas, Casco, Armadura inferior, Escudo, Guantelete. Solo en items nivel 80 o superior.'),
    ('SAFE_LV10',    N'Safe Lapis Lv10',    'REC', 'SAFE_LV9',            N'REC +85. Armas, Casco, Armadura inferior, Escudo, Guantelete. Solo en items nivel 80 o superior.'),
    ('MYSTIC_LV10',  N'Mystic Lapis Lv10',  'INT', 'MYSTIC_LV9',          N'INT +85. Armas, Casco, Armadura inferior, Escudo, Guantelete. Solo en items nivel 80 o superior.');

INSERT INTO catalog.Lapis (LapisTypeId, LapisCode, LapisName, LapisLevel, RequiredLevel, IsActive,
                           StatSTR, StatDEX, StatREC, StatLUC, StatINT, StatWIS, StatMaxHP, StatDamageAbsorption)
SELECT @SingleId, N.LapisCode, N.LapisName, 10, 80, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM @Nuevos N
WHERE NOT EXISTS (SELECT 1 FROM catalog.Lapis L WHERE L.LapisCode = N.LapisCode);

UPDATE L
SET L.LapisTypeId   = @SingleId,
    L.LapisName     = N.LapisName,
    L.LapisLevel    = 10,
    L.RequiredLevel = 80,
    L.IsActive      = 1,
    L.Description   = N.Descripcion,
    L.StatSTR = CASE WHEN N.Stat = 'STR' THEN 85 ELSE NULL END,
    L.StatDEX = CASE WHEN N.Stat = 'DEX' THEN 85 ELSE NULL END,
    L.StatREC = CASE WHEN N.Stat = 'REC' THEN 85 ELSE NULL END,
    L.StatLUC = CASE WHEN N.Stat = 'LUC' THEN 85 ELSE NULL END,
    L.StatINT = CASE WHEN N.Stat = 'INT' THEN 85 ELSE NULL END,
    L.StatWIS = CASE WHEN N.Stat = 'WIS' THEN 85 ELSE NULL END,
    L.StatMaxHP = NULL,
    L.StatDamageAbsorption = NULL,
    L.IconUrl = (SELECT F.IconUrl FROM catalog.Lapis F WHERE F.LapisCode = N.IconFrom)
FROM catalog.Lapis L
JOIN @Nuevos N ON N.LapisCode = L.LapisCode;

DELETE A
FROM catalog.LapisApplicableItemType A
JOIN catalog.Lapis L ON L.LapisId = A.LapisId
JOIN @Nuevos N ON N.LapisCode = L.LapisCode;

INSERT INTO catalog.LapisApplicableItemType (LapisId, ItemTypeId)
SELECT L.LapisId, IT.ItemTypeId
FROM catalog.Lapis L
JOIN @Nuevos N ON N.LapisCode = L.LapisCode
JOIN catalog.ItemType IT ON IT.ItemTypeCode IN ('WEAPON', 'HELMET', 'PANTS', 'SHIELD', 'GLOVES');
GO


-- ------------------------------------------------------------
-- 6) equipment.fn_RecommendedLapisForItem — V030 + Sonic Lapis Lv2 obligatorio
--    Regla del usuario (2026-09-30): en botas el linkeo sugerido SIEMPRE lleva
--    Sonic Lapis Lv2, en el socket 1. Es un lapis sin stats (utilitario): antes
--    quedaba al final y los 6 sockets se llenaban con lapis de stats.
--    Solo aplica donde LapisApplicableItemType lo permite (hoy solo BOOTS).
--    Lo usan equipment.sp_GetRecommendedSet y sp_AutoLinkCharacter (sin cambios).
--    Resto de la regla igual que V030.
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
            CASE WHEN L.LapisCode = 'SONIC_LV2' THEN 1 ELSE 0 END              AS IsForced,
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
                WHEN R.IsForced      = 1 THEN -1
                WHEN R.IsWeaponLapis = 1 THEN 0
                WHEN R.IsAbsorption  = 1 THEN 1
                ELSE 2
            END AS Grp
        FROM AbsRanked R
        WHERE R.IsForced = 1
           OR (R.IsAbsorption = 1 AND R.AbsRank <= R.AbsorptionSockets)
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
