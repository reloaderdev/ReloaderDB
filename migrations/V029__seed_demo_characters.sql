-- ============================================================
-- V029__seed_demo_characters.sql
-- Personajes demo: uno por clase, todos equipados con el auto-linkeo.
--
--   1) Usuarios demo para las 7 clases que no tenian personaje:
--      Guardian, Luchador, Defensor, Ranger, Arquero, Mago, Cura.
--      Users + UserProfile + UserRole(PLAYER) + core.Player + core.Character
--      (Level 80, IsPrimary 1). Email <personaje>@reloader.dev (EmailCreated 0).
--      Password de DESARROLLO 'Demo1234', hasheada igual que
--      auth.sp_RegisterUser del baseline: SHA2_256(nvarchar password + salt),
--      salt = CRYPT_GEN_RANDOM(32). Ver dbreadme/DEMOS.md.
--   2) equipment.sp_AutoLinkCharacter a DibuWar, RomeroSin, DePaulPagan,
--      MacOracle y a los 7 demos nuevos.
--   NazgulKash (messi) NO se toca.
--   Idempotente: si el usuario / personaje ya existe no se vuelve a crear,
--   y el auto-linkeo no hace nada si el personaje ya tiene equipo.
-- ============================================================

DECLARE @Password NVARCHAR(200) = N'Demo1234';

DECLARE @PlayerRoleId INT = (SELECT RoleId FROM auth.Role WHERE RoleCode = 'PLAYER' AND IsActive = 1);
IF @PlayerRoleId IS NULL
    THROW 50290, 'V029: no se encontro el rol PLAYER.', 1;

DECLARE @Demos TABLE (
    RowNo         INT IDENTITY(1,1) PRIMARY KEY,
    Username      NVARCHAR(50)  NOT NULL,
    CharacterName NVARCHAR(100) NOT NULL,
    ClassCode     NVARCHAR(30)  NOT NULL
);

INSERT INTO @Demos (Username, CharacterName, ClassCode)
VALUES
('demo_guardian', N'GuardianDemo', 'GUARDIAN_FURIA'),
('demo_luchador', N'LuchadorDemo', 'WARRIOR_LUZ'),
('demo_defensor', N'DefensorDemo', 'DEFENDER_LUZ'),
('demo_ranger',   N'RangerDemo',   'ASSASSIN_LUZ'),
('demo_arquero',  N'ArqueroDemo',  'HUNTER_LUZ'),
('demo_mago',     N'MagoDemo',     'PAGAN_LUZ'),
('demo_cura',     N'CuraDemo',     'ORACLE_LUZ');

IF EXISTS (SELECT 1 FROM @Demos D LEFT JOIN core.Class C ON C.ClassCode = D.ClassCode WHERE C.ClassId IS NULL)
    THROW 50291, 'V029: falta alguna clase de los demos en core.Class.', 1;

DECLARE @i INT = 1, @n INT = (SELECT COUNT(*) FROM @Demos);
DECLARE @Username NVARCHAR(50), @CharacterName NVARCHAR(100), @ClassCode NVARCHAR(30);
DECLARE @Email NVARCHAR(255), @Salt VARBINARY(128), @Hash VARBINARY(256);
DECLARE @UserId BIGINT, @PlayerId BIGINT, @ClassId INT, @FactionId INT;

WHILE @i <= @n
BEGIN
    SELECT @Username = Username, @CharacterName = CharacterName, @ClassCode = ClassCode
    FROM @Demos WHERE RowNo = @i;

    SELECT @ClassId = ClassId, @FactionId = FactionId
    FROM core.Class WHERE ClassCode = @ClassCode;

    SET @Email = LOWER(@CharacterName) + N'@reloader.dev';

    IF NOT EXISTS (SELECT 1 FROM auth.Users WHERE Username = @Username)
       AND NOT EXISTS (SELECT 1 FROM auth.Users WHERE Email = @Email)
       AND NOT EXISTS (SELECT 1 FROM core.Character WHERE CharacterName = @CharacterName)
    BEGIN
        SET @Salt = CRYPT_GEN_RANDOM(32);
        SET @Hash = HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @Password) + @Salt);

        INSERT INTO auth.Users (
            Username, Email, PasswordHash, Salt, IsActive, FailedAttempts,
            RegistrationSource, EmailCreated, CreatedAt, UpdatedAt
        )
        VALUES (
            @Username, @Email, @Hash, @Salt, 1, 0,
            'ADMIN', 0, SYSUTCDATETIME(), SYSUTCDATETIME()
        );
        SET @UserId = CAST(SCOPE_IDENTITY() AS BIGINT);

        INSERT INTO auth.UserProfile (UserId, DisplayName)
        VALUES (@UserId, @CharacterName);

        INSERT INTO auth.UserRole (UserId, RoleId, IsActive)
        VALUES (@UserId, @PlayerRoleId, 1);

        INSERT INTO core.Player (UserId, DisplayName, IsActive)
        VALUES (@UserId, @CharacterName, 1);
        SET @PlayerId = CAST(SCOPE_IDENTITY() AS BIGINT);

        INSERT INTO core.Character (
            PlayerId, FactionId, ClassId, CharacterName, Level, IsPrimary, IsActive
        )
        VALUES (
            @PlayerId, @FactionId, @ClassId, @CharacterName, 80, 1, 1
        );
    END

    SET @i += 1;
END
GO


-- ------------------------------------------------------------
-- 2) Auto-linkeo de los personajes sin equipo (NazgulKash excluido)
-- ------------------------------------------------------------
DECLARE @ToLink TABLE (RowNo INT IDENTITY(1,1) PRIMARY KEY, CharacterId BIGINT NOT NULL);

INSERT INTO @ToLink (CharacterId)
SELECT C.CharacterId
FROM core.Character C
WHERE C.IsActive = 1
  AND C.CharacterName IN (
      N'DibuWar', N'RomeroSin', N'DePaulPagan', N'MacOracle',
      N'GuardianDemo', N'LuchadorDemo', N'DefensorDemo', N'RangerDemo',
      N'ArqueroDemo', N'MagoDemo', N'CuraDemo'
  )
  AND C.CharacterName <> N'NazgulKash'
ORDER BY C.CharacterId;

DECLARE @i INT = 1, @n INT = (SELECT COUNT(*) FROM @ToLink), @CharacterId BIGINT;

WHILE @i <= @n
BEGIN
    SELECT @CharacterId = CharacterId FROM @ToLink WHERE RowNo = @i;

    EXEC equipment.sp_AutoLinkCharacter
        @CharacterId = @CharacterId,
        @Silent      = 1;

    SET @i += 1;
END
GO
