enemies = ParentObject.find("Enemies", "Vanilla")
elite = EliteType.findAll("Vanilla")

originalElites = {
	elite.Blazing,
	elite.Overloading,
	elite.Frenzied,
	elite.Leeching,
	elite.Volatile
}

------ main.lua
---- This file is automatically loaded by RoRML

-- Load Survivor scripts
if not modloader.checkFlag("TE_no_survivors") then
	--require("night")
end

-- Load Item scripts
if not modloader.checkFlag("TE_no_items") then
	-- Common
	require("Items/wings")
	require("Items/broken_lan_cable")
	require("Items/see-through_log")
	require("Items/mirror_shard")

	-- Uncommon
	require("Items/soul_devourer")
	require("Items/blood_economy")
	require("Items/thieves_hat")

	-- Rare
	require("Items/punching_bag")
	require("Items/uranium_bullets")
	require("Items/super_stickies")
	require("Items/cursed_longsword")

	-- Use
	require("Items/big_scythe")
	require("Items/hell_chain")
end

-- Load Elite Type scripts
if not modloader.checkFlag("TE_no_elites") then
	require("Elites/freeze")
end

-- Load Artifact scripts
if not modloader.checkFlag("TE_no_artifacts") then
	require("Artifacts/spiter")
	require("Artifacts/turbo")
	require("Artifacts/worms")
	require("Artifacts/pain")
end

if not modloader.checkFlag("TE_no_gameplay") then
	require("gameplay")
end

if not modloader.checkFlag("TE_no_crateQoL") then
	require("crate")
end

-- Starstorm stuff
if modloader.checkMod("StarStorm") then
	require("rules")
	require("tabmenu")
	require("Skins/skins")
end


-- Menu stuff
local red = 0
local green = 0
local blue = 0
local rainbowTimer = 0

-- Show version on title screen
callback.register("globalRoomStart", function(room)
	local function drawName()
		if room == Room.find("Start") then
			local width, height = graphics.getGameResolution()

			rainbowTimer = rainbowTimer + 1

			if rainbowTimer > 20 then
				red = math.random(0, 255)
				green = math.random(0, 255)
				blue = math.random(0, 255)
				
				rainbowTimer = 0
			end

			graphics.color(Color.fromRGB(red, green, blue))
			--graphics.color(Color.fromHex(0x808080))

			local yOffset = 0

			if modloader.checkMod("StarStorm") then
				yOffset = 10
			end

			graphics.print("Turbo Edition " .. modloader.getModVersion("Turbo Edition"), width - 3, 3 + yOffset, graphics.FONT_SMALL, graphics.ALIGN_RIGHT)
		end
	end

	graphics.bindDepth(-99, drawName)
end)


-- function stuff
function distance ( x1, y1, x2, y2 )
	local dx = x1 - x2
	local dy = y1 - y2
	return math.sqrt ( dx * dx + dy * dy )
end

function angleDif(current, target)
    return ((((current - target) % 360) + 540) % 360) - 180
end