-- ============================================================
-- V024__disable_menu_pvp_online.sql
-- Desactiva el item de menu PVP Online (IsActive = 0).
-- Reemplaza el borrador de sesion V023__disable_menu_pvp_listings.sql:
-- Mis Publicaciones (MY_LISTINGS) queda ACTIVO; solo se oculta PVP_ONLINE.
-- Los roles se mantienen en menu.MenuItemRole: para reactivarlo basta
--   UPDATE menu.MenuItem SET IsActive = 1 WHERE MenuCode = 'PVP_ONLINE';
-- ============================================================

UPDATE menu.MenuItem
SET IsActive = 0
WHERE MenuCode = 'PVP_ONLINE';
GO
