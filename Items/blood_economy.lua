-- blood_economy.lua
-- Uncommon tier item that makes the player drop an item on death

local item = Item("Blood Economy")

item.pickupText = "Gain 5% of damage dealt or taken as gold"

item.sprite = Sprite.load("Items/sprites/Blood_economy", 1, 12, 13)

item:setTier("uncommon")

-- TODO: make it spawn items on dio trigger?

-- Create an item on death
registercallback("onPlayerDeath", function(player)
    if net.host then
        local count = player:countItem(item)

        if count > 0 then
            local location = math.random(-25, 25)
            local n = 0
            local xx = player.x + location
            while n < 50 and Stage.collidesPoint(xx, player.y) do
                xx = math.approach(xx, player.x, 1)
                n = n + 1
            end

            -- Stacking the item increases the chance of gold and medium chests by 10%
            if math.chance((10 * count) - 9) then
                chest = Object.find("Chest5")
            elseif math.chance(9 + (10 * count)) then
                chest = Object.find("Chest2")
            else
                chest = Object.find("Chest1")
            end

            local ichest = chest:create(xx, player.y)
            ichest:set("cost", 0)
            misc.shakeScreen(5)

        end
        
    end

end)


registercallback("preHit", function(bullet, hit)
local player = bullet:getParent()
local count = 0

    if type(player) == "PlayerInstance" then
        count = player:countItem(item)

        if count > 0 then
            createGold(player, bullet, hit, count)
        end
    else 
        if type(hit) == "PlayerInstance" then
            count = hit:countItem(item)

            if count > 0 then
                createGold(hit, bullet, hit, count)
            end
        end
    end
end)

function createGold (player, bullet, hit, count)
    if hit:get("hp") > 0 then
        bullet:set("gold_on_hit", math.clamp(math.sqrt(bullet:get("damage") * count * 0.05), 1, math.sqrt(hit:get("hp")))) -- gold_on_hit produces the number squared amount of coins
    end
end

item:setLog{
    group = "uncommon",
    description = "Gain 5% of damage dealt or taken as gold. Dying spawns an item chest",
    story = "",
    destination = "",
    date = ""
}

