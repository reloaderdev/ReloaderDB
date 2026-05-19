# db — Versionamiento de Base de Datos

## Estructura

```
db/
├── migrations/     → Cambios de schema (DDL): CREATE, ALTER, DROP
├── seeds/          → Data inicial y datos maestros (DML): INSERT
└── dbreadme/       → Documentación de implementación por fase
```

---

## Convención de nombres

| Tipo | Formato | Ejemplo |
|---|---|---|
| Migration | `V{numero}__{descripcion}.sql` | `V001__add_nivel_to_character.sql` |
| Seed | `S{numero}__{descripcion}.sql` | `S001__add_nueva_faccion.sql` |

**Regla:** nunca modificar un archivo ya aplicado. Cada cambio es un archivo nuevo.

---

## Cómo aplicar scripts

### En local (SQL Server Docker)
```bash
sqlcmd -S localhost -d reloader-games-db -U sa -P "tu_password" -i db/migrations/V001__....sql
```

### En Azure (producción)
```bash
sqlcmd -S reloader-sql-server.database.windows.net -d reloader-games-db -U sqladmin -P "****" -i db/migrations/V001__....sql
```

---

## Historial de fases

| Fase | Descripción | Detalle |
|---|---|---|
| Fase 1 | Generación del baseline completo desde Azure SQL | [Ver documentación](dbreadme/FASE1_IMPLEMENTACION.md) |
| Fase 2 | Ambiente local con Docker SQL Server — réplica exacta de Azure | [Ver documentación](dbreadme/FASE2_AMBIENTE_LOCAL.md) |
| Fase 3 | Webservice Docker conectado al SQL Server local — ambiente completo sin Azure | [Ver documentación](dbreadme/FASE3_WEBSERVICE_LOCAL.md) |

---

## Scripts actuales

### migrations/
| Archivo | Descripción |
|---|---|
| `V000__baseline.sql` | Schema completo: 7 schemas, 31 tablas, 49 FK, 16 SPs |

### seeds/
| Archivo | Descripción |
|---|---|
| `S000__full_data.sql` | Data completa exportada desde Azure SQL (2026-04-18) |
