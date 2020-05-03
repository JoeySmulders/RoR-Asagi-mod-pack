-- if teleporter is in active state 1, let the player activate it again to spawn another boss/more mobs and gain a clover

local clover = Object.find("Clover", "Vanilla")
local teleporters = Object.find("Teleporter", "Vanilla")
local activated = false
local teleportEnabled = true
local foundTeleporter
local playerObject = ParentObject.find("P", "Vanilla")
local currentPlayer
local greenCrateInstance = Object.find("Artifact8Box2")
local redCrateInstance = Object.find("Artifact8Box3")
local whiteFlash = Object.find("WhiteFlash")

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
    local newPoints = misc.director:get("points") + 1000 + (misc.director:get("stages_passed") * 500) + (#misc.players * 100) -- Change this so it also scales with difficulty and more with players
    return newPoints
end

-- Flash the screen
local function Flash(color)
	local flash = whiteFlash:create(0, 0)
	flash.blendColor = color
	flash.alpha = 0.8
	flash:set("rate", 0.01)
end

-- Sync teleporter challenge
teleporterPacket = net.Packet("Activate Teleporter Challenge", function(player, netTeleporter)
    if isa(netTeleporter, "number") then
        log(netTeleporter .. " Teleporter number?")
    else
        local teleporter = netTeleporter:resolve()

        if teleporter:isValid() then
            if net.host and teleporter:getData().activated == false then
                if teleporter:get("isBig") then
                    ExtraDifficulty.set(ExtraDifficulty.get() + 2)
                    redCrateInstance:create(teleporter.x, teleporter.y)
                    Flash(Color.RED)
                else
                    local cloverInstance = greenCrateInstance:create(teleporter.x, teleporter.y)
                    Flash(Color.BLACK)
                end    
                misc.director:set("spawn_boss", 1)
                misc.director:set("points", getTeleporterPoints()) 
                teleporter:getData().activated = true
                teleporterPacket:sendAsHost(net.ALL, nil, netTeleporter)
            else
                if teleporter:get("isBig") then
                    Flash(Color.RED)
                    ExtraDifficulty.set(ExtraDifficulty.get() + 2)
                else
                    Flash(Color.BLACK)
                end
                teleporter:getData().activated = true
                teleporter:getData().inTeleporter = false
            end
        end 
    end
end)

-- TODO: rewrite this stuff to be a bit more logical
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
                                    if teleporter:get("isBig") then
                                        ExtraDifficulty.set(ExtraDifficulty.get() + 2)
                                        redCrateInstance:create(teleporter.x, teleporter.y)
                                        Flash(Color.RED)
                                    else
                                        local cloverInstance = greenCrateInstance:create(teleporter.x, teleporter.y)
                                        Flash(Color.BLACK)
                                    end                            
                                    misc.director:set("spawn_boss", 1)
                                    misc.director:set("points", getTeleporterPoints()) -- Change this so it also scales with difficulty 
                                    teleporter:getData().activated = true
                                    teleporter:getData().inTeleporter = false
                                    teleporterPacket:sendAsHost(net.ALL, nil, netTeleporter)
                                else
                                    teleporterPacket:sendAsClient(netTeleporter)
                                end
                                player:getData().teleporterLoop = true
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
            if teleporter:get("isBig") == 1 then
                graphics.printColor("&w&Press &!&&y&'" .. input.getControlString("enter", currentPlayer)  .. "'&!&&w& to die.&!&", teleporter.x - 40, teleporter.y - 80, graphics.FONT_DEFAULT)
            else
                graphics.printColor("&w&Press &!&&y&'" .. input.getControlString("enter", currentPlayer)  .. "'&!&&w& to challenge the odds.&!&", teleporter.x - 80, teleporter.y - 80, graphics.FONT_DEFAULT)
            end
        end
    end
end)