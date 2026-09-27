-- ============================================================
-- V025__register_player_with_character.sql
-- Registro de jugador en UNA pantalla: cuenta + personaje + menu.
--
--   1) core.Class: 7 clases nuevas (6 por faccion, 12 total)
--   2) Indice unico UX_core_Character_CharacterName (nombre unico en
--      todo el servidor; la collation CI hace que no distinga mayusculas)
--   3) auth.Users.EmailCreated bit NOT NULL DEFAULT 0
--      (email reservado <nombre>@reloader.dev; el admin crea la casilla
--       en Zoho y luego marca EmailCreated = 1)
--   4) auth.sp_RegisterPlayerWithCharacter
--   5) core.sp_GetFactionsWithClasses
--   6) auth.sp_GetUserEmailStatus
--   7) auth.sp_ListPendingEmails
--   8) Backfill: usuarios activos sin UserProfile / sin rol / sin core.Player
--
-- No modifica sp_RegisterPublicUser, sp_CreateCharacter ni sp_LoginUser.
-- ============================================================


-- ------------------------------------------------------------
-- 1) Clases nuevas — codigo <ARQUETIPO>_<FACCION>
--    FactionId se resuelve por FactionCode (sin hardcodear IDs)
-- ------------------------------------------------------------
DECLARE @LuzId   INT = (SELECT FactionId FROM core.Faction WHERE FactionCode = 'LUZ');
DECLARE @FuriaId INT = (SELECT FactionId FROM core.Faction WHERE FactionCode = 'FURIA');

IF @LuzId IS NULL OR @FuriaId IS NULL
    THROW 50250, 'V025: no se encontraron las facciones LUZ / FURIA.', 1;

IF NOT EXISTS (SELECT 1 FROM core.Class WHERE ClassCode = 'WARRIOR_LUZ')
    INSERT INTO core.Class (FactionId, ClassCode, ClassName, IsActive) VALUES (@LuzId, 'WARRIOR_LUZ', N'Luchador', 1);
IF NOT EXISTS (SELECT 1 FROM core.Class WHERE ClassCode = 'ASSASSIN_LUZ')
    INSERT INTO core.Class (FactionId, ClassCode, ClassName, IsActive) VALUES (@LuzId, 'ASSASSIN_LUZ', N'Ranger', 1);
IF NOT EXISTS (SELECT 1 FROM core.Class WHERE ClassCode = 'HUNTER_LUZ')
    INSERT INTO core.Class (FactionId, ClassCode, ClassName, IsActive) VALUES (@LuzId, 'HUNTER_LUZ', N'Arquero', 1);
IF NOT EXISTS (SELECT 1 FROM core.Class WHERE ClassCode = 'PAGAN_LUZ')
    INSERT INTO core.Class (FactionId, ClassCode, ClassName, IsActive) VALUES (@LuzId, 'PAGAN_LUZ', N'Mago', 1);
IF NOT EXISTS (SELECT 1 FROM core.Class WHERE ClassCode = 'ORACLE_LUZ')
    INSERT INTO core.Class (FactionId, ClassCode, ClassName, IsActive) VALUES (@LuzId, 'ORACLE_LUZ', N'Cura', 1);
IF NOT EXISTS (SELECT 1 FROM core.Class WHERE ClassCode = 'DEFENDER_LUZ')
    INSERT INTO core.Class (FactionId, ClassCode, ClassName, IsActive) VALUES (@LuzId, 'DEFENDER_LUZ', N'Defensor', 1);
IF NOT EXISTS (SELECT 1 FROM core.Class WHERE ClassCode = 'GUARDIAN_FURIA')
    INSERT INTO core.Class (FactionId, ClassCode, ClassName, IsActive) VALUES (@FuriaId, 'GUARDIAN_FURIA', N'Guardian', 1);
GO


-- ------------------------------------------------------------
-- 2) CharacterName unico en todo el servidor
--    Se verifica antes que no haya repetidos (sin distinguir mayusculas)
-- ------------------------------------------------------------
IF EXISTS (
    SELECT CharacterName
    FROM core.Character
    GROUP BY CharacterName
    HAVING COUNT(*) > 1
)
    THROW 50251, 'V025: hay CharacterName repetidos en core.Character; resolverlos antes de crear el indice unico.', 1;

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('core.Character')
      AND name = 'UX_core_Character_CharacterName'
)
    CREATE UNIQUE INDEX [UX_core_Character_CharacterName]
        ON [core].[Character] ([CharacterName]);
