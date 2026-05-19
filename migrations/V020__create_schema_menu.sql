-- ============================================================
-- V020__create_schema_menu.sql
-- Schema menu: menú dinámico por rol
-- Sin hardcodeo en el frontend — todo controlado desde la DB
-- Íconos en Azure Storage (reloader-files)
-- ============================================================

-- ============================================================
-- SCHEMA
-- ============================================================
CREATE SCHEMA [menu];
GO

-- ============================================================
-- menu.MenuItem
-- Cada ítem del menú de la app
-- IsActive = 0 lo deshabilita para todos sin tocar código
-- ============================================================
CREATE TABLE [menu].[MenuItem] (
    [MenuItemId]  int           IDENTITY(1,1) NOT NULL,
    [MenuCode]    nvarchar(50)  NOT NULL,
    [MenuName]    nvarchar(100) NOT NULL,
    [IconUrl]     nvarchar(500) NULL,         -- Azure Storage
    [Route]       nvarchar(200) NOT NULL,     -- ruta en la app
    [SortOrder]   int           NOT NULL DEFAULT ((0)),
    [IsActive]    bit           NOT NULL DEFAULT ((1)),
    [CreatedAt]   datetime2     NOT NULL DEFAULT (sysutcdatetime()),
    CONSTRAINT [PK_menu_MenuItem] PRIMARY KEY ([MenuItemId])
);
GO

ALTER TABLE [menu].[MenuItem]
    ADD CONSTRAINT [UQ_menu_MenuItem_Code] UNIQUE ([MenuCode]);
GO

-- ============================================================
-- menu.MenuItemRole
-- Qué roles ven qué ítems del menú
-- ============================================================
CREATE TABLE [menu].[MenuItemRole] (
    [MenuItemRoleId] int          IDENTITY(1,1) NOT NULL,
    [MenuItemId]     int          NOT NULL,
    [RoleCode]       nvarchar(50) NOT NULL,
    CONSTRAINT [PK_menu_MenuItemRole] PRIMARY KEY ([MenuItemRoleId])
);
GO

ALTER TABLE [menu].[MenuItemRole]
    ADD CONSTRAINT [UQ_menu_MenuItemRole] UNIQUE ([MenuItemId], [RoleCode]);
GO

ALTER TABLE [menu].[MenuItemRole]
    ADD CONSTRAINT [FK_menu_MenuItemRole_MenuItem]
    FOREIGN KEY ([MenuItemId]) REFERENCES [menu].[MenuItem] ([MenuItemId]);
GO

-- ============================================================
-- SEED — Ítems del menú inicial
-- ============================================================
INSERT INTO [menu].[MenuItem] (MenuCode, MenuName, IconUrl, Route, SortOrder, IsActive)
VALUES
    ('MARKETPLACE',   'Marketplace',       NULL, '/marketplace',    1, 1),
    ('MY_LISTINGS',   'Mis Publicaciones', NULL, '/my-listings',    2, 1),
    ('CHARACTER',     'Mi Personaje',      NULL, '/character',      3, 1),
    ('NOTIFICATIONS', 'Notificaciones',    NULL, '/notifications',  4, 1),
    ('PROFILE',       'Mi Perfil',         NULL, '/profile',        5, 1),
    ('ADMIN_PANEL',   'Panel Admin',       NULL, '/admin',          6, 1);
GO

-- ============================================================
-- SEED — Roles por ítem
-- PLAYER  → todo excepto ADMIN_PANEL
-- TRADER  → marketplace, listings, notificaciones, perfil
-- ADMIN   → todo
-- ============================================================

-- MARKETPLACE
INSERT INTO [menu].[MenuItemRole] (MenuItemId, RoleCode)
SELECT MenuItemId, 'PLAYER' FROM [menu].[MenuItem] WHERE MenuCode = 'MARKETPLACE';
INSERT INTO [menu].[MenuItemRole] (MenuItemId, RoleCode)
SELECT MenuItemId, 'TRADER' FROM [menu].[MenuItem] WHERE MenuCode = 'MARKETPLACE';
INSERT INTO [menu].[MenuItemRole] (MenuItemId, RoleCode)
SELECT MenuItemId, 'ADMIN'  FROM [menu].[MenuItem] WHERE MenuCode = 'MARKETPLACE';
GO

