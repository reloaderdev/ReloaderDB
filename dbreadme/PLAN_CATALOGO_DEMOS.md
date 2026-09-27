# Plan: catalogo completo, auto-linkeo y personajes demo

Todo primero en DESARROLLO (sql-dev). Sin commits hasta que el usuario lo pida.
Fuentes de datos: `LAPIS_RECIBIDOS.txt` y `SETS_RECIBIDOS.txt` (esta carpeta).

## Ya hecho — V025 (sql-dev)
12 clases (6 Luz + 6 Furia), registro en una pantalla (usuario + contrasena + personaje + faccion + clase),
email reservado `<personaje>@reloader.dev`, EmailCreated, nombres de personaje unicos,
auth-service (`/auth/factions`, `/auth/register-player`, `/auth/email-status`), app registro + Perfil.

## Fase 1 — V026 catalogo de lapis — HECHO (sql-dev)
- 23 lapis nuevos (44 en total): Mystic Lv7-9 (INT), Wise Lv7-9 (WIS), Safe Lv7-9 (REC), Life Lv7-10 (HP),
  Absorption Lv7-10, Dual Safe / Dual Mystic / Dual Wise / Dual Shrewd Lv7,
  Ultimate Triple Wise, Ultimate Triple Safe.
- Tipo nuevo `WEAPON` (exclusivo de arma): Chaotic Lapis y Max Flash Lapis.
- Correcciones: Ultimate Triple Craft -> TRIPLE; Dual Craft/Fortune Lv7 -> nivel de item 75.
- Stat nuevo `DAMAGE_ABSORPTION` (catalog.StatType y columna en catalog.Lapis).
- Piezas por lapis en `LapisApplicableItemType`.
- Limpieza V025: usuarios SUPPLIER (wizard) sin rol PLAYER ni core.Player.

## Fase 2 — V027 sets y tablas maestras — HECHO (sql-dev)
- Sets de las 11 clases que faltan (casco real, resto con patron Mail/Gaiters/Bracers/Boots,
  stats del casco en las 5 piezas, arma y escudo provisorios, accesorios Bonespike).
- `catalog.ClassBaseStat`: stats con los que nace cada clase. SE CONSULTA, NO SE COPIA
  (un UPDATE rebalancea a todos). Valores provisorios.
- `catalog.ClassStatPreference`: stats preferidos por clase; `catalog.ClassAutoLinkConfig`:
  sockets de absorcion. Solo lo usa el auto-linkeo; nunca bloquea.

## Fase 3 — V028 auto-linkeo y personaje equipado al nacer — HECHO (sql-dev)
- `equipment.sp_AutoLinkCharacter`: equipa el set de la clase (encanto [20] = absorcion 240)
  y llena cada pieza con los mejores lapis permitidos segun preferencias (sin repetir en la pieza,
  respetando pieza y nivel del item). Es una REFERENCIA: el jugador cambia lo que quiera.
- `sp_RegisterPlayerWithCharacter` llama al auto-linkeo: el personaje nace equipado (revertido en V030: nace sin set).
- PENDIENTE: validacion al guardar lapis (`sp_SaveCharacterLapisConfig` de V011 hoy no valida
  pieza ni nivel). Solo reglas del lapis (pieza, nivel, socket, sin repetir); un tanque puede ponerse WIS.
- `sp_GetCharacterScreenByUser`: result set 5 nuevo (StatCode, StatValue) con los stats base de la clase.

## Fase 4 — V029 personajes demo (uno por clase) — HECHO (sql-dev)
- Equipar DibuWar, RomeroSin, DePaulPagan, MacOracle (existen sin equipo).
- Crear demos para Guardian, Luchador, Defensor, Ranger, Arquero, Mago, Cura (ver `DEMOS.md`).
- NazgulKash (messi) no se toca.

## Fase 5 — REST + app — HECHO y probado (sql-dev + REST local)
- REST `CharacterSqlServerDAO`: lee el result set 5 y lo expone como `classBaseStats`
  `[{"StatCode":"STR","StatValue":150}, ...]` en GET characters/screen/{userId}.
- App: `CharacterScreenDto.classBaseStats` (opcional), `toStatsSummary` suma base de clase +
  items equipados + lapis; `SideStatsOverlay` muestra total y "Base / Equipo / Lapis".
- Iconos de los lapis nuevos corregidos en `CharacterScreenMapper.primaryStatOf`.

## Fase 6 — V030 nace sin set, equipar por slot y set recomendado — HECHO y probado (sql-dev)
- `sp_RegisterPlayerWithCharacter` ya no auto-linkea: el personaje nace SIN equipo.
- `equipment.sp_GetRecommendedSet @CharacterId`: 16 slots con la pieza del set de la clase
  (Equipped / EquippedItemName) + lapis sugeridos por slot. Solo lectura.
- `equipment.sp_EquipSlots @CharacterId, @SlotCodes, @WithRecommendedLapis`: equipa en los slots
  pedidos que esten vacios (encanto 20 / absorcion 240), sockets vacios o con los sugeridos.
- Logica comun en `fn_ClassSetPieces` y `fn_RecommendedLapisForItem`; `sp_AutoLinkCharacter`
  reescrito encima con el mismo resultado (verificado en las 12 clases).
- En la app: "Anadir" por slot vacio, "Linkear sugerido" por pieza (solo sockets vacios, se guarda
  con el Guardar de lapis), "Ver set recomendado" (marcar piezas y equiparlas con sus lapis).
- REST: GET characters/{id}/recommended-set y POST characters/{id}/equip-slots. App con los tres botones.
- Probado: OtamendiWar ("Anadir" del casco) y RyoskePlayer registrado desde la app (Oraculo Furia) con
  el set recomendado completo: 16 piezas, 60 lapis, todos permitidos por pieza y nivel, sin repetidos.

## Fase 7 — V031 usuarios de prueba — HECHO (sql-dev)
- OtamendiWar y RyoskePlayer/ryoske en migracion para que lleguen igual a produccion (ver `DEMOS.md`).

## Stat total
base de la clase (catalog.ClassBaseStat) + puntos asignados (build.CharacterAssignedStat)
+ items equipados (catalog.Item) + lapis (catalog.Lapis); absorcion aparte.

## Antes de produccion
- Marcar EmailCreated = 1 en casillas de Zoho existentes.
- Flyway V025..V031 en Azure, deploy de auth-service y REST, app con IS_DEV = false.

## Datos pendientes del usuario (no bloquean)
- Stats base reales por clase (nivel 80 sin equipo)
- Arma y escudo reales por clase
- Stats reales de top, pantalon, guantes y botas
