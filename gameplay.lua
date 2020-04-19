-- if teleporter is in active state 1, let the player activate it again to spawn another boss and gain a clover

local clover = Object.find("Clover", "Vanilla")
local teleporters = Object.find("Teleporter", "Vanilla")
local activated = false
local teleportEnabled = true

-- Starstorm rules
registercallback("postSelection", function()
    teleportEnabled = Rule.getSetting(Rule.find("Teleport Challenge"))
end)

registercallback("onStageEntry", function()
    activated = false
end)

registercallback("onStep", function()
    if artifact.active and activated == false and teleportEnabled == true then
        for i, teleporter in pairs(teleporters:findAll()) do
            if teleporter:get("active") == 1 then
                -- INSERT CODE TO CHECK FOR PLAYER NEARBY
                -- INSERT CODE TO CHECK IF THEY PRESS A TO SPAWN A BOSS AND A CLOVER
                local cloverInstance = clover:create(teleporter.x, teleporter.y - 20)
                activated = true
            end
        end
    end
end)