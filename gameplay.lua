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

local function getTeleporterPoints()
    local newPoints = misc.director:get("points") + 1000 + (misc.director:get("stages_passed") * 500) + (#misc.players * 100)
    return newPoints
end

-- Sync teleporter challenge
teleporterPacket = net.Packet("Activate Teleporter Challenge", function(player, netTeleporter)
    local teleporter = netTeleporter:resolve()

    if teleporter then
        if net.host and teleporter:getData().activated == false then
            local cloverInstance = clover:create(teleporter.x, teleporter.y - 20)
            misc.director:set("spawn_boss", 1)
            misc.director:set("points", getTeleporterPoints()) -- Change this so it also scales with difficulty 
            teleporter:getData().activated = true
            teleporterPacket:sendAsHost(net.ALL, nil, netTeleporter)
        else
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
                                local netTeleporter = teleporter:getNetIdentity()
                                if net.host then
                                    local cloverInstance = clover:create(teleporter.x, teleporter.y - 20)
                                    misc.director:set("spawn_boss", 1)
                                    misc.director:set("points", getTeleporterPoints()) -- Change this so it also scales with difficulty 
                                    teleporter:getData().activated = true
                                    teleporter:getData().inTeleporter = false
                                    teleporterPacket:sendAsHost(net.ALL, nil, netTeleporter)
                                else
                                    teleporterPacket:sendAsClient(netTeleporter)
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