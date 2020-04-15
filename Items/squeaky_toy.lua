-- squeaky_toy.lua
-- Rare item that makes spite balls deal damage to enemies (if spite is disabled, activate it but make it not damage players)

local item = Item("Squeaky toy")

item.pickupText = "Spite balls hurt enemies"

item.sprite = Sprite.load("Items/sprites/Squeaky_toy", 1, 18, 15)

item:setTier("rare")

local playerInstance = nil

local spiteEnabled = false
local spite = Artifact.find("Spite", "Vanilla")
local spiteBombs = Object.find("EfGrenadeEnemy", "Vanilla")
local team = ""

-- TODO: Maybe make the holder immune to spite?

-- When the player picks up the item, check if spite is enabled and change the team of spite bombs
item:addCallback("pickup", function(player)
    playerInstance = player

    local count = 1

    for i, player in ipairs(misc.players) do
        count = player:countItem(item)
    end

    if count == 1 then
        if spite.active == true then
            spiteEnabled = true
        end

        if spiteEnabled then
            playerInstance:getData().spiteTeam = "fuck everything"
        else
            spite.active = true
            playerInstance:getData().spiteTeam = "player"
        end
    end
end)

registercallback("onStep", function()
    local itemCount = 0

    for i, player in ipairs(misc.players) do
        if player:get("dead") <= 0 then
            itemCount = player:countItem(item)
            if player:getData().spiteTeam ~= "" then
                playerInstance = player
            end
        end
    end

    if itemCount > 0 then
        for i, instance in ipairs(spiteBombs:findAll()) do
            if instance:getData().adjusted ~= true then
                instance:set("team", playerInstance:getData().spiteTeam)
                instance:set("damage", instance:get("damage") * itemCount)
                instance:getData().adjusted = true
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