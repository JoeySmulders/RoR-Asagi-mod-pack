------ luck.lua
---- Adds a new artifact that makes teleporters give out a clover to the person activating them

-- Creates a new artifact with the name Artifact of Pain
local artifact = Artifact.new("Luck")
-- Make the artifact be unlocked by default
artifact.unlocked = true

-- Set the artifact's loadout info
artifact.loadoutSprite = Sprite.load("/Artifacts/sprites/luck.png", 2, 18, 17)
artifact.loadoutText = "Teleporters gift a clover on use."

local clover = Object.find("Clover", "Vanilla")
local teleporters = Object.find("Teleporter", "Vanilla")
local activated = false

-- TODO: make this more interesting lol
-- TODO: maybe give it a downside like giving enemies get 10% dodge chance

registercallback("onStageEntry", function()
    activated = false
end)

registercallback("onStep", function()
    if artifact.active and activated == false then
        for i, teleporter in pairs(teleporters:findAll()) do
            if teleporter:get("active") == 1 then
                local cloverInstance = clover:create(teleporter.x, teleporter.y - 20)
                activated = true
            end
        end
    end
end)