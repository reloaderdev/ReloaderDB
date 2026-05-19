# Fase 3 — Webservice Docker conectado a SQL Server local

**Fecha:** 2026-04-18  
**Estado:** Completado  
**Ejecutado por:** resembrinkcorrea + Claude (DBA / Orquestador)

---

## Objetivo de la Fase 3

Conectar el webservice Docker (`reloaderproject-app`) al SQL Server local (`sql-dev`) usando la red interna Docker, y validar que el flujo completo funciona sin depender de Azure.

---

## Arquitectura final del ambiente local

```
Browser / App Mobile
        ↓
http://localhost:8080
        ↓
reloader-container (Payara 6)
reloaderproject-app:latest
red: reloader-network
        ↓  JDBC → sql-dev:1433
sql-dev (SQL Server 2022)
reloader-games-db
red: reloader-network
```

Los dos contenedores se comunican por nombre (`sql-dev`) dentro de la red interna `reloader-network`. No hay tráfico hacia Azure durante el desarrollo.

---

## Comando de inicio del webservice local

```bash
docker run -d \
  --name reloader-container \
  --network reloader-network \
  -p 8080:8080 \
  -e DB_URL="jdbc:sqlserver://sql-dev:1433;database=reloader-games-db;encrypt=false;trustServerCertificate=true;loginTimeout=30;" \
  -e DB_USER="sa" \
  -e DB_PASSWORD="iOSDeveloper10%" \
  reloaderproject-app:latest
```

### Diferencias vs producción (Azure)

| Variable | Local | Azure App Service |
|---|---|---|
| `DB_URL` | `jdbc:sqlserver://sql-dev:1433;...encrypt=false` | `jdbc:sqlserver://reloader-sql-server.database.windows.net:1433;...encrypt=true` |
| `DB_USER` | `sa` | `sqladmin` |
| `DB_PASSWORD` | `iOSDeveloper10%` | `iOSDeveloper10%` |

El código Java no cambia. Solo las variables de entorno.

---

## Validación realizada

### 1. App desplegada correctamente

```
ROOT was successfully deployed in 3,024 milliseconds.
[AutoDeploy] Successfully autodeployed : ROOT.war
```

### 2. Login page accesible

```bash
curl http://localhost:8080/login.jsp
# HTTP 200 ✓
```

### 3. Flujo de login ejecutado contra base local

```bash
curl -X POST http://localhost:8080/login \
  -d "username=messi&password=Admin123"
# HTTP 302 → login.jsp?error=true
```

La redirección con `error=true` confirma que:
- La app se conectó a `sql-dev` correctamente
- El SP `auth.sp_LoginUser` se ejecutó en la base local
- El contador `FailedAttempts` de messi se incrementó en la base local

### 4. Escritura confirmada en base local

```sql
SELECT Username, FailedAttempts FROM auth.Users WHERE Username='messi'
-- messi | FailedAttempts = 4  ← la app escribió en local, no en Azure
```

---

## Problemas encontrados y soluciones

### Problema 1 — Ruta 404 al probar el endpoint de login

**Qué pasó:**  
Se probó `POST /reloaderproject/api/login` asumiendo que era un endpoint REST. La app devolvió 404.

**Causa:**  
El login no es un endpoint REST (`@Path`). Es un Servlet Java EE mapeado en `@WebServlet("/login")`. Recibe `application/x-www-form-urlencoded`, no JSON.

**Solución:**  
Usar la ruta correcta `POST /login` con form params:
```bash
curl -X POST http://localhost:8080/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=messi&password=Admin123"
```

---

### Problema 2 — encrypt=true falla en SQL Server local

**Qué pasó:**  
La cadena de conexión de Azure usa `encrypt=true` con certificado válido. SQL Server en Docker local no tiene certificado SSL configurado. La app se rechazaba la conexión.

**Solución:**  
Cambiar el `DB_URL` local a:
```
encrypt=false;trustServerCertificate=true
```
Azure mantiene `encrypt=true` en sus propias variables — no se toca.

---

## Flujo de trabajo diario resultante

```
1. sql-dev corriendo (Docker)
2. reloader-container corriendo (Docker)
3. Desarrollás en local → probás en localhost:8080
4. Cambio de schema → creás V001__descripcion.sql
5. Probás en local:
   docker exec sql-dev bash -c "sqlcmd ... -i /tmp/V001.sql"
6. Validado → corrés en Azure:
   sqlcmd -S reloader-sql-server... -i db/migrations/V001__descripcion.sql
7. commit + push → Azure despliega automáticamente
```

---

## Comandos de operación diaria

### Levantar el ambiente local completo

```bash
# Iniciar SQL Server (si está detenido)
docker start sql-dev

# Iniciar la app (si está detenida)
docker start reloader-container
```

### Detener el ambiente local

```bash
docker stop reloader-container
docker stop sql-dev
```

### Resetear la base local desde cero

```bash
docker exec sql-dev bash -c "sqlcmd -S localhost -U sa -P 'iOSDeveloper10%' -No -Q 'DROP DATABASE [reloader-games-db]'"
docker exec sql-dev bash -c "sqlcmd -S localhost -U sa -P 'iOSDeveloper10%' -No -Q 'CREATE DATABASE [reloader-games-db]'"
docker cp db/migrations/V000__baseline.sql sql-dev:/tmp/V000__baseline.sql
docker cp db/seeds/S000__full_data.sql     sql-dev:/tmp/S000__full_data.sql
docker exec sql-dev bash -c "sqlcmd -S localhost -d 'reloader-games-db' -U sa -P 'iOSDeveloper10%' -No -i /tmp/V000__baseline.sql"
docker exec sql-dev bash -c "sqlcmd -S localhost -d 'reloader-games-db' -U sa -P 'iOSDeveloper10%' -No -i /tmp/S000__full_data.sql"
```

### Aplicar un migration nuevo en local

```bash
docker cp db/migrations/V001__descripcion.sql sql-dev:/tmp/V001__descripcion.sql
docker exec sql-dev bash -c "sqlcmd -S localhost -d 'reloader-games-db' -U sa -P 'iOSDeveloper10%' -No -i /tmp/V001__descripcion.sql"
```

### Aplicar un migration en Azure (producción)

```bash
sqlcmd -S reloader-sql-server.database.windows.net -d reloader-games-db -U sqladmin -P "****" -N -C -i db/migrations/V001__descripcion.sql
```

---

## Resumen del ambiente local completo

| Componente | Contenedor | Red | Puerto |
|---|---|---|---|
| SQL Server 2022 | `sql-dev` | `reloader-network` | `1433` |
| Webservice Payara | `reloader-container` | `reloader-network` | `8080` |

**URL local:** `http://localhost:8080/login.jsp`  
**Base local:** `reloader-games-db` en `sql-dev:1433`  
**Sin dependencia de Azure para desarrollo** ✓
