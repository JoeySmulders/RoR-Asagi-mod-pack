-- This stuff here is just stolen from Starstorm, sorry Neik (this stuff should just be part of the API tho ;p)
pobj = {}
for _, parentObject in ipairs(ParentObject.findAll("Vanilla")) do
	pobj[parentObject:getName()] = parentObject
end

------ main.lua
---- This file is automatically loaded by RoRML

-- Load Survivor scripts
require("night")

-- Load Item scripts

-- Common
require("Items/wings")
require("Items/broken_lan_cable")

-- Uncommon
require("Items/soul_devourer")
require("Items/see-through_log")

-- Rare

-- Use
require("Items/big_scythe")
