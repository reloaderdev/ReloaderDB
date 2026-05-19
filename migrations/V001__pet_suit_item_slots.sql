-- V001: Define tipos PET/SUIT, agrega DefaultMaxSockets por tipo

-- 1. Agregar columna DefaultMaxSockets a catalog.ItemType
ALTER TABLE [catalog].[ItemType]
ADD [DefaultMaxSockets] int NOT NULL DEFAULT (0);
GO

-- 2. Renombrar ItemType 8: QUIVER/Carcaj → PET/Mascota
UPDATE [catalog].[ItemType]
SET [ItemTypeCode] = 'PET',
    [ItemTypeName] = 'Mascota'
WHERE [ItemTypeId] = 8;
GO

-- 3. Renombrar item demo de Carcaj a Mascota (ItemId=5, ItemTypeId=8)
UPDATE [catalog].[Item]
SET [ItemCode]     = 'ITEM_MASCOTA_DEMO',
    [ItemName]     = 'Mascota Demo',
    [Description]  = 'Mascota demo para ambiente local.',
    [FlavorText]   = 'Una mascota de prueba.'
WHERE [ItemId] = 5;
GO

-- 4. Agregar ItemType 14: SUIT/Traje
SET IDENTITY_INSERT [catalog].[ItemType] ON;
INSERT INTO [catalog].[ItemType] ([ItemTypeId], [ItemTypeCode], [ItemTypeName], [IsEquippable], [DefaultMaxSockets], [IsActive])
VALUES (14, 'SUIT', 'Traje', 1, 0, 1);
SET IDENTITY_INSERT [catalog].[ItemType] OFF;
GO

-- 5. Agregar EquipmentSlot 16: SUIT/Traje
SET IDENTITY_INSERT [catalog].[EquipmentSlot] ON;
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive])
VALUES (16, 'SUIT', 'Traje', 14, 16, 1);
SET IDENTITY_INSERT [catalog].[EquipmentSlot] OFF;
GO

-- 6. Agregar ItemTypeSlot para SUIT
SET IDENTITY_INSERT [catalog].[ItemTypeSlot] ON;
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId])
VALUES (16, 14, 16);
SET IDENTITY_INSERT [catalog].[ItemTypeSlot] OFF;
GO

-- 7. Definir DefaultMaxSockets por tipo
-- Armaduras de piezas: 6
UPDATE [catalog].[ItemType] SET [DefaultMaxSockets] = 6  WHERE [ItemTypeId] = 1;  -- HELMET
UPDATE [catalog].[ItemType] SET [DefaultMaxSockets] = 6  WHERE [ItemTypeId] = 2;  -- TOP
UPDATE [catalog].[ItemType] SET [DefaultMaxSockets] = 6  WHERE [ItemTypeId] = 3;  -- PANTS
UPDATE [catalog].[ItemType] SET [DefaultMaxSockets] = 6  WHERE [ItemTypeId] = 4;  -- GLOVES
UPDATE [catalog].[ItemType] SET [DefaultMaxSockets] = 6  WHERE [ItemTypeId] = 5;  -- BOOTS
UPDATE [catalog].[ItemType] SET [DefaultMaxSockets] = 6  WHERE [ItemTypeId] = 6;  -- WEAPON
-- Accesorios con slots: 4
UPDATE [catalog].[ItemType] SET [DefaultMaxSockets] = 4  WHERE [ItemTypeId] = 7;  -- SHIELD
UPDATE [catalog].[ItemType] SET [DefaultMaxSockets] = 4  WHERE [ItemTypeId] = 11; -- AMULET
UPDATE [catalog].[ItemType] SET [DefaultMaxSockets] = 4  WHERE [ItemTypeId] = 12; -- RING
UPDATE [catalog].[ItemType] SET [DefaultMaxSockets] = 4  WHERE [ItemTypeId] = 13; -- BRACELET
-- Sin slots: 0
UPDATE [catalog].[ItemType] SET [DefaultMaxSockets] = 0  WHERE [ItemTypeId] = 8;  -- PET
UPDATE [catalog].[ItemType] SET [DefaultMaxSockets] = 0  WHERE [ItemTypeId] = 9;  -- CAPE
UPDATE [catalog].[ItemType] SET [DefaultMaxSockets] = 0  WHERE [ItemTypeId] = 10; -- WING
-- SUIT (14) queda en 0 por DEFAULT
GO

