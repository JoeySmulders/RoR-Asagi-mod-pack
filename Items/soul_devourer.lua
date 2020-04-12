-- Soul_devourer.lua
-- Uncommon tier item that gives the player 1 extra damage every time they hit an enemy

local item = Item("Soul Devourer")

item.pickupText = "Hitting an enemy increases damage by 1, damage is lost when you take damage"

item.sprite = Sprite.load("Items/sprites/Soul_devourer", 1, 18, 15)

item:setTier("uncommon")

local damageCounter = 0

-- If player hits an enemy, increase their damage stat by 1
registercallback("onFire", function(bullet)
    local parent = bullet:getParent()

    if type(parent) == "PlayerInstance" then
        local count = parent:countItem(item)
        if count > 0 then
            damageCounter = damageCounter + count
            parent:set("damage", parent:get("damage") + count)
        end
    end
end)

-- If the player takes damage, remove damage gained by item
registercallback("onHit", function(bullet, hit, hitx, hity)
    if type(hit) == "PlayerInstance" then
        local count = hit:countItem(item)
        if count > 0 then
            hit:set("damage", hit:get("damage") - damageCounter)
            damageCounter = 0 
        end
    end
end)

item:setLog{
    group = "uncommon",
    description = "",
    story = "",
    destination = "",
    date = ""
}