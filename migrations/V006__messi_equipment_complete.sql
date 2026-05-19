-- V006: Completa el equipo de Messi: enchant, 4 piezas faltantes y lapis reales

-- 1. Actualizar EnchantLevel y DamageAbsorption en equipo existente
UPDATE [equipment].[CharacterEquipment] SET [EnchantLevel]=20, [DamageAbsorption]=240
WHERE [CharacterEquipmentId] IN (1,2,3,4,11,12); -- Helm, Bracers, Gaiters, Boots, Mail, Quiver

UPDATE [equipment].[CharacterEquipment] SET [EnchantLevel]=20
WHERE [CharacterEquipmentId] = 10; -- Weapon (sin DamageAbsorption)
GO

-- 2. Agregar CharacterEquipment faltante: RING_RIGHT, BRACELET_RIGHT, WINGS, SUIT
SET IDENTITY_INSERT [equipment].[CharacterEquipment] ON;
INSERT INTO [equipment].[CharacterEquipment]
    ([CharacterEquipmentId],[CharacterId],[EquipmentSlotId],[ItemId],[ItemTypeId],[DisplayNameOverride],[DescriptionOverride],[EquippedAt],[UpdatedAt])
VALUES
(13, 1, 13, 13, 12, NULL, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()), -- RING_RIGHT: Eternal Bonespike Band
(14, 1, 15, 14, 13, NULL, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()), -- BRACELET_RIGHT: Eternal Bonespike Bracelet
(15, 1, 10, 15, 10, NULL, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()), -- WING: Wings of Icy Splendor
(16, 1, 16, 16, 14, NULL, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()); -- SUIT: Critical Royal Avenger
SET IDENTITY_INSERT [equipment].[CharacterEquipment] OFF;
GO

-- 3. Crear sockets para RING_RIGHT (4) y BRACELET_RIGHT (4) — WINGS y SUIT tienen 0
INSERT INTO [equipment].[EquippedItemSocket] ([CharacterEquipmentId],[ItemTypeId],[SocketNumber],[IsOpen],[CreatedAt])
VALUES
(13, 12, 1, 1, SYSUTCDATETIME()),(13, 12, 2, 1, SYSUTCDATETIME()),
(13, 12, 3, 1, SYSUTCDATETIME()),(13, 12, 4, 1, SYSUTCDATETIME()),
(14, 13, 1, 1, SYSUTCDATETIME()),(14, 13, 2, 1, SYSUTCDATETIME()),
(14, 13, 3, 1, SYSUTCDATETIME()),(14, 13, 4, 1, SYSUTCDATETIME());
GO

-- 4. Reemplazar lapis vinculados con los reales de Messi
DELETE FROM [equipment].[EquippedItemLapis];
GO

SET IDENTITY_INSERT [equipment].[EquippedItemLapis] ON;
INSERT INTO [equipment].[EquippedItemLapis]
    ([EquippedItemLapisId],[EquippedItemSocketId],[CharacterEquipmentId],[ItemTypeId],[LapisId],[InsertedAt])
