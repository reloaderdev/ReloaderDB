-- ============================================================
-- V033__lapis_icons_triple_mystic.sql
-- ESTADO: CERRADA (2026-09-27) — no modificar. Pendiente de produccion
-- (produccion en v032). Cambios nuevos van en V034.
--
--   1) Lapis faltante: Ultimate Triple Mystic Lapis
--      TRIPLE Lv10, item 75+, Max HP +1500, INT +35, WIS +30
--      Piezas: HELMET TOP PANTS GLOVES
--   2) catalog.Lapis.IconUrl nvarchar(500) NULL (Azure Storage)
--   3) IconUrl de todos los lapis (se recalcula completo, re-ejecutable):
--      - Triples: imagen propia ultimate_triple_<nombre>_lapis.png
--      - Mechanic #1..#4: mechanic_lapis.png
--      - Imagen propia por familia (todos los niveles la misma):
--          PURE -> pure_lapis | SONIC -> sonic_lapis | MAX_FLASH -> max_flash_lapis
--          CHAOTIC -> chaotic_lapis | LIFE -> life_lapis | ABSORPTION -> absorption_lapis
--        (subidas con sin_imagen como placeholder; se reemplaza el archivo
--        en Azure con el mismo nombre, sin tocar la base)
--      - Resto: gema de la familia que indica el NOMBRE, aunque otro stat
--        tenga mas valor (confirmado en el juego: Dual Mystic = INT,
--        Dual Wise = WIS). Misma regla que la app (CharacterScreenMapper):
--          CRAFT / ARTESANAL -> gem_ice (STR)
--          SHREWD / ASTUCIA  -> gem_light (DEX)
--          FORTUNE / FORTUNA -> gem_fire (LUC)
--          SAFE              -> gem_lightning (REC)
--          MYSTIC            -> gem_earth (INT)
--          WISE              -> gem_dark (WIS)
--        Sin familia: con STR -> gem_ice; si no, stat mas alto
--        (empate: DEX, LUC, REC, INT, WIS); sin stats -> gem_ice
--   4) equipment.sp_GetCharacterScreenByUser — V028 + IconUrl del lapis
--      Result 2: + L.IconUrl AS LapisIconUrl | Result 3: + L.IconUrl
--      Result 1, 4 y 5 sin cambios.
--   5) catalog.Item.ImageUrl de los 26 items que no tenian imagen.
--      Imagen generica por tipo, compartida por todos los items de ese tipo
--      (igual que top/gaiters/bracers/boots/quiver_img_dark.png):
--        HELMET -> helmet_img_dark.png | WEAPON -> weapon_img_dark.png
--        SUIT   -> suit_img_dark.png   | CAPE   -> cape_img_dark.png
--      Solo cambia ImageUrl: ItemCode e ItemName no se tocan.
--   6) Oraculo (ORACLE_LUZ / ORACLE_FURIA) es de aguante: Absorcion -> REC
--      -> poco WIS. catalog.ClassStatPreference pasa de WIS:1 REC:2 a
--      REC:1 WIS:2. AbsorptionSockets queda en 2 (ya se llenan primero).
--      Solo cambia las sugerencias (fn_RecommendedLapisForItem); lo ya
--      equipado no se toca.
--      Subidas con sin_imagen como placeholder; se reemplaza el archivo en
--      Azure con el mismo nombre, sin tocar la base.
-- ============================================================


-- ------------------------------------------------------------
-- 1) Ultimate Triple Mystic Lapis
-- ------------------------------------------------------------
DECLARE @TripleTypeId INT = (SELECT LapisTypeId FROM catalog.LapisType WHERE LapisTypeCode = 'TRIPLE');

IF @TripleTypeId IS NULL
    THROW 50330, 'V033: no se encontro el tipo de lapis TRIPLE.', 1;

