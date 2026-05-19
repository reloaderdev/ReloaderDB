-- ============================================================
-- V019__sp_market_contact_review.sql
-- SPs de contacto, calificación y notificaciones del marketplace
-- ============================================================

-- ============================================================
-- market.sp_RegisterContact
-- Comprador toca "contactar" en un listing
-- ============================================================
CREATE OR ALTER PROCEDURE market.sp_RegisterContact
    @ListingId bigint,
    @UserId    bigint    -- el comprador
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Validar que el listing existe y está activo
    IF NOT EXISTS (
        SELECT 1 FROM market.Listing
        WHERE ListingId = @ListingId
          AND Status    = 'ACTIVE'
    )
    BEGIN
        SELECT CAST(0 AS BIT) AS Success, 'LISTING_NOT_FOUND' AS ErrorCode;
        RETURN;
    END

    -- No registrar si el comprador es el mismo seller
    IF EXISTS (
        SELECT 1 FROM market.Listing
        WHERE ListingId = @ListingId
          AND UserId    = @UserId
    )
    BEGIN
        SELECT CAST(0 AS BIT) AS Success, 'CANNOT_CONTACT_OWN_LISTING' AS ErrorCode;
        RETURN;
    END

    DECLARE @ContactId bigint;
    DECLARE @SellerId  bigint;

    SELECT @SellerId = UserId
    FROM market.Listing
    WHERE ListingId = @ListingId;

    BEGIN TRANSACTION;

    -- Registrar el contacto
    INSERT INTO market.Contact (ListingId, UserId)
    VALUES (@ListingId, @UserId);

    SET @ContactId = SCOPE_IDENTITY();

    -- Notificación al seller
    DECLARE @BuyerName nvarchar(100);
    SELECT @BuyerName = DisplayName
    FROM auth.UserProfile
    WHERE UserId = @UserId;

    DECLARE @ListingTitle nvarchar(200);
    SELECT @ListingTitle = Title
    FROM market.Listing
    WHERE ListingId = @ListingId;

    INSERT INTO notification.MarketNotification (
        UserId, ListingId, Type, Title, Body
    )
    VALUES (
        @SellerId,
        @ListingId,
        'CONTACT_RECEIVED',
        'Alguien está interesado',
        CONCAT(ISNULL(@BuyerName, 'Un usuario'), ' quiere contactarte por: ', @ListingTitle)
    );

    COMMIT TRANSACTION;

    SELECT
        CAST(1 AS BIT) AS Success,
        NULL           AS ErrorCode,
        @ContactId     AS ContactId;
END;
GO

