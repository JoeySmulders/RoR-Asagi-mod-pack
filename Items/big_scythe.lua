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
-- TODO: make it an explosion that damages multiple enemies?

item:addCallback("use", function(player, embryo)
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

            for _, enemy in ipairs(currentEnemies) do
                enemyCount = enemyCount + 1
            end

            local enemyTarget = math.random(1, enemyCount)

            for _, enemy in ipairs(currentEnemies) do
                if _ == enemyTarget then
                    player:fireBullet(enemy.x, enemy.y, 0, 0.1, 1000, nil, DAMAGER_NO_PROC)
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