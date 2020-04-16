------ turbo.lua
---- Adds a new artifact which makes the game 20% faster (for the most part, doesn't look like you can change timer speed, and jump height is weird)

-- Creates a new artifact with the name Artifact of Turbo
local artifact = Artifact.new("Turbo")
-- Make the artifact be unlocked by default
artifact.unlocked = true

-- Set the artifact's loadout info
artifact.loadoutSprite = Sprite.load("/Artifacts/sprites/turbo.png", 2, 18, 18)
artifact.loadoutText = "Game is 20% faster"

local speedMultiplier = 1.2

-- Make the timer go faster
registercallback("onStep", function(actor)
    if artifact.active then
        if misc.director:getAlarm(0) <= (60 - ( 60/ speedMultiplier)) then
            misc.director:setAlarm(0, 1)
        end
    end
end)

-- Change actor variables to be faster
registercallback("onActorInit", function(actor)
    if artifact.active then
        actor:set("attack_speed", actor:get("attack_speed") * speedMultiplier) 
        --actor.spriteSpeed = actor.spriteSpeed * speedMultiplier 
        
        actor:set("pHmax", actor:get("pHmax") * speedMultiplier)
        
        if actor:get("pVMax") then
            actor:set("pVmax", actor:get("pVmax") * speedMultiplier) -- This one is weird and doesn't work that well when increased
        end

        actor:set("speed", actor:get("speed") * speedMultiplier)

        if type(actor) == "PlayerInstance" then
            actor:set("hp_regen", actor:get("hp_regen") * speedMultiplier)
            actor:set("pGravity1", actor:get("pGravity1") * speedMultiplier)
        end
    end
end)
