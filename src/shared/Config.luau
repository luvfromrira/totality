-- Game-wide settings. Shared so both server and client can read them.
local Config = {}

Config.TOTAL_ROOMS = 100

-- Where room 1 is built. High up so it doesn't clash with the baseplate.
Config.START_CFRAME = CFrame.new(0, 200, 0)

-- How many rooms exist in front of / behind the furthest opened door.
Config.ROOMS_AHEAD = 2
Config.ROOMS_BEHIND = 2

-- Rooms that always use a specific preset (by name in ServerStorage.Rooms.Special).
-- Missing presets are skipped and a random room is used instead.
Config.FIXED_ROOMS = {
	[1] = "Start",
	[50] = "Midpoint",
	[100] = "Final",
}

-- Chance (0-1) that each ResearchSpawn point in a room gets a research item.
Config.RESEARCH_CHANCE = 0.35

return Config
