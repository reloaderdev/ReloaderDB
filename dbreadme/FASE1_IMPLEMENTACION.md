# Fase 1 — Generación del Baseline de Base de Datos

**Fecha:** 2026-04-18  
**Estado:** Completado  
**Ejecutado por:** resembrinkcorrea + Claude (DBA / Orquestador)

---

## Objetivo de la Fase 1

Generar los scripts que representan el estado completo actual de la base de datos `reloader-games-db` en Azure SQL, de forma que cualquier máquina nueva pueda reproducir la base exactamente desde cero corriendo esos scripts.

---

## Archivos generados

| Archivo | Ubicación | Contenido |
|---|---|---|
| `V000__baseline.sql` | `db/migrations/` | 7 schemas, 31 tablas, 49 FK constraints, 16 stored procedures |
| `S000__full_data.sql` | `db/seeds/` | Toda la data actual de las 31 tablas en orden correcto por FK |

---

## Lo que se exportó

### V000__baseline.sql — Schema completo

```
Tamaño : 55.5 KB
Líneas : 1597

Contenido:
  CREATE SCHEMA  → 7 schemas (audit, auth, build, catalog, core, equipment, notification)
  CREATE TABLE   → 31 tablas con columnas, tipos, identity, NOT NULL, defaults, PKs
  ALTER TABLE    → 49 foreign key constraints
  CREATE PROCEDURE → 16 stored procedures con lógica completa
```

**Schemas y su responsabilidad:**

| Schema | Tablas | SPs | Responsabilidad |
|---|---|---|---|
| `auth` | 4 | 4 | Autenticación y usuarios |
| `core` | 7 | 3 | Entidades del juego |
| `catalog` | 10 | 0 | Datos maestros del catálogo |
| `build` | 3 | 1 | Sistema de stats del personaje |
| `equipment` | 3 | 7 | Equipamiento del personaje |
| `notification` | 1 | 1 | Push notifications |
| `audit` | 1 | 0 | Trazabilidad |

### S000__full_data.sql — Data completa

```
Tamaño : 68.7 KB
Líneas : 576

Data exportada por tabla:
  auth.Role                     →  2 filas
  auth.Users                    →  8 filas
  auth.UserProfile              →  8 filas
  auth.UserRole                 →  8 filas
  core.Faction                  →  2 filas
  core.Class                    →  5 filas
  core.Guild                    →  2 filas
  core.GuildRank                →  7 filas
  core.Player                   →  8 filas
  core.Character                →  5 filas
  core.GuildMember              →  5 filas
  catalog.StatType              → 15 filas
  catalog.ItemType              → 13 filas
  catalog.EquipmentSlot         → 15 filas
  catalog.BindType              →  3 filas
  catalog.LapisType             →  4 filas
  catalog.Item                  → 10 filas
  catalog.ItemAllowedClass      → 10 filas
  catalog.ItemStat              → 92 filas
  catalog.ItemTypeSlot          → 15 filas
  catalog.Lapis                 →  5 filas
  catalog.LapisEffect           →  9 filas
  catalog.LapisApplicableItemType → 24 filas
  build.CharacterBaseStat       →  6 filas
  build.CharacterAssignedStat   →  0 filas
  build.CharacterFinalStat      → 12 filas
  equipment.CharacterEquipment  → 10 filas
  equipment.EquippedItemSocket  → 42 filas
  equipment.EquippedItemLapis   → 14 filas
  audit.UserLoginEvent          → 19 filas
  notification.DeviceToken      →  4 filas
```

---

## Problemas encontrados y soluciones

### Problema 1 — Output demasiado grande con una sola query

**Qué pasó:**  
El primer intento fue traer los metadatos de todas las columnas de todas las tablas en una sola consulta `sqlcmd`. El resultado fue un archivo de 834 KB que el sistema no pudo procesar correctamente.

**Solución:**  
Cambiar la estrategia: hacer una consulta por tabla dentro de un loop en PowerShell. Cada iteración trae solo las columnas de una tabla, construye el `CREATE TABLE` en memoria y lo escribe al archivo. Sin límite de tamaño.

---

### Problema 2 — Límite de PRINT en T-SQL

