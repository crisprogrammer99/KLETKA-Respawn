# Troubleshooting

## Nothing happens when pressing F8

1. Confirm you are the **host**.
2. Confirm `KletkaRespawn : 1` is present in `ue4ss/Mods/mods.txt`.
3. Restart KLETKA after changing Lua files.
4. Open `ue4ss/UE4SS.log` and search for:

```text
[KletkaRespawn]
```

5. A dead player should normally be detected as:

```text
B_Spectator_C
```

6. A living player should normally be:

```text
B_Hero_Elevator_C
```

## UE4SS loads but the mod does not

Expected structure:

```text
ue4ss/Mods/KletkaRespawn/scripts/main.lua
```

Do not add an extra nested folder such as:

```text
KletkaRespawn/KletkaRespawn/scripts/main.lua
```

## What to attach to a bug report

Please include the relevant section of `UE4SS.log` beginning with `[KletkaRespawn]`.

Do not upload personal credentials, Steam authentication data, API keys or unrelated private logs.

## Journal/objective placeholder messages

During development, messages similar to the following were observed:

```text
Destruye {item}:
{curAmount}/{targetAmount}
```

The cause has not been confirmed. The respawn Lua does not intentionally edit journal/objective data, so this is currently tracked as a separate compatibility issue rather than a confirmed KletkaRespawn bug.
