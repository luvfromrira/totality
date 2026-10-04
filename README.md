# Totality

Cosmic horror co-op (1-4 players) on Roblox. The S.S. Totality, a Solstice Solutions
vessel built to study the Sun, was ransacked, attacked and abandoned in orbit above Earth. Solstice wants its research
back, so players are sent aboard to push through 100 procedurally ordered rooms
and recover it.

## Setup
1. Install the Rojo VS Code extension, open this folder, run **Rojo: Open menu** → `default.project.json`.
2. In Studio: Plugins → Rojo → Connect.
3. Press Play. If you haven't built presets in Studio, the built-in ship rooms
   from `src/server/RoomPresets.luau` are used. The server also removes the
   default Baseplate (the ship floats in space).

## Building room presets (in Studio)
```
ServerStorage
  Rooms
    Normal    -- random-pool rooms
    Special   -- fixed rooms: Start (1), Midpoint (50), Final (100)
```
Each room is a **Model** containing:
- `Entrance` part and `Exit` part, front face pointing the way players walk
- `Door` part (optional): touching it opens it and loads the next rooms
- `ResearchSpawn` parts (optional): extra spots research may appear (it also picks random spots on floors and tables)

Optional Model attributes: `Weight`, `MinRoom`, `MaxRoom`, `Turn` (1 = exit turns left, -1 = right).

Settings live in `src/shared/Config.luau`.

## How generation works
- The whole 100-room layout is planned when the server starts. Each room's
  bounding box is checked against every earlier room, and the planner backtracks
  if nothing fits, so rooms never overlap.
- A preset can't repeat within `Config.NO_REPEAT_WITHIN` rooms.
- Only a few rooms around the players exist at a time.
- `src/server/Decay.luau` damages rooms more the deeper you go (grime, broken
  lights, debris, scorch and claw marks, alien residue). Tune with
  `Config.DECAY_START` / `Config.DECAY_FULL`.
- Built-in rooms use `src/server/RoomBuilder.luau`, which builds walls, floors and
  doorways so parts touch but never overlap (no gaps, no z-fighting).
