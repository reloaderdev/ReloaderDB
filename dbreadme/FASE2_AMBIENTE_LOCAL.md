# Fase 2 — Ambiente Local con Docker SQL Server

**Fecha:** 2026-04-18  
**Estado:** Completado  
**Ejecutado por:** resembrinkcorrea + Claude (DBA / Orquestador)

---

## Objetivo de la Fase 2

Levantar un ambiente local completo con SQL Server en Docker, cargar los scripts generados en la Fase 1, y tener una réplica exacta de la base de datos de Azure corriendo en la máquina local.

---

## Arquitectura resultante

```
RED: reloader-network (Docker)
─────────────────────────────────────────────
  sql-dev                     reloader-container (próxima fase)
  SQL Server 2022             reloaderproject-app
  puerto 1433                 puerto 8080
  reloader-games-db           DB_URL → sql-dev:1433
```

---

## Comandos ejecutados

### 1. Crear red Docker interna

```bash
docker network create reloader-network
```

Los contenedores que se conecten a esta red se comunican entre sí usando el nombre del contenedor como hostname.

### 2. Levantar SQL Server local

```bash
docker run -d \
  --name sql-dev \
  --network reloader-network \
  -e "ACCEPT_EULA=Y" \
  -e "SA_PASSWORD=iOSDeveloper10%" \
  -p 1433:1433 \
  mcr.microsoft.com/mssql/server:2022-latest
```

### 3. Crear la base de datos

```bash
docker exec sql-dev bash -c \
  "/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'iOSDeveloper10%' -No \
  -Q 'CREATE DATABASE [reloader-games-db]'"
```

### 4. Copiar y ejecutar scripts

```bash
# Copiar al contenedor
docker cp db/migrations/V000__baseline.sql sql-dev:/tmp/V000__baseline.sql
docker cp db/seeds/S000__full_data.sql     sql-dev:/tmp/S000__full_data.sql

# Ejecutar schema
docker exec sql-dev bash -c \
  "/opt/mssql-tools18/bin/sqlcmd -S localhost -d 'reloader-games-db' \
  -U sa -P 'iOSDeveloper10%' -No -i /tmp/V000__baseline.sql"

# Ejecutar data
docker exec sql-dev bash -c \
  "/opt/mssql-tools18/bin/sqlcmd -S localhost -d 'reloader-games-db' \
  -U sa -P 'iOSDeveloper10%' -No -i /tmp/S000__full_data.sql"
```

---

## Estado final de la base local

| Métrica | Valor |
|---|---|
| Tablas | 31 |
| Stored Procedures | 16 |
| Foreign Keys | 41 |
| Schemas | 7 |
| Unique Indexes | 43 |

### Datos migrados

| Tabla | Filas |
|---|---|
| `auth.Users` | 8 |
| `auth.UserProfile` | 8 |
| `auth.UserRole` | 8 |
| `auth.Role` | 2 |
| `core.Character` | 5 |
| `core.Player` | 8 |
| `core.Guild` | 1 |
| `core.GuildMember` | 5 |
| `core.Class` | 5 |
| `core.Faction` | 2 |
| `core.GuildRank` | 7 |
| `catalog.Item` | 10 |
| `catalog.ItemStat` | 92 |
| `catalog.ItemType` | 13 |
| `catalog.EquipmentSlot` | 15 |
| `catalog.StatType` | 15 |
| `catalog.ItemTypeSlot` | 15 |
| `catalog.LapisApplicableItemType` | 24 |
| `catalog.ItemAllowedClass` | 10 |
| `catalog.BindType` | 3 |
| `catalog.LapisType` | 4 |
| `catalog.Lapis` | 5 |
| `catalog.LapisEffect` | 9 |
| `equipment.CharacterEquipment` | 10 |
| `equipment.EquippedItemSocket` | 42 |
| `equipment.EquippedItemLapis` | 14 |
| `build.CharacterBaseStat` | 6 |
| `build.CharacterFinalStat` | 12 |
| `build.CharacterAssignedStat` | 0 |
| `audit.UserLoginEvent` | 19 |
| `notification.DeviceToken` | 4 |

---

## Problemas encontrados y soluciones

### Problema 1 — CREATE SCHEMA requiere batch propio

**Qué pasó:**  
Los 7 `CREATE SCHEMA` estaban en el mismo batch (un solo `GO` al final). SQL Server requiere que cada `CREATE SCHEMA` sea la primera instrucción de su propio batch.

**Error:**
```
Msg 156 Incorrect syntax near the keyword 'CREATE'
```

**Solución:**  
Agregar `GO` después de cada `CREATE SCHEMA` individualmente:
```sql
CREATE SCHEMA [auth];
GO
CREATE SCHEMA [core];
GO
```

---

### Problema 2 — Texto `(1 row affected)` contaminando el SQL

**Qué pasó:**  
`sqlcmd` incluye el mensaje `(1 row affected)` como output. Al capturar ese output para escribir el archivo SQL, el texto quedó incrustado entre sentencias SQL válidas, causando errores de sintaxis.

