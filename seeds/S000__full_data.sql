-- ============================================================
-- S000__full_data.sql
-- Data completa exportada desde Azure SQL (reloader-games-db)
-- Generado: 2026-04-18
-- Ejecutar DESPUES de V000__baseline.sql
-- ============================================================

-- auth.Role
SET IDENTITY_INSERT [auth].[Role] ON;
GO
INSERT INTO [auth].[Role] ([RoleId], [RoleCode], [RoleName], [Description], [IsActive]) VALUES (1,'ADMIN','Administrador','Rol con privilegios de administracion del sistema',1);
INSERT INTO [auth].[Role] ([RoleId], [RoleCode], [RoleName], [Description], [IsActive]) VALUES (2,'PLAYER','Jugador','Rol base para usuarios que administran sus personajes',1);
SET IDENTITY_INSERT [auth].[Role] OFF;
GO

-- auth.Users
SET IDENTITY_INSERT [auth].[Users] ON;
GO
INSERT INTO [auth].[Users] ([UserId], [Username], [Email], [PasswordHash], [Salt], [IsActive], [FailedAttempts], [LastLoginAt], [CreatedAt], [UpdatedAt]) VALUES (1,'messi','messi@reloader.dev',CONVERT(varbinary(MAX),'0x8416535DE6ADDBBEE565CD754F6945439D0DB3897422875E206E146FB4D869D7',1),CONVERT(varbinary(MAX),'0x4359B1BC5FE0037993F30A5F62CF988C6F3120F3BC7608149AC74780A2FBB81F',1),1,0,'2026-04-10 04:45:41.514','2026-04-03 23:08:27.655','2026-04-10 04:45:41.514');
INSERT INTO [auth].[Users] ([UserId], [Username], [Email], [PasswordHash], [Salt], [IsActive], [FailedAttempts], [LastLoginAt], [CreatedAt], [UpdatedAt]) VALUES (2,'dibu','dibu@reloader.dev',CONVERT(varbinary(MAX),'0x99B9C569DA5A0C311097868158E5FC1AB181BD187AFBDBB8A4A342A501AB072D',1),CONVERT(varbinary(MAX),'0xFD1ED1BE7D9DA28F9EB929D7858E44B1490B75B8872050DE2BDBD159EFEABFED',1),1,0,NULL,'2026-04-03 23:08:27.660','2026-04-03 23:08:27.660');
INSERT INTO [auth].[Users] ([UserId], [Username], [Email], [PasswordHash], [Salt], [IsActive], [FailedAttempts], [LastLoginAt], [CreatedAt], [UpdatedAt]) VALUES (3,'romero','romero@reloader.dev',CONVERT(varbinary(MAX),'0x07865F15C38B023DAEB602CB91A71E5B0EBACF3EAC4A348ED72911A44ED7DEA0',1),CONVERT(varbinary(MAX),'0x9C222487C5852DAB0197A7F81717D9C781E763134F3D61460F00051B2A6DE182',1),1,0,'2026-04-04 03:48:59.728','2026-04-03 23:08:27.662','2026-04-04 03:48:59.728');
INSERT INTO [auth].[Users] ([UserId], [Username], [Email], [PasswordHash], [Salt], [IsActive], [FailedAttempts], [LastLoginAt], [CreatedAt], [UpdatedAt]) VALUES (4,'otamendi','otamendi@reloader.dev',CONVERT(varbinary(MAX),'0x1A5179D4BB10D494F3973083DD061515414919BE3A29BEA5EC0E71A133AA6CA2',1),CONVERT(varbinary(MAX),'0x55C2C2D8D0C6C9360A6E334A79F4C6E78018028F538FEAABF45EBE44782B1323',1),1,0,'2026-04-09 19:07:26.766','2026-04-03 23:08:27.666','2026-04-09 19:07:26.766');
INSERT INTO [auth].[Users] ([UserId], [Username], [Email], [PasswordHash], [Salt], [IsActive], [FailedAttempts], [LastLoginAt], [CreatedAt], [UpdatedAt]) VALUES (5,'molina','molina@reloader.dev',CONVERT(varbinary(MAX),'0x6D379070DDF4792A09B9E598B955D7D873595080ADE0ECEAD5720D9C507DCC47',1),CONVERT(varbinary(MAX),'0xFCA45C67772B596F508C5BA5A7AA8B05B6B0531172AB7D00058BFEB2CC3987DD',1),1,0,NULL,'2026-04-03 23:08:27.668','2026-04-03 23:08:27.668');
INSERT INTO [auth].[Users] ([UserId], [Username], [Email], [PasswordHash], [Salt], [IsActive], [FailedAttempts], [LastLoginAt], [CreatedAt], [UpdatedAt]) VALUES (6,'depaul','depaul@reloader.dev',CONVERT(varbinary(MAX),'0x2A3C1E869233B249CA7566C5BA45067ED2FE6E31E9F2FD35F2CC972768D943E7',1),CONVERT(varbinary(MAX),'0x23F7C11D375FB0828C3EBABAF07262603BE8EC33077744774A09D8332A3CF0A6',1),1,0,NULL,'2026-04-03 23:08:27.672','2026-04-03 23:08:27.672');
INSERT INTO [auth].[Users] ([UserId], [Username], [Email], [PasswordHash], [Salt], [IsActive], [FailedAttempts], [LastLoginAt], [CreatedAt], [UpdatedAt]) VALUES (7,'macallister','macallister@reloader.dev',CONVERT(varbinary(MAX),'0xAD3ED9E808EEB0AD3416CCF3EEEC78AF8E40A9430933168922B0087A248FE267',1),CONVERT(varbinary(MAX),'0x0A7D548C9F01461F7BE73203CE16980CE75A6167B2595EC938444F8FDC20FAD5',1),1,0,NULL,'2026-04-03 23:08:27.675','2026-04-03 23:08:27.675');
INSERT INTO [auth].[Users] ([UserId], [Username], [Email], [PasswordHash], [Salt], [IsActive], [FailedAttempts], [LastLoginAt], [CreatedAt], [UpdatedAt]) VALUES (8,'julian','julian@reloader.dev',CONVERT(varbinary(MAX),'0xBF8E60071F72F55F43042255FDB7AC0B225A99C89245042EDB3139749610F4FA',1),CONVERT(varbinary(MAX),'0xA3E5D7EB40AA2320AEF2BA1056E9E2FB819D16CA797219F21458514BB2C23D1D',1),1,0,NULL,'2026-04-03 23:08:27.678','2026-04-03 23:08:27.678');
SET IDENTITY_INSERT [auth].[Users] OFF;
GO

-- core.Faction
SET IDENTITY_INSERT [core].[Faction] ON;
GO
INSERT INTO [core].[Faction] ([FactionId], [FactionCode], [FactionName]) VALUES (1,'LUZ','Luz');
INSERT INTO [core].[Faction] ([FactionId], [FactionCode], [FactionName]) VALUES (2,'FURIA','Furia');
SET IDENTITY_INSERT [core].[Faction] OFF;
GO

-- catalog.LapisType
SET IDENTITY_INSERT [catalog].[LapisType] ON;
GO
INSERT INTO [catalog].[LapisType] ([LapisTypeId], [LapisTypeCode], [LapisTypeName]) VALUES (1,'SINGLE','Single');
INSERT INTO [catalog].[LapisType] ([LapisTypeId], [LapisTypeCode], [LapisTypeName]) VALUES (2,'DUAL','Dual');
INSERT INTO [catalog].[LapisType] ([LapisTypeId], [LapisTypeCode], [LapisTypeName]) VALUES (3,'TRIPLE','Triple');
INSERT INTO [catalog].[LapisType] ([LapisTypeId], [LapisTypeCode], [LapisTypeName]) VALUES (4,'ULTIMATE','Ultimate');
SET IDENTITY_INSERT [catalog].[LapisType] OFF;
GO

