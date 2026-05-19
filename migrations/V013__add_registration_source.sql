-- ============================================================
-- V013__add_registration_source.sql
-- Agrega campo RegistrationSource a auth.Users
-- Valores: 'ADMIN' (registrado por panel) | 'PUBLIC' (registrado desde landing)
-- ============================================================

ALTER TABLE [auth].[Users]
ADD [RegistrationSource] NVARCHAR(20) NOT NULL DEFAULT ('ADMIN');
GO