**Qué pasó:**  
Se intentó generar el DDL completo directamente en T-SQL usando:
```sql
DECLARE @sql NVARCHAR(MAX) = ''
SELECT @sql = @sql + '...' -- acumulando el DDL
PRINT @sql
```
El `PRINT` en SQL Server tiene un límite de 8000 caracteres. Con 31 tablas el string se cortaba y el output quedaba incompleto.

**Solución:**  
Mover toda la lógica de construcción del DDL a PowerShell. PowerShell no tiene ese límite. T-SQL solo ejecuta queries simples de metadatos; PowerShell ensambla el resultado.

---

### Problema 3 — Padding y formato de salida de sqlcmd

**Qué pasó:**  
`sqlcmd` por defecto agrega espacios de relleno en las columnas para alinear el output visualmente. Al intentar parsear los resultados en PowerShell, los valores venían con espacios extra que rompían la lógica.

**Ejemplo del problema:**
```
audit                     |UserLoginEvent            |UserLoginEventId
```
En lugar de:
```
audit|UserLoginEvent|UserLoginEventId
```

**Solución:**  
Usar los flags `-W` (trim de espacios) y `-s'|'` (separador pipe) en cada llamada a `sqlcmd`. Esto devuelve valores limpios sin padding, parseables directamente con `split('|')`.

---

### Problema 4 — Orden de inserción por FK

**Qué pasó:**  
Si se insertaban datos en orden alfabético por tabla, las FK violaban constraints. Por ejemplo, `core.Character` referencia `core.Player`, que referencia `auth.Users`. Insertar `Character` primero fallaba.

**Solución:**  
Consultar todas las FK de la base (`sys.foreign_keys`) para mapear el árbol de dependencias, y definir manualmente el orden correcto de inserción:

```
auth.Role → auth.Users → core.Faction → catalog.* → core.Player
→ core.Character → equipment.* → audit.* → ...
```

41 relaciones FK mapeadas para determinar el orden correcto de las 31 tablas.

---

### Problema 5 — Columnas IDENTITY en los INSERT

**Qué pasó:**  
Las tablas con columnas `IDENTITY` (auto-increment) rechazan `INSERT` con valor explícito por defecto. Al intentar insertar datos con el ID original, SQL Server lanzaba error.

**Solución:**  
Detectar columnas identity con `COLUMNPROPERTY(..., 'IsIdentity')` y envolver los INSERTs de esas tablas con:
```sql
SET IDENTITY_INSERT [schema].[tabla] ON;
GO
-- INSERTs con IDs explícitos
SET IDENTITY_INSERT [schema].[tabla] OFF;
GO
```

---

## Herramientas utilizadas

| Herramienta | Versión | Uso |
|---|---|---|
| `sqlcmd` | 1.9.0 | Cliente SQL para ejecutar queries contra Azure SQL |
| `PowerShell` | Windows built-in | Orquestación del loop, construcción del DDL, escritura de archivos |
| Azure SQL Database | — | Fuente de los datos (reloader-games-db) |

---

## Cómo usar estos archivos

### Reproducir la base desde cero

```bash
# 1. Crear la base vacía primero en SQL Server local
sqlcmd -S localhost -U sa -P "tu_password" -Q "CREATE DATABASE [reloader-games-db]"

# 2. Correr el schema
sqlcmd -S localhost -d reloader-games-db -U sa -P "tu_password" -i db/migrations/V000__baseline.sql

# 3. Cargar la data
sqlcmd -S localhost -d reloader-games-db -U sa -P "tu_password" -i db/seeds/S000__full_data.sql
```

### Aplicar un cambio nuevo en Azure

```bash
# Solo el script nuevo, nunca modificar V000
sqlcmd -S reloader-sql-server.database.windows.net -d reloader-games-db -U sqladmin -P "****" -i db/migrations/V001__descripcion.sql
```

---

## Siguiente fase

**Fase 2 — Ambiente local con Docker**

1. Levantar SQL Server en Docker local
2. Correr `V000__baseline.sql` y `S000__full_data.sql`
3. Validar que los usuarios existentes pueden loguearse en local
4. Conectar el webservice Docker al SQL Server local