-- catalog.StatType
SET IDENTITY_INSERT [catalog].[StatType] ON;
GO
INSERT INTO [catalog].[StatType] ([StatTypeId], [StatCode], [StatName], [ValueType], [IsPrimary], [IsDerived], [IsActive]) VALUES (1,'STR','Strength','INTEGER',1,0,1);
INSERT INTO [catalog].[StatType] ([StatTypeId], [StatCode], [StatName], [ValueType], [IsPrimary], [IsDerived], [IsActive]) VALUES (2,'DEX','Dexterity','INTEGER',1,0,1);
INSERT INTO [catalog].[StatType] ([StatTypeId], [StatCode], [StatName], [ValueType], [IsPrimary], [IsDerived], [IsActive]) VALUES (3,'REC','Rec','INTEGER',1,0,1);
INSERT INTO [catalog].[StatType] ([StatTypeId], [StatCode], [StatName], [ValueType], [IsPrimary], [IsDerived], [IsActive]) VALUES (4,'INT','Intelligence','INTEGER',1,0,1);
INSERT INTO [catalog].[StatType] ([StatTypeId], [StatCode], [StatName], [ValueType], [IsPrimary], [IsDerived], [IsActive]) VALUES (5,'WIS','Wisdom','INTEGER',1,0,1);
INSERT INTO [catalog].[StatType] ([StatTypeId], [StatCode], [StatName], [ValueType], [IsPrimary], [IsDerived], [IsActive]) VALUES (6,'LUC','Luck','INTEGER',1,0,1);
INSERT INTO [catalog].[StatType] ([StatTypeId], [StatCode], [StatName], [ValueType], [IsPrimary], [IsDerived], [IsActive]) VALUES (7,'HP','Hit Points','INTEGER',0,1,1);
INSERT INTO [catalog].[StatType] ([StatTypeId], [StatCode], [StatName], [ValueType], [IsPrimary], [IsDerived], [IsActive]) VALUES (8,'MP','Mana Points','INTEGER',0,1,1);
INSERT INTO [catalog].[StatType] ([StatTypeId], [StatCode], [StatName], [ValueType], [IsPrimary], [IsDerived], [IsActive]) VALUES (9,'SP','Stamina Points','INTEGER',0,1,1);
INSERT INTO [catalog].[StatType] ([StatTypeId], [StatCode], [StatName], [ValueType], [IsPrimary], [IsDerived], [IsActive]) VALUES (10,'ATK','Attack','INTEGER',0,1,1);
INSERT INTO [catalog].[StatType] ([StatTypeId], [StatCode], [StatName], [ValueType], [IsPrimary], [IsDerived], [IsActive]) VALUES (11,'DEF','Defense','INTEGER',0,1,1);
INSERT INTO [catalog].[StatType] ([StatTypeId], [StatCode], [StatName], [ValueType], [IsPrimary], [IsDerived], [IsActive]) VALUES (12,'RES','Resistance','INTEGER',0,1,1);
INSERT INTO [catalog].[StatType] ([StatTypeId], [StatCode], [StatName], [ValueType], [IsPrimary], [IsDerived], [IsActive]) VALUES (13,'CRIT_DMG','Critical Damage','PERCENT',0,1,1);
INSERT INTO [catalog].[StatType] ([StatTypeId], [StatCode], [StatName], [ValueType], [IsPrimary], [IsDerived], [IsActive]) VALUES (14,'MOVE_SPEED','Movement Speed','INTEGER',0,1,1);
INSERT INTO [catalog].[StatType] ([StatTypeId], [StatCode], [StatName], [ValueType], [IsPrimary], [IsDerived], [IsActive]) VALUES (15,'ATTACK_SPEED','Attack Speed','INTEGER',0,1,1);
SET IDENTITY_INSERT [catalog].[StatType] OFF;
GO

-- catalog.BindType
SET IDENTITY_INSERT [catalog].[BindType] ON;
GO
INSERT INTO [catalog].[BindType] ([BindTypeId], [BindTypeCode], [BindTypeName]) VALUES (1,'NONE','Sin vinculacion');
INSERT INTO [catalog].[BindType] ([BindTypeId], [BindTypeCode], [BindTypeName]) VALUES (2,'BOUND','Vinculado');
INSERT INTO [catalog].[BindType] ([BindTypeId], [BindTypeCode], [BindTypeName]) VALUES (3,'CHARACTER_BOUND','Vinculado al personaje');
SET IDENTITY_INSERT [catalog].[BindType] OFF;
GO

-- catalog.ItemType
SET IDENTITY_INSERT [catalog].[ItemType] ON;
GO
INSERT INTO [catalog].[ItemType] ([ItemTypeId], [ItemTypeCode], [ItemTypeName], [IsEquippable], [IsActive]) VALUES (1,'HELMET','Casco',1,1);
INSERT INTO [catalog].[ItemType] ([ItemTypeId], [ItemTypeCode], [ItemTypeName], [IsEquippable], [IsActive]) VALUES (2,'TOP','Armadura superior',1,1);
INSERT INTO [catalog].[ItemType] ([ItemTypeId], [ItemTypeCode], [ItemTypeName], [IsEquippable], [IsActive]) VALUES (3,'PANTS','Armadura parte inferior',1,1);
INSERT INTO [catalog].[ItemType] ([ItemTypeId], [ItemTypeCode], [ItemTypeName], [IsEquippable], [IsActive]) VALUES (4,'GLOVES','Guantes',1,1);
INSERT INTO [catalog].[ItemType] ([ItemTypeId], [ItemTypeCode], [ItemTypeName], [IsEquippable], [IsActive]) VALUES (5,'BOOTS','Botas',1,1);
INSERT INTO [catalog].[ItemType] ([ItemTypeId], [ItemTypeCode], [ItemTypeName], [IsEquippable], [IsActive]) VALUES (6,'WEAPON','Arma',1,1);
INSERT INTO [catalog].[ItemType] ([ItemTypeId], [ItemTypeCode], [ItemTypeName], [IsEquippable], [IsActive]) VALUES (7,'SHIELD','Escudo',1,1);
INSERT INTO [catalog].[ItemType] ([ItemTypeId], [ItemTypeCode], [ItemTypeName], [IsEquippable], [IsActive]) VALUES (8,'QUIVER','Carcaj',1,1);
INSERT INTO [catalog].[ItemType] ([ItemTypeId], [ItemTypeCode], [ItemTypeName], [IsEquippable], [IsActive]) VALUES (9,'CAPE','Manto',1,1);
INSERT INTO [catalog].[ItemType] ([ItemTypeId], [ItemTypeCode], [ItemTypeName], [IsEquippable], [IsActive]) VALUES (10,'WING','Alas',1,1);
INSERT INTO [catalog].[ItemType] ([ItemTypeId], [ItemTypeCode], [ItemTypeName], [IsEquippable], [IsActive]) VALUES (11,'AMULET','Amuleto',1,1);
INSERT INTO [catalog].[ItemType] ([ItemTypeId], [ItemTypeCode], [ItemTypeName], [IsEquippable], [IsActive]) VALUES (12,'RING','Anillo',1,1);
INSERT INTO [catalog].[ItemType] ([ItemTypeId], [ItemTypeCode], [ItemTypeName], [IsEquippable], [IsActive]) VALUES (13,'BRACELET','Brazalete',1,1);
SET IDENTITY_INSERT [catalog].[ItemType] OFF;
GO

-- core.GuildRank
SET IDENTITY_INSERT [core].[GuildRank] ON;
GO
INSERT INTO [core].[GuildRank] ([GuildRankId], [RankCode], [RankName], [SortOrder], [IsActive]) VALUES (1,'R1','Rango 1',1,1);
INSERT INTO [core].[GuildRank] ([GuildRankId], [RankCode], [RankName], [SortOrder], [IsActive]) VALUES (2,'R2','Rango 2',2,1);
INSERT INTO [core].[GuildRank] ([GuildRankId], [RankCode], [RankName], [SortOrder], [IsActive]) VALUES (3,'R3','Rango 3',3,1);
INSERT INTO [core].[GuildRank] ([GuildRankId], [RankCode], [RankName], [SortOrder], [IsActive]) VALUES (4,'R4','Rango 4',4,1);
INSERT INTO [core].[GuildRank] ([GuildRankId], [RankCode], [RankName], [SortOrder], [IsActive]) VALUES (5,'R5','Rango 5',5,1);
INSERT INTO [core].[GuildRank] ([GuildRankId], [RankCode], [RankName], [SortOrder], [IsActive]) VALUES (6,'R6','Rango 6',6,1);
INSERT INTO [core].[GuildRank] ([GuildRankId], [RankCode], [RankName], [SortOrder], [IsActive]) VALUES (7,'R7','Rango 7',7,1);
SET IDENTITY_INSERT [core].[GuildRank] OFF;
GO

