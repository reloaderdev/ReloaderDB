-- ============================================================
-- V000__baseline.sql
-- Baseline completo: schemas, tablas, constraints, SPs
-- Generado: 2026-04-18
-- Base: reloader-games-db (Azure SQL)
-- ============================================================

-- ============================================================
-- SCHEMAS
-- ============================================================
CREATE SCHEMA [audit];
GO
CREATE SCHEMA [auth];
GO
CREATE SCHEMA [build];
GO
CREATE SCHEMA [catalog];
GO
CREATE SCHEMA [core];
GO
CREATE SCHEMA [equipment];
GO
CREATE SCHEMA [notification];
GO

-- ============================================================
-- TABLAS
-- ============================================================

-- audit.UserLoginEvent
CREATE TABLE [audit].[UserLoginEvent] (
    [UserLoginEventId] bigint IDENTITY(1,1) NOT NULL,
    [UserId] bigint NOT NULL,
    [LoggedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_audit_UserLoginEvent] PRIMARY KEY ([UserLoginEventId])
);
GO

-- auth.Role
CREATE TABLE [auth].[Role] (
    [RoleId] int IDENTITY(1,1) NOT NULL,
    [RoleCode] nvarchar(50) NOT NULL,
    [RoleName] nvarchar(100) NOT NULL,
    [Description] nvarchar(255) NULL,
    [IsActive] bit NOT NULL DEFAULT ((1)),
    CONSTRAINT [PK_auth_Role] PRIMARY KEY ([RoleId])
);
GO

