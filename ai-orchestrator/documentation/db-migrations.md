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
        ├── V015__sp_register_supplier.sql
        ├── ...
        ├── V025__register_player_with_character.sql
        ├── ...
        ├── V029__seed_demo_characters.sql
        ├── V030__equip_by_slot_recommended_set.sql
        ├── V031__seed_test_players.sql
        ├── V032__demo_password.sql
        ├── V033__lapis_icons_triple_mystic.sql
        ├── V034__item_recreation_over_max.sql
        └── V035__player_multiple_characters.sql
```

**Las dos carpetas deben quedar idénticas:** `ReloaderDB/migrations/` (fuente de verdad) y `reloaderproject-rest/db/migrations/`.

**Nota:** Las migrations V013+ fueron creadas para los microservicios (reloaderproject-ms) pero viven acá porque comparten la misma DB `reloader-games-db`.

## Convención de nombres

```
V{numero}__{descripcion_snake_case}.sql
```

- Número correlativo: `V001`, `V002`, ..., `V012`, `V013`, ...
- Doble guion bajo (`__`) entre versión y descripción — requisito de Flyway
- Descripción en snake_case, en inglés
- **Una migración abierta a la vez** (ver "Migración abierta / cerrada")

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
| V016 | Schema `market` — Category, Listing, ListingCategory, ListingImage, Contact, Review, SellerStats + `notification.MarketNotification` |
| V017 | Seed de categorías del marketplace |
| V018 | SPs de listings: `sp_CreateListing`, `sp_GetListings`, `sp_GetListingDetail`, `sp_CloseListing`, `sp_RenewListing`, `sp_CancelListing`, `sp_ExpireListings`, `sp_GetListingsExpiringSoon` |
| V019 | SPs de contacto, reviews y notificaciones del marketplace |
| V020 | Schema `menu` + `menu.sp_GetMenuByUser` |
| V021 | Fix del seed de menú |
| V022 | Seed de listings de ejemplo (UserId = 1) |
| V023 | SPs `market.sp_AddListingImage` (máx 5 fotos, sin transacción propia), `market.sp_GetMyListings`, `market.sp_GetCategories` |
| V024 | Desactiva el menú `PVP_ONLINE` (`IsActive = 0`); `MY_LISTINGS` queda activo. Reemplaza el borrador `V023__disable_menu_pvp_listings.sql` de reloaderproject-rest |
| V025 | Registro de jugador con personaje: 7 clases nuevas en `core.Class` (6 por facción, 12 total), índice único `UX_core_Character_CharacterName`, columna `auth.Users.EmailCreated` (externos → 1), SPs `auth.sp_RegisterPlayerWithCharacter`, `core.sp_GetFactionsWithClasses`, `auth.sp_GetUserEmailStatus`, `auth.sp_ListPendingEmails` + backfill de UserProfile / rol PLAYER / core.Player a usuarios activos que no los tenían. En producción desde 2026-09-26 |
| V026 | Catálogo de lapis completo (DAMAGE_ABSORPTION, tipo WEAPON, 23 lapis nuevos, correcciones) + limpieza SUPPLIER. En producción desde 2026-09-26 |
| V027 | Sets de las 12 clases + `catalog.ClassBaseStat` / `ClassStatPreference` / `ClassAutoLinkConfig`. En producción desde 2026-09-26 |
| V028 | `equipment.sp_AutoLinkCharacter`, registro nace equipado, result set 5 en `sp_GetCharacterScreenByUser`. En producción desde 2026-09-26 |
| V029 | Personajes demo (uno por clase) equipados. En producción desde 2026-09-26 |
| V030 | El personaje nace SIN set; `equipment.sp_GetRecommendedSet` y `equipment.sp_EquipSlots` (equipar por slot con el set de la clase como referencia); funciones `fn_ClassSetPieces` / `fn_RecommendedLapisForItem`. En producción desde 2026-09-26 |
| V031 | Usuarios de prueba de la sesión 2026-09-26 (van también a producción): `OtamendiWar` (otamendi, Guerrero Furia, solo casco) y `RyoskePlayer` / `ryoske` (Oráculo Furia, set recomendado completo) |
| V032 | Contraseña única de los `demo_*`: `DemoReloader2026!` (reemplaza `Demo1234` de V029; salt nuevo por usuario, FailedAttempts 0). No toca RyoskePlayer ni el seed S000 |
| V033 | **CERRADA. En producción desde 2026-09-27.** Ultimate Triple Mystic (INT 35 / WIS 30 / HP 1500); columna `catalog.Lapis.IconUrl` (Triples, Mechanic, Pure, Sonic, Max Flash, Chaotic, Life, Absorption con imagen propia; Single/Dual `gem_*.png` por la familia del NOMBRE: Dual Mystic = INT, Dual Wise = WIS); `sp_GetCharacterScreenByUser` devuelve `LapisIconUrl` / `IconUrl`; `catalog.Item.ImageUrl` genérica por tipo (`helmet` / `weapon` / `suit` / `cape` `_img_dark.png`); Oráculo `ClassStatPreference` REC:1 WIS:2 |
| V034 | **CERRADA. En producción desde 2026-09-30.** Recreación "Over max." de armaduras (ver detalle abajo): `catalog.RecreationBuild` / `RecreationBuildValue` / `RecreationApplicableItemType` / `ClassRecreationPreference` / `ClassRecreationConfig`, `equipment.EquippedItemRecreation` / `EquippedItemRecreationStat`, SPs `equipment.sp_GetRecreationSuggestion` y `equipment.sp_SaveRecreationConfig`, result sets 6..8 en `sp_GetCharacterScreenByUser` |
| V035 | **CERRADA (2026-09-30).** Pendiente de producción. Varios personajes por usuario desde la app (ver detalle abajo): SPs `core.sp_ListPlayerCharacters`, `core.sp_CreatePlayerCharacter` y `core.sp_SetPrimaryCharacter`. Sin tablas nuevas |

### V035 — varios personajes por usuario (sql-dev, 2026-09-30)

Reglas (definidas por el usuario, 2026-09-30):
- Máximo **5** personajes activos por usuario
- Si ya tiene un personaje **totalmente vacío** (0 filas en `equipment.CharacterEquipment`) no puede crear otro
- Misma facción de la cuenta (la de sus personajes activos); sin personajes elige cualquiera. La facción sale de la clase (`core.Class.FactionId`)
- Nombre con las reglas del registro (`^[A-Za-z0-9_]{3,20}$`, único en el servidor por `UX_core_Character_CharacterName`)
- Nace nivel 80, sin equipo y como principal (`IsPrimary = 1`, los demás a 0). No genera email: el de la cuenta es el del primer personaje
- `sp_GetCharacterScreenByUser` ya mostraba el `IsPrimary = 1`: cambiar de personaje = `sp_SetPrimaryCharacter`
- ErrorCodes de `sp_CreatePlayerCharacter`: `PLAYER_NOT_FOUND`, `INVALID_CHARACTER_NAME`, `INVALID_CLASS`, `FACTION_MISMATCH`, `MAX_CHARACTERS`, `EMPTY_CHARACTER_EXISTS`, `CHARACTER_NAME_TAKEN`. `sp_SetPrimaryCharacter`: `CHARACTER_NOT_FOUND`. Con error no escriben nada
- `sp_ListPlayerCharacters`: result 1 = cuenta (`AccountFaction*`, `CharacterCount`, `MaxCharacters`, `CanCreate`, `BlockReason`), result 2 = personajes con `EquippedCount`

### V034 — recreación "Over max." (sql-dev, 2026-09-29)

Regla del juego (definida por el usuario, 2026-09-29):

| Modalidad | Fijo (no se cambia) | Valores que el jugador reparte |
|---|---|---|
| `OVER_MAX_1` — Over max. 1 | HP +4400 | 98 / 69 / 44 |
| `OVER_MAX_2` — Over max. 2 | HP +6400, MP +2000, SP +2000 | 88 / 44 / 44 |

- Solo casco, top, medias (PANTS), guantes y botas (`RecreationApplicableItemType`); cada pieza lleva su propia modalidad
- Los 3 valores van a 3 stats **distintos** entre STR DEX REC INT WIS LUC (`StatType.IsPrimary = 1`); nunca HP / MP / SP
- **No se mezclan modalidades**: solo se guarda la modalidad y el stat de cada posición (`ValueSlot` 1..3, 1 = valor más alto); HP/MP/SP y los valores salen siempre de la modalidad
- Sugerida por clase: `ClassRecreationPreference` (valor más alto → Priority 1) + modalidad en `ClassRecreationConfig` (hoy `OVER_MAX_1` para todas). Tabla aparte de `ClassStatPreference` para no cambiar el auto-linkeo de lapis. Terceros stats: Guardián/Defensor REC, Asesino/Ranger LUC, Oráculo/Cura DEX; Oráculo sigue V033 (REC 1, WIS 2)
- `sp_SaveRecreationConfig` ErrorCodes: `CHARACTER_NOT_FOUND`, `EMPTY_CONFIG`, `DUPLICATE_PIECE`, `EQUIPMENT_NOT_OWNED`, `ITEM_NOT_RECREATABLE`, `INVALID_BUILD`, `INVALID_STAT`, `DUPLICATE_STAT`. Con error no escribe nada. `BuildCode` vacío = quitar la recreación
- `sp_GetCharacterScreenByUser`: result sets 1..5 sin cambios; 6 = modalidades, 7 = tipos recreables, 8 = recreación por pieza
- `catalog.Item.RecStat*` quedan en NULL en todos los items (eran una recreación fija por item de V005 / V027 que la app mostraba como del jugador). Desde V034 **nadie tiene recreación** hasta que la guarde desde la app. Las columnas se conservan; la app ya no las lee

### V025 — detalle

- **Clases** (`<ARQUETIPO>_<FACCION>`): Luz → WARRIOR_LUZ Luchador, ASSASSIN_LUZ Ranger, HUNTER_LUZ Arquero, PAGAN_LUZ Mago, ORACLE_LUZ Cura, DEFENDER_LUZ Defensor. Furia → las 5 existentes + GUARDIAN_FURIA Guardian. FactionId resuelto por FactionCode; ClassId con saltos de IDENTITY (en sql-dev quedaron 1001..1007): no hardcodear
- **CharacterName** único en todo el servidor, case-insensitive por la collation `SQL_Latin1_General_CP1_CI_AS`. Formato `^[A-Za-z0-9_]{3,20}$` validado en el SP con `COLLATE Latin1_General_BIN2` (para que `[A-Z]` no acepte tildes ni Ñ) y `DATALENGTH` (cuenta espacios finales)
- **Email generado** = `LOWER(CharacterName) + '@reloader.dev'`; `EmailCreated = 0` hasta que el admin crea la casilla en Zoho
- **sp_RegisterPlayerWithCharacter** → `Success, ErrorCode, UserId, CharacterId, Email`. Orden: INVALID_CHARACTER_NAME, USERNAME_TAKEN, CHARACTER_NAME_TAKEN, EMAIL_TAKEN, INVALID_CLASS. Transacción con `XACT_ABORT ON`; violaciones de índice único por carrera (2601/2627) se traducen al ErrorCode correspondiente
- No se modificaron `sp_RegisterPublicUser`, `sp_CreateCharacter` ni `sp_LoginUser`

### V026..V029 — catálogo completo, auto-linkeo y demos (sql-dev y producción, 2026-09-26)

| Versión | Descripción |
|---|---|
| V026 | Lapis completos: StatType `DAMAGE_ABSORPTION`, columna `catalog.Lapis.StatDamageAbsorption`, LapisType `WEAPON` (Chaotic, Max Flash), Ultimate Triple Craft → `TRIPLE` (`ULTIMATE` queda sin uso), Dual Craft/Fortune Lv7 → nivel 75, 23 lapis nuevos (Mystic/Wise/Safe Lv7-9, Life Lv7-10, Absorption Lv7-10, Dual Safe/Mystic/Wise/Shrewd Lv7, Ultimate Triple Wise/Safe) con `LapisEffect` y `LapisApplicableItemType`. Limpieza V025: SUPPLIER sin personajes pierden rol PLAYER y `core.Player` |
| V027 | Sets de las 11 clases sin set (casco real + Mail/Gaiters/Bracers/Boots con las stats del casco, arma y escudo provisorios copiados del Cazador), `ItemStat` BASE, `ItemAllowedClass` (Bonespike, mascota, capa, alas y traje a las 12 clases). Tablas `catalog.ClassBaseStat` (provisorio 150/90/30), `catalog.ClassStatPreference` (Priority 1..3), `catalog.ClassAutoLinkConfig` (AbsorptionSockets) |
| V028 | `equipment.sp_AutoLinkCharacter`; `auth.sp_RegisterPlayerWithCharacter` llama al auto-linkeo en la misma transacción (misma firma y resultado); `equipment.sp_GetCharacterScreenByUser` agrega el result set 5 (stats base de la clase) |
| V029 | Auto-linkeo de DibuWar, RomeroSin, DePaulPagan, MacOracle + 7 usuarios demo (uno por clase faltante, password de desarrollo en `dbreadme/DEMOS.md`). NazgulKash no se toca |

- **Regla de linkeo de lapis**: solo tipo de pieza (`LapisApplicableItemType`) + `Lapis.RequiredLevel <= Item.RequiredLevel` + socket libre + no repetir el mismo lapis en la pieza. **Nunca por clase**
- **Encanto [20]** = `EnchantLevel 20` + `DamageAbsorption 240` en casco, top, pantalón, guantes, botas y escudo; el arma lleva 20 sin absorción (igual que NazgulKash)
- **Stat total** = `catalog.ClassBaseStat` (se consulta por ClassId, no se copia) + `build.CharacterAssignedStat` + items + lapis. Absorción aparte
- **sp_AutoLinkCharacter** `@CharacterId, @Silent = 0, @Applied OUTPUT` → `CharacterId, Applied, Status (LINKED | ALREADY_EQUIPPED), ItemsEquipped, SocketsCreated, LapisLinked` (sin result set con `@Silent = 1`). Si el personaje ya tiene equipo no hace nada. Slots del mismo tipo (anillos, brazaletes) se reparten por orden de ItemId. Por pieza: 0) lapis tipo WEAPON en el arma, 1) `AbsorptionSockets` lapis de absorción de mayor nivel (solo casters), 2) resto por puntaje = stats preferidos ×3/×2/×1 + HP/100. No usa lapis con stats que no suman a la clase; sí utilitarios sin stats (Max Flash, Sonic). Abre transacción propia solo si no hay una activa

### V030 — equipar por slot y set recomendado (sql-dev y producción, 2026-09-26)

- **El personaje nace SIN set**: `auth.sp_RegisterPlayerWithCharacter` ya no llama al auto-linkeo (misma firma y mismo result set)
- **Lógica común extraída** (inline TVF, solo lectura):
  - `equipment.fn_ClassSetPieces(@ClassId, @Level)` → `EquipmentSlotId, SlotCode, SlotName, SortOrder, ItemTypeId, ItemId, ItemName, MaxSockets, EnchantLevel, DamageAbsorption` (pieza del set por slot, encanto 20 / absorción 240 como V028)
  - `equipment.fn_RecommendedLapisForItem(@ClassId, @ItemId)` → `SocketNumber, LapisId` (misma regla de lapis de V028)
  - `equipment.sp_AutoLinkCharacter` se reescribió sobre ambas: misma firma y **mismo resultado** (comparado clase por clase, las 12, contra la versión V028: idéntico)
- **`equipment.sp_GetRecommendedSet @CharacterId`** (no escribe) → 2 result sets:
  1. `SlotCode, SlotName, SortOrder, ItemId, ItemName, MaxSockets, Equipped, EquippedItemName` — los 16 slots activos por SortOrder. ItemId/ItemName/MaxSockets = pieza del set de la clase (NULL si la clase no tiene pieza). `Equipped` = el personaje ya tiene algo en el slot; `EquippedItemName` NULL si vacío
  2. `SlotCode, SocketNumber, LapisId, LapisName, LapisTypeCode` — slot vacío: sugeridos para la pieza del set; slot equipado: sugeridos para la pieza que tiene equipada (para "Linkear sugerido"). Slots con MaxSockets 0 no tienen filas
  - Personaje inexistente o inactivo → ambos result sets vacíos
- **`equipment.sp_EquipSlots @CharacterId, @SlotCodes ('BOOTS,GLOVES'), @WithRecommendedLapis = 0`** → 1 fila `Success, ErrorCode, EquippedCount, SkippedCount, LapisLinked`
  - Solo los slots pedidos que estén vacíos: pieza del set + sockets 1..MaxSockets abiertos (vacíos, o con los sugeridos si `@WithRecommendedLapis = 1`). Slots ya equipados (o sin pieza para la clase) cuentan en `SkippedCount`
  - Códigos sin distinguir mayúsculas, se ignoran espacios y repetidos
  - `ErrorCode`: `CHARACTER_NOT_FOUND` | `INVALID_SLOT` (algún código inexistente/inactivo o lista vacía). Con error no escribe nada
  - Transacción propia solo si no hay una activa (se puede probar dentro de `BEGIN TRAN .. ROLLBACK`)
- **`sp_GetCharacterScreenByUser` sin cambios**: el result set 2 ya parte de `catalog.EquipmentSlot` con LEFT JOIN, así que un slot vacío llega como 1 fila con `CharacterEquipmentId`/`ItemId`/socket/lapis en NULL (16 filas para un personaje sin equipo)
- El recomendado es solo una **referencia**: no restringe lo que se guarde después con `sp_SaveCharacterLapisConfig`
- Dato de prueba `OtamendiWar` (usuario `otamendi`, WARRIOR_FURIA): creado a mano en sql-dev; desde V031 queda en migración
- **sp_GetCharacterScreenByUser result set 5**: `StatCode NVARCHAR(30), StatValue INT` ordenado por StatTypeId (STR, DEX, REC, INT, WIS, LUC). Result sets 1..4 sin cambios

### V031 — usuarios de prueba (sql-dev y producción, 2026-09-26)

Los usuarios que se probaron en desarrollo se suben como datos de prueba para que existan igual en producción (decisión del usuario, 2026-09-26).

- **OtamendiWar**: usuario `otamendi` del seed S000; `core.Character` WARRIOR_FURIA nivel 80 (principal si otamendi no tiene otro principal) + `sp_EquipSlots 'HELMET'` sin lapis (casco del set, encanto 20, sockets vacíos, como quedó probando "Añadir"). Si otamendi no existe, no hace nada
- **RyoskePlayer / ryoske**: alta igual que `sp_RegisterPlayerWithCharacter` (Users `PUBLIC`, UserProfile, rol PLAYER, core.Player, personaje ORACLE_FURIA nivel 80 principal, email `ryoske@reloader.dev`, EmailCreated 0). `PasswordHash` y `Salt` copiados del alta en sql-dev: la contraseña es la misma que usó el usuario al registrarse. `sp_EquipSlots` de los 16 slots con `@WithRecommendedLapis = 1` → 16 piezas, 60 lapis (verificado: sin lapis fuera de pieza/nivel ni repetidos; absorción 1440 de encanto + 2250 de lapis)
- Idempotente: no crea si ya existe el usuario, el email o el personaje; `sp_EquipSlots` solo equipa slots vacíos. En sql-dev se probó con nombres temporales dentro de `BEGIN TRAN .. ROLLBACK` y el resultado es idéntico al de los usuarios originales

## Reglas para escribir migrations

1. **Idempotencia donde sea posible**: usar `CREATE OR ALTER PROCEDURE`, `IF NOT EXISTS`
2. **Sin hardcodear IDENTITY values**: usar JOINs dinámicos para referenciar filas (ver V008)
3. **GO como separador**: necesario para DDL en SQL Server cuando hay múltiples statements
4. **Secciones dentro del archivo**: DDL, datos y SPs van en la misma migración, en secciones numeradas separadas por `GO`
5. **Nunca modificar un archivo ya aplicado en producción**: crear uno nuevo (`flyway repair` solo si fue un error antes de aplicar en prod)

## Migración abierta / cerrada (decisión del usuario 2026-09-27)

Funciona como una rama con commits: **una sola migración ABIERTA a la vez**, no una por cambio.

**Migración abierta actual: ninguna** — la próxima es `V036`. V035 cerrada 2026-09-30 (pendiente de producción). Producción en `v034` (2026-09-30). (Actualizar esta línea al cerrar/abrir.)

### Flujo por cada cambio en la base
1. El cambio va en la migración ABIERTA (se edita ese archivo; nunca crear `V0NN+1` por cuenta propia). Si no hay ninguna abierta, se abre la siguiente.
2. Reaplicarla en local:
   ```sql
   DELETE FROM dbo.flyway_schema_history WHERE version = 'NNN';
   ```
   y luego `flyway migrate`. Por eso debe ser re-ejecutable: los UPDATE recalculan el valor completo (no solo `WHERE ... IS NULL`), los INSERT con `IF NOT EXISTS`.
3. **Siempre preguntar al usuario al terminar el cambio:** *"V0NN está abierta, ¿la cierras?"*
   - **No** → se sigue trabajando en la misma.
   - **Sí** → encabezado a `-- ESTADO: CERRADA`, actualizar la línea "Migración abierta actual" y el historial. El archivo cerrado **no se vuelve a tocar**, aunque no esté en producción. El próximo cambio abre `V0NN+1`.

El usuario cierra cuando se hizo algo fuerte que quedó bien, para protegerlo de errores posteriores (como un commit). Si la abierta rompe algo en local, se corrige dentro de ella; las cerradas no se tocan (el archivo queda intacto, pero los datos locales no se revierten solos).

Dentro de la migración, DDL, datos y SPs van en secciones numeradas separadas por `GO`.

### Pase a producción
Solo cuando el usuario dice **"esto va a producción"**. Flyway aplica en orden todas las pendientes (ej. `V033`, `V034`, `V035`) en Azure SQL — **no se juntan en una sola**. La que estaba abierta se cierra antes del pase.

Cada migración lleva en su encabezado `-- ESTADO: ABIERTA` o `-- ESTADO: CERRADA`.

## Schemas en uso

| Schema | Contenido |
|---|---|
| `auth` | Usuarios, login, roles, email reservado (`EmailCreated`) |
| `core` | Facciones, clases (6 por facción), Player, Character (nombre único global) |
| `catalog` | Items, lapis, tipos, maestros por clase (`ClassBaseStat`, `ClassStatPreference`, `ClassAutoLinkConfig`) |
| `equipment` | CharacterEquipment, sockets, lapis equipados |
| `market` | Marketplace de contacto: listings, fotos (1..5), categorías, contactos, reviews |
| `menu` | Menú dinámico por usuario/rol |
| `notification` | Tokens FCM, notificaciones del marketplace |

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