-- auth.UserProfile
SET IDENTITY_INSERT [auth].[UserProfile] ON;
GO
INSERT INTO [auth].[UserProfile] ([UserProfileId], [UserId], [DisplayName], [CountryCode], [TimeZone], [CreatedAt], [UpdatedAt]) VALUES (1,1,'Lionel Messi','AR','America/Argentina/Buenos_Aires','2026-04-03 23:08:27.656','2026-04-03 23:08:27.656');
INSERT INTO [auth].[UserProfile] ([UserProfileId], [UserId], [DisplayName], [CountryCode], [TimeZone], [CreatedAt], [UpdatedAt]) VALUES (2,2,'Emiliano Martinez','AR','America/Argentina/Buenos_Aires','2026-04-03 23:08:27.660','2026-04-03 23:08:27.660');
INSERT INTO [auth].[UserProfile] ([UserProfileId], [UserId], [DisplayName], [CountryCode], [TimeZone], [CreatedAt], [UpdatedAt]) VALUES (3,3,'Cristian Romero','AR','America/Argentina/Buenos_Aires','2026-04-03 23:08:27.662','2026-04-03 23:08:27.662');
INSERT INTO [auth].[UserProfile] ([UserProfileId], [UserId], [DisplayName], [CountryCode], [TimeZone], [CreatedAt], [UpdatedAt]) VALUES (4,4,'Nicolas Otamendi','AR','America/Argentina/Buenos_Aires','2026-04-03 23:08:27.666','2026-04-03 23:08:27.666');
INSERT INTO [auth].[UserProfile] ([UserProfileId], [UserId], [DisplayName], [CountryCode], [TimeZone], [CreatedAt], [UpdatedAt]) VALUES (5,5,'Nahuel Molina','AR','America/Argentina/Buenos_Aires','2026-04-03 23:08:27.668','2026-04-03 23:08:27.668');
INSERT INTO [auth].[UserProfile] ([UserProfileId], [UserId], [DisplayName], [CountryCode], [TimeZone], [CreatedAt], [UpdatedAt]) VALUES (6,6,'Rodrigo De Paul','AR','America/Argentina/Buenos_Aires','2026-04-03 23:08:27.672','2026-04-03 23:08:27.672');
INSERT INTO [auth].[UserProfile] ([UserProfileId], [UserId], [DisplayName], [CountryCode], [TimeZone], [CreatedAt], [UpdatedAt]) VALUES (7,7,'Alexis Mac Allister','AR','America/Argentina/Buenos_Aires','2026-04-03 23:08:27.675','2026-04-03 23:08:27.675');
INSERT INTO [auth].[UserProfile] ([UserProfileId], [UserId], [DisplayName], [CountryCode], [TimeZone], [CreatedAt], [UpdatedAt]) VALUES (8,8,'Julian Alvarez','AR','America/Argentina/Buenos_Aires','2026-04-03 23:08:27.679','2026-04-03 23:08:27.679');
SET IDENTITY_INSERT [auth].[UserProfile] OFF;
GO

-- auth.UserRole
SET IDENTITY_INSERT [auth].[UserRole] ON;
GO
INSERT INTO [auth].[UserRole] ([UserRoleId], [UserId], [RoleId], [AssignedAt], [IsActive]) VALUES (1,1,2,'2026-04-03 23:08:27.656',1);
INSERT INTO [auth].[UserRole] ([UserRoleId], [UserId], [RoleId], [AssignedAt], [IsActive]) VALUES (2,2,2,'2026-04-03 23:08:27.660',1);
INSERT INTO [auth].[UserRole] ([UserRoleId], [UserId], [RoleId], [AssignedAt], [IsActive]) VALUES (3,3,2,'2026-04-03 23:08:27.662',1);
INSERT INTO [auth].[UserRole] ([UserRoleId], [UserId], [RoleId], [AssignedAt], [IsActive]) VALUES (4,4,2,'2026-04-03 23:08:27.666',1);
INSERT INTO [auth].[UserRole] ([UserRoleId], [UserId], [RoleId], [AssignedAt], [IsActive]) VALUES (5,5,2,'2026-04-03 23:08:27.668',1);
INSERT INTO [auth].[UserRole] ([UserRoleId], [UserId], [RoleId], [AssignedAt], [IsActive]) VALUES (6,6,2,'2026-04-03 23:08:27.672',1);
INSERT INTO [auth].[UserRole] ([UserRoleId], [UserId], [RoleId], [AssignedAt], [IsActive]) VALUES (7,7,2,'2026-04-03 23:08:27.675',1);
INSERT INTO [auth].[UserRole] ([UserRoleId], [UserId], [RoleId], [AssignedAt], [IsActive]) VALUES (8,8,2,'2026-04-03 23:08:27.679',1);
SET IDENTITY_INSERT [auth].[UserRole] OFF;
GO

-- core.Class
SET IDENTITY_INSERT [core].[Class] ON;
GO
INSERT INTO [core].[Class] ([ClassId], [FactionId], [ClassCode], [ClassName], [IsActive]) VALUES (1,2,'WARRIOR_FURIA','Guerrero',1);
INSERT INTO [core].[Class] ([ClassId], [FactionId], [ClassCode], [ClassName], [IsActive]) VALUES (2,2,'ASSASSIN_FURIA','Asesino',1);
INSERT INTO [core].[Class] ([ClassId], [FactionId], [ClassCode], [ClassName], [IsActive]) VALUES (3,2,'HUNTER_FURIA','Cazador',1);
INSERT INTO [core].[Class] ([ClassId], [FactionId], [ClassCode], [ClassName], [IsActive]) VALUES (4,2,'PAGAN_FURIA','Pagano',1);
INSERT INTO [core].[Class] ([ClassId], [FactionId], [ClassCode], [ClassName], [IsActive]) VALUES (5,2,'ORACLE_FURIA','Oraculo',1);
SET IDENTITY_INSERT [core].[Class] OFF;
GO

-- core.Guild
SET IDENTITY_INSERT [core].[Guild] ON;
GO
INSERT INTO [core].[Guild] ([GuildId], [FactionId], [GuildName], [IsActive], [CreatedAt]) VALUES (1,2,'Nazgul',1,'2026-04-03 23:25:12.186');
SET IDENTITY_INSERT [core].[Guild] OFF;
GO

-- core.Player
SET IDENTITY_INSERT [core].[Player] ON;
GO
INSERT INTO [core].[Player] ([PlayerId], [UserId], [DisplayName], [IsActive], [CreatedAt]) VALUES (1,1,'Lionel Messi',1,'2026-04-03 23:08:27.656');
INSERT INTO [core].[Player] ([PlayerId], [UserId], [DisplayName], [IsActive], [CreatedAt]) VALUES (2,2,'Emiliano Martinez',1,'2026-04-03 23:08:27.660');
INSERT INTO [core].[Player] ([PlayerId], [UserId], [DisplayName], [IsActive], [CreatedAt]) VALUES (3,3,'Cristian Romero',1,'2026-04-03 23:08:27.662');
INSERT INTO [core].[Player] ([PlayerId], [UserId], [DisplayName], [IsActive], [CreatedAt]) VALUES (4,4,'Nicolas Otamendi',1,'2026-04-03 23:08:27.666');
INSERT INTO [core].[Player] ([PlayerId], [UserId], [DisplayName], [IsActive], [CreatedAt]) VALUES (5,5,'Nahuel Molina',1,'2026-04-03 23:08:27.668');
INSERT INTO [core].[Player] ([PlayerId], [UserId], [DisplayName], [IsActive], [CreatedAt]) VALUES (6,6,'Rodrigo De Paul',1,'2026-04-03 23:08:27.672');
INSERT INTO [core].[Player] ([PlayerId], [UserId], [DisplayName], [IsActive], [CreatedAt]) VALUES (7,7,'Alexis Mac Allister',1,'2026-04-03 23:08:27.675');
INSERT INTO [core].[Player] ([PlayerId], [UserId], [DisplayName], [IsActive], [CreatedAt]) VALUES (8,8,'Julian Alvarez',1,'2026-04-03 23:08:27.679');
SET IDENTITY_INSERT [core].[Player] OFF;
GO

