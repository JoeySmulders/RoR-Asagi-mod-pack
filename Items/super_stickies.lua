-- super_stickies.lua
-- Rare tier item that makes hits deal extra damage based on enemies max hp

local item = Item("Super Stickies")

item.pickupText = "5% chance on hit to attach 3 stickies that deal 500% damage"

item.sprite = Sprite.load("Items/sprites/super_sticky", 1, 14, 14)

item:setTier("rare")


registercallback("onHit", function(bullet, hit)
    local player = bullet:getParent()
    if type(player) == "PlayerInstance" then
        local count = player:countItem(item)

        if count > 0 then
          
        end
    end
end)

item:setLog{
    group = "rare",
    description = "5% chance on each hit to attach 3 stickies that deal 500% damage",
    story = "",
    destination = "",
    date = ""
}

