------ turbo.lua
---- Adds a new artifact which makes the game 20% faster (for the most part, doesn't look like you can change timer speed, and jump height is weird)

-- Creates a new artifact with the name Artifact of Turbo
local artifact = Artifact.new("Turbo")
-- Make the artifact be unlocked by default
artifact.unlocked = true

-- Set the artifact's loadout info
artifact.loadoutSprite = Sprite.load("/Artifacts/sprites/turbo.png", 2, 18, 18)
artifact.loadoutText = "Everything is 20% faster."

local speedMultiplier = 1.2

-- Starstorm rules
registercallback("postSelection", function()
    if artifact.active then
        speedMultiplier = Rule.getSetting(Rule.find("Turbo Artifact speed"))
        for i, player in ipairs(misc.players) do
            turbo(player)
            player:getData().speedUpTimer = {0,0,0,0,0}
        end
    end
end)

local teleporters = Object.find("Teleporter")

-- Make the timer go faster
registercallback("onStep", function()
    if artifact.active then
        if misc.director:getAlarm(0) <= (60 - ( 60 / speedMultiplier)) then
            misc.director:setAlarm(0, 1)
        end
        
        for i, player in ipairs(misc.players) do
            if player:getData().speedUpTimer then
                -- TODO: skill cooldowns don't go faster than 2x speed
                -- Speed up skill cooldowns (but not z skill) (alarms only work in ints, so use a counting system)
                for i = 3, 5, 1 do
                    if player:getAlarm(i) > 0 then
                        player:getData().speedUpTimer[i] = player:getData().speedUpTimer[i] + (speedMultiplier - 1)
                        if player:getData().speedUpTimer[i] >= 1 then
                            player:setAlarm(i, player:getAlarm(i) - 1)
                            player:getData().speedUpTimer[i] = 0 
                        end
                        if player:getData().speedUpTimer[i] <= -1 then
                            player:setAlarm(i, player:getAlarm(i) + 1) 
                            player:getData().speedUpTimer[i] = 0
                        end
                    end
                end
            end
        end

        for i, teleporter in pairs(teleporters:findMatchingOp("active", "==", 1)) do
            teleporter:set("time", teleporter:get("time") + speedMultiplier - 1)
        end
    end
end)

-- Change actor variables to be faster
registercallback("onActorInit", function(actor)
    if artifact.active then
        -- If starstorm isn't loaded, then apply this to all actors, otherwise apply players through postSelection
        if type(actor) ~= "PlayerInstance" or not modloader.checkMod("StarStorm") then
            turbo(actor)
            actor:getData().speedUpTimer = {0,0,0,0,0}
            
        end
    end
end)

-- Function that changes variables for actors
function turbo (actor)
    actor:set("attack_speed", actor:get("attack_speed") * speedMultiplier) 
    --actor.spriteSpeed = actor.spriteSpeed * speedMultiplier 
    actor:set("pHmax", actor:get("pHmax") * speedMultiplier) -- For some reasons this is set to fucking 0 during postSelection for players...

    actor:set("speed", actor:get("speed") * speedMultiplier)
    actor:set("hp_regen", actor:get("hp_regen") * speedMultiplier)

    --actor:set("pGravity1", actor:get("pGravity1") * speedMultiplier) -- Changing gravity and pVmax values by the speedmultiplier doesn't work well
    --actor:set("pGravity2", actor:get("pGravity2") * speedMultiplier)
end