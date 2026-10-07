# KLETKA Respawn v0.5.0 — First stable manual-respawn release

This is the first version of **KLETKA Respawn** confirmed working in a multiplayer host session.

## What it does

When a player dies and becomes KLETKA's spectator Pawn (`B_Spectator_C`), the host can press **F8** to revive dead players through KLETKA's own `GA_Respawn_Manual` gameplay ability.

This means the game itself performs the actual respawn flow instead of the mod manually spawning a replacement character.

## Tested setup

- Host: KLETKA + RE-UE4SS + KletkaRespawn
- Friends: normal/unmodified KLETKA
- RE-UE4SS development build used during testing: `UE4SS_v3.0.1-1161-g6eb3d9bc`

## Controls

- **F7** — diagnostic output
- **F8** — revive dead players

## Installation

1. Install a compatible RE-UE4SS build into `KLETKA/Binaries/Win64`.
2. Put `KletkaRespawn` inside `ue4ss/Mods/`.
3. Add `KletkaRespawn : 1` to `ue4ss/Mods/mods.txt`.
4. Restart the game and host the session.

## Experimental automatic respawn

Automatic respawn on floor transition is being developed separately and is **not included as a stable feature in this release**.

Please report bugs with your KLETKA version, UE4SS version and the relevant `[KletkaRespawn]` section of `UE4SS.log`.