-- catalog.EquipmentSlot
SET IDENTITY_INSERT [catalog].[EquipmentSlot] ON;
GO
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive]) VALUES (1,'HELMET','Casco',1,1,1);
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive]) VALUES (2,'TOP','Armadura superior',2,2,1);
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive]) VALUES (3,'PANTS','Armadura parte inferior',3,3,1);
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive]) VALUES (4,'GLOVES','Guantes',4,4,1);
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive]) VALUES (5,'BOOTS','Botas',5,5,1);
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive]) VALUES (6,'WEAPON','Arma',6,6,1);
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive]) VALUES (7,'SHIELD','Escudo',7,7,1);
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive]) VALUES (8,'PET','Mascota',8,8,1);
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive]) VALUES (9,'CAPE','Manto',9,9,1);
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive]) VALUES (10,'WING','Alas',10,10,1);
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive]) VALUES (11,'AMULET','Amuleto',11,11,1);
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive]) VALUES (12,'RING_LEFT','Anillo izquierdo',12,12,1);
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive]) VALUES (13,'RING_RIGHT','Anillo derecho',12,13,1);
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive]) VALUES (14,'BRACELET_LEFT','Brazalete izquierdo',13,14,1);
INSERT INTO [catalog].[EquipmentSlot] ([EquipmentSlotId], [SlotCode], [SlotName], [ItemTypeId], [SortOrder], [IsActive]) VALUES (15,'BRACELET_RIGHT','Brazalete derecho',13,15,1);
SET IDENTITY_INSERT [catalog].[EquipmentSlot] OFF;
GO

-- catalog.Item
SET IDENTITY_INSERT [catalog].[Item] ON;
GO
INSERT INTO [catalog].[Item] ([ItemId], [ItemTypeId], [BindTypeId], [ItemCode], [ItemName], [RequiredLevel], [Description], [FlavorText], [MaxSockets], [CanDye], [IsActive], [CreatedAt]) VALUES (1,1,3,'ITEM_TIRANO_RADIANTE_HELMET_20','Casco Tirano Radiante [20]',80,'Casco demo basado en captura del juego.','Un cazador no teme a nada; solo al equivocarse con su estilismo.',6,0,1,'2026-04-03 23:25:11.495');
INSERT INTO [catalog].[Item] ([ItemId], [ItemTypeId], [BindTypeId], [ItemCode], [ItemName], [RequiredLevel], [Description], [FlavorText], [MaxSockets], [CanDye], [IsActive], [CreatedAt]) VALUES (2,4,3,'ITEM_TIRANO_RADIANTE_GLOVES_20','Guantes Tirano Radiante [20]',80,'Guantes demo basados en captura del juego.','No pierdas nunca el rastro de tu presa con estos guantes fatales.',6,0,1,'2026-04-03 23:25:11.498');
INSERT INTO [catalog].[Item] ([ItemId], [ItemTypeId], [BindTypeId], [ItemCode], [ItemName], [RequiredLevel], [Description], [FlavorText], [MaxSockets], [CanDye], [IsActive], [CreatedAt]) VALUES (3,3,3,'ITEM_TIRANO_RADIANTE_PANTS_20','Pantalones Tirano Radiante [20]',80,'Pantalones demo basados en captura del juego.','No hay mucho que decir de estos pantalones.',6,0,1,'2026-04-03 23:25:11.500');
INSERT INTO [catalog].[Item] ([ItemId], [ItemTypeId], [BindTypeId], [ItemCode], [ItemName], [RequiredLevel], [Description], [FlavorText], [MaxSockets], [CanDye], [IsActive], [CreatedAt]) VALUES (4,5,3,'ITEM_TIRANO_RADIANTE_BOOTS_20','Botas Tirano Radiante [20]',80,'Botas demo basadas en captura del juego.','Con estas botas de garras, cada presa corre por cuenta propia.',4,0,1,'2026-04-03 23:25:11.504');
INSERT INTO [catalog].[Item] ([ItemId], [ItemTypeId], [BindTypeId], [ItemCode], [ItemName], [RequiredLevel], [Description], [FlavorText], [MaxSockets], [CanDye], [IsActive], [CreatedAt]) VALUES (5,8,3,'ITEM_CARCAJ_VENGANZA_20','Carcaj de Venganza [20]',80,'Carcaj demo basado en captura del juego.','Un carcaj oscuro lleno de flechas que buscan venganza.',5,0,1,'2026-04-03 23:25:11.507');
INSERT INTO [catalog].[Item] ([ItemId], [ItemTypeId], [BindTypeId], [ItemCode], [ItemName], [RequiredLevel], [Description], [FlavorText], [MaxSockets], [CanDye], [IsActive], [CreatedAt]) VALUES (6,9,3,'ITEM_MANTO_MION','Manto Mion',80,'Manto demo basado en captura del juego.','Manto con bonus generales y espiritu de mascota.',0,0,1,'2026-04-03 23:25:11.510');
INSERT INTO [catalog].[Item] ([ItemId], [ItemTypeId], [BindTypeId], [ItemCode], [ItemName], [RequiredLevel], [Description], [FlavorText], [MaxSockets], [CanDye], [IsActive], [CreatedAt]) VALUES (7,11,3,'ITEM_AMULETO_PICA_OSEA','Amuleto de Pica Osea Eterno',80,'Amuleto demo basado en captura del juego.','Amuleto Eterno perfecto, reforzado con poder fisico.',3,0,1,'2026-04-03 23:25:11.513');
INSERT INTO [catalog].[Item] ([ItemId], [ItemTypeId], [BindTypeId], [ItemCode], [ItemName], [RequiredLevel], [Description], [FlavorText], [MaxSockets], [CanDye], [IsActive], [CreatedAt]) VALUES (8,12,3,'ITEM_BANDA_PUAS_OSEAS','Banda de Puas Oseas Eterno',80,'Anillo demo basado en captura del juego.','Anillo Eterno perfecto, reforzado con poder fisico.',3,0,1,'2026-04-03 23:25:11.516');
INSERT INTO [catalog].[Item] ([ItemId], [ItemTypeId], [BindTypeId], [ItemCode], [ItemName], [RequiredLevel], [Description], [FlavorText], [MaxSockets], [CanDye], [IsActive], [CreatedAt]) VALUES (9,13,3,'ITEM_ARGOLLA_PUAS_OSEAS','Argolla de Puas Oseas Eterno',80,'Brazalete demo basado en captura del juego.','Brazalete Eterno perfecto, reforzado con poder fisico.',3,0,1,'2026-04-03 23:25:11.518');
INSERT INTO [catalog].[Item] ([ItemId], [ItemTypeId], [BindTypeId], [ItemCode], [ItemName], [RequiredLevel], [Description], [FlavorText], [MaxSockets], [CanDye], [IsActive], [CreatedAt]) VALUES (10,6,3,'ITEM_EMBERSTONE_JAVELIN_26','Emberstone Annihilation Javelin Tierra [26]',80,'Jabalina demo basada en captura del juego.','Arma de proporciones cataclismicas, vacia del corazon de la furia nociva.',5,0,1,'2026-04-03 23:25:11.521');
SET IDENTITY_INSERT [catalog].[Item] OFF;
GO