-- auth.UserProfile
CREATE TABLE [auth].[UserProfile] (
    [UserProfileId] bigint IDENTITY(1,1) NOT NULL,
    [UserId] bigint NOT NULL,
    [DisplayName] nvarchar(100) NOT NULL,
    [CountryCode] nvarchar(10) NULL,
    [TimeZone] nvarchar(100) NULL,
    [CreatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    [UpdatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_auth_UserProfile] PRIMARY KEY ([UserProfileId])
);
GO

-- auth.UserRole
CREATE TABLE [auth].[UserRole] (
    [UserRoleId] bigint IDENTITY(1,1) NOT NULL,
    [UserId] bigint NOT NULL,
    [RoleId] int NOT NULL,
    [AssignedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    [IsActive] bit NOT NULL DEFAULT ((1)),
    CONSTRAINT [PK_auth_UserRole] PRIMARY KEY ([UserRoleId])
);
GO

-- auth.Users
CREATE TABLE [auth].[Users] (
    [UserId] bigint IDENTITY(1,1) NOT NULL,
    [Username] nvarchar(50) NOT NULL,
    [Email] nvarchar(255) NOT NULL,
    [PasswordHash] varbinary(256) NOT NULL,
    [Salt] varbinary(128) NOT NULL,
    [IsActive] bit NOT NULL DEFAULT ((1)),
    [FailedAttempts] int NOT NULL DEFAULT ((0)),
    [LastLoginAt] datetime2 NULL,
    [CreatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    [UpdatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_auth_Users] PRIMARY KEY ([UserId])
);
GO

-- build.CharacterAssignedStat
CREATE TABLE [build].[CharacterAssignedStat] (
    [CharacterAssignedStatId] bigint IDENTITY(1,1) NOT NULL,
    [CharacterId] bigint NOT NULL,
    [StatTypeId] int NOT NULL,
    [AssignedValue] decimal(18,2) NOT NULL,
    [UpdatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_build_CharacterAssignedStat] PRIMARY KEY ([CharacterAssignedStatId])
);
GO

-- build.CharacterBaseStat
CREATE TABLE [build].[CharacterBaseStat] (
    [CharacterBaseStatId] bigint IDENTITY(1,1) NOT NULL,
    [CharacterId] bigint NOT NULL,
    [StatTypeId] int NOT NULL,
    [StatValue] decimal(18,2) NOT NULL,
    [UpdatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_build_CharacterBaseStat] PRIMARY KEY ([CharacterBaseStatId])
);
GO

-- build.CharacterFinalStat
CREATE TABLE [build].[CharacterFinalStat] (
    [CharacterFinalStatId] bigint IDENTITY(1,1) NOT NULL,
    [CharacterId] bigint NOT NULL,
    [StatTypeId] int NOT NULL,
    [FinalValue] decimal(18,2) NOT NULL,
    [ObservedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_build_CharacterFinalStat] PRIMARY KEY ([CharacterFinalStatId])
);
GO

-- catalog.BindType
CREATE TABLE [catalog].[BindType] (
    [BindTypeId] int IDENTITY(1,1) NOT NULL,
    [BindTypeCode] nvarchar(30) NOT NULL,
    [BindTypeName] nvarchar(100) NOT NULL,
    CONSTRAINT [PK_catalog_BindType] PRIMARY KEY ([BindTypeId])
);
GO

-- catalog.EquipmentSlot
CREATE TABLE [catalog].[EquipmentSlot] (
    [EquipmentSlotId] int IDENTITY(1,1) NOT NULL,
    [SlotCode] nvarchar(30) NOT NULL,
    [SlotName] nvarchar(100) NOT NULL,
    [ItemTypeId] int NOT NULL,
    [SortOrder] int NOT NULL,
    [IsActive] bit NOT NULL DEFAULT ((1)),
    CONSTRAINT [PK_catalog_EquipmentSlot] PRIMARY KEY ([EquipmentSlotId])
);
GO

-- catalog.Item
CREATE TABLE [catalog].[Item] (
    [ItemId] bigint IDENTITY(1,1) NOT NULL,
    [ItemTypeId] int NOT NULL,
    [BindTypeId] int NULL,
    [ItemCode] nvarchar(100) NOT NULL,
    [ItemName] nvarchar(200) NOT NULL,
    [RequiredLevel] int NOT NULL,
    [Description] nvarchar(1000) NULL,
    [FlavorText] nvarchar(2000) NULL,
    [MaxSockets] int NOT NULL DEFAULT ((0)),
    [CanDye] bit NOT NULL DEFAULT ((0)),
    [IsActive] bit NOT NULL DEFAULT ((1)),
    [CreatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_catalog_Item] PRIMARY KEY ([ItemId])
);
GO

-- catalog.ItemAllowedClass
CREATE TABLE [catalog].[ItemAllowedClass] (
    [ItemAllowedClassId] bigint IDENTITY(1,1) NOT NULL,
    [ItemId] bigint NOT NULL,
    [ClassId] int NOT NULL,
    CONSTRAINT [PK_catalog_ItemAllowedClass] PRIMARY KEY ([ItemAllowedClassId])
);
GO

-- catalog.ItemStat
CREATE TABLE [catalog].[ItemStat] (
    [ItemStatId] bigint IDENTITY(1,1) NOT NULL,
    [ItemId] bigint NOT NULL,
    [StatTypeId] int NOT NULL,
    [StatValue] decimal(18,2) NOT NULL,
    [ValueSource] nvarchar(30) NOT NULL,
    CONSTRAINT [PK_catalog_ItemStat] PRIMARY KEY ([ItemStatId])
);
GO

-- catalog.ItemType
CREATE TABLE [catalog].[ItemType] (
    [ItemTypeId] int IDENTITY(1,1) NOT NULL,
    [ItemTypeCode] nvarchar(30) NOT NULL,
    [ItemTypeName] nvarchar(100) NOT NULL,
    [IsEquippable] bit NOT NULL DEFAULT ((1)),
    [IsActive] bit NOT NULL DEFAULT ((1)),
    CONSTRAINT [PK_catalog_ItemType] PRIMARY KEY ([ItemTypeId])
);
GO

-- catalog.ItemTypeSlot
CREATE TABLE [catalog].[ItemTypeSlot] (
    [ItemTypeSlotId] bigint IDENTITY(1,1) NOT NULL,
    [ItemTypeId] int NOT NULL,
    [EquipmentSlotId] int NOT NULL,
    CONSTRAINT [PK_catalog_ItemTypeSlot] PRIMARY KEY ([ItemTypeSlotId])
);
GO

-- catalog.Lapis
CREATE TABLE [catalog].[Lapis] (
    [LapisId] bigint IDENTITY(1,1) NOT NULL,
    [LapisTypeId] int NOT NULL,
    [LapisCode] nvarchar(100) NOT NULL,
    [LapisName] nvarchar(200) NOT NULL,
    [LapisLevel] int NOT NULL,
    [RequiredLevel] int NOT NULL,
    [Description] nvarchar(1000) NULL,
    [RiskNote] nvarchar(1000) NULL,
    [IsActive] bit NOT NULL DEFAULT ((1)),
    CONSTRAINT [PK_catalog_Lapis] PRIMARY KEY ([LapisId])
);
GO

-- catalog.LapisApplicableItemType
CREATE TABLE [catalog].[LapisApplicableItemType] (
    [LapisApplicableItemTypeId] bigint IDENTITY(1,1) NOT NULL,
    [LapisId] bigint NOT NULL,
    [ItemTypeId] int NOT NULL,
    CONSTRAINT [PK_catalog_LapisApplicableItemType] PRIMARY KEY ([LapisApplicableItemTypeId])
);
GO

-- catalog.LapisEffect
CREATE TABLE [catalog].[LapisEffect] (
    [LapisEffectId] bigint IDENTITY(1,1) NOT NULL,
    [LapisId] bigint NOT NULL,
    [StatTypeId] int NOT NULL,
    [EffectValue] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_catalog_LapisEffect] PRIMARY KEY ([LapisEffectId])
);
GO

-- catalog.LapisType
CREATE TABLE [catalog].[LapisType] (
    [LapisTypeId] int IDENTITY(1,1) NOT NULL,
    [LapisTypeCode] nvarchar(30) NOT NULL,
    [LapisTypeName] nvarchar(100) NOT NULL,
    CONSTRAINT [PK_catalog_LapisType] PRIMARY KEY ([LapisTypeId])
);
GO

-- catalog.StatType
CREATE TABLE [catalog].[StatType] (
    [StatTypeId] int IDENTITY(1,1) NOT NULL,
    [StatCode] nvarchar(30) NOT NULL,
    [StatName] nvarchar(100) NOT NULL,
    [ValueType] nvarchar(20) NOT NULL,
    [IsPrimary] bit NOT NULL DEFAULT ((0)),
    [IsDerived] bit NOT NULL DEFAULT ((0)),
    [IsActive] bit NOT NULL DEFAULT ((1)),
    CONSTRAINT [PK_catalog_StatType] PRIMARY KEY ([StatTypeId])
);
GO

-- core.Character
CREATE TABLE [core].[Character] (
    [CharacterId] bigint IDENTITY(1,1) NOT NULL,
    [PlayerId] bigint NOT NULL,
    [FactionId] int NOT NULL,
    [ClassId] int NOT NULL,
    [CharacterName] nvarchar(100) NOT NULL,
    [Level] int NOT NULL,
    [Title] nvarchar(100) NULL,
    [Mode] nvarchar(50) NULL,
    [Element] nvarchar(50) NULL,
    [IsPrimary] bit NOT NULL DEFAULT ((0)),
    [IsActive] bit NOT NULL DEFAULT ((1)),
    [CreatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    [UpdatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_core_Character] PRIMARY KEY ([CharacterId])
);
GO

-- core.Class
CREATE TABLE [core].[Class] (
    [ClassId] int IDENTITY(1,1) NOT NULL,
    [FactionId] int NOT NULL,
    [ClassCode] nvarchar(30) NOT NULL,
    [ClassName] nvarchar(100) NOT NULL,
    [IsActive] bit NOT NULL DEFAULT ((1)),
    CONSTRAINT [PK_core_Class] PRIMARY KEY ([ClassId])
);
GO

-- core.Faction
CREATE TABLE [core].[Faction] (
    [FactionId] int IDENTITY(1,1) NOT NULL,
    [FactionCode] nvarchar(20) NOT NULL,
    [FactionName] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_core_Faction] PRIMARY KEY ([FactionId])
);
GO

-- core.Guild
CREATE TABLE [core].[Guild] (
    [GuildId] bigint IDENTITY(1,1) NOT NULL,
    [FactionId] int NOT NULL,
    [GuildName] nvarchar(100) NOT NULL,
    [IsActive] bit NOT NULL DEFAULT ((1)),
    [CreatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_core_Guild] PRIMARY KEY ([GuildId])
);
GO

-- core.GuildMember
CREATE TABLE [core].[GuildMember] (
    [GuildMemberId] bigint IDENTITY(1,1) NOT NULL,
    [GuildId] bigint NOT NULL,
    [CharacterId] bigint NOT NULL,
    [GuildRankId] int NOT NULL,
    [JoinDate] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    [IsActive] bit NOT NULL DEFAULT ((1)),
    CONSTRAINT [PK_core_GuildMember] PRIMARY KEY ([GuildMemberId])
);
GO

-- core.GuildRank
CREATE TABLE [core].[GuildRank] (
    [GuildRankId] int IDENTITY(1,1) NOT NULL,
    [RankCode] nvarchar(30) NOT NULL,
    [RankName] nvarchar(100) NOT NULL,
    [SortOrder] int NOT NULL,
    [IsActive] bit NOT NULL DEFAULT ((1)),
    CONSTRAINT [PK_core_GuildRank] PRIMARY KEY ([GuildRankId])
);
GO

-- core.Player
CREATE TABLE [core].[Player] (
    [PlayerId] bigint IDENTITY(1,1) NOT NULL,
    [UserId] bigint NOT NULL,
    [DisplayName] nvarchar(100) NOT NULL,
    [IsActive] bit NOT NULL DEFAULT ((1)),
    [CreatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_core_Player] PRIMARY KEY ([PlayerId])
);
GO

-- equipment.CharacterEquipment
CREATE TABLE [equipment].[CharacterEquipment] (
    [CharacterEquipmentId] bigint IDENTITY(1,1) NOT NULL,
    [CharacterId] bigint NOT NULL,
    [EquipmentSlotId] int NOT NULL,
    [ItemId] bigint NOT NULL,
    [ItemTypeId] int NOT NULL,
    [DisplayNameOverride] nvarchar(200) NULL,
    [DescriptionOverride] nvarchar(2000) NULL,
    [EquippedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    [UpdatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_equipment_CharacterEquipment] PRIMARY KEY ([CharacterEquipmentId])
);
GO

-- equipment.EquippedItemLapis
CREATE TABLE [equipment].[EquippedItemLapis] (
    [EquippedItemLapisId] bigint IDENTITY(1,1) NOT NULL,
    [EquippedItemSocketId] bigint NOT NULL,
    [CharacterEquipmentId] bigint NOT NULL,
    [ItemTypeId] int NOT NULL,
    [LapisId] bigint NOT NULL,
    [InsertedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_equipment_EquippedItemLapis] PRIMARY KEY ([EquippedItemLapisId])
);
GO

-- equipment.EquippedItemSocket
CREATE TABLE [equipment].[EquippedItemSocket] (
    [EquippedItemSocketId] bigint IDENTITY(1,1) NOT NULL,
    [CharacterEquipmentId] bigint NOT NULL,
    [ItemTypeId] int NOT NULL,
    [SocketNumber] int NOT NULL,
    [IsOpen] bit NOT NULL DEFAULT ((1)),
    [CreatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_equipment_EquippedItemSocket] PRIMARY KEY ([EquippedItemSocketId])
);
GO

-- notification.DeviceToken
CREATE TABLE [notification].[DeviceToken] (
    [DeviceTokenId] bigint IDENTITY(1,1) NOT NULL,
    [UserId] bigint NOT NULL,
    [Platform] nvarchar(20) NOT NULL,
    [DeviceToken] nvarchar(500) NOT NULL,
    [IsActive] bit NOT NULL DEFAULT ((1)),
    [LastSeenAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    [CreatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    [UpdatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_notification_DeviceToken] PRIMARY KEY ([DeviceTokenId])
);
GO

-- ============================================================
-- ============================================================
-- UNIQUE INDEXES Y CONSTRAINTS
-- ============================================================

ALTER TABLE [auth].[Role] ADD CONSTRAINT [UQ_Role_RoleCode] UNIQUE ([RoleCode]);
GO
ALTER TABLE [auth].[Role] ADD CONSTRAINT [UQ_Role_RoleName] UNIQUE ([RoleName]);
GO
ALTER TABLE [auth].[UserProfile] ADD CONSTRAINT [UQ_UserProfile_UserId] UNIQUE ([UserId]);
GO
ALTER TABLE [auth].[UserRole] ADD CONSTRAINT [UQ_UserRole_User_Role] UNIQUE ([UserId], [RoleId]);
GO
ALTER TABLE [auth].[Users] ADD CONSTRAINT [UQ_Users_Email] UNIQUE ([Email]);
GO
ALTER TABLE [auth].[Users] ADD CONSTRAINT [UQ_Users_Username] UNIQUE ([Username]);
GO
ALTER TABLE [build].[CharacterAssignedStat] ADD CONSTRAINT [UQ_CharacterAssignedStat_Character_StatType] UNIQUE ([CharacterId], [StatTypeId]);
GO
ALTER TABLE [build].[CharacterBaseStat] ADD CONSTRAINT [UQ_CharacterBaseStat_Character_StatType] UNIQUE ([CharacterId], [StatTypeId]);
GO
ALTER TABLE [build].[CharacterFinalStat] ADD CONSTRAINT [UQ_CharacterFinalStat_Character_StatType] UNIQUE ([CharacterId], [StatTypeId]);
GO
ALTER TABLE [catalog].[BindType] ADD CONSTRAINT [UQ_BindType_Code] UNIQUE ([BindTypeCode]);
GO
ALTER TABLE [catalog].[BindType] ADD CONSTRAINT [UQ_BindType_Name] UNIQUE ([BindTypeName]);
GO
ALTER TABLE [catalog].[EquipmentSlot] ADD CONSTRAINT [UQ_EquipmentSlot_Code] UNIQUE ([SlotCode]);
GO
ALTER TABLE [catalog].[EquipmentSlot] ADD CONSTRAINT [UQ_EquipmentSlot_EquipmentSlotId_ItemTypeId] UNIQUE ([EquipmentSlotId], [ItemTypeId]);
GO
ALTER TABLE [catalog].[EquipmentSlot] ADD CONSTRAINT [UQ_EquipmentSlot_SortOrder] UNIQUE ([SortOrder]);
GO
ALTER TABLE [catalog].[Item] ADD CONSTRAINT [UQ_Item_ItemCode] UNIQUE ([ItemCode]);
GO
ALTER TABLE [catalog].[Item] ADD CONSTRAINT [UQ_Item_ItemId_ItemTypeId] UNIQUE ([ItemId], [ItemTypeId]);
GO
ALTER TABLE [catalog].[ItemAllowedClass] ADD CONSTRAINT [UQ_ItemAllowedClass_Item_Class] UNIQUE ([ItemId], [ClassId]);
GO
ALTER TABLE [catalog].[ItemType] ADD CONSTRAINT [UQ_ItemType_Code] UNIQUE ([ItemTypeCode]);
GO
ALTER TABLE [catalog].[ItemType] ADD CONSTRAINT [UQ_ItemType_Name] UNIQUE ([ItemTypeName]);
GO
ALTER TABLE [catalog].[ItemTypeSlot] ADD CONSTRAINT [UQ_ItemTypeSlot_ItemType_Slot] UNIQUE ([ItemTypeId], [EquipmentSlotId]);
GO
ALTER TABLE [catalog].[Lapis] ADD CONSTRAINT [UQ_Lapis_Code] UNIQUE ([LapisCode]);
GO
ALTER TABLE [catalog].[LapisApplicableItemType] ADD CONSTRAINT [UQ_LapisApplicableItemType_Lapis_ItemType] UNIQUE ([LapisId], [ItemTypeId]);
GO
ALTER TABLE [catalog].[LapisType] ADD CONSTRAINT [UQ_LapisType_Code] UNIQUE ([LapisTypeCode]);
GO
ALTER TABLE [catalog].[LapisType] ADD CONSTRAINT [UQ_LapisType_Name] UNIQUE ([LapisTypeName]);
GO
ALTER TABLE [catalog].[StatType] ADD CONSTRAINT [UQ_StatType_Code] UNIQUE ([StatCode]);
GO
ALTER TABLE [core].[Character] ADD CONSTRAINT [UQ_Character_Player_Name] UNIQUE ([PlayerId], [CharacterName]);
GO
ALTER TABLE [core].[Class] ADD CONSTRAINT [UQ_Class_ClassId_FactionId] UNIQUE ([ClassId], [FactionId]);
GO
ALTER TABLE [core].[Class] ADD CONSTRAINT [UQ_Class_Code] UNIQUE ([ClassCode]);
GO
ALTER TABLE [core].[Class] ADD CONSTRAINT [UQ_Class_Faction_Name] UNIQUE ([FactionId], [ClassName]);
GO
ALTER TABLE [core].[Faction] ADD CONSTRAINT [UQ_Faction_Code] UNIQUE ([FactionCode]);
GO
ALTER TABLE [core].[Faction] ADD CONSTRAINT [UQ_Faction_Name] UNIQUE ([FactionName]);
GO
ALTER TABLE [core].[Guild] ADD CONSTRAINT [UQ_Guild_Faction_Name] UNIQUE ([FactionId], [GuildName]);
GO
CREATE UNIQUE INDEX [UX_GuildMember_Character_Active] ON [core].[GuildMember] ([CharacterId]);
GO
ALTER TABLE [core].[GuildRank] ADD CONSTRAINT [UQ_GuildRank_Code] UNIQUE ([RankCode]);
GO
ALTER TABLE [core].[GuildRank] ADD CONSTRAINT [UQ_GuildRank_SortOrder] UNIQUE ([SortOrder]);
GO
ALTER TABLE [core].[Player] ADD CONSTRAINT [UQ_Player_UserId] UNIQUE ([UserId]);
GO
ALTER TABLE [equipment].[CharacterEquipment] ADD CONSTRAINT [UQ_CharacterEquipment_Character_Slot] UNIQUE ([CharacterId], [EquipmentSlotId]);
GO
ALTER TABLE [equipment].[CharacterEquipment] ADD CONSTRAINT [UQ_CharacterEquipment_Id_ItemTypeId] UNIQUE ([CharacterEquipmentId], [ItemTypeId]);
GO
ALTER TABLE [equipment].[EquippedItemLapis] ADD CONSTRAINT [UQ_EquippedItemLapis_Equipment_Lapis] UNIQUE ([CharacterEquipmentId], [LapisId]);
GO
ALTER TABLE [equipment].[EquippedItemLapis] ADD CONSTRAINT [UQ_EquippedItemLapis_Socket] UNIQUE ([EquippedItemSocketId]);
GO
ALTER TABLE [equipment].[EquippedItemSocket] ADD CONSTRAINT [UQ_EquippedItemSocket_Equipment_Socket] UNIQUE ([CharacterEquipmentId], [SocketNumber]);
GO
ALTER TABLE [equipment].[EquippedItemSocket] ADD CONSTRAINT [UQ_EquippedItemSocket_Id_Equipment_ItemType] UNIQUE ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId]);
GO
ALTER TABLE [notification].[DeviceToken] ADD CONSTRAINT [UQ_DeviceToken_User_Platform] UNIQUE ([UserId], [Platform]);
GO
-- ============================================================
-- FOREIGN KEYS
-- ============================================================

ALTER TABLE [audit].[UserLoginEvent] ADD CONSTRAINT [FK_UserLoginEvent_User] FOREIGN KEY ([UserId]) REFERENCES [auth].[Users] ([UserId]);
GO
ALTER TABLE [auth].[UserProfile] ADD CONSTRAINT [FK_UserProfile_User] FOREIGN KEY ([UserId]) REFERENCES [auth].[Users] ([UserId]);
GO
ALTER TABLE [auth].[UserRole] ADD CONSTRAINT [FK_UserRole_Role] FOREIGN KEY ([RoleId]) REFERENCES [auth].[Role] ([RoleId]);
GO
ALTER TABLE [auth].[UserRole] ADD CONSTRAINT [FK_UserRole_User] FOREIGN KEY ([UserId]) REFERENCES [auth].[Users] ([UserId]);
GO
ALTER TABLE [build].[CharacterAssignedStat] ADD CONSTRAINT [FK_CharacterAssignedStat_Character] FOREIGN KEY ([CharacterId]) REFERENCES [core].[Character] ([CharacterId]);
GO
ALTER TABLE [build].[CharacterAssignedStat] ADD CONSTRAINT [FK_CharacterAssignedStat_StatType] FOREIGN KEY ([StatTypeId]) REFERENCES [catalog].[StatType] ([StatTypeId]);
GO
ALTER TABLE [build].[CharacterBaseStat] ADD CONSTRAINT [FK_CharacterBaseStat_Character] FOREIGN KEY ([CharacterId]) REFERENCES [core].[Character] ([CharacterId]);
GO
ALTER TABLE [build].[CharacterBaseStat] ADD CONSTRAINT [FK_CharacterBaseStat_StatType] FOREIGN KEY ([StatTypeId]) REFERENCES [catalog].[StatType] ([StatTypeId]);
GO
ALTER TABLE [build].[CharacterFinalStat] ADD CONSTRAINT [FK_CharacterFinalStat_Character] FOREIGN KEY ([CharacterId]) REFERENCES [core].[Character] ([CharacterId]);
GO
ALTER TABLE [build].[CharacterFinalStat] ADD CONSTRAINT [FK_CharacterFinalStat_StatType] FOREIGN KEY ([StatTypeId]) REFERENCES [catalog].[StatType] ([StatTypeId]);
GO
ALTER TABLE [catalog].[EquipmentSlot] ADD CONSTRAINT [FK_EquipmentSlot_ItemType] FOREIGN KEY ([ItemTypeId]) REFERENCES [catalog].[ItemType] ([ItemTypeId]);
GO
ALTER TABLE [catalog].[Item] ADD CONSTRAINT [FK_Item_BindType] FOREIGN KEY ([BindTypeId]) REFERENCES [catalog].[BindType] ([BindTypeId]);
GO
ALTER TABLE [catalog].[Item] ADD CONSTRAINT [FK_Item_ItemType] FOREIGN KEY ([ItemTypeId]) REFERENCES [catalog].[ItemType] ([ItemTypeId]);
GO
ALTER TABLE [catalog].[ItemAllowedClass] ADD CONSTRAINT [FK_ItemAllowedClass_Class] FOREIGN KEY ([ClassId]) REFERENCES [core].[Class] ([ClassId]);
GO
ALTER TABLE [catalog].[ItemAllowedClass] ADD CONSTRAINT [FK_ItemAllowedClass_Item] FOREIGN KEY ([ItemId]) REFERENCES [catalog].[Item] ([ItemId]);
GO
ALTER TABLE [catalog].[ItemStat] ADD CONSTRAINT [FK_ItemStat_Item] FOREIGN KEY ([ItemId]) REFERENCES [catalog].[Item] ([ItemId]);
GO
ALTER TABLE [catalog].[ItemStat] ADD CONSTRAINT [FK_ItemStat_StatType] FOREIGN KEY ([StatTypeId]) REFERENCES [catalog].[StatType] ([StatTypeId]);
GO
ALTER TABLE [catalog].[ItemTypeSlot] ADD CONSTRAINT [FK_ItemTypeSlot_EquipmentSlot] FOREIGN KEY ([EquipmentSlotId], [ItemTypeId]) REFERENCES [catalog].[EquipmentSlot] ([EquipmentSlotId], [ItemTypeId]);
GO
ALTER TABLE [catalog].[ItemTypeSlot] ADD CONSTRAINT [FK_ItemTypeSlot_ItemType] FOREIGN KEY ([ItemTypeId]) REFERENCES [catalog].[ItemType] ([ItemTypeId]);
GO
ALTER TABLE [catalog].[Lapis] ADD CONSTRAINT [FK_Lapis_LapisType] FOREIGN KEY ([LapisTypeId]) REFERENCES [catalog].[LapisType] ([LapisTypeId]);
GO
ALTER TABLE [catalog].[LapisApplicableItemType] ADD CONSTRAINT [FK_LapisApplicableItemType_ItemType] FOREIGN KEY ([ItemTypeId]) REFERENCES [catalog].[ItemType] ([ItemTypeId]);
GO
ALTER TABLE [catalog].[LapisApplicableItemType] ADD CONSTRAINT [FK_LapisApplicableItemType_Lapis] FOREIGN KEY ([LapisId]) REFERENCES [catalog].[Lapis] ([LapisId]);
GO
ALTER TABLE [catalog].[LapisEffect] ADD CONSTRAINT [FK_LapisEffect_Lapis] FOREIGN KEY ([LapisId]) REFERENCES [catalog].[Lapis] ([LapisId]);
GO
ALTER TABLE [catalog].[LapisEffect] ADD CONSTRAINT [FK_LapisEffect_StatType] FOREIGN KEY ([StatTypeId]) REFERENCES [catalog].[StatType] ([StatTypeId]);
GO
ALTER TABLE [core].[Character] ADD CONSTRAINT [FK_Character_ClassFaction] FOREIGN KEY ([ClassId], [FactionId]) REFERENCES [core].[Class] ([ClassId], [FactionId]);
GO
ALTER TABLE [core].[Character] ADD CONSTRAINT [FK_Character_Faction] FOREIGN KEY ([FactionId]) REFERENCES [core].[Faction] ([FactionId]);
GO
ALTER TABLE [core].[Character] ADD CONSTRAINT [FK_Character_Player] FOREIGN KEY ([PlayerId]) REFERENCES [core].[Player] ([PlayerId]);
GO
ALTER TABLE [core].[Class] ADD CONSTRAINT [FK_Class_Faction] FOREIGN KEY ([FactionId]) REFERENCES [core].[Faction] ([FactionId]);
GO
ALTER TABLE [core].[Guild] ADD CONSTRAINT [FK_Guild_Faction] FOREIGN KEY ([FactionId]) REFERENCES [core].[Faction] ([FactionId]);
GO
ALTER TABLE [core].[GuildMember] ADD CONSTRAINT [FK_GuildMember_Character] FOREIGN KEY ([CharacterId]) REFERENCES [core].[Character] ([CharacterId]);
GO
ALTER TABLE [core].[GuildMember] ADD CONSTRAINT [FK_GuildMember_Guild] FOREIGN KEY ([GuildId]) REFERENCES [core].[Guild] ([GuildId]);
GO
ALTER TABLE [core].[GuildMember] ADD CONSTRAINT [FK_GuildMember_GuildRank] FOREIGN KEY ([GuildRankId]) REFERENCES [core].[GuildRank] ([GuildRankId]);
GO
ALTER TABLE [core].[Player] ADD CONSTRAINT [FK_Player_User] FOREIGN KEY ([UserId]) REFERENCES [auth].[Users] ([UserId]);
GO
ALTER TABLE [equipment].[CharacterEquipment] ADD CONSTRAINT [FK_CharacterEquipment_Character] FOREIGN KEY ([CharacterId]) REFERENCES [core].[Character] ([CharacterId]);
GO
ALTER TABLE [equipment].[CharacterEquipment] ADD CONSTRAINT [FK_CharacterEquipment_EquipmentSlot] FOREIGN KEY ([EquipmentSlotId], [ItemTypeId]) REFERENCES [catalog].[EquipmentSlot] ([EquipmentSlotId], [ItemTypeId]);
GO
ALTER TABLE [equipment].[CharacterEquipment] ADD CONSTRAINT [FK_CharacterEquipment_Item] FOREIGN KEY ([ItemId], [ItemTypeId]) REFERENCES [catalog].[Item] ([ItemId], [ItemTypeId]);
GO
ALTER TABLE [equipment].[EquippedItemLapis] ADD CONSTRAINT [FK_EquippedItemLapis_CharacterEquipment] FOREIGN KEY ([CharacterEquipmentId], [ItemTypeId]) REFERENCES [equipment].[CharacterEquipment] ([CharacterEquipmentId], [ItemTypeId]);
GO
ALTER TABLE [equipment].[EquippedItemLapis] ADD CONSTRAINT [FK_EquippedItemLapis_Lapis] FOREIGN KEY ([LapisId]) REFERENCES [catalog].[Lapis] ([LapisId]);
GO
ALTER TABLE [equipment].[EquippedItemLapis] ADD CONSTRAINT [FK_EquippedItemLapis_Socket] FOREIGN KEY ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId]) REFERENCES [equipment].[EquippedItemSocket] ([EquippedItemSocketId], [CharacterEquipmentId], [ItemTypeId]);
GO
ALTER TABLE [equipment].[EquippedItemSocket] ADD CONSTRAINT [FK_EquippedItemSocket_CharacterEquipment] FOREIGN KEY ([CharacterEquipmentId], [ItemTypeId]) REFERENCES [equipment].[CharacterEquipment] ([CharacterEquipmentId], [ItemTypeId]);
GO
ALTER TABLE [notification].[DeviceToken] ADD CONSTRAINT [FK_DeviceToken_User] FOREIGN KEY ([UserId]) REFERENCES [auth].[Users] ([UserId]);
GO
-- ============================================================
-- STORED PROCEDURES
-- ============================================================

-- SP: auth.sp_ListUserActivitySegment
CREATE   PROCEDURE auth.sp_ListUserActivitySegment
AS
BEGIN
    SET NOCOUNT ON;
    ;WITH LoginStats AS (
        SELECT
            U.UserId,
            COUNT(ULE.UserLoginEventId) AS TotalLogins,
            COUNT(DISTINCT CONVERT(DATE, ULE.LoggedAt)) AS TotalActiveDays,
            COUNT(DISTINCT CASE
                WHEN ULE.LoggedAt >= DATEADD(DAY, -30, SYSUTCDATETIME())
                THEN CONVERT(DATE, ULE.LoggedAt)
            END) AS ActiveDaysLast30,
            MAX(ULE.LoggedAt) AS LastEventAt
        FROM auth.Users U
        LEFT JOIN audit.UserLoginEvent ULE
            ON ULE.UserId = U.UserId
        GROUP BY U.UserId
    )
    SELECT
        U.UserId,
        U.Username,
        U.Email,
        U.CreatedAt,
        U.LastLoginAt,
        ISNULL(LS.TotalLogins, 0) AS TotalLogins,
        ISNULL(LS.TotalActiveDays, 0) AS TotalActiveDays,
        ISNULL(LS.ActiveDaysLast30, 0) AS ActiveDaysLast30,
        LS.LastEventAt,
        CASE
            WHEN U.CreatedAt >= DATEADD(DAY, -7, SYSUTCDATETIME()) THEN 'NEW'
            WHEN ISNULL(LS.ActiveDaysLast30, 0) >= 5 THEN 'REGULAR'
            WHEN ISNULL(LS.ActiveDaysLast30, 0) BETWEEN 1 AND 4 THEN 'CASUAL'
            ELSE 'INACTIVE'
        END AS ActivitySegment
    FROM auth.Users U
    LEFT JOIN LoginStats LS
        ON LS.UserId = U.UserId
    WHERE U.IsActive = 1
    ORDER BY
        CASE
            WHEN U.CreatedAt >= DATEADD(DAY, -7, SYSUTCDATETIME()) THEN 1
            WHEN ISNULL(LS.ActiveDaysLast30, 0) >= 5 THEN 2
            WHEN ISNULL(LS.ActiveDaysLast30, 0) BETWEEN 1 AND 4 THEN 3
            ELSE 4
        END,
        U.Username;
END;
GO

-- SP: auth.sp_ListUsers
CREATE   PROCEDURE auth.sp_ListUsers
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        U.UserId,
        U.Username,
        U.Email,
        U.IsActive,
        U.FailedAttempts,
        U.LastLoginAt,
        R.RoleCode,
        P.DisplayName,
        P.CountryCode,
        P.TimeZone,
        U.CreatedAt,
        U.UpdatedAt
    FROM auth.Users U
    LEFT JOIN auth.UserRole UR
        ON UR.UserId = U.UserId
       AND UR.IsActive = 1
    LEFT JOIN auth.Role R
        ON R.RoleId = UR.RoleId
    LEFT JOIN auth.UserProfile P
        ON P.UserId = U.UserId
    ORDER BY U.UserId;
END;
GO

-- SP: auth.sp_LoginUser
CREATE   PROCEDURE auth.sp_LoginUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @UserId BIGINT;
    DECLARE @StoredHash VARBINARY(256);
    DECLARE @Salt VARBINARY(128);
    DECLARE @ComputedHash VARBINARY(256);
    SELECT
        @UserId = UserId,
        @StoredHash = PasswordHash,
        @Salt = Salt
    FROM auth.Users
    WHERE Username = @Username
      AND IsActive = 1;
    IF @UserId IS NULL
    BEGIN
        SELECT CAST(0 AS BIT) AS IsAuthenticated;
        RETURN;
    END
    SET @ComputedHash = HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @Password) + @Salt);
    IF @ComputedHash = @StoredHash
    BEGIN
        UPDATE auth.Users
        SET FailedAttempts = 0,
            LastLoginAt = SYSUTCDATETIME(),
            UpdatedAt = SYSUTCDATETIME()
        WHERE UserId = @UserId;
        INSERT INTO audit.UserLoginEvent (
            UserId
        )
        VALUES (
            @UserId
        );
        SELECT
            CAST(1 AS BIT) AS IsAuthenticated,
            U.UserId,
            U.Username,
            U.Email,
            P.DisplayName,
            P.CountryCode,
            P.TimeZone,
            R.RoleCode,
            CAST(NULL AS NVARCHAR(500)) AS PhotoUrl
        FROM auth.Users U
        LEFT JOIN auth.UserProfile P
            ON P.UserId = U.UserId
        LEFT JOIN auth.UserRole UR
            ON UR.UserId = U.UserId
           AND UR.IsActive = 1
        LEFT JOIN auth.Role R
            ON R.RoleId = UR.RoleId
        WHERE U.UserId = @UserId;
    END
    ELSE
    BEGIN
        UPDATE auth.Users
        SET FailedAttempts = FailedAttempts + 1,
            UpdatedAt = SYSUTCDATETIME()
        WHERE UserId = @UserId;
        SELECT CAST(0 AS BIT) AS IsAuthenticated;
    END
