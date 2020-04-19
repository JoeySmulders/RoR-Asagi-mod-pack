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

-- TODO: make teleporter timer go faster
-- TODO: make cooldowns go faster

-- Starstorm rules
registercallback("postSelection", function()
    if artifact.active then
        speedMultiplier = Rule.getSetting(Rule.find("Turbo Artifact speed"))
        for i, player in ipairs(misc.players) do
            turbo(player)
        end
    end
end)

-- Make the timer go faster
registercallback("onStep", function()
    if artifact.active then
        if misc.director:getAlarm(0) <= (60 - ( 60 / speedMultiplier)) then
            misc.director:setAlarm(0, 1)
        end
        -- Forced to set player speed in onStep due to weird init stuff
        for i, player in ipairs(misc.players) do
            if not player:getData().speedSet and player:get("pHmax") ~= 0 then
                player:set("pHmax", player:get("pHmax") * speedMultiplier)
                --player:set("pVmax", player:get("pVmax") * speedMultiplier)
                player:getData().speedSet = true
            end
        end
    end
end)

-- Change actor variables to be faster
registercallback("onActorInit", function(actor)
    if artifact.active then
        -- If starstorm isn't loaded, then apply this to all actors, otherwise apply players through postSelection
        if type(actor) ~= "PlayerInstance" or not modloader.checkMod("StarStorm") then
            turbo(actor)
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
    --actor:set("pGravity1", actor:get("pGravity1") * speedMultiplier) -- Changing gravity has the wrong effect and doesn't actually speed up anything, just makes you jump lower
    --actor:set("pGravity2", actor:get("pGravity2") * speedMultiplier)
end