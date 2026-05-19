-- V005: Renombra items existentes a nombres reales y pobla stats. Agrega 4 items nuevos.

-- 1. Luminous Tyrant's Helm (Casco - ItemId=1)
UPDATE [catalog].[Item] SET
    [ItemCode]            = 'ITEM_LUMINOUS_TYRANTS_HELM',
    [ItemName]            = N'Luminous Tyrant''s Helm',
    [Description]         = N'Casco de la serie Luminous Tyrant.',
    [FlavorText]          = N'El cazador que lo lleva no conoce el miedo.',
    [MaxSockets]          = 6,
    [StatDefensePower]    = 181,  [StatResistence]  = 157,
    [StatBaseMaxHP]       = 6451, [StatBaseMaxSP]   = 2933,
    [StatBaseSTR]         = 192,  [StatBaseDEX]     = 122,
    [StatBaseREC]         = 30,   [StatBaseLUC]     = 239,
    [RecStatHP]           = 4400, [RecStatSTR]      = 44,
    [RecStatDEX]          = 69,   [RecStatLUC]      = 98
WHERE [ItemId] = 1;

-- 2. Luminous Tyrant's Bracers (Guantes - ItemId=2)
UPDATE [catalog].[Item] SET
    [ItemCode]            = 'ITEM_LUMINOUS_TYRANTS_BRACERS',
    [ItemName]            = N'Luminous Tyrant''s Bracers',
    [Description]         = N'Guantelete de la serie Luminous Tyrant.',
    [FlavorText]          = N'La presa nunca escapa de estas manos.',
    [MaxSockets]          = 6,
    [StatDefensePower]    = 326,  [StatResistence]  = 282,
    [StatBaseMaxHP]       = 6301, [StatBaseMaxSP]   = 2403,
    [StatBaseSTR]         = 283,  [StatBaseDEX]     = 70,
    [StatBaseREC]         = 30,   [StatBaseLUC]     = 259,
    [RecStatHP]           = 4400, [RecStatSTR]      = 44,
    [RecStatDEX]          = 69,   [RecStatLUC]      = 98
WHERE [ItemId] = 2;

-- 3. Luminous Tyrant's Gaiters (Pantalon - ItemId=3)
UPDATE [catalog].[Item] SET
    [ItemCode]            = 'ITEM_LUMINOUS_TYRANTS_GAITERS',
    [ItemName]            = N'Luminous Tyrant''s Gaiters',
    [Description]         = N'Armadura inferior de la serie Luminous Tyrant.',
    [FlavorText]          = N'Cada paso resuena con poder absoluto.',
    [MaxSockets]          = 6,
    [StatDefensePower]    = 653,  [StatResistence]  = 565,
    [StatBaseMaxHP]       = 9916, [StatBaseMaxSP]   = 7222,
    [StatBaseSTR]         = 179,  [StatBaseDEX]     = 149,
    [StatBaseREC]         = 30,   [StatBaseLUC]     = 272,
    [RecStatHP]           = 4400, [RecStatSTR]      = 44,
    [RecStatDEX]          = 69,   [RecStatLUC]      = 98
WHERE [ItemId] = 3;

-- 4. Luminous Tyrant's Boots (Botas - ItemId=4)
UPDATE [catalog].[Item] SET
    [ItemCode]            = 'ITEM_LUMINOUS_TYRANTS_BOOTS',
    [ItemName]            = N'Luminous Tyrant''s Boots',
    [Description]         = N'Botas de la serie Luminous Tyrant.',
    [FlavorText]          = N'La velocidad de la muerte encarnada.',
    [MaxSockets]          = 6,
    [StatDefensePower]    = 435,  [StatResistence]  = 377,
    [StatBaseMaxHP]       = 3033, [StatBaseMaxSP]   = 4044,
    [StatBaseSTR]         = 95,   [StatBaseDEX]     = 219,
    [StatBaseLUC]         = 208,
    [RecStatHP]           = 4400, [RecStatSTR]      = 44,
    [RecStatDEX]          = 69,   [RecStatLUC]      = 98
WHERE [ItemId] = 4;

