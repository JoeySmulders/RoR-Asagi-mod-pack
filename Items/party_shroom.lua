-- party_shroom.lua
-- Uncommon tier item that makes the player drop an item on death

local item = Item("Party Shroom")

item.pickupText = "Heal 5 hp per second to self and nearby allies"

item.sprite = Sprite.load("Items/sprites/mushroom", 1, 13, 13)

item:setTier("uncommon")

-- Setup shroom timer and size
item:addCallback("pickup", function(player)
    local count = player:countItem(item)

    if count == 1 then
        player:getData().shroomSize = 75
        player:getData().shroomTimer = 60
    end

    if count > 1 then
        player:getData().shroomSize = player:getData().shroomSize + 10
    end

end)

registercallback("onPlayerStep", function(player)
    local count = player:countItem(item)

    if count > 0 then
        if player:getData().shroomTimer <= 0 then
            local heal = 2 + (count * 3)

            player:set('hp', player:get("hp") + heal)
            misc.damage(heal, player.x, player.y - 10, false, Color.DAMAGE_HEAL)

            for i, player2 in ipairs(misc.players) do
                if player ~= player2 then
                    if distance(player.x, player.y, player2.x, player2.y) < player:getData().shroomSize then
                        player2:set("hp", player2:get("hp") + heal)
                        misc.damage(heal, player2.x, player2.y - 10, false, Color.DAMAGE_HEAL)
                    end
                end
            end

            player:getData().shroomTimer = 60
        end

        player:getData().shroomTimer = player:getData().shroomTimer - 1
    end

end)

registercallback("onDraw", function()
    for i, player in ipairs(misc.players) do
        local count = player:countItem(item)

        if count > 0 then
            graphics.alpha(0.3)
            graphics.color(Color.DAMAGE_HEAL)
            graphics.circle(player.x, player.y, player:getData().shroomSize, true)
        end
    end
end)


item:setLog{
    group = "uncommon",
    description = "Heal 5 hp per second to self and nearby allies",
    story = "",
    destination = "",
    date = ""
}

