-- ============================================================
-- V018__sp_market_listings.sql
-- Stored Procedures de listings del marketplace
-- ============================================================

-- ============================================================
-- market.sp_CreateListing
-- El vendedor publica un listing con sus tags y fotos
-- ============================================================
CREATE OR ALTER PROCEDURE market.sp_CreateListing
    @UserId          bigint,
    @Title           nvarchar(200),
    @Description     nvarchar(2000)  = NULL,
    @Price           decimal(18,2)   = NULL,
    @CurrencyCode    nvarchar(10)    = NULL,
    @WhatsAppContact nvarchar(30)    = NULL,
    @YoutubeUrl      nvarchar(500)   = NULL,
    @CategoryCodes   nvarchar(500)   = NULL   -- categorías separadas por coma: 'ORO,SET,ARMA'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Validar que el usuario existe y está activo
    IF NOT EXISTS (SELECT 1 FROM auth.Users WHERE UserId = @UserId AND IsActive = 1)
    BEGIN
        SELECT CAST(0 AS BIT) AS Success, 'USER_NOT_FOUND' AS ErrorCode, NULL AS ListingId;
        RETURN;
    END

    DECLARE @ListingId bigint;
    DECLARE @ShareUrl  nvarchar(500);

    BEGIN TRANSACTION;

    -- Insertar listing
    INSERT INTO market.Listing (
        UserId, Title, Description, Price, CurrencyCode,
        WhatsAppContact, YoutubeUrl, Status, RenewalCount, MaxRenewals
    )
    VALUES (
        @UserId, @Title, @Description, @Price, @CurrencyCode,
        @WhatsAppContact, @YoutubeUrl, 'ACTIVE', 0, 3
    );

    SET @ListingId = SCOPE_IDENTITY();

    -- Generar ShareUrl con el ListingId
    SET @ShareUrl = CONCAT('https://reloadersystem.azurewebsites.net/market/listing/', @ListingId);

    UPDATE market.Listing
    SET ShareUrl = @ShareUrl
    WHERE ListingId = @ListingId;

    -- Insertar categorías si se enviaron
    IF @CategoryCodes IS NOT NULL
    BEGIN
        INSERT INTO market.ListingCategory (ListingId, CategoryId)
        SELECT
            @ListingId,
            C.CategoryId
        FROM market.Category C
        JOIN STRING_SPLIT(@CategoryCodes, ',') S
            ON TRIM(S.value) = C.CategoryCode
        WHERE C.IsActive = 1;
    END

    -- Crear o actualizar SellerStats
    IF NOT EXISTS (SELECT 1 FROM market.SellerStats WHERE UserId = @UserId)
    BEGIN
        INSERT INTO market.SellerStats (UserId, TotalListings, TotalSold, TotalReviews, AverageScore, ReputationPoints)
        VALUES (@UserId, 1, 0, 0, 0, 0);
    END
    ELSE
    BEGIN
        UPDATE market.SellerStats
        SET TotalListings = TotalListings + 1,
            UpdatedAt     = SYSUTCDATETIME()
        WHERE UserId = @UserId;
    END

    COMMIT TRANSACTION;

    SELECT
        CAST(1 AS BIT)  AS Success,
        NULL            AS ErrorCode,
        @ListingId      AS ListingId,
        @ShareUrl       AS ShareUrl;
END;
GO

