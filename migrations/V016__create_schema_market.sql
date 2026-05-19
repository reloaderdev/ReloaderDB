-- ============================================================
-- V016__create_schema_market.sql
-- Schema market: marketplace de items entre jugadores
-- Fase 1 — listings, tags, fotos, contacto, reputación, notificaciones
-- ============================================================

-- ============================================================
-- SCHEMA
-- ============================================================
CREATE SCHEMA [market];
GO

-- ============================================================
-- market.Category
-- Tags que el vendedor selecciona al publicar
-- Administrado desde panel admin — sin tocar código
-- ============================================================
CREATE TABLE [market].[Category] (
    [CategoryId]   int            IDENTITY(1,1) NOT NULL,
    [CategoryCode] nvarchar(30)   NOT NULL,
    [CategoryName] nvarchar(100)  NOT NULL,
    [IconUrl]      nvarchar(500)  NULL,
    [SortOrder]    int            NOT NULL DEFAULT ((0)),
    [IsActive]     bit            NOT NULL DEFAULT ((1)),
    [CreatedAt]    datetime2      NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_market_Category] PRIMARY KEY ([CategoryId])
);
GO

ALTER TABLE [market].[Category]
    ADD CONSTRAINT [UQ_market_Category_Code] UNIQUE ([CategoryCode]);
GO

-- ============================================================
-- market.Listing
-- Publicación principal del vendedor
-- ============================================================
CREATE TABLE [market].[Listing] (
    [ListingId]       bigint         IDENTITY(1,1) NOT NULL,
    [UserId]          bigint         NOT NULL,
    [Title]           nvarchar(200)  NOT NULL,
    [Description]     nvarchar(2000) NULL,
    [Price]           decimal(18,2)  NULL,
    [CurrencyCode]    nvarchar(10)   NULL,        -- USD, BRL, ARS, COP, G
    [WhatsAppContact] nvarchar(30)   NULL,        -- número directo del seller
    [YoutubeUrl]      nvarchar(500)  NULL,        -- link video YouTube
    [ShareUrl]        nvarchar(500)  NULL,        -- link público compartible
    [Status]          nvarchar(20)   NOT NULL DEFAULT ('ACTIVE'), -- ACTIVE / SOLD / EXPIRED / CANCELLED
    [RenewalCount]    int            NOT NULL DEFAULT ((0)),
    [MaxRenewals]     int            NOT NULL DEFAULT ((3)),
    [SoldPrice]       decimal(18,2)  NULL,        -- precio real al que se cerró
    [SoldCurrencyCode] nvarchar(10)  NULL,        -- moneda del cierre
    [CreatedAt]       datetime2      NOT NULL DEFAULT (sysutcdatetime()),
    [ExpiresAt]       datetime2      NOT NULL DEFAULT (dateadd(DAY, 10, sysutcdatetime())),
    [UpdatedAt]       datetime2      NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_market_Listing] PRIMARY KEY ([ListingId])
);
GO

ALTER TABLE [market].[Listing]
    ADD CONSTRAINT [FK_market_Listing_User]
    FOREIGN KEY ([UserId]) REFERENCES [auth].[Users] ([UserId]);
GO

-- ============================================================
-- market.ListingCategory
-- Relación muchos a muchos — un listing puede tener varios tags
-- ============================================================
CREATE TABLE [market].[ListingCategory] (
    [ListingCategoryId] bigint IDENTITY(1,1) NOT NULL,
    [ListingId]         bigint NOT NULL,
    [CategoryId]        int    NOT NULL,
    CONSTRAINT [PK_market_ListingCategory] PRIMARY KEY ([ListingCategoryId])
);
GO

ALTER TABLE [market].[ListingCategory]
    ADD CONSTRAINT [UQ_market_ListingCategory] UNIQUE ([ListingId], [CategoryId]);
GO

ALTER TABLE [market].[ListingCategory]
    ADD CONSTRAINT [FK_market_ListingCategory_Listing]
    FOREIGN KEY ([ListingId]) REFERENCES [market].[Listing] ([ListingId]);
GO

ALTER TABLE [market].[ListingCategory]
    ADD CONSTRAINT [FK_market_ListingCategory_Category]
    FOREIGN KEY ([CategoryId]) REFERENCES [market].[Category] ([CategoryId]);
GO

-- ============================================================
-- market.ListingImage
-- Fotos del listing — Azure Blob Storage (reloader-files)
-- Máximo 5 fotos por listing
-- ============================================================
CREATE TABLE [market].[ListingImage] (
    [ListingImageId] bigint        IDENTITY(1,1) NOT NULL,
    [ListingId]      bigint        NOT NULL,
    [ImageUrl]       nvarchar(500) NOT NULL,
    [SortOrder]      int           NOT NULL DEFAULT ((0)),
    [CreatedAt]      datetime2     NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_market_ListingImage] PRIMARY KEY ([ListingImageId])
);
GO

ALTER TABLE [market].[ListingImage]
    ADD CONSTRAINT [FK_market_ListingImage_Listing]
    FOREIGN KEY ([ListingId]) REFERENCES [market].[Listing] ([ListingId]);
