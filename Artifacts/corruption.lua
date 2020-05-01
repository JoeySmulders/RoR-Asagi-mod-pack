
------ corruption.lua
---- Adds a new artifact which changes all existing enemies with new behavior

-- Creates a new artifact with the name Artifact of Pain
local artifact = Artifact.new("Corruption")
-- Make the artifact be unlocked by default
artifact.unlocked = true

-- Set the artifact's loadout info
artifact.loadoutSprite = Sprite.load("/Artifacts/sprites/corrupt.png", 2, 18, 18)
artifact.loadoutText = "Enemies are corrupted"

local missile = Object.find("EfMissileEnemy")

registercallback("onStep", function()
    if artifact.active then
        lizard()
        --[[
        lizardG()
        lizardF()
        lizardFG()
        jelly()
        jellyG2()
        golem()
        golemS()
        crab()
        naut()
        wisp()
        wispG()
        wispG2()
        mush()
        spitter()
        child()
        parent()
        imp()
        impS()
        impM()
        clay()
        bison()
        spider()
        slime()
        bug()
        guard()
        guardG()
        boarM()
        boarMS()

        golemG()
        giantJelly()
        worm()
        wispB()
        boar()
        impG()
        impGS()
        turtle()
        ifrit()
        scavenger()
        boss1()
        boss2Clone()
        boss3()
        wurmController()
        ]]

    end
end)

-- Lemurians launch fireballs when they attack
function lizard()
    local lemurians = enemies:findAll("Lizard")

    for i, instance in ipairs(lemurians) do
        if instance:getAlarm(2) ~= -1 then
            if instance:getData().finishedAttack == nil and math.floor(instance.subimage) == 3 then
                -- Insert fireball
                missile:create(instance.x, instance.y)

                instance:getData().finishedAttack = 1
            end

        else
            instance:getData().finishedAttack = nil
        end

    end
end

-- Set the name of enemies
registercallback("onActorInit", function(actor)
    if artifact.active then
        -- TODO: Only do this on actual enemies
        actorAc = actor:getAccessor()
        actorAc.name = "Corrupted " ..actorAc.name
    end
end)