-- 5. Pudle Chum (Mascota - ItemId=5)
UPDATE [catalog].[Item] SET
    [ItemCode]                = 'ITEM_PUDLE_CHUM',
    [ItemName]                = N'Pudle Chum',
    [Description]             = N'Mascota de combate de alto nivel.',
    [FlavorText]              = N'Fiel compañero en cada batalla.',
    [MaxSockets]              = 0,
    [StatBaseSTR]             = 15, [StatBaseDEX] = 15, [StatBaseREC] = 15,
    [StatBaseINT]             = 15, [StatBaseWIS] = 15, [StatBaseLUC] = 15,
    [StatCriticalDamageBonus] = 30,
    [RecStatHP]               = 5200, [RecStatSTR] = 94, [RecStatLUC] = 17
WHERE [ItemId] = 5;

-- 6. Mion Mantle (Capa - ItemId=6)
UPDATE [catalog].[Item] SET
    [ItemCode]        = 'ITEM_MION_MANTLE',
    [ItemName]        = N'Mion Mantle',
    [Description]     = N'Manto con bonificaciones generales.',
    [FlavorText]      = N'El espiritu del Mion protege a su portador.',
    [MaxSockets]      = 0,
    [StatBaseMaxHP]   = 1000, [StatBaseMaxSP] = 2000, [StatBaseMaxMP] = 2000,
    [StatBaseDEX]     = 32,   [StatBaseREC]   = 10,   [StatBaseLUC]   = 32,
    [RecStatHP]       = 4000, [RecStatSTR]    = 90,
    [RecStatDEX]      = 65,   [RecStatLUC]    = 40
WHERE [ItemId] = 6;

-- 7. Eternal Bonespike Amulet (Amuleto - ItemId=7)
UPDATE [catalog].[Item] SET
    [ItemCode]    = 'ITEM_ETERNAL_BONESPIKE_AMULET',
    [ItemName]    = N'Eternal Bonespike Amulet',
    [Description] = N'Amuleto Eterno con picos de hueso.',
    [FlavorText]  = N'Poder fisico concentrado en cada pua.',
    [MaxSockets]  = 4,
    [RecStatSTR]  = 90, [RecStatDEX] = 40, [RecStatREC] = 40, [RecStatLUC] = 65
WHERE [ItemId] = 7;

-- 8. Eternal Bonespike Ring (Anillo izquierdo - ItemId=8)
UPDATE [catalog].[Item] SET
    [ItemCode]    = 'ITEM_ETERNAL_BONESPIKE_RING',
    [ItemName]    = N'Eternal Bonespike Ring',
    [Description] = N'Anillo Eterno con picos de hueso.',
    [FlavorText]  = N'Anillo perfecto reforzado con poder fisico.',
    [MaxSockets]  = 4,
    [RecStatSTR]  = 90, [RecStatDEX] = 40, [RecStatREC] = 40, [RecStatLUC] = 65
WHERE [ItemId] = 8;

-- 9. Eternal Bonespike Loop (Brazalete izquierdo - ItemId=9)
UPDATE [catalog].[Item] SET
    [ItemCode]    = 'ITEM_ETERNAL_BONESPIKE_LOOP',
    [ItemName]    = N'Eternal Bonespike Loop',
    [Description] = N'Brazalete Eterno izquierdo con picos de hueso.',
    [FlavorText]  = N'Brazalete perfecto reforzado con poder fisico.',
    [MaxSockets]  = 4,
    [RecStatSTR]  = 90, [RecStatDEX] = 40, [RecStatREC] = 40, [RecStatLUC] = 65
WHERE [ItemId] = 9;

-- 10. Emberstone Annihilation Javelin (Arma - ItemId=10)
UPDATE [catalog].[Item] SET
    [ItemCode]           = 'ITEM_EMBERSTONE_JAVELIN',
    [ItemName]           = N'Emberstone Annihilation Javelin',
    [Description]        = N'Jabalina de aniquilacion de Emberstone. Tipo: Javelin. Clase: Hunter.',
    [FlavorText]         = N'Arma de proporciones cataclisMicas, vacia del corazon de la furia nociva.',
    [MaxSockets]         = 6,
    [StatElement]        = N'Earth II',
    [StatAttackPowerMin] = 5561, [StatAttackPowerMax] = 6167,
    [StatBaseSTR]        = 185,  [StatBaseDEX]        = 73,  [StatBaseLUC] = 197,
    [RecStatSTR]         = 98,   [RecStatDEX]         = 50,
    [RecStatLUC]         = 75,   [RecStatREC]         = 50
WHERE [ItemId] = 10;

