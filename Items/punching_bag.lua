-- punching_bag.lua
-- Rare tier item that reduces damage taken by 80% when standing absolutely still and not doing anything

local item = Item("Punching Bag")

item.pickupText = "Reduce damage taken by 80% when standing perfectly still"

item.sprite = Sprite.load("Items/sprites/Punching_bag", 1, 18, 15)

item:setTier("rare")

-- Just before the player takes damage, check if they are standing perfectly still and then reduce the damage by 80%
registercallback("preHit", function(bullet, hit)
    if type(hit) == "PlayerInstance" then
        local count = hit:countItem(item)

        if count > 0 then
            if hit:get("pHspeed") == 0 and hit:get("pVspeed") == 0 and hit:get("activity") == 0 then -- Maybe just change this item to work like fungus?
                bullet:set("damage", bullet:get("damage") * 0.2)
                bullet:set("damage_fake", bullet:get("damage_fake") * 0.2)
            end
        end
    end
end)

item:setLog{
    group = "rare",
    description = "",
    story = "",
    destination = "",
    date = ""
}