END;
GO

-- SP: auth.sp_RegisterUser
/* =========================================================
   auth.sp_RegisterUser
   ========================================================= */
CREATE   PROCEDURE auth.sp_RegisterUser
    @Username NVARCHAR(50),
    @Email NVARCHAR(255),
    @Password NVARCHAR(200),
    @DisplayName NVARCHAR(100),
    @CountryCode NVARCHAR(10) = NULL,
    @TimeZone NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @UserId BIGINT;
    DECLARE @PlayerRoleId INT;
    DECLARE @Salt VARBINARY(128);
    DECLARE @PasswordHash VARBINARY(256);
    IF EXISTS (SELECT 1 FROM auth.Users WHERE Username = @Username)
        THROW 50001, 'Username already exists.', 1;
    IF EXISTS (SELECT 1 FROM auth.Users WHERE Email = @Email)
        THROW 50002, 'Email already exists.', 1;
    SELECT @PlayerRoleId = RoleId
    FROM auth.Role
    WHERE RoleCode = 'PLAYER'
      AND IsActive = 1;
    IF @PlayerRoleId IS NULL
        THROW 50003, 'Default PLAYER role was not found.', 1;
    SET @Salt = CRYPT_GEN_RANDOM(32);
    SET @PasswordHash = HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @Password) + @Salt);
    BEGIN TRANSACTION;
    INSERT INTO auth.Users (
        Username, Email, PasswordHash, Salt, IsActive, FailedAttempts
    )
    VALUES (
        @Username, @Email, @PasswordHash, @Salt, 1, 0
    );
    SET @UserId = SCOPE_IDENTITY();
    INSERT INTO auth.UserProfile (
        UserId, DisplayName, CountryCode, TimeZone
    )
    VALUES (
        @UserId, @DisplayName, @CountryCode, @TimeZone
    );
    INSERT INTO auth.UserRole (
        UserId, RoleId, IsActive
    )
    VALUES (
        @UserId, @PlayerRoleId, 1
    );
    INSERT INTO core.Player (
        UserId, DisplayName, IsActive
    )
    VALUES (
        @UserId, @DisplayName, 1
    );
    COMMIT TRANSACTION;
    SELECT
        @UserId AS UserId,
        @Username AS Username,
        @Email AS Email,
        @DisplayName AS DisplayName,
        'PLAYER' AS DefaultRole;
