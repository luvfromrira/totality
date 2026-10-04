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

-- How many research items each room can have (picked at random in this range).
Config.RESEARCH_MIN = 0
Config.RESEARCH_MAX = 2

-- A preset can't appear again until this many other rooms have passed.
Config.NO_REPEAT_WITHIN = 4

-- Chance (0-1) that any given lamp flickers, before damage is added.
Config.FLICKER_CHANCE = 0.05

-- Ship damage: rooms before DECAY_START are untouched, and the damage
-- ramps up until DECAY_FULL, where it's at its worst.
Config.DECAY_START = 10
Config.DECAY_FULL = 90

return Config
