-- fan_blades.lua
-- Uncommon tier item that makes the player shoot out a fan of blades in a 45 degree arc when using their Z skill

local item = Item("Fan of Blades")

item.pickupText = "25% on hit to launch a blade that deals more damage the more blades have hit the enemy"

item.sprite = Sprite.load("Items/sprites/knive_blade", 1, 8, 14)

item:setTier("uncommon")

-- Knive Object
local objKnive = Object.new("Knive")
objKnive.sprite = Sprite.load("Knive", "Items/sprites/knive", 1, 3, 8)
objKnive.depth = -99
local movementSpeed = 8
local rotationSpeed = -0.2

-- Star creation and variables
objKnive:addCallback("create", function(objKnive)
	local objKniveAc = objKnive:getAccessor()
	objKniveAc.life = 10 * 60
	objKniveAc.speed = 0
	objKniveAc.size = 1
	objKniveAc.damage = 0.25
    objKnive.spriteSpeed = 0.25
end)

objKnive:addCallback("destroy", function(objKnive)
    local objKniveAc = objKnive:getAccessor()
    local parent = Object.findInstance(objKniveAc.parent)
    local target = objKnive:getData().target

    if parent:isValid() and objKnive:getData().explode == true then
        parent:fireExplosion(objKnive.x, objKnive.y, (objKnive.sprite.width * 3) / 19, (objKnive.sprite.height * 3) / 4, objKniveAc.damage * target:getData().kniveMark , nil, nil, DAMAGER_NO_PROC)
        target:getData().kniveMark = target:getData().kniveMark + 1
    end
end)

-- Knive function called every step
objKnive:addCallback("step", function(objKnive)
    local objKniveAc = objKnive:getAccessor()

    -- Destroy the Knive when colliding with an enemy
    if objKnive:isValid() and objKnive:getData().target:isValid() and objKnive:collidesWith(objKnive:getData().target, objKnive.x, objKnive.y) and objKnive:getData().initialTimer <= 0 then
        objKnive:getData().explode = true
        objKnive:destroy()
    end

    --TODO: See if doing the initial goalAngle calculation only 
    if objKnive:isValid() and objKnive:getData().target:isValid() then
        mathX = objKnive:getData().target.x - objKnive.x
        mathY = objKnive:getData().target.y	- objKnive.y 

        local goalAngle = -math.atan2(mathY, mathX)

        goalAngle = math.deg(goalAngle)
        goalAngle = goalAngle - 90 -- For some reason

        local angleDiff = angleDif(objKnive.angle, goalAngle) -- Neik approved migraine medicine

        objKnive.angle = objKnive.angle + (angleDiff) * rotationSpeed

        -- Move forward in the direction the knive is facing
        local angle = math.rad(objKnive.angle)
        objKnive.x = objKnive.x + math.sin(angle) * -movementSpeed
        objKnive.y = objKnive.y + math.cos(angle) * -movementSpeed

    elseif objKnive:isValid() then

        objKnive:getData().explode = false
        objKnive:destroy()
    
    end

    if objKnive:isValid() then
        if objKniveAc.life == 0 then
            objKnive:getData().explode = false
            objKnive:destroy()
	    else
            objKniveAc.life = objKniveAc.life - 1
        end
        if objKnive:getData().initialTimer > 0 then
            objKnive:getData().initialTimer = objKnive:getData().initialTimer - 1
        end
    end

end)


registercallback("preHit", function(bullet, hit)
    local player = bullet:getParent()
    local count = 0
    local has_no_proc = false

    if bullet:get("bullet_properties") then
        has_no_proc = bit.band(bullet:get("bullet_properties"), DAMAGER_NO_PROC) ~= 0
    end
    
    if not has_no_proc then
        if type(player) == "PlayerInstance" then
            count = player:countItem(item)

            if count > 0 then
                if math.chance(25) then -- TODO: SYNC THIS
                    local knive = objKnive:create(player.x, player.y)
                    knive:set("parent", player.id)
                    knive:getData().initialTimer = 10

                    if hit:getData().kniveMark == nil then
                        hit:getData().kniveMark = count + 3
                    end

                    knive:getData().target = hit

                    -- This doesn't need to be synced?
                    if math.chance(50) then 
                        knive.angle = 180
                    else
                        knive.angle = 0
                    end
                
                end
            end
        end
    end

end)

item:setLog{
    group = "uncommon",
    description = "25% on hit to launch a blade at the hit enemy. The blade deals 100% + 25% for each prior blade that hit the target",
    story = "",
    destination = "",
    date = ""
}