-- 1) Lapis
IF NOT EXISTS (
    SELECT 1 FROM catalog.Lapis
    WHERE LapisCode = 'ULTIMATE_TRIPLE_MYSTIC'
       OR LapisName = N'Ultimate Triple Mystic Lapis'
)
    INSERT INTO catalog.Lapis (
        LapisTypeId, LapisCode, LapisName, LapisLevel, RequiredLevel, Description, RiskNote, IsActive,
        StatSTR, StatDEX, StatREC, StatLUC, StatINT, StatWIS, StatMaxHP, StatDamageAbsorption
    )
    VALUES (
        @TripleTypeId, 'ULTIMATE_TRIPLE_MYSTIC', N'Ultimate Triple Mystic Lapis', 10, 75,
        N'Agrega Max HP +1500, INT +35, WIS +30. Cascos, Armadura superior, Armadura inferior, Guantelete.',
        N'Puede romper el equipo si falla.', 1,
        NULL, NULL, NULL, NULL, 35, 30, 1500, NULL
    );

DECLARE @LapisId BIGINT = (
    SELECT LapisId FROM catalog.Lapis
    WHERE LapisCode = 'ULTIMATE_TRIPLE_MYSTIC'
       OR LapisName = N'Ultimate Triple Mystic Lapis'
);

-- 2) LapisEffect (misma informacion que las columnas Stat*, una fila por stat)
INSERT INTO catalog.LapisEffect (LapisId, StatTypeId, EffectValue)
SELECT @LapisId, ST.StatTypeId, V.EffectValue
FROM (VALUES
    ('INT', 35),
    ('WIS', 30),
    ('HP',  1500)
) AS V(StatCode, EffectValue)
JOIN catalog.StatType ST ON ST.StatCode = V.StatCode
WHERE NOT EXISTS (
    SELECT 1 FROM catalog.LapisEffect LE
    WHERE LE.LapisId    = @LapisId
      AND LE.StatTypeId = ST.StatTypeId
);

-- 3) Piezas donde se puede linkear
INSERT INTO catalog.LapisApplicableItemType (LapisId, ItemTypeId)
SELECT @LapisId, IT.ItemTypeId
FROM catalog.ItemType IT
WHERE IT.ItemTypeCode IN ('HELMET', 'TOP', 'PANTS', 'GLOVES')
  AND NOT EXISTS (
      SELECT 1 FROM catalog.LapisApplicableItemType A
      WHERE A.LapisId    = @LapisId
        AND A.ItemTypeId = IT.ItemTypeId
  );
GO


-- ------------------------------------------------------------
-- 2) catalog.Lapis.IconUrl
-- ------------------------------------------------------------
IF COL_LENGTH('catalog.Lapis', 'IconUrl') IS NULL
    ALTER TABLE [catalog].[Lapis]
        ADD [IconUrl] NVARCHAR(500) NULL;
GO


-- ------------------------------------------------------------
-- 3) IconUrl de todos los lapis
-- ------------------------------------------------------------
DECLARE @base NVARCHAR(200) = N'https://reloaderstorageprod.blob.core.windows.net/reloader-files/reloader_games/';

UPDATE L
SET IconUrl = @base + COALESCE(
        X.FileName,
        CASE
            WHEN LT.LapisTypeCode = 'MECHANIC'                                THEN N'mechanic_lapis.png'
            WHEN L.LapisCode LIKE 'PURE%'                                     THEN N'pure_lapis.png'
            WHEN L.LapisCode LIKE 'SONIC%'                                    THEN N'sonic_lapis.png'
            WHEN L.LapisCode LIKE 'MAX_FLASH%'                                THEN N'max_flash_lapis.png'
            WHEN L.LapisCode LIKE 'CHAOTIC%'                                  THEN N'chaotic_lapis.png'
            WHEN L.LapisCode LIKE 'LIFE%'                                     THEN N'life_lapis.png'
            WHEN L.LapisCode LIKE 'ABSORPTION%'                               THEN N'absorption_lapis.png'
            WHEN L.LapisCode LIKE '%CRAFT%'   OR L.LapisCode LIKE '%ARTESANAL%' THEN N'gem_ice.png'
            WHEN L.LapisCode LIKE '%SHREWD%'  OR L.LapisCode LIKE '%ASTUCIA%'   THEN N'gem_light.png'
            WHEN L.LapisCode LIKE '%FORTUNE%' OR L.LapisCode LIKE '%FORTUNA%'   THEN N'gem_fire.png'
            WHEN L.LapisCode LIKE '%SAFE%'                                    THEN N'gem_lightning.png'
            WHEN L.LapisCode LIKE '%MYSTIC%'                                  THEN N'gem_earth.png'
            WHEN L.LapisCode LIKE '%WISE%'                                    THEN N'gem_dark.png'
            WHEN L.StatSTR IS NOT NULL                                        THEN N'gem_ice.png'
            ELSE COALESCE(H.FileName, N'gem_ice.png')
        END)
