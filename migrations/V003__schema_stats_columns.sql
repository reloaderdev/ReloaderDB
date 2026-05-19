-- V003: Agrega columnas de stats calculables a Lapis, Item y CharacterEquipment

-- catalog.Lapis: stats del lapis
ALTER TABLE [catalog].[Lapis]
ADD [StatSTR]   int NULL,
    [StatDEX]   int NULL,
    [StatREC]   int NULL,
    [StatLUC]   int NULL,
    [StatINT]   int NULL,
    [StatWIS]   int NULL,
    [StatMaxHP] int NULL;
GO

-- catalog.Item: stats base del item
ALTER TABLE [catalog].[Item]
ADD [StatDefensePower]       int NULL,
    [StatResistence]         int NULL,
    [StatBaseMaxHP]          int NULL,
    [StatBaseMaxSP]          int NULL,
    [StatBaseMaxMP]          int NULL,
    [StatBaseSTR]            int NULL,
    [StatBaseDEX]            int NULL,
    [StatBaseREC]            int NULL,
    [StatBaseLUC]            int NULL,
    [StatBaseINT]            int NULL,
    [StatBaseWIS]            int NULL,
    [StatAttackPowerMin]     int NULL,
    [StatAttackPowerMax]     int NULL,
    [StatCriticalDamageBonus] int NULL,
    [StatElement]            nvarchar(50) NULL,
    [RecStatHP]              int NULL,
    [RecStatSTR]             int NULL,
    [RecStatDEX]             int NULL,
    [RecStatREC]             int NULL,
    [RecStatLUC]             int NULL,
    [RecStatINT]             int NULL,
    [RecStatWIS]             int NULL;
GO

-- equipment.CharacterEquipment: datos del enchant por item equipado
ALTER TABLE [equipment].[CharacterEquipment]
ADD [EnchantLevel]     int NULL,
    [DamageAbsorption] int NULL;
GO

-- Nuevo LapisType: MECHANIC
SET IDENTITY_INSERT [catalog].[LapisType] ON;
INSERT INTO [catalog].[LapisType] ([LapisTypeId], [LapisTypeCode], [LapisTypeName])
VALUES (5, 'MECHANIC', 'Mechanic');
SET IDENTITY_INSERT [catalog].[LapisType] OFF;
GO
