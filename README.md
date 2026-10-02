# Totality

Cosmic horror co-op (1-4 players) on Roblox. Players push through 100 procedurally
ordered rooms searching for research.

## Setup
1. Install the Rojo VS Code extension, open this folder, run **Rojo: Open menu** → `default.project.json`.
2. In Studio: Plugins → Rojo → Connect.
3. Press Play. If you haven't built presets in Studio, the built-in rooms from
   `src/server/RoomPresets.luau` are used: Hallway, TurnLeft, TurnRight, Office,
   Archive, Stairwell, GreatHall, Observatory, plus the Start and Final rooms.

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
- `ResearchSpawn` parts (optional): possible research item locations

Optional Model attributes: `Weight`, `MinRoom`, `MaxRoom`, `Turn` (1 = exit turns left, -1 = right).

Settings live in `src/shared/Config.luau`.