FROM catalog.Lapis L
JOIN catalog.LapisType LT ON LT.LapisTypeId = L.LapisTypeId
-- Imagen propia por codigo
LEFT JOIN (VALUES
    ('LAPIS_FORTUNA_TRIPLE_DEF', N'ultimate_triple_fortune_lapis.png'),
    ('LAPIS_ASTUCIA_TRIPLE_DEF', N'ultimate_triple_shrewd_lapis.png'),
    ('LAPIS_CRAFT_TRIPLE_DEF',   N'ultimate_triple_craft_lapis.png'),
    ('ULTIMATE_TRIPLE_WISE',     N'ultimate_triple_wise_lapis.png'),
    ('ULTIMATE_TRIPLE_SAFE',     N'ultimate_triple_safe_lapis.png'),
    ('ULTIMATE_TRIPLE_MYSTIC',   N'ultimate_triple_mistyc_lapis.png')
) X (LapisCode, FileName) ON X.LapisCode = L.LapisCode
-- Stat mas alto (solo para lapis sin familia en el nombre)
OUTER APPLY (
    SELECT TOP 1 S.FileName
    FROM (VALUES
        (1, L.StatDEX, N'gem_light.png'),
        (2, L.StatLUC, N'gem_fire.png'),
        (3, L.StatREC, N'gem_lightning.png'),
        (4, L.StatINT, N'gem_earth.png'),
        (5, L.StatWIS, N'gem_dark.png')
    ) S (Ord, Value, FileName)
    WHERE S.Value > 0
    ORDER BY S.Value DESC, S.Ord
) H;
GO


-- ------------------------------------------------------------
-- 4) equipment.sp_GetCharacterScreenByUser
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
END;
GO


-- ------------------------------------------------------------
-- 5) catalog.Item.ImageUrl de los items sin imagen
-- ------------------------------------------------------------
DECLARE @base NVARCHAR(200) = N'https://reloaderstorageprod.blob.core.windows.net/reloader-files/reloader_games/';

-- Imagen generica por tipo (solo ImageUrl; ItemCode / ItemName intactos)
UPDATE I
SET ImageUrl = @base + CASE IT.ItemTypeCode
                           WHEN 'HELMET' THEN N'helmet_img_dark.png'
                           WHEN 'WEAPON' THEN N'weapon_img_dark.png'
                           WHEN 'SUIT'   THEN N'suit_img_dark.png'
                           WHEN 'CAPE'   THEN N'cape_img_dark.png'
                       END
FROM catalog.Item I
JOIN catalog.ItemType IT ON IT.ItemTypeId = I.ItemTypeId
WHERE IT.ItemTypeCode IN ('HELMET', 'WEAPON', 'SUIT', 'CAPE');
GO


-- ------------------------------------------------------------
-- 6) Oraculo: REC:1, WIS:2 (antes WIS:1, REC:2)
-- ------------------------------------------------------------
DECLARE @RecId INT = (SELECT StatTypeId FROM catalog.StatType WHERE StatCode = 'REC');
DECLARE @WisId INT = (SELECT StatTypeId FROM catalog.StatType WHERE StatCode = 'WIS');

IF @RecId IS NULL OR @WisId IS NULL
    THROW 50331, 'V033: no se encontraron los stats REC / WIS.', 1;

UPDATE P
SET Priority = CASE P.StatTypeId WHEN @RecId THEN 1 WHEN @WisId THEN 2 END
FROM catalog.ClassStatPreference P
JOIN core.Class C ON C.ClassId = P.ClassId
WHERE C.ClassCode IN ('ORACLE_LUZ', 'ORACLE_FURIA')
  AND P.StatTypeId IN (@RecId, @WisId);
GO
