-- blood_economy.lua
-- Uncommon tier item that makes the player drop an item on death

local item = Item("Blood Economy")

item.pickupText = "Spawn an Item when you die"

item.sprite = Sprite.load("Items/sprites/Blood_economy", 1, 18, 15)

item:setTier("uncommon")

-- TODO: make it spawn items on dio trigger?

-- Create an item on death
registercallback("onPlayerDeath", function(player)
    local count = player:countItem(item)

    if count > 0 then
        local location = math.random(-50, 50)
        local n = 0
        local xx = player.x + location
        while n < 50 and Stage.collidesPoint(xx, player.y) do
            xx = math.approach(xx, player.x, 1)
            n = n + 1
        end

        -- Stacking the item increases the chance of gold and medium chests by 1%
        if math.chance(count) then
            chest = obj.Chest5
        elseif math.chance(18 + count) then
            chest = obj.Chest2
        else
            chest = obj.Chest1
        end

        local ichest = chest:create(xx, player.y)
        ichest:set("cost", 0)
        misc.shakeScreen(5)

        -- insert multiplayer sync code 
    end
end)

item:setLog{
    group = "uncommon",
    description = "",
    story = "",
    destination = "",
    date = ""
}