END;
GO

-- SP: build.sp_UpsertCharacterStat
/* =========================================================
   build.sp_UpsertCharacterStat
   @StatScope: BASE | ASSIGNED | FINAL
   ========================================================= */
CREATE   PROCEDURE build.sp_UpsertCharacterStat
    @CharacterId BIGINT,
    @StatCode NVARCHAR(30),
    @StatScope NVARCHAR(20),
    @StatValue DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatTypeId INT;
    SELECT @StatTypeId = StatTypeId
    FROM catalog.StatType
    WHERE StatCode = @StatCode
      AND IsActive = 1;
    IF @StatTypeId IS NULL
        THROW 50031, 'Stat code not found.', 1;
    IF @StatScope = 'BASE'
    BEGIN
        UPDATE build.CharacterBaseStat
        SET StatValue = @StatValue,
            UpdatedAt = SYSUTCDATETIME()
        WHERE CharacterId = @CharacterId
          AND StatTypeId = @StatTypeId;
        IF @@ROWCOUNT = 0
        BEGIN
            INSERT INTO build.CharacterBaseStat (CharacterId, StatTypeId, StatValue)
            VALUES (@CharacterId, @StatTypeId, @StatValue);
        END
    END
    ELSE IF @StatScope = 'ASSIGNED'
    BEGIN
        UPDATE build.CharacterAssignedStat
        SET AssignedValue = @StatValue,
            UpdatedAt = SYSUTCDATETIME()
        WHERE CharacterId = @CharacterId
          AND StatTypeId = @StatTypeId;
        IF @@ROWCOUNT = 0
        BEGIN
            INSERT INTO build.CharacterAssignedStat (CharacterId, StatTypeId, AssignedValue)
            VALUES (@CharacterId, @StatTypeId, @StatValue);
        END
    END
    ELSE IF @StatScope = 'FINAL'
    BEGIN
        UPDATE build.CharacterFinalStat
        SET FinalValue = @StatValue,
            ObservedAt = SYSUTCDATETIME()
        WHERE CharacterId = @CharacterId
          AND StatTypeId = @StatTypeId;
        IF @@ROWCOUNT = 0
        BEGIN
            INSERT INTO build.CharacterFinalStat (CharacterId, StatTypeId, FinalValue)
            VALUES (@CharacterId, @StatTypeId, @StatValue);
        END
    END
    ELSE
        THROW 50032, 'Invalid stat scope. Allowed values: BASE, ASSIGNED, FINAL.', 1;
    SELECT
        @CharacterId AS CharacterId,
        @StatCode AS StatCode,
        @StatScope AS StatScope,
        @StatValue AS StatValue;
