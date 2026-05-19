-- ============================================================
-- V022__seed_messi_listings.sql
-- Seed de listings de ejemplo para Messi (UserId = 1)
-- Imagen placeholder: reloaderstorageprod.blob.core.windows.net
-- ============================================================

DECLARE @img nvarchar(500) = 'https://reloaderstorageprod.blob.core.windows.net/reloader-files/reloader_games/sin_imagen.png';

-- ============================================================
-- LISTING 1 — Set Completo +15 Dark Knight
-- ============================================================
DECLARE @l1 bigint;
INSERT INTO market.Listing (UserId, Title, Description, Price, CurrencyCode, WhatsAppContact, Status, RenewalCount, MaxRenewals)
VALUES (
    1,
    'Set Completo +15 Dark Knight — Excelente estado',
    'Vendo set completo de Dark Knight nivel +15 con opción excellent. Incluye: Casco, Armadura, Pantalón, Guantes y Botas. Todo con opción de vida y mana. Listo para usar. Negociable.',
    45.00, 'USD', '+51987654321', 'ACTIVE', 0, 3
);
SET @l1 = SCOPE_IDENTITY();
UPDATE market.Listing SET ShareUrl = CONCAT('https://reloadersystem.azurewebsites.net/market/listing/', @l1) WHERE ListingId = @l1;
INSERT INTO market.ListingImage (ListingId, ImageUrl, SortOrder) VALUES (@l1, @img, 1);
INSERT INTO market.ListingCategory (ListingId, CategoryId)
SELECT @l1, CategoryId FROM market.Category WHERE CategoryCode IN ('SET', 'ARMA') AND IsActive = 1;
GO

-- ============================================================
-- LISTING 2 — Arma Apocalipsis +13
-- ============================================================
DECLARE @img nvarchar(500) = 'https://reloaderstorageprod.blob.core.windows.net/reloader-files/reloader_games/sin_imagen.png';
DECLARE @l2 bigint;
INSERT INTO market.Listing (UserId, Title, Description, Price, CurrencyCode, WhatsAppContact, Status, RenewalCount, MaxRenewals)
VALUES (
    1,
    'Espada Apocalipsis +13 +Luck +Skill — BM Ready',
    'Espada Apocalipsis nivel +13 con opciones Luck y Skill activas. Daño máximo. Perfecta para Battle Master o Dark Knight nivel alto. Precio fijo, no cambio.',
    30.00, 'USD', '+51987654321', 'ACTIVE', 0, 3
);
SET @l2 = SCOPE_IDENTITY();
UPDATE market.Listing SET ShareUrl = CONCAT('https://reloadersystem.azurewebsites.net/market/listing/', @l2) WHERE ListingId = @l2;
INSERT INTO market.ListingImage (ListingId, ImageUrl, SortOrder) VALUES (@l2, @img, 1);
INSERT INTO market.ListingCategory (ListingId, CategoryId)
SELECT @l2, CategoryId FROM market.Category WHERE CategoryCode = 'ARMA' AND IsActive = 1;
GO

-- ============================================================
-- LISTING 3 — Alas Divinas nivel 3
-- ============================================================
DECLARE @img nvarchar(500) = 'https://reloaderstorageprod.blob.core.windows.net/reloader-files/reloader_games/sin_imagen.png';
DECLARE @l3 bigint;
INSERT INTO market.Listing (UserId, Title, Description, Price, CurrencyCode, WhatsAppContact, Status, RenewalCount, MaxRenewals)
VALUES (
    1,
    'Alas Divinas Nivel 3 — Máximo atributo',
    'Alas divinas nivel 3 con absorción de daño al máximo. Son las mejores alas del juego actualmente. No le faltan opciones. Trato por WhatsApp.',
    60.00, 'USD', '+51987654321', 'ACTIVE', 0, 3
);
SET @l3 = SCOPE_IDENTITY();
UPDATE market.Listing SET ShareUrl = CONCAT('https://reloadersystem.azurewebsites.net/market/listing/', @l3) WHERE ListingId = @l3;
INSERT INTO market.ListingImage (ListingId, ImageUrl, SortOrder) VALUES (@l3, @img, 1);
INSERT INTO market.ListingCategory (ListingId, CategoryId)
SELECT @l3, CategoryId FROM market.Category WHERE CategoryCode = 'ALAS' AND IsActive = 1;
GO

