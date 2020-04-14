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
    local count = player:countItem(item) 

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
    if playerInstance then
        for i, instance in ipairs(spiteBombs:findAll()) do
            instance:set("team", playerInstance:getData().spiteTeam)
            instance:set("damage", instance:get("damage") * playerInstance:countItem(item)) -- MP stuff: make it count from every player
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