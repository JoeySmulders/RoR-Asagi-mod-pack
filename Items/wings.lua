-- Wings.lua
-- Common tier item that grants increased damage while in the air

local item = Item("Angel Wings")

item.pickupText = "Increases damage while in the air by 10%"

item.sprite = Sprite.load("Items/sprites/Angel_wings", 1, 9, 9)

item:setTier("common")

-- If player is in the air when an attack hits, deal increased damage
registercallback("onFire", function(bullet)
    local parent = bullet:getParent()

    if type(parent) == "PlayerInstance" then
        local count = parent:countItem(item)
        if count > 0 and parent:get("free") == 1 and parent:get("activity") ~= 30 then
            bullet:set("damage", bullet:get("damage") * (1.1 + (math.min(count * 0.1, 1) - 0.1))) -- Max stack count of 10 for 100% extra damage
            bullet:set("damage_fake", bullet:get("damage") + math.random(-10, 10)) -- Fake Damage variation
        end
    end
end)

item:setLog{
    group = "common",
    description = "",
    story = "",
    destination = "",
    date = ""
}