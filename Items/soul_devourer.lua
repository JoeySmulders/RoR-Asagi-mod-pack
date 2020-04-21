-- Soul_devourer.lua
-- Uncommon tier item that gives the player 1 extra damage every time they hit an enemy

local item = Item("Soul Taker")

item.pickupText = "Hitting an enemy increases damage by 1, damage is lost when you take damage"

item.sprite = Sprite.load("Items/sprites/Soul_devourer", 1, 12, 11)
local sprMeter = Sprite.load("Items/sprites/soul_meter", 14, 7, 2)
item:setTier("uncommon")

-- Initialize damage counter for the item
item:addCallback("pickup", function(player)
    local count = player:countItem(item)

    if count == 1 then
        player:set("soul-devourer_counter", 0)
    end
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

registercallback("onPlayerDraw", function(player)
    local count = player:countItem(item)
    if count > 0 then
        local meterValue = (player:get("soul-devourer_counter") / 10) + 1
        graphics.drawImage{
            image = sprMeter, 
            x = player.x, 
            y = player.y - 27, 
            subimage = math.clamp(math.round(meterValue), 1, 14)
        }
        --graphics.printColor("&bl&" .. player:get("soul-devourer_counter") .. "&!&", player.x + 12, player.y - 27, graphics.FONT_DEFAULT)
    end
end)

item:setLog{
    group = "uncommon",
    description = "Hitting an enemy increases damage by 1, but the damage is lost when you take damage",
    story = "",
    destination = "",
    date = ""
}