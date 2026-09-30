-- ============================================================
-- V035__player_multiple_characters.sql
-- ESTADO: CERRADA (2026-09-30) - no modificar. Pendiente de produccion (produccion en v034).
--
-- Crear personajes nuevos desde la app (Mi Personaje) y cambiar el principal.
-- Reglas (definidas por el usuario, 2026-09-30):
--   - maximo 5 personajes activos por usuario
--   - si ya tiene un personaje totalmente vacio (0 piezas equipadas) no puede
--     crear otro
--   - misma faccion de la cuenta (la de sus personajes activos); sin personajes
--     elige cualquiera
--   - nombre: mismas reglas del registro (^[A-Za-z0-9_]{3,20}$, unico en el
--     servidor por UX_core_Character_CharacterName)
--   - el nuevo nace nivel 80, sin equipo y como principal (IsPrimary = 1).
--     No genera email: el email de la cuenta es el del primer personaje
--
--   1) core.sp_ListPlayerCharacters
--   2) core.sp_CreatePlayerCharacter
--   3) core.sp_SetPrimaryCharacter
--
-- No modifica core.sp_CreateCharacter, core.sp_ListCharactersByUser ni
-- auth.sp_RegisterPlayerWithCharacter.
-- ============================================================


-- ------------------------------------------------------------
-- 1) core.sp_ListPlayerCharacters
--    Result 1 (1 fila): AccountFactionId, AccountFactionCode,
--              AccountFactionName, CharacterCount, MaxCharacters,
--              CanCreate, BlockReason
--              BlockReason: PLAYER_NOT_FOUND | MAX_CHARACTERS |
--                           EMPTY_CHARACTER_EXISTS | NULL
--    Result 2: personajes activos (CharacterId, CharacterName, Level,
--              FactionCode, FactionName, ClassId, ClassCode, ClassName,
--              IsPrimary, EquippedCount), principal primero
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE core.sp_ListPlayerCharacters
    @UserId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaxCharacters INT = 5;
    DECLARE @PlayerId BIGINT = (
        SELECT PlayerId FROM core.Player WHERE UserId = @UserId AND IsActive = 1
    );

    DECLARE @Chars TABLE (
        CharacterId   BIGINT,
        CharacterName NVARCHAR(100),
        Level         INT,
        FactionId     INT,
        FactionCode   NVARCHAR(50),
        FactionName   NVARCHAR(100),
        ClassId       INT,
        ClassCode     NVARCHAR(50),
        ClassName     NVARCHAR(100),
        IsPrimary     BIT,
        CreatedAt     DATETIME2,
        EquippedCount INT
    );

    INSERT INTO @Chars
    SELECT
        C.CharacterId,
        C.CharacterName,
        C.Level,
        F.FactionId,
        F.FactionCode,
        F.FactionName,
        CL.ClassId,
        CL.ClassCode,
        CL.ClassName,
        C.IsPrimary,
        C.CreatedAt,
        (SELECT COUNT(*) FROM equipment.CharacterEquipment CE WHERE CE.CharacterId = C.CharacterId)
    FROM core.Character C
    JOIN core.Faction F ON F.FactionId = C.FactionId
    JOIN core.Class CL  ON CL.ClassId  = C.ClassId
    WHERE C.PlayerId = @PlayerId
      AND C.IsActive = 1;

    DECLARE @CharacterCount INT = (SELECT COUNT(*) FROM @Chars);
    DECLARE @BlockReason NVARCHAR(50) = CASE
        WHEN @PlayerId IS NULL                               THEN 'PLAYER_NOT_FOUND'
        WHEN @CharacterCount >= @MaxCharacters                THEN 'MAX_CHARACTERS'
        WHEN EXISTS (SELECT 1 FROM @Chars WHERE EquippedCount = 0) THEN 'EMPTY_CHARACTER_EXISTS'
        ELSE NULL
    END;

    -- Faccion de la cuenta: la del personaje principal (todos comparten faccion)
    SELECT TOP (1)
        FactionId                           AS AccountFactionId,
        FactionCode                         AS AccountFactionCode,
        FactionName                         AS AccountFactionName,
        @CharacterCount                     AS CharacterCount,
        @MaxCharacters                      AS MaxCharacters,
        CAST(CASE WHEN @BlockReason IS NULL THEN 1 ELSE 0 END AS BIT) AS CanCreate,
        @BlockReason                        AS BlockReason
    FROM (
        SELECT FactionId, FactionCode, FactionName, IsPrimary, CreatedAt FROM @Chars
        UNION ALL
        SELECT CAST(NULL AS INT), CAST(NULL AS NVARCHAR(50)), CAST(NULL AS NVARCHAR(100)), CAST(0 AS BIT), CAST('9999-12-31' AS DATETIME2)
    ) X
    ORDER BY CASE WHEN FactionId IS NULL THEN 1 ELSE 0 END, IsPrimary DESC, CreatedAt ASC;

    SELECT
        CharacterId,
        CharacterName,
        Level,
        FactionCode,
        FactionName,
        ClassId,
        ClassCode,
        ClassName,
        IsPrimary,
        EquippedCount
    FROM @Chars
    ORDER BY IsPrimary DESC, CreatedAt ASC, CharacterId ASC;