GO

-- ============================================================
-- market.Contact
-- Cuando un comprador toca "contactar" en un listing
-- ============================================================
CREATE TABLE [market].[Contact] (
    [ContactId] bigint    IDENTITY(1,1) NOT NULL,
    [ListingId] bigint    NOT NULL,
    [UserId]    bigint    NOT NULL,        -- el comprador interesado
    [CreatedAt] datetime2 NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_market_Contact] PRIMARY KEY ([ContactId])
);
GO

ALTER TABLE [market].[Contact]
    ADD CONSTRAINT [FK_market_Contact_Listing]
    FOREIGN KEY ([ListingId]) REFERENCES [market].[Listing] ([ListingId]);
GO

ALTER TABLE [market].[Contact]
    ADD CONSTRAINT [FK_market_Contact_User]
    FOREIGN KEY ([UserId]) REFERENCES [auth].[Users] ([UserId]);
GO

-- ============================================================
-- market.Review
-- Calificación post-deal entre comprador y vendedor
-- ============================================================
CREATE TABLE [market].[Review] (
    [ReviewId]   bigint         IDENTITY(1,1) NOT NULL,
    [ListingId]  bigint         NOT NULL,
    [ReviewerId] bigint         NOT NULL,    -- quien califica
    [ReviewedId] bigint         NOT NULL,    -- quien es calificado
    [Score]      int            NOT NULL,    -- 1 a 5
    [Comment]    nvarchar(500)  NULL,
    [CreatedAt]  datetime2      NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_market_Review] PRIMARY KEY ([ReviewId])
);
GO

ALTER TABLE [market].[Review]
    ADD CONSTRAINT [UQ_market_Review_Listing_Reviewer]
    UNIQUE ([ListingId], [ReviewerId]);
GO

ALTER TABLE [market].[Review]
    ADD CONSTRAINT [FK_market_Review_Listing]
    FOREIGN KEY ([ListingId]) REFERENCES [market].[Listing] ([ListingId]);
GO

ALTER TABLE [market].[Review]
    ADD CONSTRAINT [FK_market_Review_Reviewer]
    FOREIGN KEY ([ReviewerId]) REFERENCES [auth].[Users] ([UserId]);
GO

ALTER TABLE [market].[Review]
    ADD CONSTRAINT [FK_market_Review_Reviewed]
    FOREIGN KEY ([ReviewedId]) REFERENCES [auth].[Users] ([UserId]);
GO

-- ============================================================
-- market.SellerStats
-- Reputación acumulada del vendedor
-- Se actualiza cada vez que cierra un deal o recibe una review
-- ============================================================
CREATE TABLE [market].[SellerStats] (
    [SellerStatsId]    bigint        IDENTITY(1,1) NOT NULL,
    [UserId]           bigint        NOT NULL,
    [TotalListings]    int           NOT NULL DEFAULT ((0)),
    [TotalSold]        int           NOT NULL DEFAULT ((0)),
    [TotalReviews]     int           NOT NULL DEFAULT ((0)),
    [AverageScore]     decimal(3,2)  NOT NULL DEFAULT ((0)),
    [ReputationPoints] int           NOT NULL DEFAULT ((0)),
    [UpdatedAt]        datetime2     NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_market_SellerStats] PRIMARY KEY ([SellerStatsId])
);
GO

ALTER TABLE [market].[SellerStats]
    ADD CONSTRAINT [UQ_market_SellerStats_User] UNIQUE ([UserId]);
GO

ALTER TABLE [market].[SellerStats]
    ADD CONSTRAINT [FK_market_SellerStats_User]
    FOREIGN KEY ([UserId]) REFERENCES [auth].[Users] ([UserId]);
GO

-- ============================================================
-- notification.MarketNotification
-- Notificaciones del marketplace
-- Usa el DeviceToken ya existente en notification.DeviceToken
-- ============================================================
CREATE TABLE [notification].[MarketNotification] (
    [NotificationId] bigint        IDENTITY(1,1) NOT NULL,
    [UserId]         bigint        NOT NULL,
    [ListingId]      bigint        NULL,
    [Type]           nvarchar(30)  NOT NULL, -- NEW_LISTING / CONTACT_RECEIVED / REVIEW_RECEIVED / LISTING_EXPIRING
    [Title]          nvarchar(100) NOT NULL,
    [Body]           nvarchar(300) NOT NULL,
    [IsRead]         bit           NOT NULL DEFAULT ((0)),
    [SentAt]         datetime2     NULL,
    [CreatedAt]      datetime2     NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_notification_MarketNotification] PRIMARY KEY ([NotificationId])
);
GO

ALTER TABLE [notification].[MarketNotification]
    ADD CONSTRAINT [FK_MarketNotification_User]
    FOREIGN KEY ([UserId]) REFERENCES [auth].[Users] ([UserId]);
GO

ALTER TABLE [notification].[MarketNotification]
    ADD CONSTRAINT [FK_MarketNotification_Listing]
    FOREIGN KEY ([ListingId]) REFERENCES [market].[Listing] ([ListingId]);
GO
