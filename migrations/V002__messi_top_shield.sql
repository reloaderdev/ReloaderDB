-- V002: Agrega items demo TOP y SHIELD, los equipa en Messi (CharacterId=1)

-- 1. Items demo para TOP y SHIELD
SET IDENTITY_INSERT [catalog].[Item] ON;
INSERT INTO [catalog].[Item] ([ItemId], [ItemTypeId], [BindTypeId], [ItemCode], [ItemName], [RequiredLevel], [Description], [FlavorText], [MaxSockets], [CanDye], [IsActive], [CreatedAt])
VALUES
(11, 2, 3, 'ITEM_TIRANO_RADIANTE_TOP_20',    'Armadura Tirano Radiante [20]', 80, 'Armadura superior demo.', 'El torso del cazador, blindado contra cualquier amenaza.', 6, 0, 1, SYSUTCDATETIME()),
(12, 7, 3, 'ITEM_ESCUDO_TIRANO_RADIANTE_20', 'Escudo Tirano Radiante [20]',   80, 'Escudo demo.',            'Un escudo que ha resistido mil emboscadas.',              4, 0, 1, SYSUTCDATETIME());
SET IDENTITY_INSERT [catalog].[Item] OFF;
GO

-- 2. Equipar en Messi (CharacterId=1)
SET IDENTITY_INSERT [equipment].[CharacterEquipment] ON;
INSERT INTO [equipment].[CharacterEquipment] ([CharacterEquipmentId], [CharacterId], [EquipmentSlotId], [ItemId], [ItemTypeId], [DisplayNameOverride], [DescriptionOverride], [EquippedAt], [UpdatedAt])
VALUES
(11, 1, 2, 11, 2, NULL, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),  -- TOP
(12, 1, 7, 12, 7, NULL, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());  -- SHIELD
SET IDENTITY_INSERT [equipment].[CharacterEquipment] OFF;
GO

-- 3. Crear sockets: TOP=6, SHIELD=4 (todos abiertos)
INSERT INTO [equipment].[EquippedItemSocket] ([CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt])
VALUES
(11, 2, 1, 1, SYSUTCDATETIME()),
(11, 2, 2, 1, SYSUTCDATETIME()),
(11, 2, 3, 1, SYSUTCDATETIME()),
(11, 2, 4, 1, SYSUTCDATETIME()),
(11, 2, 5, 1, SYSUTCDATETIME()),
(11, 2, 6, 1, SYSUTCDATETIME()),
(12, 7, 1, 1, SYSUTCDATETIME()),
(12, 7, 2, 1, SYSUTCDATETIME()),
(12, 7, 3, 1, SYSUTCDATETIME()),
(12, 7, 4, 1, SYSUTCDATETIME());
GO
