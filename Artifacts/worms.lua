
------ worms.lua
---- Adds a new artifact which makes worms the only enemy that spawns, and all non overloading worms gain a random color

-- Creates a new artifact with the name Artifact of Worms
local artifact = Artifact.new("Worm")
-- Make the artifact be unlocked by default
artifact.unlocked = true

-- Set the artifact's loadout info
artifact.loadoutSprite = Sprite.load("/Artifacts/sprites/worm.png", 2, 18, 18)
artifact.loadoutText = "Worm Party."

local worm = Object.find("Worm", "Vanilla")

registercallback("onStep", function()
    if artifact.active then
        misc.director:set("points", 1000000)
        misc.director:set("card_choice", 7) -- 7 is the monstercard ID for worm
    end
end)

registercallback("onActorInit", function(actor)
    if artifact.active then
        -- Change color of non elite worms to be completely random
        if actor:getObject() == worm and actor:getElite() == nil then
            actor.blendColor = Color.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
        end
    end
end)