-- ============================================================
-- market.sp_SaveReview
-- Calificación post-deal
-- Solo puede calificar quien contactó el listing
-- ============================================================
CREATE OR ALTER PROCEDURE market.sp_SaveReview
    @ListingId  bigint,
    @ReviewerId bigint,
    @ReviewedId bigint,
    @Score      int,           -- 1 a 5
    @Comment    nvarchar(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Validar score
    IF @Score < 1 OR @Score > 5
    BEGIN
        SELECT CAST(0 AS BIT) AS Success, 'INVALID_SCORE' AS ErrorCode;
        RETURN;
    END

    -- Validar que el reviewer contactó el listing
    IF NOT EXISTS (
        SELECT 1 FROM market.Contact
        WHERE ListingId = @ListingId
          AND UserId    = @ReviewerId
    )
    BEGIN
        SELECT CAST(0 AS BIT) AS Success, 'NO_CONTACT_FOUND' AS ErrorCode;
        RETURN;
    END

    -- Validar que no calificó antes
    IF EXISTS (
        SELECT 1 FROM market.Review
        WHERE ListingId  = @ListingId
          AND ReviewerId = @ReviewerId
    )
    BEGIN
        SELECT CAST(0 AS BIT) AS Success, 'ALREADY_REVIEWED' AS ErrorCode;
        RETURN;
    END

    BEGIN TRANSACTION;

    INSERT INTO market.Review (ListingId, ReviewerId, ReviewedId, Score, Comment)
    VALUES (@ListingId, @ReviewerId, @ReviewedId, @Score, @Comment);

    -- Actualizar SellerStats del calificado
    UPDATE market.SellerStats
    SET TotalReviews     = TotalReviews + 1,
        AverageScore     = (
            SELECT AVG(CAST(Score AS decimal(3,2)))
            FROM market.Review
            WHERE ReviewedId = @ReviewedId
        ),
        ReputationPoints = ReputationPoints + CASE WHEN @Score >= 4 THEN 5 ELSE 0 END,
        UpdatedAt        = SYSUTCDATETIME()
    WHERE UserId = @ReviewedId;

    -- Notificación al calificado
    DECLARE @ReviewerName nvarchar(100);
    SELECT @ReviewerName = DisplayName
    FROM auth.UserProfile
    WHERE UserId = @ReviewerId;

    INSERT INTO notification.MarketNotification (
        UserId, ListingId, Type, Title, Body
    )
    VALUES (
        @ReviewedId,
        @ListingId,
        'REVIEW_RECEIVED',
        'Nueva calificación recibida',
        CONCAT(
            ISNULL(@ReviewerName, 'Un usuario'), ' te calificó con ',
            @Score, ' estrella', CASE WHEN @Score = 1 THEN '' ELSE 's' END
        )
    );

    COMMIT TRANSACTION;

    SELECT CAST(1 AS BIT) AS Success, NULL AS ErrorCode;
END;
GO

-- ============================================================
-- market.sp_GetSellerProfile
-- Perfil público del seller con reputación y listings activos
-- ============================================================
CREATE OR ALTER PROCEDURE market.sp_GetSellerProfile
    @UserId bigint
AS
BEGIN
    SET NOCOUNT ON;

    -- Result 1: Datos del seller
    SELECT
        U.UserId,
        P.DisplayName,
        P.CountryCode,
        U.CreatedAt                             AS MemberSince,
        ISNULL(SS.TotalListings, 0)             AS TotalListings,
        ISNULL(SS.TotalSold, 0)                 AS TotalSold,
        ISNULL(SS.TotalReviews, 0)              AS TotalReviews,
        ISNULL(SS.AverageScore, 0)              AS AverageScore,
        ISNULL(SS.ReputationPoints, 0)          AS ReputationPoints
    FROM auth.Users U
    LEFT JOIN auth.UserProfile P ON P.UserId = U.UserId
    LEFT JOIN market.SellerStats SS ON SS.UserId = U.UserId
    WHERE U.UserId = @UserId
      AND U.IsActive = 1;

    -- Result 2: Listings activos del seller
    SELECT
        L.ListingId,
        L.Title,
        L.Price,
        L.CurrencyCode,
        L.Status,
        L.CreatedAt,
        L.ExpiresAt,
        (
            SELECT TOP 1 ImageUrl
            FROM market.ListingImage
            WHERE ListingId = L.ListingId
            ORDER BY SortOrder
        ) AS ThumbnailUrl
    FROM market.Listing L
    WHERE L.UserId = @UserId
      AND L.Status = 'ACTIVE'
    ORDER BY L.CreatedAt DESC;

    -- Result 3: Últimas reviews recibidas
    SELECT TOP 10
        R.Score,
        R.Comment,
        P.DisplayName   AS ReviewerName,
        R.CreatedAt
    FROM market.Review R
    LEFT JOIN auth.UserProfile P ON P.UserId = R.ReviewerId
    WHERE R.ReviewedId = @UserId
    ORDER BY R.CreatedAt DESC;
END;
GO

-- ============================================================
-- notification.sp_GetPendingNotifications
-- Notificaciones pendientes del usuario
-- ============================================================
CREATE OR ALTER PROCEDURE notification.sp_GetPendingNotifications
    @UserId bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        N.NotificationId,
        N.ListingId,
        N.Type,
        N.Title,
        N.Body,
        N.IsRead,
        N.CreatedAt
    FROM notification.MarketNotification N
    WHERE N.UserId = @UserId
    ORDER BY N.CreatedAt DESC;
END;
GO

-- ============================================================
-- notification.sp_MarkNotificationRead
-- Marcar notificación como leída
-- ============================================================
CREATE OR ALTER PROCEDURE notification.sp_MarkNotificationRead
    @NotificationId bigint,
    @UserId         bigint
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE notification.MarketNotification
    SET IsRead = 1
    WHERE NotificationId = @NotificationId
      AND UserId         = @UserId;

    SELECT @@ROWCOUNT AS Updated;
END;
GO

-- ============================================================
-- notification.sp_SendRandomListingNotification
-- Envía notificación de un listing al azar a usuarios activos
-- Para ejecutar desde n8n o scheduler periódicamente
-- ============================================================
CREATE OR ALTER PROCEDURE notification.sp_SendRandomListingNotification
AS
BEGIN
    SET NOCOUNT ON;

    -- Seleccionar un listing activo al azar
    DECLARE @ListingId   bigint;
    DECLARE @ListingTitle nvarchar(200);
    DECLARE @SellerName  nvarchar(100);

    SELECT TOP 1
        @ListingId    = L.ListingId,
        @ListingTitle = L.Title,
        @SellerName   = P.DisplayName
    FROM market.Listing L
    LEFT JOIN auth.UserProfile P ON P.UserId = L.UserId
    WHERE L.Status = 'ACTIVE'
      AND L.ExpiresAt > SYSUTCDATETIME()
    ORDER BY NEWID();   -- al azar

    IF @ListingId IS NULL
        RETURN;

    -- Insertar notificación para todos los usuarios activos
    -- excepto el seller del listing
    INSERT INTO notification.MarketNotification (
        UserId, ListingId, Type, Title, Body
    )
    SELECT
        U.UserId,
        @ListingId,
        'NEW_LISTING',
        'Nueva publicación disponible',
        CONCAT(ISNULL(@SellerName, 'Un vendedor'), ' publicó: ', @ListingTitle)
    FROM auth.Users U
    WHERE U.IsActive = 1
      AND U.UserId <> (SELECT UserId FROM market.Listing WHERE ListingId = @ListingId)
      -- No enviar si ya recibió esta notificación
      AND NOT EXISTS (
          SELECT 1
          FROM notification.MarketNotification MN
          WHERE MN.UserId    = U.UserId
            AND MN.ListingId = @ListingId
            AND MN.Type      = 'NEW_LISTING'
      );

    SELECT
        @ListingId    AS ListingId,
        @ListingTitle AS ListingTitle,
        @@ROWCOUNT    AS NotificationsSent;
END;
GO
