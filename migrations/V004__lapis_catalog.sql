-- V004: Catalogo real de lapis con stats calculables y aplicabilidad por tipo de item

-- 1. Corregir Lapis #5 (Ultimate Triple Shrewd: DEX era 35, real es 30)
UPDATE [catalog].[Lapis]
SET [Description] = N'Agrega Max HP +1500, DEX +30, LUC +30.',
    [LapisName]   = N'Lapis Astucia Triple Definitivo'
WHERE [LapisId] = 5;
GO

-- 2. Poblar stats en lapis existentes (1-5)
UPDATE [catalog].[Lapis] SET [StatSTR]=75                                    WHERE [LapisId]=1; -- Craft Lv9
UPDATE [catalog].[Lapis] SET [StatLUC]=75                                    WHERE [LapisId]=2; -- Fortune Lv9
UPDATE [catalog].[Lapis] SET [StatLUC]=65                                    WHERE [LapisId]=3; -- Lv8 Fortune
UPDATE [catalog].[Lapis] SET [StatMaxHP]=1500, [StatSTR]=30, [StatLUC]=35   WHERE [LapisId]=4; -- Ult Triple Fortune
UPDATE [catalog].[Lapis] SET [StatMaxHP]=1500, [StatDEX]=30, [StatLUC]=30   WHERE [LapisId]=5; -- Ult Triple Shrewd
GO

