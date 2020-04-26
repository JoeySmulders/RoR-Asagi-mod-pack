-- hell_chain.lua
-- Use item that links enemies together

local item = Item("Bloody Cross")

item.pickupText = "Link all enemies, making them share damage taken by half"
item.sprite = Sprite.load("Items/sprites/hell_chain", 1, 14, 14)
item:setTier("use")
item.isUseItem = true
item.useCooldown = 20

ItemPool.find("enigma", "vanilla"):add(item)

linked = Buff.new("Linked")
linked.sprite = Sprite.load("Items/sprites/linked", 1, 1, 1)

local currentEnemies = {}

local wormBody = Object.find("WormBody", "Vanilla")

-- Apply debuff to all existing enemies (TODO: Make it only on the current screen)
item:addCallback("use", function(player, embryo)
    currentEnemies = {}
    currentEnemies = enemies:findAll()
    
    if #currentEnemies > 0 then
        for i, enemy in ipairs(currentEnemies) do
            if embryo then
                enemy:getData().linkedEmbryo = true
            end
            enemy:applyBuff(linked, 10 * 60)
        end
    end

end)

-- Make all enemies take the damage
registercallback("preHit", function(bullet, hit)
    if hit:hasBuff(linked) then
        for i, enemy in ipairs(currentEnemies) do 
            if enemy ~= hit and enemy:isValid() and enemy:hasBuff(linked) then

                local damage = 0
                -- deal full damage if embryo procced
                if enemy:getData().linkedEmbryo == true then
                    damage = bullet:get("damage")
                else
                    damage = bullet:get("damage") / 2
                end

                enemy:set("hp", enemy:get("hp") - damage)
                misc.damage(damage, enemy.x, enemy.y - 10 , false, Color.GREY)
            end
        end
    end
end)

-- Remove enemies from the table when the debuff ends
linked:addCallback("end", function(actor)
    for i, enemy in ipairs(currentEnemies) do 
        if actor == enemy or actor:isValid() == false then
            table.remove(currentEnemies, i)
        end
    end
end)

-- Draw lines between all enemies with the debuff
registercallback("onDraw", function()
    if #currentEnemies > 0 then
        graphics.alpha(0.1)
        graphics.color(Color.BLACK)
        for i, enemy1 in ipairs(currentEnemies) do 
            if enemy1:isValid() and enemy1:getObject() ~= wormBody then
                for i, enemy2 in ipairs(currentEnemies) do
                    if enemy2:isValid() and enemy2:getObject() ~= wormBody then
                        if enemy1 ~= enemy2 then
                            graphics.line(enemy1.x, enemy1.y, enemy2.x, enemy2.y, 3)
                        end
                    end
                end
            end
        end

    end
end)

item:setLog{
    group = "use",
    description = "Link all enemies on screen. Damaging a linked enemy makes all other linked enemies take half the damage dealt",
    story = "",
    destination = "",
    date = ""
}