-- ============================================================
-- V032__demo_password.sql
-- Contrasena unica de los usuarios demo: 'DemoReloader2026!'
-- (reemplaza 'Demo1234' de V029). Decision del usuario 2026-09-26.
--
--   Solo usuarios demo_* creados por V029 (RegistrationSource ADMIN).
--   Hash igual que auth.sp_RegisterUser / V029:
--   SHA2_256(nvarchar password + salt), salt nuevo CRYPT_GEN_RANDOM(32)
--   por usuario. Resetea FailedAttempts.
--   No toca a usuarios que se registraron solos (RyoskePlayer) ni a
--   los usuarios del seed S000.
-- ============================================================

DECLARE @Password NVARCHAR(200) = N'DemoReloader2026!';

DECLARE @Demos TABLE (RowNo INT IDENTITY(1,1) PRIMARY KEY, UserId BIGINT NOT NULL);

INSERT INTO @Demos (UserId)
SELECT UserId
FROM auth.Users
WHERE Username IN ('demo_guardian', 'demo_luchador', 'demo_defensor', 'demo_ranger',
                   'demo_arquero', 'demo_mago', 'demo_cura')
  AND RegistrationSource = 'ADMIN'
ORDER BY UserId;

DECLARE @i INT = 1, @n INT = (SELECT COUNT(*) FROM @Demos);
DECLARE @UserId BIGINT, @Salt VARBINARY(128);

WHILE @i <= @n
BEGIN
    SELECT @UserId = UserId FROM @Demos WHERE RowNo = @i;
    SET @Salt = CRYPT_GEN_RANDOM(32);

    UPDATE auth.Users
    SET Salt           = @Salt,
        PasswordHash   = HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @Password) + @Salt),
        FailedAttempts = 0,
        UpdatedAt      = SYSUTCDATETIME()
    WHERE UserId = @UserId;

    SET @i += 1;
END
GO