END
GO


-- ------------------------------------------------------------
-- 2) core.sp_CreatePlayerCharacter
--    La faccion sale de la clase. Devuelve 1 fila: Success, ErrorCode,
--    CharacterId. Con error no escribe nada.
--    ErrorCode: PLAYER_NOT_FOUND | INVALID_CHARACTER_NAME | INVALID_CLASS |
--               FACTION_MISMATCH | MAX_CHARACTERS | EMPTY_CHARACTER_EXISTS |
--               CHARACTER_NAME_TAKEN
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE core.sp_CreatePlayerCharacter
    @UserId        BIGINT,
    @CharacterName NVARCHAR(100),
    @ClassId       INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @MaxCharacters    INT = 5;
    DECLARE @ErrorCode        NVARCHAR(50) = NULL;
    DECLARE @CharacterId      BIGINT = NULL;
    DECLARE @ClassFactionId   INT = NULL;
    DECLARE @AccountFactionId INT = NULL;
    DECLARE @PlayerId BIGINT = (
        SELECT PlayerId FROM core.Player WHERE UserId = @UserId AND IsActive = 1
    );

    IF @PlayerId IS NULL
        SET @ErrorCode = 'PLAYER_NOT_FOUND';

    -- Mismo formato que auth.sp_RegisterPlayerWithCharacter
    IF @ErrorCode IS NULL AND (
           @CharacterName IS NULL
        OR DATALENGTH(@CharacterName) / 2 NOT BETWEEN 3 AND 20
        OR @CharacterName COLLATE Latin1_General_BIN2 LIKE N'%[^A-Za-z0-9_]%'
    )
        SET @ErrorCode = 'INVALID_CHARACTER_NAME';

    IF @ErrorCode IS NULL
    BEGIN
        SELECT @ClassFactionId = FactionId
        FROM core.Class
        WHERE ClassId = @ClassId
          AND IsActive = 1;

        IF @ClassFactionId IS NULL
            SET @ErrorCode = 'INVALID_CLASS';
    END

    IF @ErrorCode IS NULL
    BEGIN
        SELECT TOP (1) @AccountFactionId = FactionId
        FROM core.Character
        WHERE PlayerId = @PlayerId
          AND IsActive = 1
        ORDER BY IsPrimary DESC, CreatedAt ASC;

        IF @AccountFactionId IS NOT NULL AND @AccountFactionId <> @ClassFactionId
            SET @ErrorCode = 'FACTION_MISMATCH';
    END

    IF @ErrorCode IS NULL
       AND (SELECT COUNT(*) FROM core.Character WHERE PlayerId = @PlayerId AND IsActive = 1) >= @MaxCharacters
        SET @ErrorCode = 'MAX_CHARACTERS';

    IF @ErrorCode IS NULL AND EXISTS (
        SELECT 1
        FROM core.Character C
        WHERE C.PlayerId = @PlayerId
          AND C.IsActive = 1
          AND NOT EXISTS (SELECT 1 FROM equipment.CharacterEquipment CE WHERE CE.CharacterId = C.CharacterId)
    )
        SET @ErrorCode = 'EMPTY_CHARACTER_EXISTS';

    IF @ErrorCode IS NULL AND EXISTS (SELECT 1 FROM core.Character WHERE CharacterName = @CharacterName)
        SET @ErrorCode = 'CHARACTER_NAME_TAKEN';

    IF @ErrorCode IS NOT NULL
    BEGIN
        SELECT
            CAST(0 AS BIT)                   AS Success,
            CAST(@ErrorCode AS NVARCHAR(50)) AS ErrorCode,
            CAST(NULL AS BIGINT)             AS CharacterId;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE core.Character
        SET IsPrimary = 0,
            UpdatedAt = SYSUTCDATETIME()
        WHERE PlayerId = @PlayerId
          AND IsPrimary = 1;

        INSERT INTO core.Character (
            PlayerId, FactionId, ClassId, CharacterName, Level, IsPrimary, IsActive
        )
        VALUES (
            @PlayerId, @ClassFactionId, @ClassId, @CharacterName, 80, 1, 1
        );
        SET @CharacterId = CAST(SCOPE_IDENTITY() AS BIGINT);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        -- Carrera entre dos creaciones con el mismo nombre: gana el indice unico
        IF ERROR_NUMBER() IN (2601, 2627) AND ERROR_MESSAGE() LIKE N'%UX_core_Character_CharacterName%'
        BEGIN
            SELECT
                CAST(0 AS BIT)                         AS Success,
                CAST('CHARACTER_NAME_TAKEN' AS NVARCHAR(50)) AS ErrorCode,
                CAST(NULL AS BIGINT)                   AS CharacterId;
            RETURN;
        END;

        THROW;
    END CATCH

    SELECT
        CAST(1 AS BIT)             AS Success,
        CAST(NULL AS NVARCHAR(50)) AS ErrorCode,
        @CharacterId               AS CharacterId;
