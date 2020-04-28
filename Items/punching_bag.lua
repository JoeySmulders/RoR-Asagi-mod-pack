-- punching_bag.lua
-- Rare tier item that reduces damage taken by 50% when standing absolutely still and not doing anything

local item = Item("Punching Bag")

item.pickupText = "Reduce damage taken by 50% when standing perfectly still"

item.sprite = Sprite.load("Items/sprites/Punching_bag", 1, 12, 13)

item:setTier("rare")

-- Just before the player takes damage, check if they are standing perfectly still and then reduce the damage by 50
registercallback("preHit", function(bullet, hit)
    if type(hit) == "PlayerInstance" then
        local count = hit:countItem(item)

        if count > 0 then
            if hit:get("pHspeed") == 0 and hit:get("pVspeed") == 0 and hit:get("activity") == 0 then
                bullet:set("damage", bullet:get("damage") * (0.55 - (math.clamp(count, 1, 4) * 0.05)))
                bullet:set("damage_fake", bullet:get("damage_fake") * (0.55 - (math.clamp(count, 1, 4) * 0.05)))
            end
        end
    end
end)

item:setLog{
    group = "rare",
    description = "Reduce damage taken by 50% when standing perfectly still",
    story = "",
    destination = "",
    date = ""
}

