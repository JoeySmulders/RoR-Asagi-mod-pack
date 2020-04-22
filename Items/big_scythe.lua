-- big_scythe.lua
-- Use item that does massive damage to a random enemy

local item = Item("Big Scythe")

item.pickupText = "Deal massive damage to a random enemy"
item.sprite = Sprite.load("Items/sprites/Big_scythe", 1, 13, 13)
item:setTier("use")
item.isUseItem = true
item.useCooldown = 30

ItemPool.find("enigma", "vanilla"):add(item)

-- TODO: make it prioritize enemies on screen first
-- TODO: add a visual effect for it

scytheAttack = net.Packet("Big Scythe Packet", function(player, enemyX, enemyY)
    player:fireExplosion(enemyX, enemyY, 5 / 19, 5 / 4, 1000, nil, nil, DAMAGER_NO_PROC)
    if net.host then
        teleporterPacket:sendAsHost(net.EXCLUDE, player, enemyX, enemyY)
    end
end)

item:addCallback("use", function(player, embryo)
    if not net.online or net.localPlayer == player then
        local count = 1
        -- Hit two enemies if embryo is procced
        if embryo then
            count = 2
        end

        -- Get the current enemies and take a random one to attack
        for i = 1, count, 1 do
            local currentEnemies = enemies:findAll()
            
            if currentEnemies then
                local enemyCount = 0

                for i, enemy in ipairs(currentEnemies) do
                    enemyCount = enemyCount + 1
                end

                local enemyTarget = math.random(1, enemyCount)

                for i, enemy in ipairs(currentEnemies) do
                    if i == enemyTarget then
                        player:fireExplosion(enemy.x, enemy.y, 5 / 19, 5 / 4, 1000, nil, nil, DAMAGER_NO_PROC)

                        if net.host then
                            scytheAttack:sendAsHost(net.ALL, nil, enemy.x, enemy.x)
                        else
                            scytheAttack:sendAsClient(enemy.x, enemy.y)
                        end
                    end
                end
            end
        end
    end

end)

item:setLog{
    group = "use",
    description = "Deal 100000% damage to a random enemy",
    story = "",
    destination = "",
    date = ""
}