-- ============================================================
-- market.sp_GetListings
-- El comprador navega — filtra por categoría, texto y precio
-- ============================================================
CREATE OR ALTER PROCEDURE market.sp_GetListings
    @CategoryCode  nvarchar(30)  = NULL,   -- filtro por tag
    @SearchText    nvarchar(200) = NULL,   -- búsqueda libre en título
    @MinPrice      decimal(18,2) = NULL,
    @MaxPrice      decimal(18,2) = NULL,
    @CurrencyCode  nvarchar(10)  = NULL,
    @PageNumber    int           = 1,
    @PageSize      int           = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset int = (@PageNumber - 1) * @PageSize;

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
        L.CreatedAt,
        L.ExpiresAt,
        -- Seller info
        U.UserId,
        P.DisplayName       AS SellerName,
        P.CountryCode       AS SellerCountry,
        ISNULL(SS.AverageScore, 0)      AS SellerScore,
        ISNULL(SS.TotalSold, 0)         AS SellerTotalSold,
        ISNULL(SS.ReputationPoints, 0)  AS SellerReputation,
        -- Primera imagen del listing
        (
            SELECT TOP 1 ImageUrl
            FROM market.ListingImage
            WHERE ListingId = L.ListingId
            ORDER BY SortOrder
        ) AS ThumbnailUrl,
        -- Tags del listing
        (
            SELECT STRING_AGG(C.CategoryName, ', ')
            FROM market.ListingCategory LC
            JOIN market.Category C ON C.CategoryId = LC.CategoryId
            WHERE LC.ListingId = L.ListingId
        ) AS Categories
    FROM market.Listing L
    JOIN auth.Users U
        ON U.UserId = L.UserId
    LEFT JOIN auth.UserProfile P
        ON P.UserId = L.UserId
    LEFT JOIN market.SellerStats SS
        ON SS.UserId = L.UserId
    WHERE
        L.Status = 'ACTIVE'
        AND L.ExpiresAt > SYSUTCDATETIME()
        AND (
            @CategoryCode IS NULL
            OR EXISTS (
                SELECT 1
                FROM market.ListingCategory LC
                JOIN market.Category C ON C.CategoryId = LC.CategoryId
                WHERE LC.ListingId = L.ListingId
                  AND C.CategoryCode = @CategoryCode
            )
        )
        AND (
            @SearchText IS NULL
            OR L.Title LIKE CONCAT('%', @SearchText, '%')
        )
        AND (
            @MinPrice IS NULL
            OR L.Price >= @MinPrice
        )
        AND (
            @MaxPrice IS NULL
            OR L.Price <= @MaxPrice
        )
        AND (
            @CurrencyCode IS NULL
            OR L.CurrencyCode = @CurrencyCode
        )
    ORDER BY L.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- ============================================================
-- market.sp_GetListingDetail
-- Detalle completo de un listing — comprador lo abre
-- ============================================================
CREATE OR ALTER PROCEDURE market.sp_GetListingDetail
    @ListingId bigint
AS
BEGIN
    SET NOCOUNT ON;

    -- Result 1: Listing principal
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
        L.SoldPrice,
        L.SoldCurrencyCode,
        L.RenewalCount,
        L.MaxRenewals,
        L.CreatedAt,
        L.ExpiresAt,
        -- Seller
        U.UserId,
        P.DisplayName       AS SellerName,
        P.CountryCode       AS SellerCountry,
        ISNULL(SS.AverageScore, 0)      AS SellerScore,
        ISNULL(SS.TotalSold, 0)         AS SellerTotalSold,
        ISNULL(SS.TotalReviews, 0)      AS SellerTotalReviews,
        ISNULL(SS.ReputationPoints, 0)  AS SellerReputation
    FROM market.Listing L
    JOIN auth.Users U ON U.UserId = L.UserId
    LEFT JOIN auth.UserProfile P ON P.UserId = L.UserId
    LEFT JOIN market.SellerStats SS ON SS.UserId = L.UserId
    WHERE L.ListingId = @ListingId;

    -- Result 2: Imágenes
    SELECT
        ImageUrl,
        SortOrder
    FROM market.ListingImage
    WHERE ListingId = @ListingId
    ORDER BY SortOrder;

    -- Result 3: Categorías / Tags
    SELECT
        C.CategoryCode,
        C.CategoryName,
        C.IconUrl
    FROM market.ListingCategory LC
    JOIN market.Category C ON C.CategoryId = LC.CategoryId
    WHERE LC.ListingId = @ListingId
    ORDER BY C.SortOrder;

    -- Result 4: Reviews del seller (últimas 5)
    SELECT TOP 5
        R.Score,
        R.Comment,
        P.DisplayName   AS ReviewerName,
        R.CreatedAt
    FROM market.Review R
    LEFT JOIN auth.UserProfile P ON P.UserId = R.ReviewerId
    WHERE R.ReviewedId = (
        SELECT UserId FROM market.Listing WHERE ListingId = @ListingId
    )
    ORDER BY R.CreatedAt DESC;
END;
GO

