# DB Migrations — Convenciones y Guía

## Ubicación

```
reloaderproject-rest/
└── db/
    └── migrations/
        ├── V000__baseline.sql
        ├── V001__create_schema.sql
        ├── ...
        ├── V012__item_image_url.sql
        ├── V013__add_registration_source.sql
        ├── V014__sp_register_public_user.sql
        └── V015__sp_register_supplier.sql
```

**Nota:** Las migrations V013+ fueron creadas para los microservicios (reloaderproject-ms) pero viven acá porque comparten la misma DB `reloader-games-db`.

## Convención de nombres

```
V{numero}__{descripcion_snake_case}.sql
```

- Número correlativo: `V001`, `V002`, ..., `V012`, `V013`, ...
- Doble guion bajo (`__`) entre versión y descripción — requisito de Flyway
- Descripción en snake_case, en inglés
- Una responsabilidad por archivo

**Ejemplos correctos:**
```
V013__add_character_faction.sql
V014__sp_update_equipment.sql
```

## Historial de migraciones

| Versión | Descripción |
|---|---|
| V000 | Baseline — estado inicial de la base |
| V001 | Creación de schemas y tablas base |
| V002–V006 | Datos seed: items, lapis, sockets iniciales |
| V007 | Stored procedures base de personaje |
| V008 | Re-inserta EquippedItemLapis con lookup dinámico (fix producción) |
| V009 | SP GetCharacterScreen — result set equipment |
| V010 | SP GetCharacterScreen — catálogo lapis y aplicabilidad |
| V011 | SP SaveCharacterLapisConfig — guardar lapis vía XML |
| V012 | Columna ImageUrl en catalog.Item + URLs Azure Storage + SP update |
| V013 | Campo `RegistrationSource` en `auth.Users` — valores: `ADMIN` / `PUBLIC` / `SUPPLIER` |
| V014 | SP `auth.sp_RegisterPublicUser` — registro desde landing pública (RegistrationSource=PUBLIC) |
| V015 | SP `auth.sp_RegisterSupplier` — registro de proveedores (RegistrationSource=SUPPLIER) |

## Reglas para escribir migrations

1. **Idempotencia donde sea posible**: usar `CREATE OR ALTER PROCEDURE`, `IF NOT EXISTS`
2. **Sin hardcodear IDENTITY values**: usar JOINs dinámicos para referenciar filas (ver V008)
3. **GO como separador**: necesario para DDL en SQL Server cuando hay múltiples statements
4. **Una sola responsabilidad**: no mezclar DDL con DML con SPs en el mismo archivo
5. **Nunca modificar un archivo ya aplicado en producción**: crear uno nuevo (`flyway repair` solo si fue un error antes de aplicar en prod)

## Schemas en uso

| Schema | Contenido |
|---|---|
| `auth` | Usuarios, login |
| `catalog` | Items, lapis, tipos |
| `equipment` | CharacterEquipment, sockets, lapis equipados |

## Ambiente local Docker

### PC Casa
```
Host:       localhost:1433
DB:         reloader-games-db
User:       devlocal
Password:   Dev@Local2026
Contenedor: sql-dev (imagen mssql/server:2022)
Red:        reloader-network
```

### Mac Work
```
Host:       localhost:1433
DB:         reloader-games-db
User:       sa
Password:   iOSDeveloper10%
Contenedor: sql-dev (imagen azure-sql-edge — compatible Apple Silicon)
Red:        reloader-network
Schema:     V000 → V015 aplicados ✅
```

## Ambiente producción (Azure SQL)

```
Host: reloader-db-server.database.windows.net:1433
DB: reloader-games-db
User: (ver secrets Azure)
```

Ver `documentation/flyway.md` para los comandos completos de conexión.
