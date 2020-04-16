
------ pain.lua
---- Adds a new artifact which makes all players and enemies have a max hp of 1, while disabling all other forms of damage resistance except dio's

-- Creates a new artifact with the name Artifact of Pain
local artifact = Artifact.new("Pain")
-- Make the artifact be unlocked by default
artifact.unlocked = true

-- Set the artifact's loadout info
artifact.loadoutSprite = Sprite.load("/Artifacts/sprites/pain.png", 2, 18, 18)
artifact.loadoutText = "Health is 1"

local glass = Artifact.find("Glass", "Vanilla")

-- Player will always be at 1 max hp
registercallback("onPlayerStep", function(player)
    if artifact.active then
        player:set("maxhp", 1)
        player:set("maxshield", 0)
        player:set("scarf", 0)
        player:set("armor", 0)
    end
end)

-- Enemies will spawn with 1 max hp
registercallback("onActorInit", function(actor)
    -- If both pain and glass are on at the same time, don't reduce enemy hp
    if artifact.active and not glass.active then
        actor:set("hp", 1)
        actor:set("maxhp", 1)
    end
end)