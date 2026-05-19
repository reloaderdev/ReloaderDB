-- ============================================================
-- V017__market_category_seed.sql
-- Categorías iniciales del marketplace
-- Administrable desde panel — agregar más con INSERT simple
-- ============================================================

INSERT INTO [market].[Category] (CategoryCode, CategoryName, SortOrder, IsActive)
VALUES
    ('ORO',         'Oro / Gold',       1,  1),
    ('CUENTA',      'Cuenta',           2,  1),
    ('SET',         'Set / Armadura',   3,  1),
    ('ARMA',        'Arma',             4,  1),
    ('ACCESORIO',   'Accesorio',        5,  1),
    ('ALAS',        'Alas',             6,  1),
    ('MONTURA',     'Montura',          7,  1),
    ('TRAJE',       'Traje',            8,  1),
    ('PET',         'Pet',              9,  1),
    ('GEMA',        'Gema / Lapis',     10, 1),
    ('GM',          'GM Items',         11, 1),
    ('CONSUMIBLE',  'Consumible',       12, 1);
GO
