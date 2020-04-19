
------ spiter.lua
---- Adds a new artifact which makes more spite balls appear

-- Creates a new artifact with the name Artifact of Spiteful
local artifact = Artifact.new("Spiteful")
-- Make the artifact be unlocked by default
artifact.unlocked = true

-- Set the artifact's loadout info
artifact.loadoutSprite = Sprite.load("/Artifacts/sprites/spite2.png", 2, 18, 18)
artifact.loadoutText = "Enemies explode on hit."

local spite = Artifact.find("Spite", "Vanilla")
local spiteBombs = Object.find("EfGrenadeEnemy", "Vanilla")

local onhitLoop = 1
local bounce = true
local bounceAmount = 1
local playerDeath = 50

-- Starstorm rules
registercallback("postSelection", function()
    onhitLoop = Rule.getSetting(Rule.find("Spiteful on hit"))
    bounce = Rule.getSetting(Rule.find("Spiteful on bounce"))
    bounceAmount = Rule.getSetting(Rule.find("Amount generated on bounce"))
    playerDeath = Rule.getSetting(Rule.find("Player death creates spite"))
end)

-- Everytime ANY actor gets hit with damage they create a spite ball.
registercallback("onHit", function(damager, hit, x, y)
    if artifact.active then
        for i = 1, onhitLoop, 1 do
            local extraSpite = spiteBombs:create(x, y)
            extraSpite:getData().noReplicate = true
            extraSpite:set("team", hit:get("team"))
        end
    end
end)

-- Drop 50 friendly spite balls on player death
registercallback("onPlayerDeath", function(player)
    if artifact.active then
        for i = 1, playerDeath, 1 do
            local extraSpite = spiteBombs:create(player.x, player.y)
            extraSpite:getData().noReplicate = true
            extraSpite:set("team", player:get("team"))
        end
    end
end)

-- If both spite and spiteful are active at the same time, create many more spite balls
registercallback("onStep", function()
    if bounce then
        if artifact.active and spite.active then
            for i, instance in ipairs(spiteBombs:findAll()) do
                if instance:getData().noReplicate ~= true then
                    if instance:collidesMap(instance.x, instance.y + 4) then
                        instance:getData().bounced = true
                    end
                    if instance:getData().bounced == true and not instance:collidesMap(instance.x, instance.y + 4) then
                        for i = 1, bounceAmount, 1 do
                            local extraSpite = spiteBombs:create(instance.x, instance.y)
                            extraSpite:getData().noReplicate = true
                            instance:getData().bounced = false
                        end

                    end
                end
                
            end
        end
    end
    
end)