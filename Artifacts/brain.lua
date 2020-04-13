
------ brain.lua
---- Adds a new artifact which makes all damage numbers appear larger

-- Creates a new artifact with the name Artifact of Brain
local artifact = Artifact.new("Brain")
-- Make the artifact be unlocked by default
artifact.unlocked = true

-- Set the artifact's loadout info
artifact.loadoutSprite = Sprite.load("/Artifacts/sprites/example.png", 2, 18, 18)
artifact.loadoutText = "To Be Fair, You Have To Have a Very High IQ to Enjoy Risk of Rain"

-- Increase the damage_fake value of every bullet
registercallback("onFire", function(bullet)
    if artifact.active then
        bullet:set("damage_fake", bullet:get("damage_fake") * (10e30 * (math.random()) + 1) ) -- Fake Damage variation
    end
end)
