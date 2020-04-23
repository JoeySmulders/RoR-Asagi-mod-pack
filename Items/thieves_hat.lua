-- thieves_hat.lua
-- Uncommon tier item that boosts the players movement when jumping in midair

local item = Item("Thieves Hat")

item.pickupText = "Boost forward when jumping in midair while holding a direction"

item.sprite = Sprite.load("Items/sprites/Thieves_hat", 1, 14, 10)
local jumpSprite = Sprite.load("Items/sprites/thieves_jump", 3, 6, 8)

item:setTier("uncommon")

-- Initialize damage counter for the item
item:addCallback("pickup", function(player)
    local count = player:countItem(item) 
    if count == 1 then
        player:set("feather", player:get("feather") + 1)
        player:set("bamboo_boost", 0)
    end
end)

local jump = ParticleType.new("Thief Jump")
jump:sprite(jumpSprite, true, true, false)
jump:life(0.3 * 60, 0.3 * 60)

particleSync = net.Packet("Thieves Hat Particle Sync", function(player, xOffset, playerVSpeed)
    jump:burst("middle", player.x + xOffset, player.y, 1)
    player:set("pVspeed", playerVSpeed)

    if net.host then
        particleSync:sendAsHost(net.EXCLUDE, player, playerVSpeed)
    end
end)

thievesHatSync = net.Packet("Thieves Hat Sync", function(player, playerHSpeed, playerVSpeed, activityType)
    player:set("pHspeed", playerHSpeed)
    player:set("pVspeed", playerVSpeed)
    player:set("activity_type", activityType)

    if net.host then
        thievesHatSync:sendAsHost(net.EXCLUDE, player, playerHSpeed, activityType)
    end
end)

registercallback("onPlayerStep", function(player)
    local count = player:countItem(item)
    
    if count > 0 then

        -- TODO: Make the item work with controller?
        -- TODO: Figure out how to actually make ropes stop acting weird when you have this item
        if player:get("activity") == 30 then
            player:set("bamboo_boost", 0)
        else
            -- When you jump in midair while having a jump available and are holding either left or right you get the boost jump
            if player:control("jump") == input.PRESSED and player:get("free") == 1 and player:get("jump_count") < player:get("feather") 
            and (player:control("left") == input.HELD or player:control("right") == input.HELD) then
                local xOffset = 0
                if player:getFacingDirection() == 0 then
                    player:set("bamboo_boost", 1)
                    jump:burst("middle", player.x - 5, player.y, 1)           
                    xOffset = -5        
                else
                    player:set("bamboo_boost", 2)
                    jump:burst("middle", player.x + 5, player.y, 1)
                    xOffset = 5
                end 

                player:set("moveUp", 1) 
                player:set("pVspeed", player:get("pVmax") * -1)
                player:set("jump_count", player:get("jump_count") + 1)

                if net.host then
                    particleSync:sendAsHost(net.ALL, nil, xOffset, player:get("pVspeed"))
                else
                    particleSync:sendAsClient(xOffset, player:get("pVspeed"))
                end
            end

            -- If jumping to the right
            if player:get("bamboo_boost") == 1 and (player:get("activity_type") == 3 or player:get("activity_type") == 0) then
                player:set("activity_type", 3)
                player:set("pHspeed", player:get("pHmax") * 1.5 + (0.5 * count))
                if player:control("right") == input.NEUTRAL then
                    player:set("activity_type", 0)
                    player:set("bamboo_boost", 0)
                end
                if net.host then
                    thievesHatSync:sendAsHost(net.ALL, nil, player:get("pHspeed"), player:get("pVspeed"), player:get("activity_type"))
                else
                    thievesHatSync:sendAsClient(player:get("pHspeed"), player:get("pVspeed"), player:get("activity_type"))
                end
            end
            -- If jumping to the left
            if player:get("bamboo_boost") == 2 and (player:get("activity_type") == 3 or player:get("activity_type") == 0) then
                player:set("activity_type", 3)
                player:set("pHspeed", player:get("pHmax") * -1.5 - (0.5 * count))
                if player:control("left") == input.NEUTRAL then
                    player:set("activity_type", 0)
                    player:set("bamboo_boost", 0)
                else
                    if net.host then
                        thievesHatSync:sendAsHost(net.ALL, nil, player:get("pHspeed"), player:get("pVspeed"), player:get("activity_type"))
                    else
                        thievesHatSync:sendAsClient(player:get("pHspeed"), player:get("pVspeed"), player:get("activity_type"))
                    end
                end
            end

            -- Disable boost when you hit the floor
            if player:get("free") == 0 and player:get("bamboo_boost") ~= 0 then
                if (player:get("activity_type") == 3) then 
                    player:set("activity_type", 0)
                end
                player:set("bamboo_boost", 0)

                if net.host then
                    thievesHatSync:sendAsHost(net.ALL, nil, player:get("pHspeed"), player:get("pVspeed"), player:get("activity_type"))
                else
                    thievesHatSync:sendAsClient(player:get("pHspeed"), player:get("pVspeed"), player:get("activity_type"))
                end
            end
        end
    end
end)

item:setLog{
    group = "uncommon",
    description = "Boost forward with extra horizontal speed when jumping in midair",
    story = "",
    destination = "",
    date = ""
}

