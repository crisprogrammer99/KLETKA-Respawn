# KLETKA Respawn Mod — Host can revive dead friends

I made a small UE4SS mod for **KLETKA** that lets the host revive dead players without waiting for the normal resurrection method.

The important part is that it does **not** manually fake a new character. After some testing, I found KLETKA's own manual-respawn gameplay ability (`GA_Respawn_Manual`) and the mod activates that for players who are currently in the game's spectator state.

### Current stable behavior
- Host installs the mod.
- Friends can join with a normal/unmodified game.
- When a friend dies, the host presses **F8**.
- Dead players are revived using KLETKA's own respawn flow.
- **F7** writes diagnostic information to `UE4SS.log`.

### Requirements
- KLETKA
- RE-UE4SS
- Windows

The exact UE4SS build I used while developing/testing was:
`UE4SS_v3.0.1-1161-g6eb3d9bc`

I'm also working on an **automatic respawn when the group advances to the next floor**, but that part is still experimental and is not being presented as stable yet.

If anyone wants to test it, report bugs or help improve the floor-change trigger, contributions are welcome.

**Unofficial community mod — not affiliated with the KLETKA developers or RE-UE4SS.**
