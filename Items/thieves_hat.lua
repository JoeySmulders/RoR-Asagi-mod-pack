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
        player:getData().hatRopeTimer = 0
    end
end)

local jump = ParticleType.new("Thief Jump")
jump:sprite(jumpSprite, true, true, false)
jump:life(0.3 * 60, 0.3 * 60)

particleSync = net.Packet("Thieves Hat Particle Sync", function(player, xOffset, playerVSpeed, jumpCount)
    jump:burst("middle", player.x + xOffset, player.y, 1)
    player:set("pVspeed", playerVSpeed)
    player:set("jump_count", jumpCount) -- Jumping is vanilla synced so we have to tell the other clients to know if we can jump again or not or it wil desync

    if net.host then
        particleSync:sendAsHost(net.EXCLUDE, player, playerVSpeed, jumpCount)
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

function boostJump(player, horizontalMovement, controlSide, playerAc)
    player:set("activity_type", 3)
    player:set("pHspeed", player:get("pHmax") * horizontalMovement)

    local cancel = false
    if controlSide == "right" then
        if playerAc.moveLeft == 1 or playerAc.moveRight == 0 then
            cancel = true
        end
    end

    if controlSide == "left" then
        if playerAc.moveRight == 1 or playerAc.moveLeft == 0 then
            cancel = true
        end
    end

    if cancel then
        player:set("activity_type", 0)
        player:set("bamboo_boost", 0)
        player:getData().changedBoostDirection = true
    end

    if player:getData().changedBoostDirection == true then
        if net.host then
            thievesHatSync:sendAsHost(net.ALL, nil, player:get("pHspeed"), player:get("pVspeed"), player:get("activity_type"))
        else
            thievesHatSync:sendAsClient(player:get("pHspeed"), player:get("pVspeed"), player:get("activity_type"))
        end
        player:getData().changedBoostDirection = false
    end
end

registercallback("onPlayerStep", function(player)
    local count = player:countItem(item)
    
    if count > 0 then
        
        if player:get("activity") == 30 then
            player:set("bamboo_boost", 0)
            player:getData().hatRopeTimer = 5
        else
            -- Timer used to disable the boost jump when jumping off ropes for a few frames
            if player:getData().hatRopeTimer > 0 then
                player:getData().hatRopeTimer = player:getData().hatRopeTimer - 1
            end

            local playerAc = player:getAccessor()
            -- When you jump in midair while having a jump available and are holding either left or right you get the boost jump
            --if player:control("jump") == input.PRESSED and player:get("free") == 1 and player:get("jump_count") < player:get("feather") 
            --and (player:control("left") == input.HELD or player:control("right") == input.HELD) and player:getData().hatRopeTimer <= 0 then
            if player:control("jump") == input.PRESSED and player:get("free") == 1 and player:get("jump_count") < player:get("feather") 
            and (playerAc.moveLeft == 1 or playerAc.moveRight == 1) and player:getData().hatRopeTimer <= 0 then
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
                    particleSync:sendAsHost(net.ALL, nil, xOffset, player:get("pVspeed"), player:get("jump_count"))
                else
                    particleSync:sendAsClient(xOffset, player:get("pVspeed"), player:get("jump_count"))
                end

                player:getData().changedBoostDirection = true
            end

            -- If jumping to the right
            if player:get("bamboo_boost") == 1 and (player:get("activity_type") == 3 or player:get("activity_type") == 0) then
                boostJump(player, 1.5 + (0.5 * count), "right", playerAc)
            end

            -- If jumping to the left
            if player:get("bamboo_boost") == 2 and (player:get("activity_type") == 3 or player:get("activity_type") == 0) then
                boostJump(player, -1.5 - (0.5 * count), "left", playerAc)
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

