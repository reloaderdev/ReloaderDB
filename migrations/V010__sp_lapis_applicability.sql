-- V010: Agrega CE.ItemTypeId al Result 2 y nuevo Result 4 con aplicabilidad de lapis.
--       Permite al app filtrar qué lapis pueden insertarse en cada slot.

ALTER PROCEDURE equipment.sp_GetCharacterScreenByUser
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

    -- Result 2: Slots equipados + stats del item + enchant + sockets + stats del lapis
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
