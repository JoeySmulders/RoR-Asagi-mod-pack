-- see-through_log.lua
-- Common tier item that shoots out 9 stars around the player every 10 seconds

local item = Item("See-through log")

item.pickupText = "Shoot out ninja stars every 10 seconds"

item.sprite = Sprite.load("Items/sprites/See-through_log", 1, 18, 15)

item:setTier("common")

-- Star Object
local objStar = Object.new("Star")
objStar.sprite = Sprite.load("Star", "Items/sprites/star", 1, 5, 5)
objStar.depth = 1
local enemies = pobj.enemies
local rotationSpeed = 5

-- Star creation and variables
objStar:addCallback("create", function(objStar)
	local objStarAc = objStar:getAccessor()
	objStarAc.life = 4 * 60
	objStarAc.speed = 2
	objStarAc.size = 1
	objStarAc.damage = 0.5
	objStar.spriteSpeed = 0.25
end)

-- Star function called every step
objStar:addCallback("step", function(objStar)
	local objStarAc = objStar:getAccessor()
	local parent = Object.findInstance(objStarAc.parent)

    local enemy = enemies:findNearest(objStar.x, objStar.y)
    
    objStar.angle = objStar.angle + rotationSpeed

	-- Destroy the Star when lifetime reaches 0
	if objStarAc.life == 0 or (enemy and objStar:collidesWith(enemy, objStar.x, objStar.y)) then
		parent:fireExplosion(objStar.x, objStar.y, (objStar.sprite.width * 3) / 19, (objStar.sprite.height * 3) / 4, objStarAc.damage, nil, nil)
		objStar:destroy()
	else
		objStarAc.life = objStarAc.life - 1
	end

end)

-- Setup the star timer when picking up the item
item:addCallback("pickup", function(player)
	player:set("log-star_timer", 10 * 60)
end)

registercallback("onPlayerStep", function(player)
    local count = player:countItem(item)
    local direction = 0

    if count > 0 then
        if player:get("log-star_timer") <= 0 then
            for i = 1, 8, 1 do
                local star = objStar:create(player.x, player.y)
                star:set("direction", direction)
                star:set("parent", player.id)
                direction = direction + 45
            end
            -- Stacking item reduces cooldown by 1 second, to 1 second max.
            player:set("log-star_timer", (11 - count) * 60)
        end

        player:set("log-star_timer", player:get("log-star_timer") - 1)
    end
end)

item:setLog{
    group = "common",
    description = "",
    story = "",
    destination = "",
    date = ""
}