-- 11. Luminous Tyrant's Mail (Top/Armadura superior - ItemId=11, agregado en V002)
UPDATE [catalog].[Item] SET
    [ItemCode]         = 'ITEM_LUMINOUS_TYRANTS_MAIL',
    [ItemName]         = N'Luminous Tyrant''s Mail',
    [Description]      = N'Armadura superior de la serie Luminous Tyrant.',
    [FlavorText]       = N'Forjada en la tierra para resistir cualquier golpe.',
    [MaxSockets]       = 6,
    [StatElement]      = N'Earth II',
    [StatDefensePower] = 1080, [StatResistence]  = 1080,
    [StatBaseMaxHP]    = 9933, [StatBaseMaxSP]   = 9244,
    [StatBaseSTR]      = 201,  [StatBaseDEX]     = 201,  [StatBaseLUC] = 209,
    [RecStatHP]        = 4400, [RecStatSTR]      = 44,
    [RecStatDEX]       = 69,   [RecStatLUC]      = 98
WHERE [ItemId] = 11;

-- 12. Ethereal Quiver (Escudo/off-hand - ItemId=12, agregado en V002)
UPDATE [catalog].[Item] SET
    [ItemCode]         = 'ITEM_ETHEREAL_QUIVER',
    [ItemName]         = N'Ethereal Quiver',
    [Description]      = N'Carcaj etéreo con alta absorcion de daño.',
    [FlavorText]       = N'Contiene flechas que nunca fallan su objetivo.',
    [MaxSockets]       = 4,
    [StatDefensePower] = 158,
    [RecStatHP]        = 2400, [RecStatDEX] = 60, [RecStatLUC] = 11
WHERE [ItemId] = 12;
GO

-- 13. Nuevos items (Ids 13-16)
SET IDENTITY_INSERT [catalog].[Item] ON;
INSERT INTO [catalog].[Item]
    ([ItemId],[ItemTypeId],[BindTypeId],[ItemCode],[ItemName],[RequiredLevel],[Description],[FlavorText],[MaxSockets],[CanDye],[IsActive],[CreatedAt],
     [RecStatSTR],[RecStatDEX],[RecStatREC],[RecStatLUC])
VALUES
(13, 12, 3, 'ITEM_ETERNAL_BONESPIKE_BAND',     N'Eternal Bonespike Band',     80, N'Anillo Eterno derecho con picos de hueso.',     N'Anillo perfecto reforzado con poder fisico.',    4, 0, 1, SYSUTCDATETIME(), 90, 40, 40, 65),
(14, 13, 3, 'ITEM_ETERNAL_BONESPIKE_BRACELET', N'Eternal Bonespike Bracelet', 80, N'Brazalete Eterno derecho con picos de hueso.', N'Brazalete perfecto reforzado con poder fisico.', 4, 0, 1, SYSUTCDATETIME(), 90, 40, 40, 65);
SET IDENTITY_INSERT [catalog].[Item] OFF;
GO

SET IDENTITY_INSERT [catalog].[Item] ON;
INSERT INTO [catalog].[Item]
    ([ItemId],[ItemTypeId],[BindTypeId],[ItemCode],[ItemName],[RequiredLevel],[Description],[FlavorText],[MaxSockets],[CanDye],[IsActive],[CreatedAt],
     [StatDefensePower],[StatResistence])
VALUES
(15, 10, 3, 'ITEM_WINGS_ICY_SPLENDOR', N'Wings of Icy Splendor', 61, N'Alas de esplendor helado. Lv.61.', N'El frio del abismo se manifiesta en cada pluma.', 0, 0, 1, SYSUTCDATETIME(), 150, 150);
SET IDENTITY_INSERT [catalog].[Item] OFF;
GO

SET IDENTITY_INSERT [catalog].[Item] ON;
INSERT INTO [catalog].[Item]
    ([ItemId],[ItemTypeId],[BindTypeId],[ItemCode],[ItemName],[RequiredLevel],[Description],[FlavorText],[MaxSockets],[CanDye],[IsActive],[CreatedAt],
     [StatBaseSTR],[StatBaseDEX],[StatBaseREC],[StatBaseINT],[StatBaseWIS],[StatBaseLUC],[RecStatHP],[RecStatSTR],[RecStatLUC])
VALUES
(16, 14, 3, 'ITEM_CRITICAL_ROYAL_AVENGER', N'Critical Royal Avenger', 80, N'Traje de combate con bonus de stats balanceados.', N'El vengador real que todo cazador merece.', 0, 0, 1, SYSUTCDATETIME(), 20, 20, 20, 20, 20, 20, 4200, 88, 34);
SET IDENTITY_INSERT [catalog].[Item] OFF;
GO
