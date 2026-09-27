# Personajes demo (sql-dev)

Creados / equipados por `V029__seed_demo_characters.sql`. Uno por clase, todos nivel 80,
equipados con `equipment.sp_AutoLinkCharacter` (set de la clase, encanto [20], lapis de referencia).

**Password de DESARROLLO de los usuarios `demo_*`: `Demo1234`**
(hash igual que `auth.sp_RegisterUser`: SHA2_256(password nvarchar + salt), salt `CRYPT_GEN_RANDOM(32)`).
Van tambien a produccion como datos de prueba (decision del usuario, 2026-09-26): la password es conocida,
desactivarlos (`IsActive = 0`) cuando ya no se usen.

## Usuarios demo nuevos (V029)

| Username | Personaje | Clase | Faccion | Email reservado |
|---|---|---|---|---|
| demo_guardian | GuardianDemo | Guardian (GUARDIAN_FURIA) | Furia | guardiandemo@reloader.dev |
| demo_luchador | LuchadorDemo | Luchador (WARRIOR_LUZ) | Luz | luchadordemo@reloader.dev |
| demo_defensor | DefensorDemo | Defensor (DEFENDER_LUZ) | Luz | defensordemo@reloader.dev |
| demo_ranger | RangerDemo | Ranger (ASSASSIN_LUZ) | Luz | rangerdemo@reloader.dev |
| demo_arquero | ArqueroDemo | Arquero (HUNTER_LUZ) | Luz | arquerodemo@reloader.dev |
| demo_mago | MagoDemo | Mago (PAGAN_LUZ) | Luz | magodemo@reloader.dev |
| demo_cura | CuraDemo | Cura (ORACLE_LUZ) | Luz | curademo@reloader.dev |

Todos: RegistrationSource `ADMIN`, EmailCreated 0, UserProfile (DisplayName = personaje), rol PLAYER, core.Player.

## Personajes existentes equipados en V029

| Username | Personaje | Clase |
|---|---|---|
| dibu | DibuWar | Guerrero (WARRIOR_FURIA) |
| romero | RomeroSin | Asesino (ASSASSIN_FURIA) |
| depaul | DePaulPagan | Pagano (PAGAN_FURIA) |
| macallister | MacOracle | Oraculo (ORACLE_FURIA) |

Sus passwords son las que ya tenian (no se tocaron).

## Usuarios de prueba (V031)

| Username | Personaje | Clase | Estado |
|---|---|---|---|
| otamendi | OtamendiWar | Guerrero (WARRIOR_FURIA) | solo casco del set, sin lapis (prueba de "Añadir") |
| RyoskePlayer | ryoske | Oraculo (ORACLE_FURIA) | registrado desde la app; set recomendado completo (16 piezas, 60 lapis) |

RyoskePlayer: la password es la que uso el usuario al registrarse (hash y salt copiados, no estan en este archivo).

## No se toca

- **NazgulKash** (usuario `messi`, Cazador): equipo armado a mano en V002..V008.

## Volver a equipar un personaje

El auto-linkeo solo actua si el personaje NO tiene equipo. Para regenerarlo en desarrollo:
borrar su `equipment.EquippedItemLapis`, `EquippedItemSocket` y `CharacterEquipment` y ejecutar

```sql
EXEC equipment.sp_AutoLinkCharacter @CharacterId = <id>;
```
