-- ============================================================
-- V014__sp_register_public_user.sql
-- SP para registrar usuarios desde la landing pública (Ktor)
-- RegistrationSource = 'PUBLIC'
-- ============================================================

CREATE OR ALTER PROCEDURE auth.sp_RegisterPublicUser
    @Username   NVARCHAR(50),
    @Email      NVARCHAR(255),
    @PasswordHash VARBINARY(256),
    @Salt         VARBINARY(128)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar username duplicado
    IF EXISTS (SELECT 1 FROM auth.Users WHERE Username = @Username)
    BEGIN
        SELECT
            CAST(0 AS BIT)      AS Success,
            'USERNAME_TAKEN'    AS ErrorCode,
            NULL                AS UserId;
        RETURN;
    END

    -- Validar email duplicado
    IF EXISTS (SELECT 1 FROM auth.Users WHERE Email = @Email)
    BEGIN
        SELECT
            CAST(0 AS BIT)      AS Success,
            'EMAIL_TAKEN'       AS ErrorCode,
            NULL                AS UserId;
        RETURN;
    END

    -- Insertar usuario
    INSERT INTO auth.Users (
        Username,
        Email,
        PasswordHash,
        Salt,
        IsActive,
        FailedAttempts,
        RegistrationSource,
        CreatedAt,
        UpdatedAt
    )
    VALUES (
        @Username,
        @Email,
        @PasswordHash,
        @Salt,
        1,
        0,
        'PUBLIC',
        SYSUTCDATETIME(),
        SYSUTCDATETIME()
    );

    SELECT
        CAST(1 AS BIT)      AS Success,
        NULL                AS ErrorCode,
        SCOPE_IDENTITY()    AS UserId;
END
GO
