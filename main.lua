------ main.lua
---- This file is automatically loaded by RoRML

require("resources")
require("version")

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