-- V008: Re-inserta EquippedItemLapis usando lookup dinamico por (CharacterEquipmentId, SocketNumber)
--       Evita dependencia de IDENTITY values que varian entre entornos (local vs produccion)

DELETE FROM [equipment].[EquippedItemLapis];
GO

INSERT INTO [equipment].[EquippedItemLapis] (EquippedItemSocketId, CharacterEquipmentId, ItemTypeId, LapisId)
SELECT EIS.EquippedItemSocketId, EIS.CharacterEquipmentId, CE.ItemTypeId, src.LapisId
FROM (VALUES
    -- HELM (CE=1): Craft|Ult.Fortune|Ult.Shrewd|Ult.Craft|Fortune|Dual.Fortune
    (1,1,1),(1,2,4),(1,3,5),(1,4,7),(1,5,2),(1,6,6),
    -- BRACERS/GLOVES (CE=2): Craft|Ult.Fortune|Ult.Shrewd|Ult.Craft|Fortune|Dual.Fortune
    (2,1,1),(2,2,4),(2,3,5),(2,4,7),(2,5,2),(2,6,6),
    -- GAITERS/PANTS (CE=3): Ult.Fortune|Ult.Shrewd|Ult.Craft|Dual.Fortune|Fortune|Craft
    (3,1,4),(3,2,5),(3,3,7),(3,4,6),(3,5,2),(3,6,1),
    -- BOOTS (CE=4): Lv8.Fortune|Shrewd.Lv7|Lv8.Craft|Lv8.Shrewd|Dual.Craft.Lv6|Sonic
    (4,1,3),(4,2,8),(4,3,9),(4,4,10),(4,5,11),(4,6,12),
    -- AMULET (CE=7): Mech#3|Dual.Fortune.Lv6|Mech#2|Dual.Craft.Lv6
    (7,1,16),(7,2,18),(7,3,15),(7,4,11),
    -- RING LEFT (CE=8): Mech#3|Mech#2|Mech#1|Mech#4
    (8,1,16),(8,2,15),(8,3,14),(8,4,17),
    -- BRACELET LEFT (CE=9): Mech#3|Mech#2|Mech#1|Pure
    (9,1,16),(9,2,15),(9,3,14),(9,4,19),
    -- WEAPON (CE=10): MaxFlash|Lv8.Craft|Chaotic|Lv8.Fortune|Fortune.Lv9|Craft.Lv9
    (10,1,20),(10,2,9),(10,3,21),(10,4,3),(10,5,2),(10,6,1),
    -- MAIL/TOP (CE=11): Ult.Fortune|Ult.Shrewd|Lv8.Craft|Lv8.Fortune|Lv8.Shrewd|Dual.Craft.Lv7
    (11,1,4),(11,2,5),(11,3,9),(11,4,3),(11,5,10),(11,6,13),
    -- RING RIGHT (CE=13): Mech#3|Mech#2|Mech#1|Mech#4
    (13,1,16),(13,2,15),(13,3,14),(13,4,17),
    -- BRACELET RIGHT (CE=14): Mech#3|Mech#2|Pure|Mech#1
    (14,1,16),(14,2,15),(14,3,19),(14,4,14)
) AS src(ce_id, socket_num, LapisId)
JOIN equipment.EquippedItemSocket EIS
    ON EIS.CharacterEquipmentId = src.ce_id
    AND EIS.SocketNumber        = src.socket_num
JOIN equipment.CharacterEquipment CE
    ON CE.CharacterEquipmentId  = EIS.CharacterEquipmentId;
GO
