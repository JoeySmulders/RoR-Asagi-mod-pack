-- lycoris.lua
-- Rare tier item that spawns flower traps on killed enemies

local item = Item("Radiant Flower")

item.pickupText = "Killed enemies sprout deadly flowers"

item.sprite = Sprite.load("Items/sprites/lycoris", 1, 12, 10)

item:setTier("rare")

-- Plant Object
local objPlant = Object.new("Lycoris")
objPlant.sprite = Sprite.load("Plant", "Items/sprites/plant", 4, 7, 6)
objPlant.depth = 1

-- Star creation and variables
objPlant:addCallback("create", function(objPlant)
	local objPlantAc = objPlant:getAccessor()
	objPlantAc.life = 120 * 60
	objPlantAc.speed = 0
	objPlantAc.size = 1
	objPlant.spriteSpeed = 0.1
end)

objPlant:addCallback("destroy", function(objPlant)
    objPlantAc = objPlant:getAccessor()
    local parent = Object.findInstance(objPlantAc.parent)

    -- Set the parent damage and stun to 1 then revert it back to their actual damage to get around needing an actorInstance to fire an explosion I guess
    local revertDamage = parent:get("damage")
    parent:set("damage", 1)
    parent:set("stun", 1.33)
    parent:fireExplosion(objPlant.x, objPlant.y, (objPlant.sprite.width) / 19, (objPlant.sprite.height) / 4, objPlantAc.damage, nil, nil, DAMAGER_NO_PROC + DAMAGER_NO_RECALC)
    parent:set("damage", revertDamage)
    parent:set("stun", 0)
end)

objPlant:addCallback("step", function(objPlant)
    -- Stop the animation when it reaches the last frame
    if objPlant.spriteSpeed ~= 0 then
        if math.floor(objPlant.subimage) == objPlant.sprite.frames then
            objPlant.spriteSpeed = 0
        end
    end

    local enemy = enemies:findNearest(objPlant.x, objPlant.y)

    -- Destroy the plant when it collides with an enemy and deal damage
    if enemy and objPlant:collidesWith(enemy, objPlant.x, objPlant.y) then
        objPlant:destroy()
    end
end)


registercallback("onNPCDeath", function(npc)
    if npc then
        -- Get all the damage from all players who have the item
        local totalDamage = 0
        local finalPlayer = nil
        for i, player in ipairs(misc.players) do
            if player:get("dead") == 0 then
                local count = player:countItem(item)

                if count > 0 then
                    totalDamage = totalDamage + player:get("damage") * (3 + (2 * count))
                    finalPlayer = player
                end
            end
        end

        if totalDamage > 0 and finalPlayer ~= nil then
            local plant = objPlant:create(npc.x, npc.y)
            local yOffset = 1

            -- Check if there is ground 100 pixels below the enemy, otherwise delete the plant
            while not plant:collidesMap(plant.x, plant.y + yOffset) do
                yOffset = yOffset + 1
                if yOffset > 100 then
                    break
                end
            end

            if yOffset < 100 then 
                plant.y = plant.y + yOffset - 1

                plant:set("damage", totalDamage)
                plant:set("parent", finalPlayer.id)
            else
                plant:delete()
            end
        end
    end

end)

item:setLog{
    group = "rare",
    description = "Killed enemies sprout deadly flowers that deal 500% damage and stun for 2 seconds",
    story = "",
    destination = "",
    date = ""
}