-- MY_LISTINGS
INSERT INTO [menu].[MenuItemRole] (MenuItemId, RoleCode)
SELECT MenuItemId, 'PLAYER' FROM [menu].[MenuItem] WHERE MenuCode = 'MY_LISTINGS';
INSERT INTO [menu].[MenuItemRole] (MenuItemId, RoleCode)
SELECT MenuItemId, 'TRADER' FROM [menu].[MenuItem] WHERE MenuCode = 'MY_LISTINGS';
INSERT INTO [menu].[MenuItemRole] (MenuItemId, RoleCode)
SELECT MenuItemId, 'ADMIN'  FROM [menu].[MenuItem] WHERE MenuCode = 'MY_LISTINGS';
GO

-- CHARACTER — PLAYER y ADMIN solamente
-- TRADER no lo tiene asignado por defecto
-- Si quiere → admin le asigna el rol desde la DB
INSERT INTO [menu].[MenuItemRole] (MenuItemId, RoleCode)
SELECT MenuItemId, 'PLAYER' FROM [menu].[MenuItem] WHERE MenuCode = 'CHARACTER';
INSERT INTO [menu].[MenuItemRole] (MenuItemId, RoleCode)
SELECT MenuItemId, 'ADMIN'  FROM [menu].[MenuItem] WHERE MenuCode = 'CHARACTER';
GO

-- NOTIFICATIONS
INSERT INTO [menu].[MenuItemRole] (MenuItemId, RoleCode)
SELECT MenuItemId, 'PLAYER' FROM [menu].[MenuItem] WHERE MenuCode = 'NOTIFICATIONS';
INSERT INTO [menu].[MenuItemRole] (MenuItemId, RoleCode)
SELECT MenuItemId, 'TRADER' FROM [menu].[MenuItem] WHERE MenuCode = 'NOTIFICATIONS';
INSERT INTO [menu].[MenuItemRole] (MenuItemId, RoleCode)
SELECT MenuItemId, 'ADMIN'  FROM [menu].[MenuItem] WHERE MenuCode = 'NOTIFICATIONS';
GO

-- PROFILE
INSERT INTO [menu].[MenuItemRole] (MenuItemId, RoleCode)
SELECT MenuItemId, 'PLAYER' FROM [menu].[MenuItem] WHERE MenuCode = 'PROFILE';
INSERT INTO [menu].[MenuItemRole] (MenuItemId, RoleCode)
SELECT MenuItemId, 'TRADER' FROM [menu].[MenuItem] WHERE MenuCode = 'PROFILE';
INSERT INTO [menu].[MenuItemRole] (MenuItemId, RoleCode)
SELECT MenuItemId, 'ADMIN'  FROM [menu].[MenuItem] WHERE MenuCode = 'PROFILE';
GO

-- ADMIN_PANEL — solo ADMIN
INSERT INTO [menu].[MenuItemRole] (MenuItemId, RoleCode)
SELECT MenuItemId, 'ADMIN' FROM [menu].[MenuItem] WHERE MenuCode = 'ADMIN_PANEL';
GO

-- ============================================================
-- menu.sp_GetMenuByUser
-- El frontend llama esto al login
-- Devuelve los ítems activos para el rol del usuario
-- ============================================================
CREATE OR ALTER PROCEDURE menu.sp_GetMenuByUser
    @UserId bigint
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RoleCode nvarchar(50);

    SELECT @RoleCode = R.RoleCode
    FROM auth.UserRole UR
    JOIN auth.Role R ON R.RoleId = UR.RoleId
    WHERE UR.UserId   = @UserId
      AND UR.IsActive = 1;

    -- Si no tiene rol asignado → sin menú
    IF @RoleCode IS NULL
    BEGIN
        SELECT
            CAST(NULL AS int)          AS MenuItemId,
            CAST(NULL AS nvarchar(50)) AS MenuCode
        WHERE 1 = 0;
        RETURN;
    END

    SELECT
        MI.MenuItemId,
        MI.MenuCode,
        MI.MenuName,
        MI.IconUrl,
        MI.Route,
        MI.SortOrder
    FROM menu.MenuItem MI
    JOIN menu.MenuItemRole MIR
        ON MIR.MenuItemId = MI.MenuItemId
       AND MIR.RoleCode   = @RoleCode
    WHERE MI.IsActive = 1
    ORDER BY MI.SortOrder;
END;
GO

-- ============================================================
-- Actualizar auth.Role seed — agregar TRADER si no existe
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM auth.Role WHERE RoleCode = 'TRADER')
BEGIN
    INSERT INTO auth.Role (RoleCode, RoleName, Description, IsActive)
    VALUES ('TRADER', 'Trader', 'Usuario del marketplace sin personaje', 1);
END
GO
