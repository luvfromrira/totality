# Totality

Cosmic horror co-op (1-4 players) on Roblox. Players push through 100 procedurally
ordered rooms searching for research.

## Setup
1. Install the Rojo VS Code extension, open this folder, run **Rojo: Open menu** → `default.project.json`.
2. In Studio: Plugins → Rojo → Connect.
3. Press Play. If you haven't built presets in Studio, the built-in liminal rooms
   from `src/server/RoomPresets.luau` are used (hallways, cubicles, backrooms,
   pool rooms, hotel, waiting room, garage, school, restroom, playroom, stairwell,
   archive, dead mall, observatory, plus the Start and Final rooms).

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
- Only a few rooms around the players exist at a time.
- Built-in rooms use `src/server/RoomBuilder.luau`, which builds walls, floors and
  doorways so parts touch but never overlap (no gaps, no z-fighting).
