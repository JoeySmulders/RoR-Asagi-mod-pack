-- if teleporter is in active state 1, let the player activate it again to spawn another boss/more mobs and gain a clover

local clover = Object.find("Clover", "Vanilla")
local teleporters = Object.find("Teleporter", "Vanilla")
local activated = false
local teleportEnabled = true
local inTeleporter = false
local foundTeleporter
local playerObject = ParentObject.find("P", "Vanilla")
local currentPlayer


-- Starstorm rules
registercallback("postSelection", function()
    teleportEnabled = Rule.getSetting(Rule.find("Teleport Challenge"))
end)

-- Reset being able to do the clover challenge on stage entry
registercallback("onStageEntry", function()
    activated = false
end)

-- Check if the teleporter is in active state 1 and if a player is next to it, then check if they press A
registercallback("onStep", function()
    if activated == false and teleportEnabled == true then
        
        for i, teleporter in pairs(teleporters:findAll()) do
            if teleporter:get("active") == 1 then

                local loop = true
                for i, player in ipairs(misc.players) do
                    if player.x > teleporter.x - 50 and player.x < teleporter.x + 50 and player.y > teleporter.y -50 and player.y < teleporter.y + 50 then
                        inTeleporter = true
                        foundTeleporter = teleporter
                        loop = false
                        currentPlayer = player
                    else
                        inTeleporter = false
                    end
                end

                if loop == false then
                    for i, player in ipairs(misc.players) do
                        
                        if player:control("enter") == input.PRESSED and player.x > teleporter.x - 50 and player.x < teleporter.x + 50 and player.y > teleporter.y -50 and player.y < teleporter.y + 50 then
                            local cloverInstance = clover:create(teleporter.x, teleporter.y - 20)
                            misc.director:set("spawn_boss", 1)
                            misc.director:set("points", misc.director:get("points") + 1500 + misc.director:get("stages_passed") * 1000)
                            activated = true
                        end
                    end
                end
                
            else
                inTeleporter = false
            end
        end

    else
        inTeleporter = false
    end
end)

registercallback("onDraw", function()
    if inTeleporter == true then
        graphics.printColor("&w&Press &!&&y&'" .. input.getControlString("enter", currentPlayer)  .. "'&!&&w& to challenge the odds.&!&", foundTeleporter.x - 80, foundTeleporter.y - 80, graphics.FONT_DEFAULT)
    end
end)


-- Respawn a command chest if the user using it dies

local crateRespawn = true
local activeCrates = {}
local crates = ParentObject.find("commandCrates", "Vanilla")

-- Starstorm rules
registercallback("postSelection", function()
    crateRespawn = Rule.getSetting(Rule.find("Crate Respawn"))
end)

registercallback("onStageEntry", function()
    for i, player in ipairs(misc.players) do
        player:getData().crateActive = false
    end
    activeCrates = {}
end)

registercallback("postStep", function()
    if crateRespawn then

        for i, crate in ipairs(crates:findMatchingOp("active", "==", 1)) do
            local player = Object.findInstance(crate:get("owner"))
            if player and player:getData().crateActive == false then
                table.insert(activeCrates, {["player"] = player, ["crate"] = crate:getObject()})
                player:getData().crateActive = true
            end
        end

        for key, data in pairs(activeCrates) do
            if data.player:get("dead") == 1 then 
                data.crate:create(data.player.x, data.player.y)
                activeCrates[key] = nil
            else

                if data.player:get("activity") ~= 95 then
                    activeCrates[key] = nil  
                end
            end

        end
    end
end)