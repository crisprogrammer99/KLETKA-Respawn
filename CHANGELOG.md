# Changelog

## v0.8.0-beta

- Experimental automatic respawn trigger based on `LyraGameMode:SetSessionCurrentFloor`.
- `B_Elevator_C:MulticastFinishMove` used as a fallback.
- Keeps the proven manual `F8` respawn.
- **Automatic floor-transition behavior is not yet confirmed working.**

## v0.5.0

- First version confirmed working in multiplayer.
- Detects dead players via `B_Spectator_C`.
- Uses KLETKA's own `GA_Respawn_Manual_C`.
- Host can press `F8` to revive dead friends.
- Other players did not need to install the mod in the tested setup.

## Earlier development builds

v0.1–v0.4 were diagnostic/prototype builds used to discover KLETKA's death and respawn flow. They are not recommended for normal use.