-- catalog.Lapis
SET IDENTITY_INSERT [catalog].[Lapis] ON;
GO
INSERT INTO [catalog].[Lapis] ([LapisId], [LapisTypeId], [LapisCode], [LapisName], [LapisLevel], [RequiredLevel], [Description], [RiskNote], [IsActive]) VALUES (1,1,'LAPIS_ARTESANAL_LV9','Lapis Artesanal Lv9',9,75,'Habilidad STR +75. Aplicable a armas, cascos, armadura parte inferior, escudos y guantelete.','Si el enlace o la extraccion fallan, el articulo puede quedar destruido.',1);
INSERT INTO [catalog].[Lapis] ([LapisId], [LapisTypeId], [LapisCode], [LapisName], [LapisLevel], [RequiredLevel], [Description], [RiskNote], [IsActive]) VALUES (2,1,'LAPIS_FORTUNA_LV9','Lapis Fortuna Lv9',9,75,'Habilidad LUC +75. Aplicable a armas, cascos, armadura parte inferior, escudos y guantelete.','Si el enlace o la extraccion fallan, el articulo puede quedar destruido.',1);
INSERT INTO [catalog].[Lapis] ([LapisId], [LapisTypeId], [LapisCode], [LapisName], [LapisLevel], [RequiredLevel], [Description], [RiskNote], [IsActive]) VALUES (3,1,'LAPIS_FORTUNA_LV8','Lapis Fortuna Lv8',8,71,'Habilidad LUC +65. Aplicable a armas, cascos, armadura superior, armadura parte inferior, escudos y zapatos.','Si el enlace falla, este lapis se rompe junto con el articulo al que este vinculado.',1);
INSERT INTO [catalog].[Lapis] ([LapisId], [LapisTypeId], [LapisCode], [LapisName], [LapisLevel], [RequiredLevel], [Description], [RiskNote], [IsActive]) VALUES (4,3,'LAPIS_FORTUNA_TRIPLE_DEF','Lapis Fortuna Triple Definitivo',10,75,'Agrega Max HP +1500, STR +30, LUC +35.','Puede romper el equipo si falla la vinculacion o la extraccion.',1);
INSERT INTO [catalog].[Lapis] ([LapisId], [LapisTypeId], [LapisCode], [LapisName], [LapisLevel], [RequiredLevel], [Description], [RiskNote], [IsActive]) VALUES (5,3,'LAPIS_ASTUCIA_TRIPLE_DEF','Lapis Astucia Triple Definitivo',10,75,'Agrega Max HP +1500, DEX +35, LUC +30.','Puede romper el equipo si falla la vinculacion o la extraccion.',1);
SET IDENTITY_INSERT [catalog].[Lapis] OFF;
GO

-- catalog.LapisEffect
SET IDENTITY_INSERT [catalog].[LapisEffect] ON;
GO
INSERT INTO [catalog].[LapisEffect] ([LapisEffectId], [LapisId], [StatTypeId], [EffectValue]) VALUES (1,1,1,75.00);
INSERT INTO [catalog].[LapisEffect] ([LapisEffectId], [LapisId], [StatTypeId], [EffectValue]) VALUES (2,2,6,75.00);
INSERT INTO [catalog].[LapisEffect] ([LapisEffectId], [LapisId], [StatTypeId], [EffectValue]) VALUES (3,3,6,65.00);
INSERT INTO [catalog].[LapisEffect] ([LapisEffectId], [LapisId], [StatTypeId], [EffectValue]) VALUES (4,4,7,1500.00);
INSERT INTO [catalog].[LapisEffect] ([LapisEffectId], [LapisId], [StatTypeId], [EffectValue]) VALUES (5,4,1,30.00);
INSERT INTO [catalog].[LapisEffect] ([LapisEffectId], [LapisId], [StatTypeId], [EffectValue]) VALUES (6,4,6,35.00);
INSERT INTO [catalog].[LapisEffect] ([LapisEffectId], [LapisId], [StatTypeId], [EffectValue]) VALUES (7,5,7,1500.00);
INSERT INTO [catalog].[LapisEffect] ([LapisEffectId], [LapisId], [StatTypeId], [EffectValue]) VALUES (8,5,2,35.00);
INSERT INTO [catalog].[LapisEffect] ([LapisEffectId], [LapisId], [StatTypeId], [EffectValue]) VALUES (9,5,6,30.00);
SET IDENTITY_INSERT [catalog].[LapisEffect] OFF;
GO

-- catalog.ItemTypeSlot
SET IDENTITY_INSERT [catalog].[ItemTypeSlot] ON;
GO
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId]) VALUES (1,1,1);
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId]) VALUES (2,2,2);
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId]) VALUES (3,3,3);
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId]) VALUES (4,4,4);
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId]) VALUES (5,5,5);
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId]) VALUES (6,6,6);
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId]) VALUES (7,7,7);
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId]) VALUES (8,8,8);
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId]) VALUES (9,9,9);
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId]) VALUES (10,10,10);
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId]) VALUES (11,11,11);
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId]) VALUES (12,12,12);
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId]) VALUES (13,12,13);
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId]) VALUES (14,13,14);
INSERT INTO [catalog].[ItemTypeSlot] ([ItemTypeSlotId], [ItemTypeId], [EquipmentSlotId]) VALUES (15,13,15);
SET IDENTITY_INSERT [catalog].[ItemTypeSlot] OFF;
GO