-- ============================================================
-- market.sp_CloseListing
-- El vendedor marca el listing como vendido
-- Registra el precio de cierre y suma puntos de reputación
-- ============================================================
CREATE OR ALTER PROCEDURE market.sp_CloseListing
    @ListingId       bigint,
    @UserId          bigint,
    @SoldPrice       decimal(18,2) = NULL,
    @SoldCurrencyCode nvarchar(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Validar que el listing pertenece al usuario
    IF NOT EXISTS (
        SELECT 1 FROM market.Listing
        WHERE ListingId = @ListingId
          AND UserId = @UserId
          AND Status = 'ACTIVE'
    )
    BEGIN
        SELECT CAST(0 AS BIT) AS Success, 'LISTING_NOT_FOUND' AS ErrorCode;
        RETURN;
    END

    BEGIN TRANSACTION;

    UPDATE market.Listing
    SET Status           = 'SOLD',
        SoldPrice        = @SoldPrice,
        SoldCurrencyCode = @SoldCurrencyCode,
        UpdatedAt        = SYSUTCDATETIME()
    WHERE ListingId = @ListingId;

    -- Sumar puntos de reputación al seller (10 puntos por venta)
    UPDATE market.SellerStats
    SET TotalSold        = TotalSold + 1,
        ReputationPoints = ReputationPoints + 10,
        UpdatedAt        = SYSUTCDATETIME()
    WHERE UserId = @UserId;

    COMMIT TRANSACTION;

    SELECT CAST(1 AS BIT) AS Success, NULL AS ErrorCode;
END;
GO

-- ============================================================
-- market.sp_RenewListing
-- El vendedor renueva su listing por 10 días más
-- Máximo 3 renovaciones
-- ============================================================
CREATE OR ALTER PROCEDURE market.sp_RenewListing
    @ListingId bigint,
    @UserId    bigint
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RenewalCount int;
    DECLARE @MaxRenewals  int;

    SELECT
        @RenewalCount = RenewalCount,
        @MaxRenewals  = MaxRenewals
    FROM market.Listing
    WHERE ListingId = @ListingId
      AND UserId    = @UserId
      AND Status    = 'ACTIVE';

    IF @RenewalCount IS NULL
    BEGIN
        SELECT CAST(0 AS BIT) AS Success, 'LISTING_NOT_FOUND' AS ErrorCode;
        RETURN;
    END

    IF @RenewalCount >= @MaxRenewals
    BEGIN
        SELECT CAST(0 AS BIT) AS Success, 'MAX_RENEWALS_REACHED' AS ErrorCode;
        RETURN;
    END

    UPDATE market.Listing
    SET ExpiresAt    = DATEADD(DAY, 10, SYSUTCDATETIME()),
        RenewalCount = RenewalCount + 1,
        UpdatedAt    = SYSUTCDATETIME()
    WHERE ListingId = @ListingId;

    SELECT
        CAST(1 AS BIT)              AS Success,
        NULL                        AS ErrorCode,
        RenewalCount                AS RenewalCount,
        MaxRenewals                 AS MaxRenewals,
        ExpiresAt                   AS NewExpiresAt
    FROM market.Listing
    WHERE ListingId = @ListingId;
END;
GO

-- ============================================================
-- market.sp_CancelListing
-- El vendedor baja su publicación
-- ============================================================
CREATE OR ALTER PROCEDURE market.sp_CancelListing
    @ListingId bigint,
    @UserId    bigint
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM market.Listing
        WHERE ListingId = @ListingId
          AND UserId    = @UserId
          AND Status    = 'ACTIVE'
    )
    BEGIN
        SELECT CAST(0 AS BIT) AS Success, 'LISTING_NOT_FOUND' AS ErrorCode;
        RETURN;
    END

    UPDATE market.Listing
    SET Status    = 'CANCELLED',
        UpdatedAt = SYSUTCDATETIME()
    WHERE ListingId = @ListingId;

    SELECT CAST(1 AS BIT) AS Success, NULL AS ErrorCode;
END;
GO

-- ============================================================
-- market.sp_ExpireListings
-- Job automático — vence listings expirados
-- Ejecutar periódicamente (scheduler / n8n)
-- ============================================================
CREATE OR ALTER PROCEDURE market.sp_ExpireListings
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE market.Listing
    SET Status    = 'EXPIRED',
        UpdatedAt = SYSUTCDATETIME()
    WHERE Status    = 'ACTIVE'
      AND ExpiresAt < SYSUTCDATETIME();

    SELECT @@ROWCOUNT AS ExpiredCount;
END;
GO

-- ============================================================
-- market.sp_GetListingsExpiringSoon
-- Listings que vencen en 2 días — para enviar notificación al seller
-- ============================================================
CREATE OR ALTER PROCEDURE market.sp_GetListingsExpiringSoon
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        L.ListingId,
        L.UserId,
        L.Title,
        L.ExpiresAt,
        L.RenewalCount,
        L.MaxRenewals
    FROM market.Listing L
    WHERE L.Status = 'ACTIVE'
      AND L.ExpiresAt BETWEEN SYSUTCDATETIME() AND DATEADD(DAY, 2, SYSUTCDATETIME());
END;
GO
