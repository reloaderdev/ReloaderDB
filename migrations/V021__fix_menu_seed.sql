-- ============================================================
-- V021__fix_menu_seed.sql
-- Corrige el seed del menú:
--   - Elimina NOTIFICATIONS (no es ítem de menú)
--   - Corrige PROFILE → PERFIL con ruta /perfil
--   - Agrega RULETA y PVP_ONLINE
--   - ADMIN_PANEL queda desactivado (IsActive = 0)
--   - Asigna todos los ítems activos al rol ADMIN
-- ============================================================

-- Limpiar roles existentes para reseedear limpio
DELETE FROM menu.MenuItemRole;
GO

-- Limpiar ítems existentes
DELETE FROM menu.MenuItem;
DBCC CHECKIDENT ('menu.MenuItem', RESEED, 0);
GO

-- ============================================================
-- SEED DEFINITIVO
-- ============================================================
INSERT INTO menu.MenuItem (MenuCode, MenuName, IconUrl, Route, SortOrder, IsActive)
VALUES
    ('PERFIL',       'Mi Perfil',          NULL, '/perfil',       1, 1),
    ('CHARACTER',    'Mi Personaje',       NULL, '/character',    2, 1),
    ('RULETA',       'Ruleta',             NULL, '/ruleta',       3, 1),
    ('PVP_ONLINE',   'PVP Online',         NULL, '/pvp-online',   4, 1),
    ('MARKETPLACE',  'Marketplace',        NULL, '/marketplace',  5, 1),
    ('MY_LISTINGS',  'Mis Publicaciones',  NULL, '/my-listings',  6, 1),
    ('ADMIN_PANEL',  'Panel Admin',        NULL, '/admin',        7, 0);  -- desactivado hasta que exista la pantalla
GO

-- ============================================================
-- ROLES — solo ítems activos
-- ============================================================

-- PERFIL → PLAYER, TRADER, ADMIN
INSERT INTO menu.MenuItemRole (MenuItemId, RoleCode)
SELECT MenuItemId, 'PLAYER' FROM menu.MenuItem WHERE MenuCode = 'PERFIL';
INSERT INTO menu.MenuItemRole (MenuItemId, RoleCode)
SELECT MenuItemId, 'TRADER' FROM menu.MenuItem WHERE MenuCode = 'PERFIL';
INSERT INTO menu.MenuItemRole (MenuItemId, RoleCode)
SELECT MenuItemId, 'ADMIN'  FROM menu.MenuItem WHERE MenuCode = 'PERFIL';
GO

-- CHARACTER → PLAYER, ADMIN
INSERT INTO menu.MenuItemRole (MenuItemId, RoleCode)
SELECT MenuItemId, 'PLAYER' FROM menu.MenuItem WHERE MenuCode = 'CHARACTER';
INSERT INTO menu.MenuItemRole (MenuItemId, RoleCode)
SELECT MenuItemId, 'ADMIN'  FROM menu.MenuItem WHERE MenuCode = 'CHARACTER';
GO

-- RULETA → PLAYER, ADMIN
INSERT INTO menu.MenuItemRole (MenuItemId, RoleCode)
SELECT MenuItemId, 'PLAYER' FROM menu.MenuItem WHERE MenuCode = 'RULETA';
INSERT INTO menu.MenuItemRole (MenuItemId, RoleCode)
SELECT MenuItemId, 'ADMIN'  FROM menu.MenuItem WHERE MenuCode = 'RULETA';
GO

-- PVP_ONLINE → PLAYER, ADMIN
INSERT INTO menu.MenuItemRole (MenuItemId, RoleCode)
SELECT MenuItemId, 'PLAYER' FROM menu.MenuItem WHERE MenuCode = 'PVP_ONLINE';
INSERT INTO menu.MenuItemRole (MenuItemId, RoleCode)
SELECT MenuItemId, 'ADMIN'  FROM menu.MenuItem WHERE MenuCode = 'PVP_ONLINE';
GO

-- MARKETPLACE → PLAYER, TRADER, ADMIN
INSERT INTO menu.MenuItemRole (MenuItemId, RoleCode)
SELECT MenuItemId, 'PLAYER' FROM menu.MenuItem WHERE MenuCode = 'MARKETPLACE';
INSERT INTO menu.MenuItemRole (MenuItemId, RoleCode)
SELECT MenuItemId, 'TRADER' FROM menu.MenuItem WHERE MenuCode = 'MARKETPLACE';
INSERT INTO menu.MenuItemRole (MenuItemId, RoleCode)
SELECT MenuItemId, 'ADMIN'  FROM menu.MenuItem WHERE MenuCode = 'MARKETPLACE';
GO

-- MY_LISTINGS → PLAYER, TRADER, ADMIN
INSERT INTO menu.MenuItemRole (MenuItemId, RoleCode)
SELECT MenuItemId, 'PLAYER' FROM menu.MenuItem WHERE MenuCode = 'MY_LISTINGS';
INSERT INTO menu.MenuItemRole (MenuItemId, RoleCode)
SELECT MenuItemId, 'TRADER' FROM menu.MenuItem WHERE MenuCode = 'MY_LISTINGS';
INSERT INTO menu.MenuItemRole (MenuItemId, RoleCode)
SELECT MenuItemId, 'ADMIN'  FROM menu.MenuItem WHERE MenuCode = 'MY_LISTINGS';
GO