END
GO


-- ------------------------------------------------------------
-- 3) core.sp_SetPrimaryCharacter
--    Devuelve 1 fila: Success, ErrorCode (CHARACTER_NOT_FOUND si el
--    personaje no es del usuario o no esta activo). Con error no escribe.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE core.sp_SetPrimaryCharacter
    @UserId      BIGINT,
    @CharacterId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @PlayerId BIGINT = (
        SELECT C.PlayerId
        FROM core.Character C
        JOIN core.Player P ON P.PlayerId = C.PlayerId
        WHERE C.CharacterId = @CharacterId
          AND C.IsActive = 1
          AND P.UserId = @UserId
          AND P.IsActive = 1
    );

    IF @PlayerId IS NULL
    BEGIN
        SELECT
            CAST(0 AS BIT)                        AS Success,
            CAST('CHARACTER_NOT_FOUND' AS NVARCHAR(50)) AS ErrorCode;
        RETURN;
    END

    BEGIN TRANSACTION;

    UPDATE core.Character
    SET IsPrimary = CASE WHEN CharacterId = @CharacterId THEN 1 ELSE 0 END,
        UpdatedAt = SYSUTCDATETIME()
    WHERE PlayerId = @PlayerId
      AND (IsPrimary = 1 OR CharacterId = @CharacterId);

    COMMIT TRANSACTION;

    SELECT
        CAST(1 AS BIT)             AS Success,
        CAST(NULL AS NVARCHAR(50)) AS ErrorCode;
END
GO
