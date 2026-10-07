# KLETKA Respawn

Unofficial **host-side respawn mod for KLETKA** using RE-UE4SS.

The stable version lets the **host press `F8` to revive every dead player** using KLETKA's own `GA_Respawn_Manual` gameplay ability. The other players do **not** need to install the mod for the tested manual-respawn workflow.

> **Status**
>
> - ✅ **Stable/manual:** `v0.5.0` — tested working in multiplayer.
> - 🧪 **Experimental:** `v0.8.0-beta` — attempts automatic respawn when the session changes floor. This automatic trigger is **not yet confirmed working**, so it is kept out of the stable build.

## What it does

When a player dies, KLETKA changes that player to `B_Spectator_C`. The mod detects dead/spectating players and asks their Ability System Component to activate the game's own manual-respawn ability:

```text
PlayerState
  -> AbilitySystemComponent
  -> TryActivateAbilityByClass(GA_Respawn_Manual_C)
```

This is much more reliable than manually spawning a new character because KLETKA itself handles the normal respawn flow, including the character, health/state setup, movement and replication.

## Requirements

- KLETKA on Steam
- Windows
- **RE-UE4SS**
- Tested during development with experimental RE-UE4SS build:
  `UE4SS_v3.0.1-1161-g6eb3d9bc`
- Tested against a KLETKA build using Unreal Engine 5.7.x

RE-UE4SS is **not included** in this repository. Download it from the official RE-UE4SS project.

## Installation

1. Install RE-UE4SS in KLETKA's Win64 directory:

   ```text
   ...\Steam\steamapps\common\KLETKA\KLETKA\Binaries\Win64\
   ```

   With the newer experimental UE4SS layout, you should have roughly:

   ```text
   Win64\
   ├── KLETKA-Win64-Shipping.exe
   ├── dwmapi.dll
   └── ue4ss\
   ```

2. Copy the repository folder:

   ```text
   KletkaRespawn
   ```

   into:

   ```text
   ...\Win64\ue4ss\Mods\
   ```

3. Open:

   ```text
   ...\Win64\ue4ss\Mods\mods.txt
   ```

   and add:

   ```text
   KletkaRespawn : 1
   ```

4. Restart KLETKA completely.

5. Host a multiplayer game.

## Usage — stable version

- `F7` — diagnostic information in `UE4SS.log`
- `F8` — revive all players currently detected as `B_Spectator_C`

The tested setup is:

```text
HOST: KLETKA + UE4SS + KletkaRespawn
FRIENDS: normal KLETKA
```

Your friends do not need the mod for the manual F8 respawn that was tested during development.

## Experimental automatic floor respawn

An experimental build is included under:

```text
experimental/v0.8-auto-floor/
```

It tries to trigger the same working respawn ability when KLETKA updates the current session floor through:

```text
LyraGameMode:SetSessionCurrentFloor(int NewFloor)
```

with `B_Elevator_C:MulticastFinishMove` as a fallback.

**This automatic trigger is still experimental and should not be advertised as stable until confirmed in a real multiplayer test.**

## Troubleshooting

Check:

```text
...\KLETKA\Binaries\Win64\ue4ss\UE4SS.log
```

A successful load should contain:

```text
[KletkaRespawn] v0.5 cargado.
```

When `F8` works, the log should show that `GA_Respawn_Manual` was accepted and that the dead player's Pawn changed back to `B_Hero_Elevator_C`.

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for more detail.

## Known issues

- Automatic respawn on floor transition is experimental.
- Some users may see unrelated-looking journal/objective messages with unresolved placeholders such as `{item}`, `{curAmount}` or `{targetAmount}` after installing/testing UE4SS. The cause has **not been confirmed** and this mod does not intentionally modify journal/objective data.
- Game or UE4SS updates may break reflected class/function names.

## Uninstall

Remove:

```text
...\ue4ss\Mods\KletkaRespawn\
```

and remove or disable:

```text
KletkaRespawn : 1
```

from `mods.txt`.

You can leave UE4SS installed if you use it for other mods.

## Contributing

Bug reports and pull requests are welcome. If reporting a bug, include:

- KLETKA version/build if known
- UE4SS version
- whether you were the host
- number of players
- relevant `[KletkaRespawn]` lines from `UE4SS.log`

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Disclaimer

This is an unofficial community mod and is not affiliated with, endorsed by, or supported by KLETKA's developers/publisher or the RE-UE4SS project.

Use it in private/co-op sessions with people who know you are using the mod. Back up important saves before testing experimental builds.

## License

MIT. See [LICENSE](LICENSE).
