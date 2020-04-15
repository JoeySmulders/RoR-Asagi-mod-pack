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
	require("night")
end

-- Load Item scripts
if not modloader.checkFlag("TE_no_items") then
	-- Common
	require("Items/wings")
	require("Items/broken_lan_cable")
	require("Items/see-through_log")

	-- Uncommon
	require("Items/soul_devourer")
	require("Items/blood_economy")
	require("Items/thieves_hat")

	-- Rare
	require("Items/punching_bag")
	require("Items/140_leaf_clover")

	-- Use
	require("Items/big_scythe")
	require("Items/squeaky_toy")
end

-- Load Elite Type scripts
if not modloader.checkFlag("TE_no_elites") then
	require("Elites/freeze")
end

-- Load Artifact scripts
if not modloader.checkFlag("TE_no_artifacts") then
	require("Artifacts/brain")
	require("Artifacts/worms")
end