-- core.Character
SET IDENTITY_INSERT [core].[Character] ON;
GO
INSERT INTO [core].[Character] ([CharacterId], [PlayerId], [FactionId], [ClassId], [CharacterName], [Level], [Title], [Mode], [Element], [IsPrimary], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (1,1,2,3,'NazgulKash',80,'Royal Querubin','MAXIMO','Tierra',1,1,'2026-04-03 23:25:12.305','2026-04-03 23:25:12.305');
INSERT INTO [core].[Character] ([CharacterId], [PlayerId], [FactionId], [ClassId], [CharacterName], [Level], [Title], [Mode], [Element], [IsPrimary], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (2,2,2,1,'DibuWar',80,'Demo Furia','MAXIMO','Tierra',1,1,'2026-04-03 23:25:12.315','2026-04-03 23:25:12.315');
INSERT INTO [core].[Character] ([CharacterId], [PlayerId], [FactionId], [ClassId], [CharacterName], [Level], [Title], [Mode], [Element], [IsPrimary], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (3,3,2,2,'RomeroSin',80,'Demo Furia','MAXIMO','Tierra',1,1,'2026-04-03 23:25:12.317','2026-04-03 23:25:12.317');
INSERT INTO [core].[Character] ([CharacterId], [PlayerId], [FactionId], [ClassId], [CharacterName], [Level], [Title], [Mode], [Element], [IsPrimary], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (4,6,2,4,'DePaulPagan',80,'Demo Furia','MAXIMO','Tierra',1,1,'2026-04-03 23:25:12.322','2026-04-03 23:25:12.322');
INSERT INTO [core].[Character] ([CharacterId], [PlayerId], [FactionId], [ClassId], [CharacterName], [Level], [Title], [Mode], [Element], [IsPrimary], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (5,7,2,5,'MacOracle',80,'Demo Furia','MAXIMO','Tierra',1,1,'2026-04-03 23:25:12.326','2026-04-03 23:25:12.326');
SET IDENTITY_INSERT [core].[Character] OFF;
GO

-- catalog.ItemAllowedClass
SET IDENTITY_INSERT [catalog].[ItemAllowedClass] ON;
GO
INSERT INTO [catalog].[ItemAllowedClass] ([ItemAllowedClassId], [ItemId], [ClassId]) VALUES (10,1,3);
INSERT INTO [catalog].[ItemAllowedClass] ([ItemAllowedClassId], [ItemId], [ClassId]) VALUES (9,2,3);
INSERT INTO [catalog].[ItemAllowedClass] ([ItemAllowedClassId], [ItemId], [ClassId]) VALUES (11,3,3);
INSERT INTO [catalog].[ItemAllowedClass] ([ItemAllowedClassId], [ItemId], [ClassId]) VALUES (8,4,3);
INSERT INTO [catalog].[ItemAllowedClass] ([ItemAllowedClassId], [ItemId], [ClassId]) VALUES (5,5,3);
INSERT INTO [catalog].[ItemAllowedClass] ([ItemAllowedClassId], [ItemId], [ClassId]) VALUES (7,6,3);
INSERT INTO [catalog].[ItemAllowedClass] ([ItemAllowedClassId], [ItemId], [ClassId]) VALUES (2,7,3);
INSERT INTO [catalog].[ItemAllowedClass] ([ItemAllowedClassId], [ItemId], [ClassId]) VALUES (4,8,3);
INSERT INTO [catalog].[ItemAllowedClass] ([ItemAllowedClassId], [ItemId], [ClassId]) VALUES (3,9,3);
INSERT INTO [catalog].[ItemAllowedClass] ([ItemAllowedClassId], [ItemId], [ClassId]) VALUES (6,10,3);
SET IDENTITY_INSERT [catalog].[ItemAllowedClass] OFF;
GO

-- catalog.ItemStat
SET IDENTITY_INSERT [catalog].[ItemStat] ON;
GO
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (1,1,7,6157.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (2,1,7,4400.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (3,1,1,92.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (4,1,1,44.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (5,1,2,122.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (6,1,2,69.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (7,1,3,30.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (8,1,6,239.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (9,1,6,98.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (10,2,7,6301.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (11,2,7,4400.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (12,2,1,283.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (13,2,1,44.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (14,2,2,70.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (15,2,2,69.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (16,2,3,30.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (17,2,6,259.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (18,2,6,98.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (19,3,7,9916.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (20,3,7,4400.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (21,3,1,179.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (22,3,1,44.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (23,3,2,149.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (24,3,2,69.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (25,3,3,30.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (26,3,6,272.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (27,3,6,98.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (28,4,7,3033.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (29,4,7,4400.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (30,4,9,4044.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (31,4,1,95.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (32,4,1,44.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (33,4,2,219.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (34,4,2,69.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (35,4,6,208.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (36,4,6,98.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (37,4,14,1.00,'SPECIAL');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (38,5,1,210.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (39,5,1,58.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (40,5,2,10.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (41,5,6,150.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (42,5,7,2000.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (43,5,9,500.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (44,6,7,1000.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (45,6,7,4000.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (46,6,9,1000.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (47,6,9,1000.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (48,6,2,32.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (49,6,2,65.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (50,6,3,10.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (51,6,6,32.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (52,6,6,40.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (53,6,1,90.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (54,7,1,130.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (55,7,1,90.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (56,7,2,150.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (57,7,2,40.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (58,7,3,100.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (59,7,3,40.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (60,7,4,60.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (61,7,5,90.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (62,7,6,130.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (63,7,6,65.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (64,8,1,160.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (65,8,1,90.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (66,8,2,160.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (67,8,2,40.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (68,8,3,160.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (69,8,3,40.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (70,8,4,20.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (71,8,5,150.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (72,8,6,160.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (73,8,6,65.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (74,9,1,130.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (75,9,1,90.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (76,9,2,130.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (77,9,2,40.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (78,9,3,130.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (79,9,3,40.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (80,9,4,20.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (81,9,5,120.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (82,9,6,130.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (83,9,6,65.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (84,10,10,5561.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (85,10,10,6167.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (86,10,1,185.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (87,10,1,98.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (88,10,2,73.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (89,10,2,50.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (90,10,6,197.00,'BASE');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (91,10,6,75.00,'BONUS');
INSERT INTO [catalog].[ItemStat] ([ItemStatId], [ItemId], [StatTypeId], [StatValue], [ValueSource]) VALUES (92,10,3,50.00,'BASE');
SET IDENTITY_INSERT [catalog].[ItemStat] OFF;
GO

-- catalog.LapisApplicableItemType
SET IDENTITY_INSERT [catalog].[LapisApplicableItemType] ON;
GO
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (2,1,1);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (3,1,3);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (1,1,4);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (5,1,6);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (4,1,7);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (7,2,1);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (8,2,3);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (6,2,4);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (10,2,6);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (9,2,7);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (20,3,1);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (23,3,2);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (21,3,3);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (19,3,5);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (24,3,6);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (22,3,7);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (16,4,1);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (18,4,2);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (17,4,3);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (15,4,4);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (12,5,1);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (14,5,2);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (13,5,3);
INSERT INTO [catalog].[LapisApplicableItemType] ([LapisApplicableItemTypeId], [LapisId], [ItemTypeId]) VALUES (11,5,4);
SET IDENTITY_INSERT [catalog].[LapisApplicableItemType] OFF;
GO

-- core.GuildMember
SET IDENTITY_INSERT [core].[GuildMember] ON;
GO
INSERT INTO [core].[GuildMember] ([GuildMemberId], [GuildId], [CharacterId], [GuildRankId], [JoinDate], [IsActive]) VALUES (1,1,1,1,'2026-04-03 23:25:12.531',1);
INSERT INTO [core].[GuildMember] ([GuildMemberId], [GuildId], [CharacterId], [GuildRankId], [JoinDate], [IsActive]) VALUES (2,1,2,2,'2026-04-03 23:25:12.547',1);
INSERT INTO [core].[GuildMember] ([GuildMemberId], [GuildId], [CharacterId], [GuildRankId], [JoinDate], [IsActive]) VALUES (3,1,3,3,'2026-04-03 23:25:12.551',1);
INSERT INTO [core].[GuildMember] ([GuildMemberId], [GuildId], [CharacterId], [GuildRankId], [JoinDate], [IsActive]) VALUES (4,1,4,4,'2026-04-03 23:25:12.555',1);
INSERT INTO [core].[GuildMember] ([GuildMemberId], [GuildId], [CharacterId], [GuildRankId], [JoinDate], [IsActive]) VALUES (5,1,5,5,'2026-04-03 23:25:12.559',1);
SET IDENTITY_INSERT [core].[GuildMember] OFF;
GO

-- build.CharacterBaseStat
SET IDENTITY_INSERT [build].[CharacterBaseStat] ON;
GO
INSERT INTO [build].[CharacterBaseStat] ([CharacterBaseStatId], [CharacterId], [StatTypeId], [StatValue], [UpdatedAt]) VALUES (1,1,1,13.00,'2026-04-03 23:30:57.003');
INSERT INTO [build].[CharacterBaseStat] ([CharacterBaseStatId], [CharacterId], [StatTypeId], [StatValue], [UpdatedAt]) VALUES (2,1,3,12.00,'2026-04-03 23:30:57.007');
INSERT INTO [build].[CharacterBaseStat] ([CharacterBaseStatId], [CharacterId], [StatTypeId], [StatValue], [UpdatedAt]) VALUES (3,1,4,7.00,'2026-04-03 23:30:57.011');
INSERT INTO [build].[CharacterBaseStat] ([CharacterBaseStatId], [CharacterId], [StatTypeId], [StatValue], [UpdatedAt]) VALUES (4,1,5,10.00,'2026-04-03 23:30:57.014');
INSERT INTO [build].[CharacterBaseStat] ([CharacterBaseStatId], [CharacterId], [StatTypeId], [StatValue], [UpdatedAt]) VALUES (5,1,2,14.00,'2026-04-03 23:30:57.016');
INSERT INTO [build].[CharacterBaseStat] ([CharacterBaseStatId], [CharacterId], [StatTypeId], [StatValue], [UpdatedAt]) VALUES (6,1,6,1759.00,'2026-04-03 23:30:57.019');
SET IDENTITY_INSERT [build].[CharacterBaseStat] OFF;
GO

-- build.CharacterAssignedStat
SET IDENTITY_INSERT [build].[CharacterAssignedStat] ON;
GO
SET IDENTITY_INSERT [build].[CharacterAssignedStat] OFF;
GO

-- build.CharacterFinalStat
SET IDENTITY_INSERT [build].[CharacterFinalStat] ON;
GO
INSERT INTO [build].[CharacterFinalStat] ([CharacterFinalStatId], [CharacterId], [StatTypeId], [FinalValue], [ObservedAt]) VALUES (1,1,1,3664.00,'2026-04-03 23:30:57.022');
INSERT INTO [build].[CharacterFinalStat] ([CharacterFinalStatId], [CharacterId], [StatTypeId], [FinalValue], [ObservedAt]) VALUES (2,1,3,1524.00,'2026-04-03 23:30:57.025');
INSERT INTO [build].[CharacterFinalStat] ([CharacterFinalStatId], [CharacterId], [StatTypeId], [FinalValue], [ObservedAt]) VALUES (3,1,4,530.00,'2026-04-03 23:30:57.027');
INSERT INTO [build].[CharacterFinalStat] ([CharacterFinalStatId], [CharacterId], [StatTypeId], [FinalValue], [ObservedAt]) VALUES (4,1,5,1032.00,'2026-04-03 23:30:57.031');
INSERT INTO [build].[CharacterFinalStat] ([CharacterFinalStatId], [CharacterId], [StatTypeId], [FinalValue], [ObservedAt]) VALUES (5,1,2,2493.00,'2026-04-03 23:30:57.034');
INSERT INTO [build].[CharacterFinalStat] ([CharacterFinalStatId], [CharacterId], [StatTypeId], [FinalValue], [ObservedAt]) VALUES (6,1,6,5159.00,'2026-04-03 23:30:57.037');
INSERT INTO [build].[CharacterFinalStat] ([CharacterFinalStatId], [CharacterId], [StatTypeId], [FinalValue], [ObservedAt]) VALUES (7,1,7,113396.00,'2026-04-03 23:30:57.040');
INSERT INTO [build].[CharacterFinalStat] ([CharacterFinalStatId], [CharacterId], [StatTypeId], [FinalValue], [ObservedAt]) VALUES (8,1,8,13285.00,'2026-04-03 23:30:57.043');
INSERT INTO [build].[CharacterFinalStat] ([CharacterFinalStatId], [CharacterId], [StatTypeId], [FinalValue], [ObservedAt]) VALUES (9,1,9,55391.00,'2026-04-03 23:30:57.045');
INSERT INTO [build].[CharacterFinalStat] ([CharacterFinalStatId], [CharacterId], [StatTypeId], [FinalValue], [ObservedAt]) VALUES (10,1,10,12749.00,'2026-04-03 23:30:57.049');
INSERT INTO [build].[CharacterFinalStat] ([CharacterFinalStatId], [CharacterId], [StatTypeId], [FinalValue], [ObservedAt]) VALUES (11,1,11,5078.00,'2026-04-03 23:30:57.051');
INSERT INTO [build].[CharacterFinalStat] ([CharacterFinalStatId], [CharacterId], [StatTypeId], [FinalValue], [ObservedAt]) VALUES (12,1,12,3523.00,'2026-04-03 23:30:57.055');
SET IDENTITY_INSERT [build].[CharacterFinalStat] OFF;
GO

-- equipment.CharacterEquipment
SET IDENTITY_INSERT [equipment].[CharacterEquipment] ON;
GO
INSERT INTO [equipment].[CharacterEquipment] ([CharacterEquipmentId], [CharacterId], [EquipmentSlotId], [ItemId], [ItemTypeId], [DisplayNameOverride], [DescriptionOverride], [EquippedAt], [UpdatedAt]) VALUES (1,1,1,1,1,NULL,NULL,'2026-04-03 23:27:41.540','2026-04-03 23:27:41.540');
INSERT INTO [equipment].[CharacterEquipment] ([CharacterEquipmentId], [CharacterId], [EquipmentSlotId], [ItemId], [ItemTypeId], [DisplayNameOverride], [DescriptionOverride], [EquippedAt], [UpdatedAt]) VALUES (2,1,4,2,4,NULL,NULL,'2026-04-03 23:27:41.545','2026-04-03 23:27:41.545');
INSERT INTO [equipment].[CharacterEquipment] ([CharacterEquipmentId], [CharacterId], [EquipmentSlotId], [ItemId], [ItemTypeId], [DisplayNameOverride], [DescriptionOverride], [EquippedAt], [UpdatedAt]) VALUES (3,1,3,3,3,NULL,NULL,'2026-04-03 23:27:41.602','2026-04-03 23:27:41.602');
INSERT INTO [equipment].[CharacterEquipment] ([CharacterEquipmentId], [CharacterId], [EquipmentSlotId], [ItemId], [ItemTypeId], [DisplayNameOverride], [DescriptionOverride], [EquippedAt], [UpdatedAt]) VALUES (4,1,5,4,5,NULL,NULL,'2026-04-03 23:27:41.606','2026-04-03 23:27:41.606');
INSERT INTO [equipment].[CharacterEquipment] ([CharacterEquipmentId], [CharacterId], [EquipmentSlotId], [ItemId], [ItemTypeId], [DisplayNameOverride], [DescriptionOverride], [EquippedAt], [UpdatedAt]) VALUES (5,1,8,5,8,NULL,NULL,'2026-04-03 23:27:41.609','2026-04-03 23:27:41.609');
INSERT INTO [equipment].[CharacterEquipment] ([CharacterEquipmentId], [CharacterId], [EquipmentSlotId], [ItemId], [ItemTypeId], [DisplayNameOverride], [DescriptionOverride], [EquippedAt], [UpdatedAt]) VALUES (6,1,9,6,9,NULL,NULL,'2026-04-03 23:27:41.611','2026-04-03 23:27:41.611');
INSERT INTO [equipment].[CharacterEquipment] ([CharacterEquipmentId], [CharacterId], [EquipmentSlotId], [ItemId], [ItemTypeId], [DisplayNameOverride], [DescriptionOverride], [EquippedAt], [UpdatedAt]) VALUES (7,1,11,7,11,NULL,NULL,'2026-04-03 23:27:41.615','2026-04-03 23:27:41.615');
INSERT INTO [equipment].[CharacterEquipment] ([CharacterEquipmentId], [CharacterId], [EquipmentSlotId], [ItemId], [ItemTypeId], [DisplayNameOverride], [DescriptionOverride], [EquippedAt], [UpdatedAt]) VALUES (8,1,12,8,12,NULL,NULL,'2026-04-03 23:27:41.618','2026-04-03 23:27:41.618');
INSERT INTO [equipment].[CharacterEquipment] ([CharacterEquipmentId], [CharacterId], [EquipmentSlotId], [ItemId], [ItemTypeId], [DisplayNameOverride], [DescriptionOverride], [EquippedAt], [UpdatedAt]) VALUES (9,1,14,9,13,NULL,NULL,'2026-04-03 23:27:41.621','2026-04-03 23:27:41.621');
INSERT INTO [equipment].[CharacterEquipment] ([CharacterEquipmentId], [CharacterId], [EquipmentSlotId], [ItemId], [ItemTypeId], [DisplayNameOverride], [DescriptionOverride], [EquippedAt], [UpdatedAt]) VALUES (10,1,6,10,6,NULL,NULL,'2026-04-03 23:27:41.623','2026-04-03 23:27:41.623');
SET IDENTITY_INSERT [equipment].[CharacterEquipment] OFF;
GO

-- audit.UserLoginEvent
SET IDENTITY_INSERT [audit].[UserLoginEvent] ON;
GO
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (19,1,'2026-04-10 04:45:41.539');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (18,1,'2026-04-09 19:19:00.848');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (16,1,'2026-04-09 03:31:15.246');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (15,1,'2026-04-08 15:04:23.282');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (14,1,'2026-04-08 15:03:48.762');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (13,1,'2026-04-07 23:26:41.976');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (12,1,'2026-04-07 18:46:26.108');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (11,1,'2026-04-07 18:40:08.392');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (10,1,'2026-04-07 16:45:51.734');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (9,1,'2026-04-07 16:42:04.098');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (8,1,'2026-04-07 16:32:19.362');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (6,1,'2026-04-07 13:27:32.227');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (5,1,'2026-04-07 13:21:21.654');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (4,1,'2026-04-07 13:19:04.808');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (3,1,'2026-04-07 13:18:21.926');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (2,1,'2026-04-07 13:17:36.852');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (1,1,'2026-04-07 13:17:34.632');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (17,4,'2026-04-09 19:07:26.789');
INSERT INTO [audit].[UserLoginEvent] ([UserLoginEventId], [UserId], [LoggedAt]) VALUES (7,4,'2026-04-07 13:43:06.838');
SET IDENTITY_INSERT [audit].[UserLoginEvent] OFF;
GO

-- notification.DeviceToken
SET IDENTITY_INSERT [notification].[DeviceToken] ON;
GO
INSERT INTO [notification].[DeviceToken] ([DeviceTokenId], [UserId], [Platform], [DeviceToken], [IsActive], [LastSeenAt], [CreatedAt], [UpdatedAt]) VALUES (1,1,'ANDROID','cx681OzEQBCg1x8a-G4Hzy:APA91bH0-0pTndkArOeSlo79v1LxLvjEFeADWf3rC5wsUked4ff6axrCLE7DqqqGiWcRgA3Apcni7iifZXdPLKx_Mp4Khk5sxPjBOmiUhn8EQeanHALleGU',1,'2026-04-09 03:31:18.159','2026-04-07 14:45:47.184','2026-04-09 03:31:18.159');
INSERT INTO [notification].[DeviceToken] ([DeviceTokenId], [UserId], [Platform], [DeviceToken], [IsActive], [LastSeenAt], [CreatedAt], [UpdatedAt]) VALUES (2,4,'ANDROID','cOTrrzWbSQeZ8ZDzaVkmWm:APA91bEeYYU-qJrZVIEJ_HSMJvDYbCuODLns1y7_0piluCbDVzdn4v-3tCXFXlF1fjfRyxVJKAwyMN-mFw0y70EikIfGm-KpnwpbF5D7NvGqEsOG0O36GbY',1,'2026-04-09 19:07:28.318','2026-04-07 16:33:05.542','2026-04-09 19:07:28.318');
INSERT INTO [notification].[DeviceToken] ([DeviceTokenId], [UserId], [Platform], [DeviceToken], [IsActive], [LastSeenAt], [CreatedAt], [UpdatedAt]) VALUES (3,4,'IOS','e8PEFq5qikUltKHEPpDftu:APA91bEOR8KvRQDtj8wA-k9Wcy0VCcPKSC7WziPnK_neyEn8F15SXG2w1cG3uxSVJAbHalfzeMGaml7ZwfVwdToL5Hg_J5NQg95Y8mxXnQXTtCKV4m23f70',1,'2026-04-07 23:23:45.838','2026-04-07 23:23:45.838','2026-04-07 23:23:45.838');
INSERT INTO [notification].[DeviceToken] ([DeviceTokenId], [UserId], [Platform], [DeviceToken], [IsActive], [LastSeenAt], [CreatedAt], [UpdatedAt]) VALUES (4,1,'IOS','e8PEFq5qikUltKHEPpDftu:APA91bEOR8KvRQDtj8wA-k9Wcy0VCcPKSC7WziPnK_neyEn8F15SXG2w1cG3uxSVJAbHalfzeMGaml7ZwfVwdToL5Hg_J5NQg95Y8mxXnQXTtCKV4m23f70',1,'2026-04-07 23:26:42.619','2026-04-07 23:26:42.619','2026-04-07 23:26:42.619');
SET IDENTITY_INSERT [notification].[DeviceToken] OFF;
GO

-- equipment.EquippedItemSocket
SET IDENTITY_INSERT [equipment].[EquippedItemSocket] ON;
GO
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (1,1,1,1,1,'2026-04-03 23:27:41.541');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (2,1,1,2,1,'2026-04-03 23:27:41.541');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (3,1,1,3,1,'2026-04-03 23:27:41.541');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (4,1,1,4,1,'2026-04-03 23:27:41.541');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (5,1,1,5,0,'2026-04-03 23:27:41.541');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (6,1,1,6,1,'2026-04-03 23:27:41.541');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (7,2,4,1,1,'2026-04-03 23:27:41.597');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (8,2,4,2,1,'2026-04-03 23:27:41.597');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (9,2,4,3,1,'2026-04-03 23:27:41.597');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (10,2,4,4,1,'2026-04-03 23:27:41.597');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (11,2,4,5,1,'2026-04-03 23:27:41.597');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (12,2,4,6,1,'2026-04-03 23:27:41.597');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (13,3,3,1,1,'2026-04-03 23:27:41.602');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (14,3,3,2,1,'2026-04-03 23:27:41.602');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (15,3,3,3,1,'2026-04-03 23:27:41.602');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (16,3,3,4,1,'2026-04-03 23:27:41.602');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (17,3,3,5,1,'2026-04-03 23:27:41.602');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (18,3,3,6,1,'2026-04-03 23:27:41.602');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (19,4,5,1,1,'2026-04-03 23:27:41.606');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (20,4,5,2,1,'2026-04-03 23:27:41.606');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (21,4,5,3,1,'2026-04-03 23:27:41.606');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (22,4,5,4,1,'2026-04-03 23:27:41.606');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (23,5,8,1,1,'2026-04-03 23:27:41.609');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (24,5,8,2,1,'2026-04-03 23:27:41.609');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (25,5,8,3,1,'2026-04-03 23:27:41.609');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (26,5,8,4,1,'2026-04-03 23:27:41.609');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (27,5,8,5,1,'2026-04-03 23:27:41.609');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (28,6,9,1,1,'2026-04-03 23:27:41.612');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (29,7,11,1,1,'2026-04-03 23:27:41.615');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (30,7,11,2,1,'2026-04-03 23:27:41.615');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (31,7,11,3,1,'2026-04-03 23:27:41.615');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (32,8,12,1,1,'2026-04-03 23:27:41.618');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (33,8,12,2,1,'2026-04-03 23:27:41.618');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (34,8,12,3,1,'2026-04-03 23:27:41.618');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (35,9,13,1,1,'2026-04-03 23:27:41.621');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (36,9,13,2,1,'2026-04-03 23:27:41.621');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (37,9,13,3,1,'2026-04-03 23:27:41.621');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (38,10,6,1,1,'2026-04-03 23:27:41.623');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (39,10,6,2,1,'2026-04-03 23:27:41.623');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (40,10,6,3,1,'2026-04-03 23:27:41.623');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (41,10,6,4,1,'2026-04-03 23:27:41.623');
INSERT INTO [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [SocketNumber], [IsOpen], [CreatedAt]) VALUES (42,10,6,5,1,'2026-04-03 23:27:41.623');
SET IDENTITY_INSERT [equipment].[EquippedItemSocket] OFF;
GO

-- equipment.EquippedItemLapis
SET IDENTITY_INSERT [equipment].[EquippedItemLapis] ON;
GO
INSERT INTO [equipment].[EquippedItemLapis] ([EquippedItemLapisId], [EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [LapisId], [InsertedAt]) VALUES (1,1,1,1,1,'2026-04-03 23:27:41.833');
INSERT INTO [equipment].[EquippedItemLapis] ([EquippedItemLapisId], [EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [LapisId], [InsertedAt]) VALUES (2,2,1,1,4,'2026-04-03 23:27:41.838');
INSERT INTO [equipment].[EquippedItemLapis] ([EquippedItemLapisId], [EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [LapisId], [InsertedAt]) VALUES (3,3,1,1,2,'2026-04-03 23:27:41.840');
INSERT INTO [equipment].[EquippedItemLapis] ([EquippedItemLapisId], [EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [LapisId], [InsertedAt]) VALUES (4,4,1,1,5,'2026-04-03 23:27:41.843');
INSERT INTO [equipment].[EquippedItemLapis] ([EquippedItemLapisId], [EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [LapisId], [InsertedAt]) VALUES (5,7,2,4,1,'2026-04-03 23:27:41.846');
INSERT INTO [equipment].[EquippedItemLapis] ([EquippedItemLapisId], [EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [LapisId], [InsertedAt]) VALUES (6,8,2,4,2,'2026-04-03 23:27:41.849');
INSERT INTO [equipment].[EquippedItemLapis] ([EquippedItemLapisId], [EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [LapisId], [InsertedAt]) VALUES (7,9,2,4,4,'2026-04-03 23:27:41.851');
INSERT INTO [equipment].[EquippedItemLapis] ([EquippedItemLapisId], [EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [LapisId], [InsertedAt]) VALUES (8,13,3,3,1,'2026-04-03 23:27:41.854');
INSERT INTO [equipment].[EquippedItemLapis] ([EquippedItemLapisId], [EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [LapisId], [InsertedAt]) VALUES (9,14,3,3,5,'2026-04-03 23:27:41.856');
INSERT INTO [equipment].[EquippedItemLapis] ([EquippedItemLapisId], [EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [LapisId], [InsertedAt]) VALUES (10,15,3,3,4,'2026-04-03 23:27:41.859');
INSERT INTO [equipment].[EquippedItemLapis] ([EquippedItemLapisId], [EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [LapisId], [InsertedAt]) VALUES (11,38,10,6,1,'2026-04-03 23:27:41.861');
INSERT INTO [equipment].[EquippedItemLapis] ([EquippedItemLapisId], [EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [LapisId], [InsertedAt]) VALUES (12,39,10,6,3,'2026-04-03 23:27:41.864');
INSERT INTO [equipment].[EquippedItemLapis] ([EquippedItemLapisId], [EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [LapisId], [InsertedAt]) VALUES (13,40,10,6,2,'2026-04-03 23:27:41.867');
INSERT INTO [equipment].[EquippedItemLapis] ([EquippedItemLapisId], [EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId], [LapisId], [InsertedAt]) VALUES (16,5,1,1,3,'2026-04-07 17:34:03.191');
SET IDENTITY_INSERT [equipment].[EquippedItemLapis] OFF;
GO