GO


-- ------------------------------------------------------------
-- 3) auth.Users.EmailCreated
-- ------------------------------------------------------------
IF COL_LENGTH('auth.Users', 'EmailCreated') IS NULL
    ALTER TABLE [auth].[Users]
        ADD [EmailCreated] BIT NOT NULL
            CONSTRAINT [DF_auth_Users_EmailCreated] DEFAULT ((0));
GO

-- Los emails externos (gmail, etc.) ya existen: no son casillas por crear.
-- Solo los @reloader.dev quedan pendientes (EmailCreated = 0).
UPDATE auth.Users
SET EmailCreated = 1
WHERE Email NOT LIKE N'%@reloader.dev'
  AND EmailCreated = 0;
GO


-- ------------------------------------------------------------
-- 4) auth.sp_RegisterPlayerWithCharacter
--    Crea en una transaccion: Users + UserProfile + UserRole(PLAYER)
--    + core.Player + core.Character (Level 80, IsPrimary 1).
--    Devuelve 1 fila: Success, ErrorCode, UserId, CharacterId, Email
--    ErrorCode: INVALID_CHARACTER_NAME | USERNAME_TAKEN |
--               CHARACTER_NAME_TAKEN | EMAIL_TAKEN | INVALID_CLASS
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE auth.sp_RegisterPlayerWithCharacter
    @Username      NVARCHAR(50),
    @PasswordHash  VARBINARY(256),
    @Salt          VARBINARY(128),
    @CharacterName NVARCHAR(100),
    @FactionId     INT,
    @ClassId       INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ErrorCode    NVARCHAR(50)  = NULL;
    DECLARE @Email        NVARCHAR(255) = NULL;
    DECLARE @UserId       BIGINT        = NULL;
    DECLARE @PlayerId     BIGINT        = NULL;
    DECLARE @CharacterId  BIGINT        = NULL;
    DECLARE @PlayerRoleId INT;

    -- Formato ^[A-Za-z0-9_]{3,20}$ — collation binaria para que [A-Z]
    -- no acepte letras con tilde ni la Ñ; DATALENGTH cuenta espacios finales
    IF @CharacterName IS NULL
       OR DATALENGTH(@CharacterName) / 2 NOT BETWEEN 3 AND 20
       OR @CharacterName COLLATE Latin1_General_BIN2 LIKE N'%[^A-Za-z0-9_]%'
        SET @ErrorCode = 'INVALID_CHARACTER_NAME';
    ELSE
        SET @Email = LOWER(@CharacterName) + N'@reloader.dev';

    IF @ErrorCode IS NULL AND EXISTS (SELECT 1 FROM auth.Users WHERE Username = @Username)
        SET @ErrorCode = 'USERNAME_TAKEN';

    IF @ErrorCode IS NULL AND EXISTS (SELECT 1 FROM core.Character WHERE CharacterName = @CharacterName)
        SET @ErrorCode = 'CHARACTER_NAME_TAKEN';

    IF @ErrorCode IS NULL AND EXISTS (SELECT 1 FROM auth.Users WHERE Email = @Email)
        SET @ErrorCode = 'EMAIL_TAKEN';

    IF @ErrorCode IS NULL AND NOT EXISTS (
        SELECT 1
        FROM core.Class
        WHERE ClassId   = @ClassId
          AND FactionId = @FactionId
          AND IsActive  = 1
    )
        SET @ErrorCode = 'INVALID_CLASS';

    IF @ErrorCode IS NOT NULL
    BEGIN
        SELECT
            CAST(0 AS BIT)                  AS Success,
            CAST(@ErrorCode AS NVARCHAR(50)) AS ErrorCode,
            CAST(NULL AS BIGINT)            AS UserId,
            CAST(NULL AS BIGINT)            AS CharacterId,
            CAST(NULL AS NVARCHAR(255))     AS Email;
        RETURN;
    END

    SELECT @PlayerRoleId = RoleId
    FROM auth.Role
    WHERE RoleCode = 'PLAYER'
      AND IsActive = 1;

    IF @PlayerRoleId IS NULL
        THROW 50252, 'Default PLAYER role was not found.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO auth.Users (
            Username, Email, PasswordHash, Salt, IsActive, FailedAttempts,
            RegistrationSource, EmailCreated, CreatedAt, UpdatedAt
        )
        VALUES (
            @Username, @Email, @PasswordHash, @Salt, 1, 0,
            'PUBLIC', 0, SYSUTCDATETIME(), SYSUTCDATETIME()
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
        SET @CharacterId = CAST(SCOPE_IDENTITY() AS BIGINT);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        -- Carrera entre dos registros simultaneos: el indice/constraint unico
        -- gana y se traduce al mismo ErrorCode de negocio
        IF ERROR_NUMBER() IN (2601, 2627)
        BEGIN
            DECLARE @Msg NVARCHAR(4000) = ERROR_MESSAGE();
            SET @ErrorCode = CASE
                WHEN @Msg LIKE N'%UX_core_Character_CharacterName%' THEN 'CHARACTER_NAME_TAKEN'
                WHEN @Msg LIKE N'%UQ_Users_Username%'               THEN 'USERNAME_TAKEN'
                WHEN @Msg LIKE N'%UQ_Users_Email%'                  THEN 'EMAIL_TAKEN'
                ELSE NULL
            END;

            IF @ErrorCode IS NOT NULL
            BEGIN
                SELECT
                    CAST(0 AS BIT)                  AS Success,
                    CAST(@ErrorCode AS NVARCHAR(50)) AS ErrorCode,
                    CAST(NULL AS BIGINT)            AS UserId,
                    CAST(NULL AS BIGINT)            AS CharacterId,
                    CAST(NULL AS NVARCHAR(255))     AS Email;
                RETURN;
            END
        END;

        THROW;
    END CATCH

    SELECT
        CAST(1 AS BIT)              AS Success,
        CAST(NULL AS NVARCHAR(50))  AS ErrorCode,
        @UserId                     AS UserId,
        @CharacterId                AS CharacterId,
        @Email                      AS Email;
END
GO


-- ------------------------------------------------------------
-- 5) core.sp_GetFactionsWithClasses — solo clases activas
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE core.sp_GetFactionsWithClasses
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        F.FactionId,
        F.FactionCode,
        F.FactionName,
        C.ClassId,
        C.ClassCode,
        C.ClassName
    FROM core.Faction F
    JOIN core.Class C
        ON C.FactionId = F.FactionId
       AND C.IsActive  = 1
    ORDER BY F.FactionId, C.ClassId;
