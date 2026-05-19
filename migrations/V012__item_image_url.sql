-- V012: Agrega ImageUrl a catalog.Item y actualiza el SP para retornarla

ALTER TABLE catalog.Item
    ADD ImageUrl nvarchar(500) NULL;
GO

DECLARE @base nvarchar(200) = 'https://reloaderstorageprod.blob.core.windows.net/reloader-files/reloader_games/';

-- Luminous Tyrant set
UPDATE catalog.Item SET ImageUrl = @base + 'top_img_dark.png'     WHERE ItemCode = 'ITEM_LUMINOUS_TYRANTS_MAIL';
UPDATE catalog.Item SET ImageUrl = @base + 'gaiters_img_dark.png' WHERE ItemCode = 'ITEM_LUMINOUS_TYRANTS_GAITERS';
UPDATE catalog.Item SET ImageUrl = @base + 'bracers_img_dark.png' WHERE ItemCode = 'ITEM_LUMINOUS_TYRANTS_BRACERS';
UPDATE catalog.Item SET ImageUrl = @base + 'boots_img_dark.png'   WHERE ItemCode = 'ITEM_LUMINOUS_TYRANTS_BOOTS';

-- Accessories Bonespike
UPDATE catalog.Item SET ImageUrl = @base + 'bonespike_amulet_dark.png'    WHERE ItemCode = 'ITEM_ETERNAL_BONESPIKE_AMULET';
UPDATE catalog.Item SET ImageUrl = @base + 'bonespike_ring_right.png'      WHERE ItemCode = 'ITEM_ETERNAL_BONESPIKE_RING';
UPDATE catalog.Item SET ImageUrl = @base + 'bonespike_ban_left.png'        WHERE ItemCode = 'ITEM_ETERNAL_BONESPIKE_BAND';
UPDATE catalog.Item SET ImageUrl = @base + 'bonespike_loop_right.png'      WHERE ItemCode = 'ITEM_ETERNAL_BONESPIKE_LOOP';
UPDATE catalog.Item SET ImageUrl = @base + 'bonespike_bracelet_left.png'   WHERE ItemCode = 'ITEM_ETERNAL_BONESPIKE_BRACELET';

-- Otros
UPDATE catalog.Item SET ImageUrl = @base + 'pet_img_dark.png'    WHERE ItemCode = 'ITEM_PUDLE_CHUM';
UPDATE catalog.Item SET ImageUrl = @base + 'quiver_img_dark.png' WHERE ItemCode = 'ITEM_ETHEREAL_QUIVER';
UPDATE catalog.Item SET ImageUrl = @base + 'wing_devocion.png'   WHERE ItemCode = 'ITEM_WINGS_ICY_SPLENDOR';
GO

-- Actualiza SP para incluir I.ImageUrl en Result 2
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
END;
GO
