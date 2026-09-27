-- ============================================================
-- V031__seed_test_players.sql
-- Usuarios de prueba de la sesion del 2026-09-26 (registro + set
-- recomendado), para tenerlos igual en desarrollo y en produccion.
--
--   1) OtamendiWar (usuario otamendi del seed S000): Guerrero Furia,
--      nivel 80, principal. Solo con el casco del set (encanto 20,
--      sockets vacios), como quedo probando "Anadir".
--   2) RyoskePlayer: registro publico (PLAYER) con el personaje ryoske,
--      Oraculo Furia, nivel 80, principal. Email reservado
--      ryoske@reloader.dev (EmailCreated 0). Se copian el hash y el salt
--      del alta en desarrollo: entra con la misma contrasena.
--      Set recomendado completo: 16 piezas con sus lapis sugeridos.
--   Idempotente: si el usuario / personaje ya existe no se vuelve a crear,
--   y sp_EquipSlots solo equipa slots vacios.
-- ============================================================

-- ------------------------------------------------------------
-- 1) OtamendiWar
-- ------------------------------------------------------------
DECLARE @PlayerId    BIGINT = (SELECT P.PlayerId FROM core.Player P
                               JOIN auth.Users U ON U.UserId = P.UserId
                               WHERE U.Username = 'otamendi');
DECLARE @ClassId     INT, @FactionId INT, @CharacterId BIGINT;

SELECT @ClassId = ClassId, @FactionId = FactionId
FROM core.Class WHERE ClassCode = 'WARRIOR_FURIA';

IF @ClassId IS NULL
    THROW 50310, 'V031: no se encontro la clase WARRIOR_FURIA.', 1;

IF @PlayerId IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM core.Character WHERE CharacterName = N'OtamendiWar')
BEGIN
    INSERT INTO core.Character (
        PlayerId, FactionId, ClassId, CharacterName, Level, IsPrimary, IsActive
    )
    VALUES (
        @PlayerId, @FactionId, @ClassId, N'OtamendiWar', 80,
        CASE WHEN EXISTS (SELECT 1 FROM core.Character
                          WHERE PlayerId = @PlayerId AND IsPrimary = 1) THEN 0 ELSE 1 END,
        1
    );
    SET @CharacterId = CAST(SCOPE_IDENTITY() AS BIGINT);

    EXEC equipment.sp_EquipSlots
        @CharacterId          = @CharacterId,
        @SlotCodes            = N'HELMET',
        @WithRecommendedLapis = 0;
END
GO


-- ------------------------------------------------------------
-- 2) RyoskePlayer / ryoske
-- ------------------------------------------------------------
DECLARE @PlayerRoleId INT = (SELECT RoleId FROM auth.Role WHERE RoleCode = 'PLAYER' AND IsActive = 1);
DECLARE @ClassId INT, @FactionId INT;
DECLARE @UserId BIGINT, @PlayerId BIGINT, @CharacterId BIGINT;

IF @PlayerRoleId IS NULL
    THROW 50311, 'V031: no se encontro el rol PLAYER.', 1;

SELECT @ClassId = ClassId, @FactionId = FactionId
FROM core.Class WHERE ClassCode = 'ORACLE_FURIA';

IF @ClassId IS NULL
    THROW 50312, 'V031: no se encontro la clase ORACLE_FURIA.', 1;

IF NOT EXISTS (SELECT 1 FROM auth.Users WHERE Username = 'RyoskePlayer')
   AND NOT EXISTS (SELECT 1 FROM auth.Users WHERE Email = N'ryoske@reloader.dev')
   AND NOT EXISTS (SELECT 1 FROM core.Character WHERE CharacterName = N'ryoske')
BEGIN
    INSERT INTO auth.Users (
        Username, Email, PasswordHash, Salt, IsActive, FailedAttempts,
        RegistrationSource, EmailCreated, CreatedAt, UpdatedAt
    )
    VALUES (
        'RyoskePlayer', N'ryoske@reloader.dev',
        0x665394DEDEF411BB01C2A908383272870AF4364CED698C1850908FC94EF55314,
        0x1B37364FCCFB6D9317F5ADE7265F2BDB93A0DC82661C810A6F1B34284D3E70C2,
        1, 0, 'PUBLIC', 0, SYSUTCDATETIME(), SYSUTCDATETIME()
    );
    SET @UserId = CAST(SCOPE_IDENTITY() AS BIGINT);

    INSERT INTO auth.UserProfile (UserId, DisplayName)
    VALUES (@UserId, N'ryoske');

    INSERT INTO auth.UserRole (UserId, RoleId, IsActive)
    VALUES (@UserId, @PlayerRoleId, 1);

    INSERT INTO core.Player (UserId, DisplayName, IsActive)
    VALUES (@UserId, N'ryoske', 1);
    SET @PlayerId = CAST(SCOPE_IDENTITY() AS BIGINT);

    INSERT INTO core.Character (
        PlayerId, FactionId, ClassId, CharacterName, Level, IsPrimary, IsActive
    )
    VALUES (
        @PlayerId, @FactionId, @ClassId, N'ryoske', 80, 1, 1
    );
    SET @CharacterId = CAST(SCOPE_IDENTITY() AS BIGINT);

    EXEC equipment.sp_EquipSlots
        @CharacterId          = @CharacterId,
        @SlotCodes            = N'HELMET,TOP,PANTS,GLOVES,BOOTS,WEAPON,SHIELD,PET,CAPE,WING,AMULET,RING_LEFT,RING_RIGHT,BRACELET_LEFT,BRACELET_RIGHT,SUIT',
        @WithRecommendedLapis = 1;
END
GO