END
GO


-- ------------------------------------------------------------
-- 6) auth.sp_GetUserEmailStatus — 0 filas si el usuario no existe
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE auth.sp_GetUserEmailStatus
    @UserId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.UserId,
        U.Email,
        U.EmailCreated
    FROM auth.Users U
    WHERE U.UserId = @UserId;
END
GO


-- ------------------------------------------------------------
-- 7) auth.sp_ListPendingEmails — casillas por crear en Zoho
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE auth.sp_ListPendingEmails
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.UserId,
        U.Username,
        U.Email,
        U.CreatedAt
    FROM auth.Users U
    WHERE U.IsActive     = 1
      AND U.EmailCreated = 0
    ORDER BY U.CreatedAt DESC, U.UserId DESC;
END
GO


-- ------------------------------------------------------------
-- 8) Backfill — usuarios activos registrados sin perfil / rol / player
--    (ej. leomessi, max, hamilton, Senna, wizard). Sin personaje.
--    El rol PLAYER se asigna solo a quien no tiene NINGUN rol activo,
--    para no sumar PLAYER a un ADMIN o TRADER existente.
-- ------------------------------------------------------------
INSERT INTO auth.UserProfile (UserId, DisplayName)
SELECT U.UserId, U.Username
FROM auth.Users U
WHERE U.IsActive = 1
  AND NOT EXISTS (SELECT 1 FROM auth.UserProfile P WHERE P.UserId = U.UserId);

INSERT INTO auth.UserRole (UserId, RoleId, IsActive)
SELECT U.UserId, R.RoleId, 1
FROM auth.Users U
CROSS JOIN auth.Role R
WHERE R.RoleCode = 'PLAYER'
  AND R.IsActive = 1
  AND U.IsActive = 1
  AND NOT EXISTS (
      SELECT 1 FROM auth.UserRole UR
      WHERE UR.UserId = U.UserId
        AND UR.IsActive = 1
  );

INSERT INTO core.Player (UserId, DisplayName, IsActive)
SELECT U.UserId, U.Username, 1
FROM auth.Users U
WHERE U.IsActive = 1
  AND NOT EXISTS (SELECT 1 FROM core.Player P WHERE P.UserId = U.UserId);
GO