END;
GO

-- SP: core.sp_CreateCharacter
/* =========================================================
   core.sp_CreateCharacter
   ========================================================= */
CREATE   PROCEDURE core.sp_CreateCharacter
    @UserId BIGINT,
    @FactionId INT,
    @ClassId INT,
    @CharacterName NVARCHAR(100),
    @Level INT = 80,
    @Title NVARCHAR(100) = NULL,
    @Mode NVARCHAR(50) = NULL,
    @Element NVARCHAR(50) = NULL,
    @IsPrimary BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @PlayerId BIGINT;
    DECLARE @CharacterId BIGINT;
    SELECT @PlayerId = PlayerId
    FROM core.Player
    WHERE UserId = @UserId
      AND IsActive = 1;
    IF @PlayerId IS NULL
        THROW 50011, 'Player not found for the provided user.', 1;
    IF EXISTS (
        SELECT 1
        FROM core.Character
        WHERE PlayerId = @PlayerId
          AND CharacterName = @CharacterName
    )
        THROW 50012, 'Character name already exists for this player.', 1;
    BEGIN TRANSACTION;
    IF @IsPrimary = 1
    BEGIN
        UPDATE core.Character
        SET IsPrimary = 0,
            UpdatedAt = SYSUTCDATETIME()
        WHERE PlayerId = @PlayerId;
    END
    INSERT INTO core.Character (
        PlayerId, FactionId, ClassId, CharacterName, Level, Title, Mode, Element, IsPrimary, IsActive
    )
    VALUES (
        @PlayerId, @FactionId, @ClassId, @CharacterName, @Level, @Title, @Mode, @Element, @IsPrimary, 1
    );
    SET @CharacterId = SCOPE_IDENTITY();
    COMMIT TRANSACTION;
    SELECT
        @CharacterId AS CharacterId,
        @PlayerId AS PlayerId,
        @CharacterName AS CharacterName,
        @Level AS CharacterLevel,
        @IsPrimary AS IsPrimary;
