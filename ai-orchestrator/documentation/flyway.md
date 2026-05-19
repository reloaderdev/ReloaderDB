# Flyway — Versionamiento de Base de Datos

## Instalación

**Mac:** instalado via Homebrew — `brew install flyway`
**Versión activa:** 12.4.0

Verificar instalación:
```
flyway -v
```

## Configuración del proyecto

Flyway se usa **solo para migraciones de base de datos**. No está integrado al deploy del servicio REST.

### Azure SQL (Producción)

```bash
flyway -url="jdbc:sqlserver://reloader-db-server.database.windows.net:1433;databaseName=reloader-games-db;encrypt=true;trustServerCertificate=false;loginTimeout=30" \
       -user=<usuario-prod> \
       -password=<password-prod> \
       -locations=filesystem:/Users/resembrink/Documents/GitHub/reloaderproject-rest/db/migrations \
       info
```

> Nota: el nombre de la base tiene guiones — poner el valor de `-url=` entre comillas para evitar que el shell lo parta.

### SQL Server local (Docker)

```bash
flyway -url="jdbc:sqlserver://localhost:1433;databaseName=reloader-games-db;encrypt=false;trustServerCertificate=true" \
       -user=devlocal \
       -password=Dev@Local2026 \
       -locations=filesystem:/Users/resembrink/Documents/GitHub/reloaderproject-rest/db/migrations \
       info
```

## Comandos principales

| Comando | Descripción |
|---|---|
| `flyway info` | Ver estado de todas las migraciones |
| `flyway migrate` | Aplicar migraciones pendientes |
| `flyway baseline` | Marcar estado actual como V000 (solo primera vez) |
| `flyway repair` | Reparar checksums tras reescribir un script fallido |
| `flyway validate` | Verificar que los scripts no cambiaron |

## Flujo: primera vez en un entorno nuevo

```bash
# 1. Marcar la base existente como baseline (ya tiene tablas)
flyway baseline -baselineVersion=0 -baselineDescription="Estado inicial"

# 2. Aplicar migraciones desde V001 en adelante
flyway migrate
```

## Flujo: agregar una migración nueva

1. Crear el archivo en `db/migrations/` siguiendo la convención (ver `db-migrations.md`)
2. Commitear y pushear → el archivo queda versionado en git
3. Ejecutar `flyway migrate` en el entorno destino

## Historial de aplicación en producción

| Evento | Fecha | Versiones aplicadas |
|---|---|---|
| Primera aplicación prod | 2026-04-18 | V001 → V012 |

## Errores comunes y soluciones

| Error | Causa | Solución |
|---|---|---|
| FK constraint en V008 | Script usaba IDs de IDENTITY locales | Reescribir con JOIN dinámico + `flyway repair` + `flyway migrate` |
| "does not recognize" al ejecutar flyway | PATH apunta a carpeta raíz, no al binario | Verificar que PATH = `C:\flyway\flyway-10.10.0` (con el número de versión) |
| URL parsing falla con guiones en DB name | Shell parte el argumento | Poner `-url=...` entre comillas dobles |
| Firewall Azure bloquea conexión | IP del cliente no está en allowlist | Agregar IP en Azure Portal → SQL Server → Networking |
