local sprFreezePal = Sprite.load("FreezeElitePalette", "Elites/Palettes/Freeze_Elite", 1, 0, 0)

elite.Freezing = EliteType.new("Freezing")
elite.Freezing.displayName = "Freezing"
elite.Freezing.color = Color.fromHex(0x0000FF)
elite.Freezing.palette = sprFreezePal -- Elite Palettes don't work for magma worms, maybe assign one to the monster card?

local magmaWorm = MonsterCard.find("Magma Worm", "Vanilla") 
local wormHead = Object.find("WormHead", "Vanilla")
local wormBody = Object.find("WormBody", "Vanilla")

magmaWorm.eliteTypes:add(elite.Freezing)

-- Adding a new elite type for magma worm seems to enable the rest of the original elites for them too, disable them
for i, eliteType in ipairs(originalElites) do
    if eliteType ~= elite.Overloading then
        magmaWorm.eliteTypes:remove(eliteType)
    end
end

registercallback("onPlayerStep", function(player)
    -- Check for collision with wormhead or wormbody if they are freezing
    for i, worm in ipairs(wormHead:findMatchingOp("elite_type", "==", elite.Freezing.id)) do
        if player:collidesWith(worm, player.x, player.y) then
            player:getData().frozen = 1
        end
    end
    for i, worm in ipairs(wormBody:findMatchingOp("elite_type", "==", elite.Freezing.id)) do
        if player:collidesWith(worm, player.x, player.y) then
            player:getData().frozen = 1
        end
    end

    -- Insert code to freeze player
    if player:getData().frozen == 1 then
        
    end
end)