VALUES
-- HELM (CE=1, IT=1): Craft|Ult.Fortune|Ult.Shrewd|Ult.Craft|Fortune|Dual.Fortune
(1,  1,  1, 1,  1,  SYSUTCDATETIME()),
(2,  2,  1, 1,  4,  SYSUTCDATETIME()),
(3,  3,  1, 1,  5,  SYSUTCDATETIME()),
(4,  4,  1, 1,  7,  SYSUTCDATETIME()),
(5,  5,  1, 1,  2,  SYSUTCDATETIME()),
(6,  6,  1, 1,  6,  SYSUTCDATETIME()),
-- BRACERS/GLOVES (CE=2, IT=4): Craft|Ult.Fortune|Ult.Shrewd|Ult.Craft|Fortune|Dual.Fortune
(7,  7,  2, 4,  1,  SYSUTCDATETIME()),
(8,  8,  2, 4,  4,  SYSUTCDATETIME()),
(9,  9,  2, 4,  5,  SYSUTCDATETIME()),
(10, 10, 2, 4,  7,  SYSUTCDATETIME()),
(11, 11, 2, 4,  2,  SYSUTCDATETIME()),
(12, 12, 2, 4,  6,  SYSUTCDATETIME()),
-- GAITERS/PANTS (CE=3, IT=3): Ult.Fortune|Ult.Shrewd|Ult.Craft|Dual.Fortune|Fortune|Craft
(13, 13, 3, 3,  4,  SYSUTCDATETIME()),
(14, 14, 3, 3,  5,  SYSUTCDATETIME()),
(15, 15, 3, 3,  7,  SYSUTCDATETIME()),
(16, 16, 3, 3,  6,  SYSUTCDATETIME()),
(17, 17, 3, 3,  2,  SYSUTCDATETIME()),
(18, 18, 3, 3,  1,  SYSUTCDATETIME()),
-- BOOTS (CE=4, IT=5): Lv8.Fortune|Shrewd.Lv7|Lv8.Craft|Lv8.Shrewd|Dual.Craft.Lv6|Sonic
(19, 19, 4, 5,  3,  SYSUTCDATETIME()),
(20, 20, 4, 5,  8,  SYSUTCDATETIME()),
(21, 21, 4, 5,  9,  SYSUTCDATETIME()),
(22, 22, 4, 5,  10, SYSUTCDATETIME()),
(23, 43, 4, 5,  11, SYSUTCDATETIME()),
(24, 44, 4, 5,  12, SYSUTCDATETIME()),
-- AMULET (CE=7, IT=11): Mech#3|Dual.Fortune.Lv6|Mech#2|Dual.Craft.Lv6
(25, 29, 7, 11, 16, SYSUTCDATETIME()),
(26, 30, 7, 11, 18, SYSUTCDATETIME()),
(27, 31, 7, 11, 15, SYSUTCDATETIME()),
(28, 46, 7, 11, 11, SYSUTCDATETIME()),
-- RING LEFT (CE=8, IT=12): Mech#3|Mech#2|Mech#1|Mech#4
(29, 32, 8, 12, 16, SYSUTCDATETIME()),
(30, 33, 8, 12, 15, SYSUTCDATETIME()),
(31, 34, 8, 12, 14, SYSUTCDATETIME()),
(32, 47, 8, 12, 17, SYSUTCDATETIME()),
-- BRACELET LEFT (CE=9, IT=13): Mech#3|Mech#2|Mech#1|Pure
(33, 35, 9, 13, 16, SYSUTCDATETIME()),
(34, 36, 9, 13, 15, SYSUTCDATETIME()),
(35, 37, 9, 13, 14, SYSUTCDATETIME()),
(36, 48, 9, 13, 19, SYSUTCDATETIME()),
-- WEAPON (CE=10, IT=6): MaxFlash|Lv8.Craft|Chaotic|Lv8.Fortune|Fortune.Lv9|Craft.Lv9
(37, 38, 10, 6, 20, SYSUTCDATETIME()),
(38, 39, 10, 6, 9,  SYSUTCDATETIME()),
(39, 40, 10, 6, 21, SYSUTCDATETIME()),
(40, 41, 10, 6, 3,  SYSUTCDATETIME()),
(41, 42, 10, 6, 2,  SYSUTCDATETIME()),
(42, 45, 10, 6, 1,  SYSUTCDATETIME()),
-- MAIL/TOP (CE=11, IT=2): Ult.Fortune|Ult.Shrewd|Lv8.Craft|Lv8.Fortune|Lv8.Shrewd|Dual.Craft.Lv7
(43, 49, 11, 2, 4,  SYSUTCDATETIME()),
(44, 50, 11, 2, 5,  SYSUTCDATETIME()),
(45, 51, 11, 2, 9,  SYSUTCDATETIME()),
(46, 52, 11, 2, 3,  SYSUTCDATETIME()),
(47, 53, 11, 2, 10, SYSUTCDATETIME()),
(48, 54, 11, 2, 13, SYSUTCDATETIME()),
-- RING RIGHT (CE=13, IT=12): Mech#3|Mech#2|Mech#1|Mech#4
(49, 59, 13, 12, 16, SYSUTCDATETIME()),
(50, 60, 13, 12, 15, SYSUTCDATETIME()),
(51, 61, 13, 12, 14, SYSUTCDATETIME()),
(52, 62, 13, 12, 17, SYSUTCDATETIME()),
-- BRACELET RIGHT (CE=14, IT=13): Mech#3|Mech#2|Pure|Mech#1
(53, 63, 14, 13, 16, SYSUTCDATETIME()),
(54, 64, 14, 13, 15, SYSUTCDATETIME()),
(55, 65, 14, 13, 19, SYSUTCDATETIME()),
(56, 66, 14, 13, 14, SYSUTCDATETIME());
SET IDENTITY_INSERT [equipment].[EquippedItemLapis] OFF;
GO
