# Installation

## 1. Locate KLETKA

In Steam:

**Library → KLETKA → Manage → Browse local files**

Then go to:

```text
KLETKA\Binaries\Win64
```

You should see `KLETKA-Win64-Shipping.exe`.

## 2. Install RE-UE4SS

Use an RE-UE4SS build compatible with the Unreal Engine version currently used by KLETKA.

The build used during development was:

```text
UE4SS_v3.0.1-1161-g6eb3d9bc
```

For the experimental layout used in testing, the Win64 directory contained:

```text
KLETKA-Win64-Shipping.exe
dwmapi.dll
ue4ss\
```

## 3. Install the mod

Copy:

```text
KletkaRespawn
```

to:

```text
...\KLETKA\Binaries\Win64\ue4ss\Mods\
```

Expected structure:

```text
ue4ss\
└── Mods\
    ├── mods.txt
    └── KletkaRespawn\
        └── scripts\
            └── main.lua
```

Add to `mods.txt`:

```text
KletkaRespawn : 1
```

## 4. Test

Restart KLETKA and host a game.

After a friend dies, press `F8`.

If the installation is correct, `UE4SS.log` should include `[KletkaRespawn]` messages.
