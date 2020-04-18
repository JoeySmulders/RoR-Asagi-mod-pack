-- Soul_devourer.lua
-- Uncommon tier item that gives the player 1 extra damage every time they hit an enemy

local item = Item("Soul Devourer")

item.pickupText = "Hitting an enemy increases damage by 1, damage is lost when you take damage"

item.sprite = Sprite.load("Items/sprites/Soul_devourer", 1, 18, 15)

item:setTier("uncommon")

-- Initialize damage counter for the item
item:addCallback("pickup", function(player)
	player:set("soul-devourer_counter", 0)
end)

registercallback("onHit", function(bullet, hit)
    local parent = bullet:getParent()
    -- If player hits an enemy, increase their damage stat by 1
    if type(parent) == "PlayerInstance" then
        local count = parent:countItem(item)
        if count > 0 then
            parent:set("soul-devourer_counter", parent:get("soul-devourer_counter") + count)
            parent:set("damage", parent:get("damage") + count)
        end
    end
    -- If the player takes damage, remove damage gained by item
    if type(hit) == "PlayerInstance" then
        local count = hit:countItem(item)
        if count > 0 then
            hit:set("damage", hit:get("damage") - hit:get("soul-devourer_counter"))
            hit:set("soul-devourer_counter", 0)
        end
    end
end)

item:setLog{
    group = "uncommon",
    description = "Hitting an enemy increases damage by 1, but the damage is lost when you take damage",
    story = "",
    destination = "",
    date = ""
}