-- 3. Agregar 16 lapis nuevos
SET IDENTITY_INSERT [catalog].[Lapis] ON;
INSERT INTO [catalog].[Lapis] ([LapisId],[LapisTypeId],[LapisCode],[LapisName],[LapisLevel],[RequiredLevel],[Description],[RiskNote],[IsActive],[StatDEX],[StatLUC],[StatSTR],[StatREC],[StatMaxHP],[StatINT],[StatWIS])
VALUES
(6,  2, 'DUAL_FORTUNE_LV7',       N'Lapis Fortuna Dual Lv7',              7,  65, N'DEX +35, LUC +40. Cascos, Armadura superior, Armadura inferior, Guantelete.',                    N'Puede romper el equipo si falla.',1, 35,40, NULL,NULL,NULL,NULL,NULL),
(7,  4, 'LAPIS_CRAFT_TRIPLE_DEF', N'Lapis Artesanal Triple Definitivo',   10, 75, N'Agrega Max HP +1500, STR +35, REC +30.',                                                         N'Puede romper el equipo si falla.',1, NULL,NULL,35,30,1500,NULL,NULL),
(8,  1, 'SHREWD_LV7',             N'Lapis Astucia Lv7',                   7,  65, N'DEX +50. Armas, Armadura superior, Guantelete, Zapatos.',                                        N'Si falla, el lapis se rompe.',    1, 50, NULL,NULL,NULL,NULL,NULL,NULL),
(9,  1, 'LAPIS_CRAFT_LV8',        N'Lapis Artesanal Lv8',                 8,  71, N'STR +65. Armas, Cascos, Armadura superior, Armadura inferior, Escudos, Guantelete, Zapatos.',    N'Si falla, el lapis se rompe.',    1, NULL,NULL,65, NULL,NULL,NULL,NULL),
(10, 1, 'LAPIS_SHREWD_LV8',       N'Lapis Astucia Lv8',                   8,  71, N'DEX +65. Armas, Cascos, Armadura superior, Armadura inferior, Escudos, Guantelete, Zapatos.',    N'Si falla, el lapis se rompe.',    1, 65, NULL,NULL,NULL,NULL,NULL,NULL),
(11, 2, 'DUAL_CRAFT_LV6',         N'Lapis Artesanal Dual Lv6',            6,  60, N'STR +30, DEX +25. Armas, Cascos, Armadura, Escudos, Guantelete, Zapatos, Collares.',             N'Si falla, el lapis se rompe.',    1, 25, NULL,30, NULL,NULL,NULL,NULL),
(12, 1, 'SONIC_LV2',              N'Lapis Sonico Lv2',                    2,  40, N'Solo aplicable a Zapatos.',                                                                       N'Si falla, el lapis se rompe.',    1, NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(13, 2, 'DUAL_CRAFT_LV7',         N'Lapis Artesanal Dual Lv7',            7,  65, N'STR +40, DEX +35. Cascos, Armadura superior, Armadura inferior, Guantelete.',                   N'Si falla, el lapis se rompe.',    1, 35, NULL,40, NULL,NULL,NULL,NULL),
(14, 5, 'MECHANIC_1',             N'Lapis Mecanico #1',                   1,  60, N'STR +15, DEX +15, REC +15, INT +15, WIS +15, LUC +15. Anillos, Collares, Brazaletes.',          N'Si falla, el lapis se rompe.',    1, 15, 15,  15, 15,  NULL,15,  15),
(15, 5, 'MECHANIC_2',             N'Lapis Mecanico #2',                   2,  65, N'STR +25, DEX +25, REC +25, INT +25, WIS +25, LUC +25. Anillos, Collares, Brazaletes.',          N'Si falla, el lapis se rompe.',    1, 25, 25,  25, 25,  NULL,25,  25),
(16, 5, 'MECHANIC_3',             N'Lapis Mecanico #3',                   3,  70, N'STR +35, DEX +35, REC +35, INT +35, WIS +35, LUC +35. Anillos, Collares, Brazaletes.',          N'Si falla, el lapis se rompe.',    1, 35, 35,  35, 35,  NULL,35,  35),
(17, 5, 'MECHANIC_4',             N'Lapis Mecanico #4',                   4,  75, N'STR +45, DEX +45, REC +45, INT +45, WIS +45, LUC +45. Solo Anillos.',                           N'Si falla, el lapis se rompe.',    1, 45, 45,  45, 45,  NULL,45,  45),
(18, 2, 'DUAL_FORTUNE_LV6',       N'Lapis Fortuna Dual Lv6',              6,  60, N'DEX +25, LUC +30. Armas, Cascos, Armadura, Escudos, Guantelete, Zapatos, Collares.',             N'Si falla, el lapis se rompe.',    1, 25, 30,  NULL,NULL,NULL,NULL,NULL),
(19, 1, 'PURE_LAPIS',             N'Lapis Puro',                          1,  60, N'STR +15, DEX +15, REC +15, INT +15, WIS +15, LUC +15. Cascos, Brazaletes.',                     N'Si falla, el lapis se rompe.',    1, 15, 15,  15, 15,  NULL,15,  15),
(20, 1, 'MAX_FLASH_LAPIS',        N'Lapis Max Flash',                     10, 75, N'Solo aplicable a Armas.',                                                                         N'Puede romper el equipo si falla.',1, NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(21, 2, 'CHAOTIC_LAPIS',          N'Lapis Caotico',                       10, 75, N'STR +45, DEX +45. Solo aplicable a Armas.',                                                       N'Puede romper el equipo si falla.',1, 45, NULL,45, NULL,NULL,NULL,NULL);
SET IDENTITY_INSERT [catalog].[Lapis] OFF;
GO

-- 4. Reemplazar LapisApplicableItemType completo con datos reales
DELETE FROM [catalog].[LapisApplicableItemType];
GO

SET IDENTITY_INSERT [catalog].[LapisApplicableItemType] ON;
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId],[LapisId],[ItemTypeId]) VALUES
-- Craft Lapis Lv9 (1): Weapons(6), Helmets(1), Lower Armor(3), Shields(7), Gauntlet(4)
(1,1,6),(2,1,1),(3,1,3),(4,1,7),(5,1,4),
-- Fortune Lapis Lv9 (2): Weapons(6), Helmets(1), Lower Armor(3), Shields(7), Gauntlet(4)
(6,2,6),(7,2,1),(8,2,3),(9,2,7),(10,2,4),
-- Lv8 Fortune Lapis (3): Weapons(6), Helmets(1), Upper(2), Lower(3), Shields(7), Gauntlet(4), Shoes(5)
(11,3,6),(12,3,1),(13,3,2),(14,3,3),(15,3,7),(16,3,4),(17,3,5),
-- Ultimate Triple Fortune (4): Helmets(1), Upper(2), Lower(3), Gauntlet(4)
(18,4,1),(19,4,2),(20,4,3),(21,4,4),
-- Ultimate Triple Shrewd (5): Helmets(1), Upper(2), Lower(3), Gauntlet(4)
(22,5,1),(23,5,2),(24,5,3),(25,5,4),
-- Dual Fortune Lv7 (6): Helmets(1), Upper(2), Lower(3), Gauntlet(4)
(26,6,1),(27,6,2),(28,6,3),(29,6,4),
-- Ultimate Triple Craft (7): Helmets(1), Upper(2), Lower(3), Gauntlet(4)
(30,7,1),(31,7,2),(32,7,3),(33,7,4),
-- Shrewd Lv7 (8): Weapons(6), Upper(2), Gauntlet(4), Shoes(5)
(34,8,6),(35,8,2),(36,8,4),(37,8,5),
-- Lv8 Craft Lapis (9): Weapons(6), Helmets(1), Upper(2), Lower(3), Shields(7), Gauntlet(4), Shoes(5)
(38,9,6),(39,9,1),(40,9,2),(41,9,3),(42,9,7),(43,9,4),(44,9,5),
-- Lv8 Shrewd Lapis (10): Weapons(6), Helmets(1), Upper(2), Lower(3), Shields(7), Gauntlet(4), Shoes(5)
(45,10,6),(46,10,1),(47,10,2),(48,10,3),(49,10,7),(50,10,4),(51,10,5),
-- Dual Craft Lv6 (11): Weapons(6), Helmets(1), Upper(2), Lower(3), Shields(7), Gauntlet(4), Shoes(5), Necklaces(11)
(52,11,6),(53,11,1),(54,11,2),(55,11,3),(56,11,7),(57,11,4),(58,11,5),(59,11,11),
-- Sonic Lv2 (12): Shoes(5)
(60,12,5),
-- Dual Craft Lv7 (13): Helmets(1), Upper(2), Lower(3), Gauntlet(4)
(61,13,1),(62,13,2),(63,13,3),(64,13,4),
-- Mechanic #1 (14): Rings(12), Necklaces(11), Bracelets(13)
(65,14,12),(66,14,11),(67,14,13),
-- Mechanic #2 (15): Rings(12), Necklaces(11), Bracelets(13)
(68,15,12),(69,15,11),(70,15,13),
-- Mechanic #3 (16): Rings(12), Necklaces(11), Bracelets(13)
(71,16,12),(72,16,11),(73,16,13),
-- Mechanic #4 (17): Rings(12) only
(74,17,12),
-- Dual Fortune Lv6 (18): Weapons(6), Helmets(1), Upper(2), Lower(3), Shields(7), Gauntlet(4), Shoes(5), Necklaces(11)
(75,18,6),(76,18,1),(77,18,2),(78,18,3),(79,18,7),(80,18,4),(81,18,5),(82,18,11),
-- Pure Lapis (19): Helmets(1), Bracelets(13)
(83,19,1),(84,19,13),
-- Max Flash Lapis (20): Weapons(6)
(85,20,6),
-- Chaotic Lapis (21): Weapons(6)
(86,21,6);
SET IDENTITY_INSERT [catalog].[LapisApplicableItemType] OFF;
GO
