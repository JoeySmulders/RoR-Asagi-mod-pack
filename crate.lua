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
    if crate:isValid() then
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

-- Make sure the game knows they aren't still browsing the crate? Just to make sure it doesn't desync
crateExtraSync = net.Packet("Crate Extra Sync", function(player)
    player:set("activity", 0)
    player:set("activity_type", 0)

    if net.host then
        crateExtraSync:sendAsHost(net.EXCLUDE, player)
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
                if data.player and data.player:isValid() then
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
                else
                    -- Erase the table value and recreate the chest if the player doesn't exist anymore
                    if net.host then
                        data.crate:create(data.crateX, data.crateY)
                    end
                    activeCrates[key] = nil
                end

            end
        end

        -- If the player jumps, delete the current crates and remake them
        if crateBackout then
            for key, data in pairs(activeCrates) do
                
                if data.player:control("jump") == input.PRESSED then

                    for i, crate in ipairs(crates:findMatchingOp("active", ">=", 1)) do
                        if Object.findInstance(crate:get("owner")) == data.player then

                            -- Save the selection for the item you are hovering over when backing out (Disable it for release since it's not in public version of SS yet)
                            if modloader.checkMod("StarStorm") then
                                SSCrate.setSelection(data.player, crate, crate:get("selection"))
                            end

                            local oldPositionX = crate.x 
                            local oldPositionY = crate.y

                            data.player:set("activity", 0)
                            data.player:set("activity_type", 0)

                            if net.host then
                                data.crate:create(oldPositionX, oldPositionY)
                                crateNetBackout:sendAsHost(net.ALL, nil, crate:getNetIdentity(), data.crate, oldPositionX, oldPositionY)
                            else
                                crateNetBackout:sendAsClient(crate:getNetIdentity(), data.crate, oldPositionX, oldPositionY)
                            end

                            crate:set("active", 0)
                            crate:delete()

                        end
                    end

                    data.player:getData().crateActive = false
                    activeCrates[key] = nil  

                    -- Safety measure?
                    if net.host then
                        crateExtraSync:sendAsHost(net.ALL, nil)
                    else
                        crateExtraSync:sendAsClient()
                    end

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