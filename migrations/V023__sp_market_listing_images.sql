-- ============================================================
-- V023__sp_market_listing_images.sql
-- SPs para publicar con fotos y gestionar "Mis Publicaciones"
-- Reloader no vende: solo conecta. Precio/moneda son informativos.
-- Toda publicación requiere entre 1 y 5 fotos (validado en REST + aquí el máximo).
-- ============================================================

-- ============================================================
-- market.sp_AddListingImage
-- Registra una foto (ya subida a Azure Blob) de un listing propio y activo
-- Máximo 5 fotos por listing
-- NO abre transacción propia: el REST la maneja (todo-o-nada con sp_CreateListing)
-- ============================================================
CREATE OR ALTER PROCEDURE market.sp_AddListingImage
    @ListingId bigint,
    @UserId    bigint,
    @ImageUrl  nvarchar(500),
    @SortOrder int
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que el listing existe, pertenece al usuario y está activo
    IF NOT EXISTS (
        SELECT 1 FROM market.Listing
        WHERE ListingId = @ListingId
          AND UserId    = @UserId
          AND Status    = 'ACTIVE'
    )
    BEGIN
        SELECT CAST(0 AS BIT) AS Success, 'LISTING_NOT_FOUND' AS ErrorCode, CAST(NULL AS bigint) AS ListingImageId;
        RETURN;
    END

    -- Validar máximo de 5 fotos (bloqueo para evitar carrera entre inserts concurrentes)
    DECLARE @ImageCount int;

    SELECT @ImageCount = COUNT(*)
    FROM market.ListingImage WITH (UPDLOCK, HOLDLOCK)
    WHERE ListingId = @ListingId;

    IF @ImageCount >= 5
    BEGIN
        SELECT CAST(0 AS BIT) AS Success, 'MAX_IMAGES_REACHED' AS ErrorCode, CAST(NULL AS bigint) AS ListingImageId;
        RETURN;
    END

    INSERT INTO market.ListingImage (ListingId, ImageUrl, SortOrder)
    VALUES (@ListingId, @ImageUrl, @SortOrder);

    SELECT
        CAST(1 AS BIT)                    AS Success,
        CAST(NULL AS nvarchar(50))        AS ErrorCode,
        CAST(SCOPE_IDENTITY() AS bigint)  AS ListingImageId;
END;
GO

-- ============================================================
-- market.sp_GetMyListings
-- "Mis Publicaciones" — todas las publicaciones del usuario
-- (ACTIVE, SOLD, EXPIRED, CANCELLED), más nuevas primero
-- ============================================================
CREATE OR ALTER PROCEDURE market.sp_GetMyListings
    @UserId bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        L.ListingId,
        L.Title,
        L.Description,
        L.Price,
        L.CurrencyCode,
        L.WhatsAppContact,
        L.YoutubeUrl,
        L.ShareUrl,
        L.Status,
        L.RenewalCount,
        L.MaxRenewals,
        L.CreatedAt,
        L.ExpiresAt,
        -- Primera imagen del listing
        (
            SELECT TOP 1 LI.ImageUrl
            FROM market.ListingImage LI
            WHERE LI.ListingId = L.ListingId
            ORDER BY LI.SortOrder, LI.ListingImageId
        ) AS ThumbnailUrl,
        -- Tags del listing
        (
            SELECT STRING_AGG(C.CategoryName, ', ')
            FROM market.ListingCategory LC
            JOIN market.Category C ON C.CategoryId = LC.CategoryId
            WHERE LC.ListingId = L.ListingId
        ) AS Categories,
        -- Cantidad de fotos
        (
            SELECT CAST(COUNT(*) AS int)
            FROM market.ListingImage LI
            WHERE LI.ListingId = L.ListingId
        ) AS ImageCount
    FROM market.Listing L
    WHERE L.UserId = @UserId
    ORDER BY L.CreatedAt DESC, L.ListingId DESC;
END;
GO

-- ============================================================
-- market.sp_GetCategories
-- Categorías activas para los chips del formulario de publicación
-- ============================================================
CREATE OR ALTER PROCEDURE market.sp_GetCategories
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        C.CategoryId,
        C.CategoryCode,
        C.CategoryName,
        C.IconUrl
    FROM market.Category C
    WHERE C.IsActive = 1
    ORDER BY C.SortOrder, C.CategoryName;
END;
GO
