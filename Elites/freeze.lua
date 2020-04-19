local sprFreezePal = Sprite.load("FreezeElitePalette", "Elites/Palettes/Freeze_Elite", 1, 0, 0)
local sprFrozen = Sprite.load("FreezeFrozen", "Elites/Sprites/Frozen", 1, 7, 8)

elite.Freezing = EliteType.new("Freezing")
elite.Freezing.displayName = "Freezing"
elite.Freezing.color = Color.fromHex(0x0000FF)
elite.Freezing.palette = sprFreezePal -- Elite Palettes don't work for magma worms, maybe assign one to the monster card?

local magmaWorm = MonsterCard.find("Magma Worm", "Vanilla") 
local wormHead = Object.find("WormHead", "Vanilla")
local wormBody = Object.find("WormBody", "Vanilla")

magmaWorm.eliteTypes:add(elite.Freezing)

local freezeTimer = 2 * 60
local freezeImmune = 5 * 60

-- TODO: turn the freeze into a debuff instead of hardcoded
-- TODO: have an actual sprite or palette for the Freezing magma worm instead of just adding a color

-- Adding a new elite type for magma worm seems to enable the rest of the original elites for them too, disable them
for i, eliteType in ipairs(originalElites) do
    if eliteType ~= elite.Overloading then
        magmaWorm.eliteTypes:remove(eliteType)
    end
end

registercallback("onActorInit", function(player)
    if type(player) == "PlayerInstance" then
        player:getData().frozen = 0
        player:getData().frozenTimer = 0
    end
end)


registercallback("onPlayerStep", function(player)
    -- Check for collision with wormhead or wormbody if they are freezing
    for i, worm in ipairs(wormHead:findMatchingOp("elite_type", "==", elite.Freezing.id)) do
        if player:collidesWith(worm, player.x, player.y) then
            if player:getData().frozenTimer <= freezeTimer and player:getData().frozen ~= 1 then
                player:getData().frozen = 1
                player:getData().frozenTimer = freezeTimer
            end
        end
    end
    for i, worm in ipairs(wormBody:findMatchingOp("elite_type", "==", elite.Freezing.id)) do
        if player:collidesWith(worm, player.x, player.y) then
            if player:getData().frozenTimer <= freezeTimer and player:getData().frozen ~= 1 then
                player:getData().frozen = 1
                player:getData().frozenTimer = freezeTimer
            end
        end
    end

    --TODO: Fix bug where getting frozen while on rope requires you to jump after being unfrozen (game still thinks you are climbing)

    -- Freezes the player, making them drop to the floor and stuck in the idle animation for x amount of seconds
    if player:getData().frozen == 1 then
        player:set("disable_ai", 1)

        if not player:collidesMap(player.x, player.y + 5) then
            player.y = player.y + 5
        end

        player.sprite = player:getAnimation("idle")
        player:getData().frozenTimer = player:getData().frozenTimer - 1

        if player:getData().frozenTimer <= 0 then
            player:getData().frozen = 0
            player:set("disable_ai", 0)
            player:getData().frozenTimer = freezeTimer + freezeImmune -- Make player immune to ice for a few seconds after recovering
        end
    end

    -- Tick down the freeze immunity
    if player:getData().frozen == 0 then
        if player:getData().frozenTimer >= freezeTimer then
            player:getData().frozenTimer = player:getData().frozenTimer - 1
        end
    end
end)

registercallback("onDraw", function()
    for i, player in ipairs(misc.players) do
        -- Draw the frozen sprite on top of the player when they get frozen by a Freezing elite
        if player:getData().frozen == 1 then
            graphics.drawImage{sprFrozen, player.x, player.y,
            width = player.sprite.width + 5,
            height = player.sprite.height + 5
        }
        end
    end
end)