-- ============================================================
-- LISTING 4 — Montura Unicornio Dorado
-- ============================================================
DECLARE @img nvarchar(500) = 'https://reloaderstorageprod.blob.core.windows.net/reloader-files/reloader_games/sin_imagen.png';
DECLARE @l4 bigint;
INSERT INTO market.Listing (UserId, Title, Description, Price, CurrencyCode, WhatsAppContact, Status, RenewalCount, MaxRenewals)
VALUES (
    1,
    'Montura Unicornio Dorado nivel 5 — Muy rápido',
    'Unicornio Dorado nivel 5, el más rápido del servidor. Tiene todos sus niveles mejorados. Ideal para farmear rápido o mostrar en el mapa. Precio en PEN también aceptado.',
    20.00, 'USD', '+51987654321', 'ACTIVE', 0, 3
);
SET @l4 = SCOPE_IDENTITY();
UPDATE market.Listing SET ShareUrl = CONCAT('https://reloadersystem.azurewebsites.net/market/listing/', @l4) WHERE ListingId = @l4;
INSERT INTO market.ListingImage (ListingId, ImageUrl, SortOrder) VALUES (@l4, @img, 1);
INSERT INTO market.ListingCategory (ListingId, CategoryId)
SELECT @l4, CategoryId FROM market.Category WHERE CategoryCode = 'MONTURA' AND IsActive = 1;
GO

-- ============================================================
-- LISTING 5 — Pack de Zen (Oro) 5,000,000,000
-- ============================================================
DECLARE @img nvarchar(500) = 'https://reloaderstorageprod.blob.core.windows.net/reloader-files/reloader_games/sin_imagen.png';
DECLARE @l5 bigint;
INSERT INTO market.Listing (UserId, Title, Description, Price, CurrencyCode, WhatsAppContact, Status, RenewalCount, MaxRenewals)
VALUES (
    1,
    'Pack 5,000,000,000 de Zen — Entrega inmediata',
    '5 billones de zen listos para entregar. Acumulado durante semanas de farmeo. Precio por paquete, acepto combinaciones. Coordinar horario por WhatsApp. Entrega en menos de 10 minutos.',
    8.00, 'USD', '+51987654321', 'ACTIVE', 0, 3
);
SET @l5 = SCOPE_IDENTITY();
UPDATE market.Listing SET ShareUrl = CONCAT('https://reloadersystem.azurewebsites.net/market/listing/', @l5) WHERE ListingId = @l5;
INSERT INTO market.ListingImage (ListingId, ImageUrl, SortOrder) VALUES (@l5, @img, 1);
INSERT INTO market.ListingCategory (ListingId, CategoryId)
SELECT @l5, CategoryId FROM market.Category WHERE CategoryCode = 'ORO' AND IsActive = 1;
GO

-- ============================================================
-- LISTING 6 — Traje Oscuro Exclusivo
-- ============================================================
DECLARE @img nvarchar(500) = 'https://reloaderstorageprod.blob.core.windows.net/reloader-files/reloader_games/sin_imagen.png';
DECLARE @l6 bigint;
INSERT INTO market.Listing (UserId, Title, Description, Price, CurrencyCode, WhatsAppContact, Status, RenewalCount, MaxRenewals)
VALUES (
    1,
    'Traje Oscuro Exclusivo — Edición Limitada',
    'Traje de edición limitada que ya no se consigue en el juego. Apariencia única, efecto de partículas oscuras al caminar. Solo tengo uno. Precio justo, trato por WhatsApp.',
    25.00, 'USD', '+51987654321', 'ACTIVE', 0, 3
);
SET @l6 = SCOPE_IDENTITY();
UPDATE market.Listing SET ShareUrl = CONCAT('https://reloadersystem.azurewebsites.net/market/listing/', @l6) WHERE ListingId = @l6;
INSERT INTO market.ListingImage (ListingId, ImageUrl, SortOrder) VALUES (@l6, @img, 1);
INSERT INTO market.ListingCategory (ListingId, CategoryId)
SELECT @l6, CategoryId FROM market.Category WHERE CategoryCode = 'TRAJE' AND IsActive = 1;
GO

-- ============================================================
-- SELLER STATS para Messi
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM market.SellerStats WHERE UserId = 1)
BEGIN
    INSERT INTO market.SellerStats (UserId, TotalListings, TotalSold, TotalReviews, AverageScore, ReputationPoints)
    VALUES (1, 6, 3, 5, 4.80, 65);
END
ELSE
BEGIN
    UPDATE market.SellerStats
    SET TotalListings    = 6,
        TotalSold        = 3,
        TotalReviews     = 5,
        AverageScore     = 4.80,
        ReputationPoints = 65,
        UpdatedAt        = SYSUTCDATETIME()
    WHERE UserId = 1;
END
GO