-- 8. Sincronizar MaxSockets de items existentes con las reglas del tipo
UPDATE [catalog].[Item] SET [MaxSockets] = 6 WHERE [ItemTypeId] = 5;  -- Botas
UPDATE [catalog].[Item] SET [MaxSockets] = 6 WHERE [ItemTypeId] = 6;  -- Arma
UPDATE [catalog].[Item] SET [MaxSockets] = 4 WHERE [ItemTypeId] = 7;  -- Escudo
UPDATE [catalog].[Item] SET [MaxSockets] = 0 WHERE [ItemTypeId] = 8;  -- Mascota
UPDATE [catalog].[Item] SET [MaxSockets] = 0 WHERE [ItemTypeId] = 9;  -- Capa
UPDATE [catalog].[Item] SET [MaxSockets] = 0 WHERE [ItemTypeId] = 10; -- Alas
UPDATE [catalog].[Item] SET [MaxSockets] = 4 WHERE [ItemTypeId] = 11; -- Amuleto
UPDATE [catalog].[Item] SET [MaxSockets] = 4 WHERE [ItemTypeId] = 12; -- Anillo
UPDATE [catalog].[Item] SET [MaxSockets] = 4 WHERE [ItemTypeId] = 13; -- Brazalete
GO

-- 9. Eliminar sockets del personaje demo para PET (ahora 0 slots)
DELETE FROM [equipment].[EquippedItemLapis]
WHERE [EquippedItemSocketId] IN (
    SELECT [EquippedItemSocketId] FROM [equipment].[EquippedItemSocket]
    WHERE [ItemTypeId] = 8
);
DELETE FROM [equipment].[EquippedItemSocket] WHERE [ItemTypeId] = 8;
GO

-- 10. Eliminar sockets del personaje demo para CAPE (ahora 0 slots)
DELETE FROM [equipment].[EquippedItemLapis]
WHERE [EquippedItemSocketId] IN (
    SELECT [EquippedItemSocketId] FROM [equipment].[EquippedItemSocket]
    WHERE [ItemTypeId] = 9
);
DELETE FROM [equipment].[EquippedItemSocket] WHERE [ItemTypeId] = 9;
GO

-- 11. Completar sockets faltantes en el personaje demo
-- BOOTS (CharacterEquipmentId=4, ItemTypeId=5): tenia 4 → necesita 6
INSERT INTO [equipment].[EquippedItemSocket] ([CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt])
VALUES (4, 5, 5, 1, SYSUTCDATETIME()),
       (4, 5, 6, 1, SYSUTCDATETIME());

-- WEAPON (CharacterEquipmentId=10, ItemTypeId=6): tenia 5 → necesita 6
INSERT INTO [equipment].[EquippedItemSocket] ([CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt])
VALUES (10, 6, 6, 1, SYSUTCDATETIME());

-- AMULET (CharacterEquipmentId=7, ItemTypeId=11): tenia 3 → necesita 4
INSERT INTO [equipment].[EquippedItemSocket] ([CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt])
VALUES (7, 11, 4, 1, SYSUTCDATETIME());

-- RING (CharacterEquipmentId=8, ItemTypeId=12): tenia 3 → necesita 4
INSERT INTO [equipment].[EquippedItemSocket] ([CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt])
VALUES (8, 12, 4, 1, SYSUTCDATETIME());

-- BRACELET (CharacterEquipmentId=9, ItemTypeId=13): tenia 3 → necesita 4
INSERT INTO [equipment].[EquippedItemSocket] ([CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt])
VALUES (9, 13, 4, 1, SYSUTCDATETIME());
GO
