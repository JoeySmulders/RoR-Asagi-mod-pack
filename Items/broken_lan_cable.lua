-- broken_lan_cable.lua
-- Common tier item that delays the damage a player takes by 2 seconds

local item = Item("Broken LAN cable")

item.pickupText = "Delay damage taken by 1 seconds and reduce it by 10%"

item.sprite = Sprite.load("Items/sprites/LAN_cable", 1, 12, 12)

item:setTier("common")

-- Initialize damage table
item:addCallback("pickup", function(player)
    local count = player:countItem(item) 
    if count == 1 then
        player:getData().damageTable = {}
        player:getData().LANtimer = 60
    end
end)

-- Revert damage done on hit and store the damage in a table with a timer
registercallback("onHit", function(bullet, hit)
    -- If the player takes damage, delay it
    if type(hit) == "PlayerInstance" then
        local count = hit:countItem(item)
        if count > 0 then
            count = math.clamp(count, 1, 6)
            
            -- Apply armor reduction
            local realDamage = bullet:get("damage") * (1 - (hit:get("armor") / (hit:get("armor") + 100)))

            if hit:get("shield") > 0 then
                hit:set("shield", hit:get("shield") + realDamage)
            else
                hit:set("hp", hit:get("hp") + realDamage)
            end

            local timer = count -- Stacking item increases delay by 1 second per item
            local reducedDamage = realDamage * (0.9 - (0.02 * (count - 1))) -- Reduce the damage before storing it

            table.insert(hit:getData().damageTable, {["timer"] = timer, ["damage"] = realDamage})
        end
    end
end)

-- Every second, check the damage values to see which should be applied
registercallback("onPlayerStep", function(player)
    local count = player:countItem(item)

    if count > 0 then
        
        if player:getData().LANtimer <= 0 then

            if #player:getData().damageTable > 0 then
                for i, data in ipairs(player:getData().damageTable) do
                    if data.timer <= 0 then
                        if player:get("invincible") == 0 then
                            if player:get("shield") > 0 then
                                player:set("shield", player:get("shield") - data.damage)
                                player:set("shield_cooldown", 7 * 60)
                                misc.damage(data.damage, player.x, player.y, false, Color.ORANGE)
                            else
                                player:set("hp", player:get("hp") - data.damage)
                                player:set("shield_cooldown", 7 * 60)
                                misc.damage(data.damage, player.x, player.y - 10, false, Color.ORANGE)
                            end
                        end
                        table.remove(player:getData().damageTable, i)
                        --break -- Maybe stop the loop so you don't do multiple damage instances in one frame?
                    else
                        data.timer = data.timer - 1
                    end
                end
            end

            player:getData().LANtimer = 60
        else
            player:getData().LANtimer = player:getData().LANtimer - 1
        end
    end
end)

-- clean up the damage table on death, stage entry and game end
registercallback("onPlayerDeath", function(player)
    player:getData().damageTable = {}
end)

registercallback("onStageEntry", function()
    for i, player in ipairs(misc.players) do
        if player:getData().damageTable then
            player:getData().damageTable = {}
        end
    end
end)

registercallback("onGameEnd", function()
    for i, player in ipairs(misc.players) do
        if player:getData().damageTable then
            player:getData().damageTable = {}
        end
    end
end)

item:setLog{
    group = "common",
    description = "Delay damage taken by 1 seconds and reduce it by 10%",
    story = "",
    destination = "",
    date = ""
}