END;
GO

-- SP: core.sp_GetPrimaryCharacterContext
/* =========================================================
   core.sp_GetPrimaryCharacterContext
   Devuelve multiples result sets para backend REST/web/mobile
   ========================================================= */
CREATE   PROCEDURE core.sp_GetPrimaryCharacterContext
    @UserId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PlayerId BIGINT;
    DECLARE @CharacterId BIGINT;
    SELECT @PlayerId = P.PlayerId
    FROM core.Player P
    WHERE P.UserId = @UserId
      AND P.IsActive = 1;
    IF @PlayerId IS NULL
        THROW 50021, 'Player not found for the provided user.', 1;
    SELECT TOP (1) @CharacterId = C.CharacterId
    FROM core.Character C
    WHERE C.PlayerId = @PlayerId
      AND C.IsActive = 1
    ORDER BY C.IsPrimary DESC, C.CharacterId ASC;
    IF @CharacterId IS NULL
    BEGIN
        SELECT CAST(NULL AS BIGINT) AS CharacterId, CAST(NULL AS NVARCHAR(100)) AS CharacterName WHERE 1 = 0;
        SELECT CAST(NULL AS BIGINT) AS GuildId, CAST(NULL AS NVARCHAR(100)) AS GuildName WHERE 1 = 0;
        SELECT CAST(NULL AS BIGINT) AS CharacterEquipmentId WHERE 1 = 0;
        SELECT CAST(NULL AS BIGINT) AS EquippedItemSocketId WHERE 1 = 0;
        SELECT CAST(NULL AS BIGINT) AS CharacterBaseStatId WHERE 1 = 0;
        SELECT CAST(NULL AS BIGINT) AS CharacterAssignedStatId WHERE 1 = 0;
        SELECT CAST(NULL AS BIGINT) AS CharacterFinalStatId WHERE 1 = 0;
        RETURN;
    END
    SELECT
        C.CharacterId,
        C.CharacterName,
        C.Level,
        C.Title,
        C.Mode,
        C.Element,
        C.IsPrimary,
        F.FactionId,
        F.FactionCode,
        F.FactionName,
        CL.ClassId,
        CL.ClassCode,
        CL.ClassName
    FROM core.Character C
    JOIN core.Faction F ON F.FactionId = C.FactionId
    JOIN core.Class CL ON CL.ClassId = C.ClassId
    WHERE C.CharacterId = @CharacterId;
    SELECT
        GM.GuildMemberId,
        G.GuildId,
        G.GuildName,
        GR.GuildRankId,
        GR.RankCode,
        GR.RankName,
        GM.JoinDate
    FROM core.GuildMember GM
    JOIN core.Guild G ON G.GuildId = GM.GuildId
    JOIN core.GuildRank GR ON GR.GuildRankId = GM.GuildRankId
    WHERE GM.CharacterId = @CharacterId
      AND GM.IsActive = 1;
    SELECT
        CE.CharacterEquipmentId,
        CE.CharacterId,
        CE.EquipmentSlotId,
        ES.SlotCode,
        ES.SlotName,
        CE.ItemId,
        I.ItemCode,
        I.ItemName,
        CE.ItemTypeId,
        IT.ItemTypeCode,
        IT.ItemTypeName,
        I.RequiredLevel,
        I.MaxSockets,
        I.Description,
        I.FlavorText,
        CE.DisplayNameOverride,
        CE.DescriptionOverride,
        CE.EquippedAt,
        CE.UpdatedAt
    FROM equipment.CharacterEquipment CE
    JOIN catalog.EquipmentSlot ES ON ES.EquipmentSlotId = CE.EquipmentSlotId
    JOIN catalog.Item I ON I.ItemId = CE.ItemId
    JOIN catalog.ItemType IT ON IT.ItemTypeId = CE.ItemTypeId
    WHERE CE.CharacterId = @CharacterId
    ORDER BY ES.SortOrder;
    SELECT
        EIS.EquippedItemSocketId,
        EIS.CharacterEquipmentId,
        EIS.SocketNumber,
        EIS.IsOpen,
        EIL.EquippedItemLapisId,
        EIL.LapisId,
        L.LapisCode,
        L.LapisName,
        L.LapisLevel
    FROM equipment.EquippedItemSocket EIS
    LEFT JOIN equipment.EquippedItemLapis EIL ON EIL.EquippedItemSocketId = EIS.EquippedItemSocketId
    LEFT JOIN catalog.Lapis L ON L.LapisId = EIL.LapisId
    WHERE EIS.CharacterEquipmentId IN (
        SELECT CharacterEquipmentId
        FROM equipment.CharacterEquipment
        WHERE CharacterId = @CharacterId
    )
    ORDER BY EIS.CharacterEquipmentId, EIS.SocketNumber;
    SELECT
        CBS.CharacterBaseStatId,
        ST.StatCode,
        ST.StatName,
        CBS.StatValue,
        CBS.UpdatedAt
    FROM build.CharacterBaseStat CBS
    JOIN catalog.StatType ST ON ST.StatTypeId = CBS.StatTypeId
    WHERE CBS.CharacterId = @CharacterId
    ORDER BY ST.StatCode;
    SELECT
        CAS.CharacterAssignedStatId,
        ST.StatCode,
        ST.StatName,
        CAS.AssignedValue,
        CAS.UpdatedAt
    FROM build.CharacterAssignedStat CAS
    JOIN catalog.StatType ST ON ST.StatTypeId = CAS.StatTypeId
    WHERE CAS.CharacterId = @CharacterId
    ORDER BY ST.StatCode;
    SELECT
        CFS.CharacterFinalStatId,
        ST.StatCode,
        ST.StatName,
        CFS.FinalValue,
        CFS.ObservedAt
    FROM build.CharacterFinalStat CFS
    JOIN catalog.StatType ST ON ST.StatTypeId = CFS.StatTypeId
    WHERE CFS.CharacterId = @CharacterId
    ORDER BY ST.StatCode;
END;
GO

-- SP: core.sp_ListCharactersByUser
CREATE   PROCEDURE core.sp_ListCharactersByUser
    @UserId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        C.CharacterId,
        C.CharacterName,
        C.Level,
        C.Title,
        C.Mode,
        C.Element,
        C.IsPrimary,
        C.IsActive,
        F.FactionCode,
        F.FactionName,
        CL.ClassCode,
        CL.ClassName,
        G.GuildName,
        GR.RankCode,
        GR.RankName
    FROM core.Player P
    JOIN core.Character C
        ON C.PlayerId = P.PlayerId
    JOIN core.Faction F
        ON F.FactionId = C.FactionId
    JOIN core.Class CL
        ON CL.ClassId = C.ClassId
    LEFT JOIN core.GuildMember GM
        ON GM.CharacterId = C.CharacterId
       AND GM.IsActive = 1
    LEFT JOIN core.Guild G
        ON G.GuildId = GM.GuildId
    LEFT JOIN core.GuildRank GR
        ON GR.GuildRankId = GM.GuildRankId
    WHERE P.UserId = @UserId
      AND P.IsActive = 1
    ORDER BY C.IsPrimary DESC, C.CharacterName ASC;
END;
GO

-- SP: equipment.sp_ClearEquippedItemLapis
/* =========================================================
   equipment.sp_ClearEquippedItemLapis
   ========================================================= */
CREATE   PROCEDURE equipment.sp_ClearEquippedItemLapis
    @CharacterEquipmentId BIGINT,
    @SocketNumber INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE EIL
    FROM equipment.EquippedItemLapis EIL
    JOIN equipment.EquippedItemSocket EIS ON EIS.EquippedItemSocketId = EIL.EquippedItemSocketId
    WHERE EIS.CharacterEquipmentId = @CharacterEquipmentId
      AND EIS.SocketNumber = @SocketNumber;
    SELECT
        @CharacterEquipmentId AS CharacterEquipmentId,
        @SocketNumber AS SocketNumber,
        @@ROWCOUNT AS RowsDeleted;