**Error:**
```
Msg 156 Incorrect syntax near the keyword 'CREATE'
Column name '(1 row affected)' does not exist
```

**Solución:**  
Filtrar con regex en PowerShell tanto singular como plural:
```powershell
Where-Object { $_ -notmatch '\(\d+ rows? affected\)' }
```
El error original solo filtraba `'rows affected'` (plural) y no capturaba `'row affected'` (singular, cuando hay 1 sola fila).

---

### Problema 3 — FKs compuestas generaban ALTER TABLE duplicados

**Qué pasó:**  
La query de FK devolvía una fila por columna. FKs con 2 o 3 columnas generaban 2 o 3 `ALTER TABLE` con el mismo nombre de constraint, fallando en el segundo intento.

**Error:**
```
Msg 2714 There is already an object named 'FK_Character_ClassFaction'
```

**Solución:**  
Usar `STRING_AGG` en la query para agrupar todas las columnas de un FK en una sola fila:
```sql
STRING_AGG(pc.name, ',') WITHIN GROUP (ORDER BY fkc.constraint_column_id) AS parent_cols
```
Resultado: un solo `ALTER TABLE` con todas las columnas agrupadas:
```sql
ALTER TABLE [core].[Character] ADD CONSTRAINT [FK_Character_ClassFaction]
  FOREIGN KEY ([ClassId], [FactionId]) REFERENCES [core].[Class] ([ClassId], [FactionId]);
```

---

### Problema 4 — FKs que referencian UNIQUE indexes, no PKs

**Qué pasó:**  
Varias FKs compuestas no referencian la PK de la tabla destino sino un índice UNIQUE. Al no exportar los unique indexes, SQL Server no podía validar la referencia.

**Error:**
```
Msg 1776 There are no primary or candidate keys in the referenced table
'catalog.EquipmentSlot' that match the referencing column list
```

**Solución:**  
Agregar una sección `UNIQUE INDEXES Y CONSTRAINTS` entre las tablas y las FKs. Se exportaron 43 unique indexes/constraints usando `sys.indexes` con `is_unique=1 AND is_primary_key=0`.

---

### Problema 5 — Columnas varbinary sin tamaño en el baseline

**Qué pasó:**  
En la generación del `CREATE TABLE`, el tipo `varbinary` no tenía su tamaño incluido (`varbinary(256)`, `varbinary(128)`). SQL Server interpretó `varbinary` sin tamaño como `varbinary(1)` — solo 1 byte.

**Error:**
```
Msg 2628 String or binary data would be truncated in table 'auth.Users', column 'PasswordHash'
```

**Solución:**  
El campo `CHARACTER_MAXIMUM_LENGTH` de `INFORMATION_SCHEMA.COLUMNS` sí devuelve el tamaño para `varbinary`. Se agregó `varbinary` a la lista de tipos que usan ese valor:
```sql
[PasswordHash] varbinary(256) NOT NULL,
[Salt] varbinary(128) NOT NULL,
```

---

### Problema 6 — Exportación de columnas varbinary como string Unicode

**Qué pasó:**  
Las columnas `PasswordHash` y `Salt` son `varbinary`. Al exportarlas con `CAST(column AS NVARCHAR(MAX))`, el resultado eran caracteres Unicode ilegibles que SQL Server no podía reimportar.

**Error:**
```
Msg 257 Implicit conversion from data type varchar to varbinary is not allowed
```

**Solución:**  
Exportar como hex string con `CONVERT(NVARCHAR(MAX), column, 1)` que devuelve formato `0x8416535D...`, y envolver en el INSERT con `CONVERT(varbinary(MAX), '0x...', 1)`:
```sql
INSERT INTO [auth].[Users] (..., [PasswordHash], ...)
VALUES (..., CONVERT(varbinary(MAX),'0x8416535DE6ADDB...',1), ...)
```
Se verificó que el hash en local coincide byte a byte con Azure:
```
Azure: 0x8416535DE6ADDBBEE565CD754F6945439D0DB3897422875E206E146FB4D869D7
Local: 0x8416535DE6ADDBBEE565CD754F6945439D0DB3897422875E206E146FB4D869D7
```

---

## Validación final

```sql
-- Conteo de objetos en local
SELECT 'Tablas'  AS tipo, COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'
UNION ALL
SELECT 'SPs',   COUNT(*) FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE='PROCEDURE'
UNION ALL
SELECT 'FKs',   COUNT(*) FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
UNION ALL
SELECT 'Schemas', COUNT(*) FROM sys.schemas WHERE name NOT IN (...)

-- Resultado: 31 tablas / 16 SPs / 41 FKs / 7 schemas ✓
```

El SP de login funciona correctamente — devuelve `IsAuthenticated = 0` para contraseñas incorrectas y procesaría `1` para la contraseña real del usuario (los hashes son idénticos a Azure).

---

## Siguiente fase

**Fase 3 — Conectar el webservice Docker al SQL Server local**

1. Buildear la imagen de la app localmente
2. Ejecutar `docker run` con `DB_URL` apuntando a `sql-dev:1433`
3. Conectar al mismo `reloader-network`
4. Validar login desde la app web en `localhost:8080`
