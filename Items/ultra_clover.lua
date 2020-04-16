-- ultra_clover.lua
-- Rare item that increases clover stack by 5 (10% if you have none, 7.5% otherwise)

local item = Item("168 Leaf Clover")

item.pickupText = "Elite enemies drop items far more often"

item.sprite = Sprite.load("Items/sprites/Clover", 1, 18, 15)

item:setTier("rare")

local clover = Object.find("Clover", "Vanilla")

-- Increase a players clover stack by 5 when picking it up
item:addCallback("pickup", function(player)
    --player:set("clover", player:get("clover") + 5) This does not show up in Starstorm HUD due to how the tracker only looks for how instances of the item clover you actually have
    -- So just drop 3 clovers instead for now
    local xOffset = -50
    for i = 1, 3, 1 do
        local cloverInstance = clover:create(player.x + xOffset, player.y)
        xOffset = xOffset + 50
    end
end)

item:setLog{
    group = "rare",
    description = "",
    story = "",
    destination = "",
    date = ""
}