END;
GO

-- SP: equipment.sp_GetCharacterEquipmentContext
CREATE   PROCEDURE equipment.sp_GetCharacterEquipmentContext
    @CharacterId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        C.CharacterId,
        C.CharacterName,
        ES.SlotCode,
        ES.SlotName,
        CE.CharacterEquipmentId,
        I.ItemId,
        I.ItemCode,
        I.ItemName,
        I.RequiredLevel,
        I.MaxSockets,
        I.Description,
        I.FlavorText,
        CE.DisplayNameOverride,
        CE.DescriptionOverride,
        CE.EquippedAt,
        CE.UpdatedAt
    FROM core.Character C
    JOIN equipment.CharacterEquipment CE
        ON CE.CharacterId = C.CharacterId
    JOIN catalog.EquipmentSlot ES
        ON ES.EquipmentSlotId = CE.EquipmentSlotId
    JOIN catalog.Item I
        ON I.ItemId = CE.ItemId
    WHERE C.CharacterId = @CharacterId
    ORDER BY ES.SortOrder;
    SELECT
        CE.CharacterEquipmentId,
        ES.SlotCode,
        I.ItemName,
        S.EquippedItemSocketId,
        S.SocketNumber,
        S.IsOpen,
        L.LapisId,
        L.LapisCode,
        L.LapisName,
        L.LapisLevel
    FROM equipment.CharacterEquipment CE
    JOIN catalog.EquipmentSlot ES
        ON ES.EquipmentSlotId = CE.EquipmentSlotId
    JOIN catalog.Item I
        ON I.ItemId = CE.ItemId
    LEFT JOIN equipment.EquippedItemSocket S
        ON S.CharacterEquipmentId = CE.CharacterEquipmentId
    LEFT JOIN equipment.EquippedItemLapis EIL
        ON EIL.EquippedItemSocketId = S.EquippedItemSocketId
    LEFT JOIN catalog.Lapis L
        ON L.LapisId = EIL.LapisId
    WHERE CE.CharacterId = @CharacterId
    ORDER BY ES.SortOrder, S.SocketNumber;
    SELECT
        CE.CharacterEquipmentId,
        ES.SlotCode,
        I.ItemName,
        ST.StatCode,
        ST.StatName,
        IS1.StatValue,
        IS1.ValueSource
    FROM equipment.CharacterEquipment CE
    JOIN catalog.EquipmentSlot ES
        ON ES.EquipmentSlotId = CE.EquipmentSlotId
    JOIN catalog.Item I
        ON I.ItemId = CE.ItemId
    JOIN catalog.ItemStat IS1
        ON IS1.ItemId = I.ItemId
    JOIN catalog.StatType ST
        ON ST.StatTypeId = IS1.StatTypeId
    WHERE CE.CharacterId = @CharacterId
    ORDER BY ES.SortOrder, ST.StatCode, IS1.ValueSource;
END;
GO

-- SP: equipment.sp_GetCharacterScreenByUser
CREATE PROCEDURE equipment.sp_GetCharacterScreenByUser
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
    -- Result 1: Character info
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
    JOIN core.Faction F ON F.FactionId = C.FactionId
    JOIN core.Class CL ON CL.ClassId = C.ClassId
    WHERE C.CharacterId = @CharacterId;
    -- Result 2: All 15 slots with equipped item + sockets + lapis
    SELECT
        ES.SlotCode,
        ES.SlotName,
        ES.SortOrder,
        CE.CharacterEquipmentId,
        I.ItemId,
        I.ItemCode,
        COALESCE(CE.DisplayNameOverride, I.ItemName) AS ItemName,
        I.MaxSockets,
        S.EquippedItemSocketId,
        S.SocketNumber,
        S.IsOpen,
        L.LapisId,
        L.LapisCode,
        L.LapisName,
        L.LapisLevel,
        LT.LapisTypeCode
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
    -- Result 3: Full lapis catalog for the picker
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
        ST.StatCode,
        ST.StatName,
        LE.EffectValue
    FROM catalog.Lapis L
    JOIN catalog.LapisType LT ON LT.LapisTypeId = L.LapisTypeId
    LEFT JOIN catalog.LapisEffect LE ON LE.LapisId = L.LapisId
    LEFT JOIN catalog.StatType ST ON ST.StatTypeId = LE.StatTypeId
    WHERE L.IsActive = 1
    ORDER BY L.LapisLevel, L.LapisCode;
END;
GO

-- SP: equipment.sp_ListPendingLapisByCharacter
CREATE   PROCEDURE equipment.sp_ListPendingLapisByCharacter
    @CharacterId BIGINT,
    @ArmorOnly BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        C.CharacterId,
        C.CharacterName,
        CL.ClassCode,
        CL.ClassName,
        ES.SlotCode,
        ES.SlotName,
        I.ItemId,
        I.ItemCode,
        I.ItemName,
        CE.CharacterEquipmentId,
        S.EquippedItemSocketId,
        S.SocketNumber
    FROM core.Character C
    JOIN core.Class CL
        ON CL.ClassId = C.ClassId
    JOIN equipment.CharacterEquipment CE
        ON CE.CharacterId = C.CharacterId
    JOIN catalog.EquipmentSlot ES
        ON ES.EquipmentSlotId = CE.EquipmentSlotId
    JOIN catalog.Item I
        ON I.ItemId = CE.ItemId
    JOIN equipment.EquippedItemSocket S
        ON S.CharacterEquipmentId = CE.CharacterEquipmentId
       AND S.IsOpen = 1
    LEFT JOIN equipment.EquippedItemLapis EIL
        ON EIL.EquippedItemSocketId = S.EquippedItemSocketId
    WHERE C.CharacterId = @CharacterId
      AND C.IsActive = 1
      AND EIL.EquippedItemLapisId IS NULL
      AND (
            @ArmorOnly = 0
            OR ES.SlotCode IN ('HELMET', 'GLOVES', 'PANTS', 'BOOTS')
          )
    ORDER BY
        ES.SortOrder,
        S.SocketNumber;
END;
GO

-- SP: equipment.sp_SaveCharacterLapisConfig
CREATE PROCEDURE equipment.sp_SaveCharacterLapisConfig
    @CharacterId BIGINT,
    @ConfigXml   XML
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Config TABLE (
        CharacterEquipmentId BIGINT,
        SocketNumber         INT,
        LapisId              BIGINT NULL
    );
    INSERT INTO @Config (CharacterEquipmentId, SocketNumber, LapisId)
    SELECT
        node.value('(CharacterEquipmentId)[1]', 'BIGINT'),
        node.value('(SocketNumber)[1]',         'INT'),
        NULLIF(node.value('(LapisId)[1]',       'NVARCHAR(20)'), '')
    FROM @ConfigXml.nodes('/config/socket') AS T(node);
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Limpiar sockets donde LapisId es null
        DELETE EIL
        FROM equipment.EquippedItemLapis EIL
        JOIN equipment.EquippedItemSocket S
            ON S.EquippedItemSocketId = EIL.EquippedItemSocketId
        JOIN @Config C
            ON C.CharacterEquipmentId = S.CharacterEquipmentId
           AND C.SocketNumber = S.SocketNumber
           AND C.LapisId IS NULL;
        UPDATE S SET S.IsOpen = 1
        FROM equipment.EquippedItemSocket S
        JOIN @Config C
            ON C.CharacterEquipmentId = S.CharacterEquipmentId
           AND C.SocketNumber = S.SocketNumber
           AND C.LapisId IS NULL;
        -- Upsert lapis donde LapisId tiene valor
        MERGE equipment.EquippedItemLapis AS target
        USING (
            SELECT
                S.EquippedItemSocketId,
                S.CharacterEquipmentId,
                CE.ItemTypeId,
                C.LapisId
            FROM @Config C
            JOIN equipment.EquippedItemSocket S
                ON S.CharacterEquipmentId = C.CharacterEquipmentId
               AND S.SocketNumber = C.SocketNumber
            JOIN equipment.CharacterEquipment CE
                ON CE.CharacterEquipmentId = S.CharacterEquipmentId
            WHERE C.LapisId IS NOT NULL
        ) AS source
        ON target.EquippedItemSocketId = source.EquippedItemSocketId
        WHEN MATCHED THEN
            UPDATE SET target.LapisId = source.LapisId, target.InsertedAt = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (EquippedItemSocketId, CharacterEquipmentId, ItemTypeId, LapisId, InsertedAt)
            VALUES (source.EquippedItemSocketId, source.CharacterEquipmentId, source.ItemTypeId, source.LapisId, SYSUTCDATETIME());
        UPDATE S SET S.IsOpen = 0
        FROM equipment.EquippedItemSocket S
        JOIN @Config C
            ON C.CharacterEquipmentId = S.CharacterEquipmentId
           AND C.SocketNumber = S.SocketNumber
           AND C.LapisId IS NOT NULL;
        COMMIT TRANSACTION;
        SELECT
            S.CharacterEquipmentId,
            S.SocketNumber,
            S.IsOpen,
            EIL.LapisId,
            L.LapisCode,
            L.LapisName,
            L.LapisLevel
        FROM equipment.EquippedItemSocket S
        JOIN equipment.CharacterEquipment CE ON CE.CharacterEquipmentId = S.CharacterEquipmentId
        LEFT JOIN equipment.EquippedItemLapis EIL ON EIL.EquippedItemSocketId = S.EquippedItemSocketId
        LEFT JOIN catalog.Lapis L ON L.LapisId = EIL.LapisId
        WHERE CE.CharacterId = @CharacterId
        ORDER BY S.CharacterEquipmentId, S.SocketNumber;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- SP: equipment.sp_UpsertCharacterEquipment
