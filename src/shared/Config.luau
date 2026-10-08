-- Game-wide settings. Shared so both server and client can read them.
local Config = {}

Config.TOTAL_ROOMS = 100

-- true = don't start a run; lay out every room side by side to look at.
Config.SHOWCASE = false
-- Puts the cutscene crew NPC in room 1 so you can see how it looks.
Config.PREVIEW_NPC = true

-- Set to a number to replay the same run every time (e.g. 194006090).
-- Leave as nil for a new random run each time.
Config.SEED = nil

-- Where room 1 is built. High up so it doesn't clash with the baseplate.
Config.START_CFRAME = CFrame.new(0, 200, 0)

-- How many rooms exist in front of / behind the furthest opened door.
Config.ROOMS_AHEAD = 2
Config.ROOMS_BEHIND = 2

-- Rooms that always use a specific preset (by name in ServerStorage.Rooms.Special).
-- Missing presets are skipped and a random room is used instead.
Config.FIXED_ROOMS = {
	[1] = "Start",
	[24] = "MemorialRoom",
	[50] = "Midpoint",
	[100] = "Final",
}

-- How many research items each room can have (picked at random in this range).
Config.RESEARCH_MIN = 0
Config.RESEARCH_MAX = 2

-- Optional looping ambient sound: paste a sound's asset ID from the Creator
-- Store (e.g. a low drone or ship hum). nil = no sound.
Config.AMBIENT_SOUND_ID = 1843721367

-- Footstep sound (replaces Roblox's default footsteps). nil = silent.
Config.FOOTSTEP_SOUND_ID = 87061775498714

-- Movement. Hold Shift to sprint; running out of stamina leaves you winded
-- (WINDED_SPEED) until stamina is full again.
Config.WALK_SPEED = 16
Config.SPRINT_SPEED = 24
Config.WINDED_SPEED = 12
Config.SPRINT_MAX_STAMINA = 100
Config.SPRINT_DRAIN = 22 -- per second while sprinting (~4.5 s of sprint)
Config.SPRINT_REGEN = 30 -- per second once refilling starts
Config.SPRINT_REGEN_DELAY = 1.5 -- seconds after you stop sprinting

-- A preset can't appear again until this many other rooms have passed.
Config.NO_REPEAT_WITHIN = 4

-- Presets with the same Group attribute (like the left and right corridor
-- bends) must have at least this many rooms between them.
Config.GROUP_GAP = 3

-- Chance (0-1) that any given lamp flickers, before damage is added.
Config.FLICKER_CHANCE = 0.05

-- Ship damage: starts at DECAY_START and is at its worst by DECAY_FULL.
-- DECAY_CURVE above 1 makes it build up slowly at first (higher = slower).
Config.DECAY_START = 3
Config.DECAY_FULL = 100
Config.DECAY_CURVE = 2.4

return Config
