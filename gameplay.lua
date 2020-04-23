-- if teleporter is in active state 1, let the player activate it again to spawn another boss/more mobs and gain a clover

local clover = Object.find("Clover", "Vanilla")
local teleporters = Object.find("Teleporter", "Vanilla")
local activated = false
local teleportEnabled = true
local foundTeleporter
local playerObject = ParentObject.find("P", "Vanilla")
local currentPlayer


-- Starstorm rules
registercallback("postSelection", function()
    teleportEnabled = Rule.getSetting(Rule.find("Teleport Challenge"))
end)

-- Reset being able to do the clover challenge on stage entry
registercallback("onStageEntry", function()
    for i, teleporter in pairs(teleporters:findAll()) do
        teleporter:getData().activated = false
    end
end)

-- TODO: use netInstance stuff so you can actually sync the teleporter activated/inTeleporter values


local function getTeleporterPoints()
    local newPoints = misc.director:get("points") + 1000 + (misc.director:get("stages_passed") * 500) + (#misc.players * 100)
    return newPoints
end

-- Sync teleporter challenge
teleporterPacket = net.Packet("Activate Teleporter Challenge", function(player, teleporterState)
    local teleporter = teleporters:findMatchingOp("active", "==", teleporterState)

    if #teleporter > 0 then
        if net.host and teleporter[1]:getData().activated == false then
            teleporter = teleporter[1]
            local cloverInstance = clover:create(teleporter.x, teleporter.y - 20)
            misc.director:set("spawn_boss", 1)
            misc.director:set("points", getTeleporterPoints()) -- Change this so it also scales with difficulty 
            teleporter:getData().activated = true
            teleporterPacket:sendAsHost(net.ALL, nil, teleporterState)
        else
            teleporter = teleporter[1]
            teleporter:getData().activated = true
            teleporter:getData().inTeleporter = false
        end
    end 
end)


-- Check if the teleporter is in active state 1 and if a player is next to it, then check if they press A
registercallback("onStep", function()
    if teleportEnabled == true then
        
        for i, teleporter in pairs(teleporters:findAll()) do
            if teleporter:get("active") == 1 and teleporter:getData().activated == false then

                local found = false
                for i, player in ipairs(misc.players) do
                    player:getData().teleporterLoop = true
                    if found == false then
                        if player.x > teleporter.x - 50 and player.x < teleporter.x + 50 and player.y > teleporter.y -50 and player.y < teleporter.y + 50 then
                            teleporter:getData().inTeleporter = true
                            player:getData().teleporterLoop = false
                            currentPlayer = player
                            found = true
                        else
                            teleporter:getData().inTeleporter = false
                        end
                    end
                end

                for i, player in ipairs(misc.players) do
                    if player:getData().teleporterLoop == false then                       
                        if player:control("enter") == input.PRESSED and player.x > teleporter.x - 50 and player.x < teleporter.x + 50 and player.y > teleporter.y -50 and player.y < teleporter.y + 50 then
                            if not net.online or net.localPlayer == player then
                                if net.host then
                                    local cloverInstance = clover:create(teleporter.x, teleporter.y - 20)
                                    misc.director:set("spawn_boss", 1)
                                    misc.director:set("points", getTeleporterPoints()) -- Change this so it also scales with difficulty 
                                    teleporter:getData().activated = true
                                    teleporter:getData().inTeleporter = false
                                    teleporterPacket:sendAsHost(net.ALL, nil, teleporterState)
                                else
                                    teleporterPacket:sendAsClient(teleporter:get("active"))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

registercallback("onDraw", function()
    for i, teleporter in pairs(teleporters:findAll()) do
        if teleporter:getData().inTeleporter == true and teleporter:getData().activated == false then
            graphics.printColor("&w&Press &!&&y&'" .. input.getControlString("enter", currentPlayer)  .. "'&!&&w& to challenge the odds.&!&", teleporter.x - 80, teleporter.y - 80, graphics.FONT_DEFAULT)
        end
    end
end)


-- Respawn a command chest if the user using it dies, and be able to back out of opening one
local crateRespawn = true
local crateBackout = true
local activeCrates = {}
local crates = ParentObject.find("commandCrates", "Vanilla")

-- Starstorm rules
registercallback("postSelection", function()
    crateRespawn = Rule.getSetting(Rule.find("Crate Respawn"))
    crateBackout = Rule.getSetting(Rule.find("Crate Backout"))
end)

registercallback("onStageEntry", function()
    for i, player in ipairs(misc.players) do
        player:getData().crateActive = false
    end
    activeCrates = {}
end)


crateNetBackout = net.Packet("Crate Backout Sync", function(player, crateNet, crateType, crateX, crateY)

    local crate = crateNet:resolve()
    if crate then
        crate:set("active", 0)
        crate:delete()
    end

    player:set("activity", 0)
    player:set("activity_type", 0)

    if net.host then
        local newCrate = crateType:create(crateX, crateY)
        crateNetBackout:sendAsHost(net.EXCLUDE, player, crateNet, crateType, crateX, crateY)
    end
end)

registercallback("onStep", function()
    if crateRespawn or crateBackout then

        -- Check all crates to see if they are active and insert the crate and player into a table
        for i, crate in ipairs(crates:findMatchingOp("active", "==", 1)) do
            local player = Object.findInstance(crate:get("owner"))
            if player and player:getData().crateActive == false then
                table.insert(activeCrates, {["player"] = player, ["crate"] = crate:getObject(), ["crateX"] = crate.x, ["crateY"] = crate.y})
            end
        end

        -- Only set crateActive to true after looping through all crates
        for key, data in pairs(activeCrates) do
            if data.player then
                data.player:getData().crateActive = true
            end
        end

        -- If the player dies, create a new command crate of the same type
        if crateRespawn then
            for key, data in pairs(activeCrates) do
                if data.player:get("dead") == 1 then 

                    -- Crates are naturally synced, so only the host has to create a new one for it to work
                    if net.host then
                        data.crate:create(data.crateX, data.crateY)
                    end

                    activeCrates[key] = nil  
                else
                    if data.player:get("activity") ~= 95 then
                        activeCrates[key] = nil  
                    end
                end

            end
        end

        -- If the player jumps, delete the current crates and remake them
        if crateBackout then
            for key, data in pairs(activeCrates) do
                
                if data.player:control("jump") == input.PRESSED then

                    for i, crate in ipairs(crates:findMatchingOp("active", ">=", 1)) do
                        if Object.findInstance(crate:get("owner")) == data.player then

                            local oldPositionX = crate.x 
                            local oldPositionY = crate.y
                            
                            local crateNet = crate:getNetIdentity()

                            data.player:set("activity", 0)
                            data.player:set("activity_type", 0)

                            if net.host then
                                data.crate:create(oldPositionX, oldPositionY)
                                crateNetBackout:sendAsHost(net.ALL, nil, crateNet, data.crate, oldPositionX, oldPositionY)
                            else
                                crateNetBackout:sendAsClient(crateNet, data.crate, oldPositionX, oldPositionY)
                            end

                            crate:set("active", 0)
                            crate:delete()

                        end
                    end
                    data.player:getData().crateActive = false
                    activeCrates[key] = nil  
                else
                    if data.player:get("activity") ~= 95 then
                        data.player:getData().crateActive = false
                        activeCrates[key] = nil  
                    end
                end

            end

        end

        -- Can probaly get rid of a few of the earlier crateActive = false calls
        for i, player in ipairs(misc.players) do
            if player:get("activity") ~= 95 and player:getData().crateActive == true then
                player:getData().crateActive = false
            end
        end

    end
end)

--[[]
-- Teleporter crate stuff

local crateTeleporter = true

-- Starstorm rules
registercallback("postSelection", function()
    crateTeleporter = Rule.getSetting(Rule.find("Crate on Teleporter"))
end)


registercallback("onPlayerStep", function(player)
    if crateTeleporter then
        for i, teleporter in pairs(teleporters:findMatchingOp("active", "==", 1)) do
            if teleporter:get("time") < 1 then
                for i, crate in ipairs(crates:findAll()) do
                    if Object.findInstance(crate:get("owner")) == player then
                        teleporter:set("active", 0)
                    end
                end
            end
        end

        for i, teleporter in pairs(teleporters:findMatchingOp("active", "==", 4)) do
            for i, crate in ipairs(crates:findAll()) do
                if Object.findInstance(crate:get("owner")) == player then
                    teleporter:set("active", 3)
                    teleporter:set("locked", 0)
                end
            end
        end
    end

end)

--]]