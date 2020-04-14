-- broken_lan_cable.lua
-- Common tier item that delays the damage a player takes by 2 seconds

local item = Item("Broken LAN cable")

item.pickupText = "Delay damage taken by 2 seconds"

item.sprite = Sprite.load("Items/sprites/LAN_cable", 1, 18, 15)

item:setTier("common")

local damageTable = {} -- For the love of god replace this with a getData setup jesus fuck

registercallback("onHit", function(bullet, hit)
    -- If the player takes damage, delay it
    if type(hit) == "PlayerInstance" then
        local count = hit:countItem(item)
        if count > 0 then
            if hit:get("shield") > 0 then
                hit:set("shield", hit:get("shield") + bullet:get("damage"))
            else
                hit:set("hp", hit:get("hp") + bullet:get("damage"))
            end

            local timer = (1 + count) * 60 -- Stacking item increases delay by 1 second per item

            damageTable[timer] = bullet:get("damage")
        end
    end
end)

registercallback("onPlayerStep", function(player)
    local count = player:countItem(item)

    local tempTable = {}

    local tableCount = 0
    for i, value in pairs(damageTable) do
        tableCount = tableCount + 1
    end

    -- TODO: Change it so it only checks once a second for these values instead of every fucking frame (hard to do with current table setup)
    if count > 0 then
        if tableCount > 0 then
            for timer, value in pairs(damageTable) do
                if timer <= 0 then
                    if player:get("shield") > 0 then
                        player:set("shield", player:get("shield") - value)
                        player:set("shield_cooldown", 7 * 60)
                        misc.damage(value, player.x, player.y, false, Color.ORANGE)
                    else
                        player:set("hp", player:get("hp") - value)
                        player:set("shield_cooldown", 7 * 60)
                        misc.damage(value, player.x, player.y - 10, false, Color.ORANGE)
                    end
                else
                    timer = timer - 1
                    tempTable[timer] = value
                end
            end

            damageTable = tempTable
        end
    end
end)

-- clean up the damage table on death so they don't store it into the next game or level
registercallback("onPlayerDeath", function(player)
    damageTable = {}
end)

item:setLog{
    group = "common",
    description = "",
    story = "",
    destination = "",
    date = ""
}