# Mod de respawn para KLETKA — el host puede revivir a sus amigos

He preparado un pequeño mod mediante **UE4SS** para KLETKA que permite al host revivir a los jugadores muertos sin tener que esperar al sistema normal de resurrección.

Después de varias pruebas localicé la habilidad interna que usa KLETKA para el respawn manual (`GA_Respawn_Manual`), así que el mod no se limita a crear un personaje artificialmente: activa el propio flujo de resurrección del juego.

### Funcionamiento estable actual
- El host instala el mod.
- Los amigos pueden entrar con KLETKA sin modificar.
- Cuando un jugador muere, el host pulsa **F8**.
- El jugador muerto reaparece mediante el sistema real de KLETKA.
- **F7** genera información de diagnóstico en `UE4SS.log`.

### Requisitos
- KLETKA
- RE-UE4SS
- Windows

La build de UE4SS utilizada durante el desarrollo/pruebas fue:
`UE4SS_v3.0.1-1161-g6eb3d9bc`

También estoy trabajando en que los jugadores muertos **reaparezcan automáticamente al avanzar a la siguiente planta**, pero esa parte todavía es experimental y no la considero estable.

Si alguien quiere probarlo, informar de errores o ayudar a mejorar el trigger de cambio de planta, cualquier colaboración es bienvenida.

**Mod no oficial de la comunidad; no está afiliado con los desarrolladores de KLETKA ni con RE-UE4SS.**
