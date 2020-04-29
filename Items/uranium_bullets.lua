-- uranium_bullets.lua
-- Rare tier item that makes hits deal extra damage based on enemies max hp

local item = Item("Uranium Bullets")

item.pickupText = "Deal an extra 1% of enemy max hp per hit"

item.sprite = Sprite.load("Items/sprites/uranium_bullets", 1, 12, 13)

item:setTier("rare")

registercallback("preHit", function(bullet, hit)
    local has_no_proc = false

    if bullet:get("bullet_properties") then
        has_no_proc = bit.band(bullet:get("bullet_properties"), DAMAGER_NO_PROC) ~= 0
    end
    
    if not has_no_proc then
        local player = bullet:getParent()
        if type(player) == "PlayerInstance" then
            local count = player:countItem(item)

            if count > 0 then
                --local damageMultiplier = (bullet:get("damage") / player:get("damage"))
                local enemyHealth = hit:get("maxhp")

                --local extraDamage = (damageMultiplier / (110 - math.clamp(count * 10, 10, 60))) * enemyHealth
                local extraDamage = enemyHealth * (0.005 + (count * 0.005))

                --log(bullet:get("damage"), "original damage")

                bullet:set("damage", bullet:get("damage") + extraDamage)
                bullet:set("damage_fake", bullet:get("damage_fake") + extraDamage)

                --log(enemyHealth, "enemy max health")
                --log(bullet:get("damage"), "final damage dealt")
                --log(extraDamage, "added damage")
            end
        end
    end
end)

item:setLog{
    group = "rare",
    description = "Deal extra damage on each attack for 1% of enemy max hp",
    story = "",
    destination = "",
    date = ""
}