/* =========================================================
   equipment.sp_UpsertCharacterEquipment
   ========================================================= */
CREATE   PROCEDURE equipment.sp_UpsertCharacterEquipment
    @CharacterId BIGINT,
    @EquipmentSlotCode NVARCHAR(30),
    @ItemId BIGINT,
    @DisplayNameOverride NVARCHAR(200) = NULL,
    @DescriptionOverride NVARCHAR(2000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @EquipmentSlotId INT;
    DECLARE @ItemTypeId INT;
    DECLARE @CharacterEquipmentId BIGINT;
    DECLARE @MaxSockets INT;
    SELECT
        @EquipmentSlotId = EquipmentSlotId
    FROM catalog.EquipmentSlot
    WHERE SlotCode = @EquipmentSlotCode
      AND IsActive = 1;
    IF @EquipmentSlotId IS NULL
        THROW 50041, 'Equipment slot not found.', 1;
    SELECT
        @ItemTypeId = ItemTypeId,
        @MaxSockets = MaxSockets
    FROM catalog.Item
    WHERE ItemId = @ItemId
      AND IsActive = 1;
    IF @ItemTypeId IS NULL
        THROW 50042, 'Item not found.', 1;
    IF NOT EXISTS (
        SELECT 1
        FROM catalog.ItemTypeSlot
        WHERE ItemTypeId = @ItemTypeId
          AND EquipmentSlotId = @EquipmentSlotId
    )
        THROW 50043, 'The item type is not valid for the requested equipment slot.', 1;
    BEGIN TRANSACTION;
    UPDATE equipment.CharacterEquipment
    SET ItemId = @ItemId,
        ItemTypeId = @ItemTypeId,
        DisplayNameOverride = @DisplayNameOverride,
        DescriptionOverride = @DescriptionOverride,
        UpdatedAt = SYSUTCDATETIME()
    WHERE CharacterId = @CharacterId
      AND EquipmentSlotId = @EquipmentSlotId;
    IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO equipment.CharacterEquipment (
            CharacterId, EquipmentSlotId, ItemId, ItemTypeId, DisplayNameOverride, DescriptionOverride
        )
        VALUES (
            @CharacterId, @EquipmentSlotId, @ItemId, @ItemTypeId, @DisplayNameOverride, @DescriptionOverride
        );
    END
    SELECT @CharacterEquipmentId = CharacterEquipmentId
    FROM equipment.CharacterEquipment
    WHERE CharacterId = @CharacterId
      AND EquipmentSlotId = @EquipmentSlotId;
    DELETE EIL
    FROM equipment.EquippedItemLapis EIL
    JOIN equipment.EquippedItemSocket EIS ON EIS.EquippedItemSocketId = EIL.EquippedItemSocketId
    WHERE EIS.CharacterEquipmentId = @CharacterEquipmentId
      AND EIS.SocketNumber > @MaxSockets;
    DELETE FROM equipment.EquippedItemSocket
    WHERE CharacterEquipmentId = @CharacterEquipmentId
      AND SocketNumber > @MaxSockets;
    ;WITH Numbers AS (
        SELECT 1 AS SocketNumber
        UNION ALL
        SELECT SocketNumber + 1
        FROM Numbers
        WHERE SocketNumber + 1 <= @MaxSockets
    )
    INSERT INTO equipment.EquippedItemSocket (
        CharacterEquipmentId, ItemTypeId, SocketNumber, IsOpen
    )
    SELECT
        @CharacterEquipmentId,
        @ItemTypeId,
        N.SocketNumber,
        1
    FROM Numbers N
    WHERE NOT EXISTS (
        SELECT 1
        FROM equipment.EquippedItemSocket EIS
        WHERE EIS.CharacterEquipmentId = @CharacterEquipmentId
          AND EIS.SocketNumber = N.SocketNumber
    )
    OPTION (MAXRECURSION 100);
    COMMIT TRANSACTION;
    SELECT
        @CharacterEquipmentId AS CharacterEquipmentId,
        @CharacterId AS CharacterId,
        @EquipmentSlotId AS EquipmentSlotId,
        @ItemId AS ItemId,
        @ItemTypeId AS ItemTypeId,
        @MaxSockets AS MaxSockets;
END;
GO

-- SP: equipment.sp_UpsertEquippedItemLapis
/* =========================================================
   equipment.sp_UpsertEquippedItemLapis
   ========================================================= */
CREATE   PROCEDURE equipment.sp_UpsertEquippedItemLapis
    @CharacterEquipmentId BIGINT,
    @SocketNumber INT,
    @LapisId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @EquippedItemSocketId BIGINT;
    DECLARE @ItemTypeId INT;
    SELECT
        @ItemTypeId = ItemTypeId
    FROM equipment.CharacterEquipment
    WHERE CharacterEquipmentId = @CharacterEquipmentId;
    IF @ItemTypeId IS NULL
        THROW 50051, 'Character equipment not found.', 1;
    SELECT @EquippedItemSocketId = EquippedItemSocketId
    FROM equipment.EquippedItemSocket
    WHERE CharacterEquipmentId = @CharacterEquipmentId
      AND SocketNumber = @SocketNumber;
    IF @EquippedItemSocketId IS NULL
        THROW 50052, 'Socket not found for the requested equipment item.', 1;
    IF NOT EXISTS (
        SELECT 1
        FROM catalog.LapisApplicableItemType
        WHERE LapisId = @LapisId
          AND ItemTypeId = @ItemTypeId
    )
        THROW 50053, 'The selected lapis is not compatible with this item type.', 1;
    IF EXISTS (
        SELECT 1
        FROM equipment.EquippedItemLapis
        WHERE CharacterEquipmentId = @CharacterEquipmentId
          AND LapisId = @LapisId
          AND EquippedItemSocketId <> @EquippedItemSocketId
    )
        THROW 50054, 'The same lapis cannot be repeated within the same equipped item.', 1;
    UPDATE equipment.EquippedItemLapis
    SET LapisId = @LapisId,
        ItemTypeId = @ItemTypeId,
        InsertedAt = SYSUTCDATETIME()
    WHERE EquippedItemSocketId = @EquippedItemSocketId;
    IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO equipment.EquippedItemLapis (
            EquippedItemSocketId, CharacterEquipmentId, ItemTypeId, LapisId
        )
        VALUES (
            @EquippedItemSocketId, @CharacterEquipmentId, @ItemTypeId, @LapisId
        );
    END
    SELECT
        @CharacterEquipmentId AS CharacterEquipmentId,
        @SocketNumber AS SocketNumber,
        @LapisId AS LapisId;
END;
GO

-- SP: notification.sp_UpsertDeviceToken
CREATE   PROCEDURE notification.sp_UpsertDeviceToken
    @UserId BIGINT,
    @Platform NVARCHAR(20),
    @DeviceToken NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF NOT EXISTS (
        SELECT 1
        FROM auth.Users
        WHERE UserId = @UserId
          AND IsActive = 1
    )
        THROW 50061, 'Active user not found.', 1;
    IF @Platform NOT IN ('ANDROID', 'IOS')
        THROW 50062, 'Invalid platform. Allowed values: ANDROID, IOS.', 1;
    UPDATE notification.DeviceToken
    SET DeviceToken = @DeviceToken,
        IsActive = 1,
        LastSeenAt = SYSUTCDATETIME(),
        UpdatedAt = SYSUTCDATETIME()
    WHERE UserId = @UserId
      AND Platform = @Platform;
    IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO notification.DeviceToken (
            UserId, Platform, DeviceToken, IsActive, LastSeenAt
        )
        VALUES (
            @UserId, @Platform, @DeviceToken, 1, SYSUTCDATETIME()
        );
    END
    SELECT
        DeviceTokenId,
        UserId,
        Platform,
        DeviceToken,
        IsActive,
        LastSeenAt,
        UpdatedAt
    FROM notification.DeviceToken
    WHERE UserId = @UserId
      AND Platform = @Platform;
END;
GO

