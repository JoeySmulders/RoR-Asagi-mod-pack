-- super_stickies.lua
-- Rare tier item that makes hits deal extra damage based on enemies max hp

local item = Item("Super Stickies")

item.pickupText = "5% chance on hit to attach 3 stickies that deal 600% damage"

item.sprite = Sprite.load("Items/sprites/super_sticky", 1, 14, 14)

item:setTier("rare")

superStickies = net.Packet("Super Sticky Packet", function(player, xPosition, yPosition)
    local sticky = player:fireExplosion(xPosition, yPosition, 5 / 19, 5 / 4, 1, nil)
    sticky:getData().noSticky = true
    sticky:set("sticky", 10) -- 10 sticky value is equal to 500% damage
    if net.host then
        teleporterPacket:sendAsHost(net.EXCLUDE, player, xPosition, yPosition)
    end
end)

registercallback("onHit", function(bullet, hit)
    local has_no_proc = false

    if bullet:get("bullet_properties") then
        has_no_proc = bit.band(bullet:get("bullet_properties"), DAMAGER_NO_PROC) ~= 0
    end
    
    if not has_no_proc then
        if bullet:getData().noSticky ~= true then
            local player = bullet:getParent()
            if type(player) == "PlayerInstance" then
                local count = player:countItem(item)

                if count > 0 then
                    if math.chance(5) then
                    -- can't use a loop because of how the game treats stickies (applying multiple in the same frame will only deal damage once)
                        player:getData().repeatStickies = 1 + (count * 2)
                        player:getData().stickyPositionX = hit.x
                        player:getData().stickyPositionY = hit.y
                    end
                end
            end
        end
    end
end)

-- TODO: make them fire over a longer period of time instead of every frame
-- Fire only one sticky per frame
registercallback("onPlayerStep", function(player)
    if player:getData().repeatStickies then
        if player:getData().repeatStickies > 0 then
            local sticky = player:fireExplosion(player:getData().stickyPositionX, player:getData().stickyPositionY, 5 / 19, 5 / 4, 1, nil)
            sticky:getData().noSticky = true
            sticky:set("sticky", 10) -- 10 sticky value is equal to 500% damage
            player:getData().repeatStickies = player:getData().repeatStickies - 1

            if net.host then
                superStickies:sendAsHost(net.ALL, nil, player:getData().stickyPositionX, player:getData().stickyPositionY)
            else
                superStickies:sendAsClient(player:getData().stickyPositionX, player:getData().stickyPositionY)
            end

        end
    end
end)

item:setLog{
    group = "rare",
    description = "5% chance on each hit to attach 3 stickies that deal 100% upfront damage, then explode for 500% damage",
    story = "",
    destination = "",
    date = ""
}

