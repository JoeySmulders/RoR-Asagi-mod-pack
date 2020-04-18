-- mirror_shard.lua
-- Common tier item that replicates the mirror use ability as a passive chance attack

local item = Item("Mirror shard")

item.pickupText = "10% on attack to create a shadow partner for 1 second"

item.sprite = Sprite.load("Items/sprites/mirror_shard", 1, 12, 12)

item:setTier("common")

-- TODO: make it properly stack with broken mirror (make a new variable to determine when you use mirror and store the SP it gave as the "original" value)

-- Setup 
item:addCallback("pickup", function(player)
    player:getData().extraAttackTimer = 0
end)

registercallback("onPlayerStep", function(player)
    local count = player:countItem(item)

    if count > 0 then
        if player:getData().extraAttackTimer > 0 then
            player:getData().extraAttackTimer = player:getData().extraAttackTimer - 1
        end
    end
end)

registercallback("onFire", function(bullet)
    local player = bullet:getParent()

    if type(player) == "PlayerInstance" then
        local count = player:countItem(item)

        if count > 0 then
            if player:getData().extraAttackTimer == 0 then
                if math.chance(5 + (5 * count)) then
                    if player:get("sp_dur") < 60 and player:get("sp") < 1 then
                        player:set("sp", player:get("sp") + 1)
                    end
                    player:set("sp_dur", player:get("sp_dur") + 60) 
                end
                player:getData().extraAttackTimer = 60
            end

        end
    end
end)

item:setLog{
    group = "common",
    description = "10% on attack to create a shadow partner for 1 second",
    story = "",
    destination = "",
    date = ""
}