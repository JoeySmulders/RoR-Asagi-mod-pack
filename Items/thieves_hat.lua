-- thieves_hat.lua
-- Uncommon tier item that boosts the players movement when jumping in midair

local item = Item("Thieves Hat")

item.pickupText = "Boost forward when jumping in midair"

item.sprite = Sprite.load("Items/sprites/Thieves_hat", 1, 18, 15)

item:setTier("uncommon")

-- Initialize damage counter for the item
item:addCallback("pickup", function(player)
    local count = player:countItem(item) 
    if count == 1 then
        player:set("feather", player:get("feather") + 1)
        player:set("bamboo_boost", 0)
    end
end)

registercallback("onPlayerStep", function(player)
    local count = player:countItem(item)
    
    if count > 0 then
        -- TODO: Figure out how to actually make ropes stop acting weird when you have this item
        -- TODO 2: Put some momentum into it instead of just stopping instantly when you stop holding the direction
        -- TODO 3: Put an animation effect when doing a boost jump
        if player:get("activity") == 30 then
            player:set("bamboo_boost", 0)
        else
            -- When you jump in midair while having a jump available and are holding either left or right you get the boost jump
            if player:control("jump") == input.PRESSED and player:get("free") == 1 and player:get("jump_count") < player:get("feather") 
            and (player:control("left") == input.HELD or player:control("right") == input.HELD) then
                if player:getFacingDirection() == 0 then
                    player:set("bamboo_boost", 1)
                else
                    player:set("bamboo_boost", 2)
                end 
                player:set("moveUp", 1) 
                player:set("pVspeed", player:get("pVmax") * -1)
                player:set("jump_count", player:get("jump_count") + 1)
            end

            -- If jumping to the right
            if player:get("bamboo_boost") == 1 then
                player:set("activity_type", 3)
                player:set("pHspeed", player:get("pHmax") * 1.5 + (0.5 * count))
                if player:control("right") == input.NEUTRAL then
                    player:set("activity_type", 0)
                    player:set("bamboo_boost", 0)
                end
            end
            -- If jumping to the left
            if player:get("bamboo_boost") == 2 then
                player:set("activity_type", 3)
                player:set("pHspeed", player:get("pHmax") * -1.5 - (0.5 * count))
                if player:control("left") == input.NEUTRAL then
                    player:set("activity_type", 0)
                    player:set("bamboo_boost", 0)
                end
            end

            -- Disable boost when you hit the floor
            if player:get("free") == 0 then
                player:set("activity_type", 0)
                player:set("bamboo_boost", 0)
            end
        end
    end
end)

item:setLog{
    group = "uncommon",
    description = "",
    story = "",
    destination = "",
    date = ""
}

