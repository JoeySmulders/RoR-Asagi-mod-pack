-- Add the Buster character
local buster = Survivor.new("Buster")

-- Insert general sprites (idle,walk,jump,climb,death), numbers are amount of frames, x origin and y origin
local sprites = {
    idle = Sprite.load("buster_idle", "Survivors/buster/idle", 1, 5, 6),
    walk = Sprite.load("buster_walk", "Survivors/buster/walk", 7, 5, 6),
	jump = Sprite.load("buster_jump", "Survivors/buster/jump", 1, 5, 6),
	climb = Sprite.load("buster_climb", "Survivors/buster/climb", 2, 5, 6),
    death = Sprite.load("buster_death", "Survivors/buster/death", 8, 48, 13),
    -- decoy from Crudely Drawn Buddy
    decoy = Sprite.load("buster_decoy", "Survivors/buster/decoy", 1, 9, 18),
}

local sprBlast = Sprite.load("buster_blast", "Survivors/buster/blast", 5, 6, 5)
local sprBlast1 = Sprite.load("buster_blast1", "Survivors/buster/blast1", 3, 3, 3)
local sprBlast1left = Sprite.load("buster_blast1left", "Survivors/buster/blast1left", 3, 7, 3)
local sprBlast2 = Sprite.load("buster_blast2", "Survivors/buster/blast2", 3, 3, 3)
local sprBlast2left = Sprite.load("buster_blast2left", "Survivors/buster/blast2left", 3, 17, 3)
local sprBlast3 = Sprite.load("buster_blast3", "Survivors/buster/blast3", 3, 3, 3)
local sprBlast3left = Sprite.load("buster_blast3left", "Survivors/buster/blast3left", 3, 37, 3)
local sprBlast4 = Sprite.load("buster_blast4", "Survivors/buster/blast4", 3, 3, 9)
local sprBlast4left = Sprite.load("buster_blast4left", "Survivors/buster/blast4left", 3, 117, 9)

local sprBar = Sprite.load("buster_bar", "Survivors/buster/bar", 1, 0, 0)
local sprSlam = Sprite.load("buster_slam", "Survivors/buster/dunk", 5, 0, 0)
local sprDash = Sprite.load("buster_dash", "Survivors/buster/dash", 5, 0, 0)
local sprExplosive = Sprite.load("buster_explosive", "Survivors/buster/scarf", 5, 0, 0)

local sprSkills = Sprite.load("buster_skills", "Survivors/buster/skills", 5, 0, 0)


local customBar = Object.find("CustomBar")


local blast1 = ParticleType.new("Blast1")
blast1:sprite(sprBlast1, true, true, false)
blast1:life(0.2 * 60, 0.2 * 60)

-- explosion Object
local objExplode = Object.new("ExplosiveScarf")
objExplode.sprite = Sprite.load("ExplosiveScarf", "Survivors/buster/explosive", 1, 5, 5)
objExplode.depth = 1

-- Explosive creation and variables
objExplode:addCallback("create", function(objExplode)
	local objExplodeAc = objExplode:getAccessor()
	objExplodeAc.life = 2 * 60
	objExplodeAc.speed = 0
	objExplodeAc.size = 1
	objExplodeAc.damage = 25
	objExplode.spriteSpeed = 0.25
end)

objExplode:addCallback("destroy", function(objExplode)
    local objExplodeAc = objExplode:getAccessor()
    local parent = Object.findInstance(objExplodeAc.parent)
    
    if parent:isValid() then
        parent:fireExplosion(objExplode.x, objExplode.y, (objExplode.sprite.width * 10) / 19, (objExplode.sprite.height * 10) / 4, objExplodeAc.damage, nil, nil, DAMAGER_NO_PROC)
    end
end)

-- Explosive function called every step
objExplode:addCallback("step", function(objExplode)
	local objExplodeAc = objExplode:getAccessor()

    if objExplode:isValid() then
        if objExplodeAc.life == 0 then
            objExplode:destroy()
	    else
            objExplodeAc.life = objExplodeAc.life - 1
        end
    end

end)


-- Description and skill icons
buster:setLoadoutInfo(
[[&y&Buster&!& is a master of explosives, he fearlessly charges into battle
This survivor focuses on using positioning and timing to deliver extremely high damage at close ranges]]
, sprSkills)

-- Character select skill descriptions
buster:setLoadoutSkill(1, "Blast Strike", 
[[Charge up a strike and release it to deal &y&up to 1000% damage&!&.
The attack can be &b&charged during other actions&!&, but deals &r&self damage if left at full charge&!&.]])

buster:setLoadoutSkill(2, "Blazing Slam", 
[[Immediately drop down and slam the ground, dealing &y&up to 600% damage&!& based on distance fallen.
On impact, &y&launches enemies into the air&!& while setting them &y&ablaze for 30% of the damage dealt&!&.]])

buster:setLoadoutSkill(3, "Slide Boost", 
[[&y&Slide a short distance&!& in the direction you are walking, or &y&up into the air&!& while not moving.
&b&Instantly charges Blast Strike to full&!& when used while charging, and &b&jumping cancels the slide&!&.]])

buster:setLoadoutSkill(4, "Explosive Scarf", 
[[Release &y&10 explosives&!& around you that will detonate after 2 seconds for &y&250% damage each&!&.]])

-- Extra menu sprite
buster.idleSprite = sprites.idle

-- character skill name color
buster.loadoutColor = Color.fromRGB(137, 30, 43)

-- Sprite for character select
buster.loadoutSprite = Sprite.load("buster_select", "Survivors/buster/select", 4, 2, 0)

-- Character walk animation on title screen
buster.titleSprite = sprites.walk

-- Quote displayed when beating the game
buster.endingQuote = "And so he left..."

buster:addCallback("init", function(player)
    -- Set player animations
    player:setAnimations(sprites)

    -- survivor starting stats (health, damage, regen)
    player:survivorSetInitialStats(130, 14, 0.01)

    -- set player skill icons (last number is cooldown in frames)
    player:setSkill(1,
    "Blast Strike",
    "Charge up a strike for up to 1000% damage",
    sprSkills, 1,
    0.5 * 60
    )

    player:setSkill(2,
    "Blazing Slam",
    "Slam into the ground for up to 600% damage, knocking up enemies and setting them ablaze",
    sprSkills, 2,
    5 * 60
    )

    player:setSkill(3,
    "Slide Boost",
    "Slide along the ground or boost into the air depending on movement",
    sprSkills, 3,
    3 * 60
    )

    player:setSkill(4,
    "Explosive Scarf",
    "Release 10 explosives around you, detonating after 2 seconds for 250% damage",
    sprSkills, 4,
    12 * 60
    )

    player:set("pHmax", 1.2)
end)

-- Increase character stats on levelup
buster:addCallback("levelUp", function(player)
    -- (health, damage, regen, armor)
    player:survivorLevelUpStats(32, 4, 0.001, 2)
end)

-- Change skill 4 description when scepter is picked up
buster:addCallback("scepter", function(player)
    player:setSkill(4,
    "Chain Explosive Scarf",
    "Release 10 explosives around you, detonating after 1 second for 250% damage and releasing more explosives",
    sprSkills, 5,
    6 * 60
    )
end)

buster:addCallback("step", function(player)
    -- If the charge bar exists, increase the blastCharge timer
    if player:getData().chargeBar and player:getData().chargeBar:isValid() then
        if player:getData().blastCharge < 180 then
            player:getData().blastCharge = player:getData().blastCharge + 1
        end
        -- If the timer is almost at the end, change the color and start taking damage
        if player:getData().chargeBar:get("time") < 5 then
            player:getData().chargeBar:set("barColor", Color.fromRGB(198,69,36).gml)
            player:getData().chargeBar:set("time", 5)
            player:getData().chargeDamage = true
        end
    end

    -- If the skill button is released, get rid of the charge bar and perform the attack if the player is capable of attacking
    if player:control("ability1") == input.NEUTRAL and player:getData().blastCharging == true then
        if player:get("activity") == 0 then
            -- Activate Z skill
            player:survivorActivityState(1, sprBlast, 0.20, true, true)
        end
        player:getData().blastCharging = false
        player:getData().chargeDamage = false
        player:getData().chargeBar:destroy()
    end

    -- Deal damage to the player if the charge is at full
    if player:getData().chargeDamage == true then
        if player:getData().chargeDamageTimer <= 0 then
            local damage = player:get("hp") * 0.1
            player:set("hp", player:get("hp") - damage)
            misc.shakeScreen(3)
            misc.damage(damage, player.x, player.y - 10, false, Color.ORANGE)
            player:getData().chargeDamageTimer = 60
        else
            player:getData().chargeDamageTimer = player:getData().chargeDamageTimer - 1
        end

    end


end)

-- Called when the player tries to use a skill 
buster:addCallback("useSkill", function(player, skill)
	-- Make sure the player isn't doing anything when pressing the button
	if player:get("activity") == 0 then
        -- Set the player's state (skill index, animation, animation speed (times 60 fps), scalespeed (true for scaling with attack speed), resetHSpeed (true if you can't move on the ground during it))

        -- Z skill charge set up
        if skill == 1 and player:getData().blastCharging ~= true then
            player:getData().blastCharging = true
            player:getData().blastCharge = 0

            local bar = customBar:create(player.x, player.y + 100)
            bar.sprite = sprBar
            local time = (3 * 60) / player:get("attack_speed")
			bar:set("time", time)
			bar:set("maxtime", time)
			bar:set("barColor", Color.fromRGB(255,255,255).gml)
			bar:set("parent", player.id)
			bar:set("charge", 1)
            player:getData().chargeBar = bar
            player:getData().chargeDamageTimer = 60
        end

		if skill == 2 then
			-- X skill
            player:survivorActivityState(2, sprSlam, 0.25, true, true)
		elseif skill == 3 then
            -- C skill
            
            if player:get("pHspeed") == 0 then
                player:getData().slideUp = true
            else
                player:getData().slideUp = false
            end

            player:survivorActivityState(3, sprDash, 0.25, false, false)
            if player:getData().blastCharging == true then
                player:getData().blastCharge = 180 -- Insert full bar
                player:getData().chargeBar:set("time", 5)
            end
		elseif skill == 4 then
			-- V skill
            player:survivorActivityState(4, sprExplosive, 0.25, true, true)
		end
		
		-- Put the skill on cooldown
		player:activateSkillCooldown(skill)
	end
end)

-- Called each frame the player is in a skill state
buster:addCallback("onSkill", function(player, skill, relevantFrame)
	-- The 'relevantFrame' argument is set to the current animation frame only when the animation frame is changed
	-- Otherwise, it will be 0

	if skill == 1 then 
		-- Z skill: blast
		
		if relevantFrame == 4 then
			-- Code is ran when the 4th frame of the animation starts
			
			-- The "survivorFireHeavenCracker" method handles the effects of the item Heaven Cracker
			-- If the effect is triggered, it returns the fired bullet, otherwise it returns nil
			if player:survivorFireHeavenCracker(1) == nil then
				-- The player's "sp" variable is the attack multiplier given by Shattered Mirror
                for i = 0, player:get("sp") do

                    local damage = 0
                    local sprite = sprBlast1

                    -- Deal more damage based on how charged the attack is
                    if player:getData().blastCharge == 180 then
                        damage = 10

                        if player:getFacingDirection() == 180 then
                            sprite = sprBlast4left
                        else
                            sprite = sprBlast4
                        end

                    elseif player:getData().blastCharge > 120 then
                        damage = 5

                        if player:getFacingDirection() == 180 then
                            sprite = sprBlast3left
                        else
                            sprite = sprBlast3
                        end

                    elseif player:getData().blastCharge > 60 then
                        damage = 3

                        if player:getFacingDirection() == 180 then
                            sprite = sprBlast2left
                        else
                            sprite = sprBlast2
                        end

                    else
                        damage = 1

                        if player:getFacingDirection() == 180 then
                            sprite = sprBlast1left
                        else
                            sprite = sprBlast1
                        end
                        
                    end

                    -- Input some variables based on how long you charged
                    local bullet = player:fireExplosion(player.x + player.xscale * 10, player.y + 1, sprite.width / 19, sprite.height / 4, damage, sprite, sprSparks7)
                    misc.shakeScreen(damage)
                    
				end
			end
			
			-- Play explosion sound effect
			
		end
		
		
	elseif skill == 2 then
		-- X skill: slam

        -- Slam down
        if relevantFrame == 3 then
            
            -- Check if there is ground 200 pixels below the player, then teleport to that position
            local yOffset = 2
            local i = 0
            while not player:collidesMap(player.x, player.y + yOffset) do
                player.y = player.y + 2
                i = i + 2
                if i > 300 then
                    break
                end
            end

            local damage = i / 50

            local bullet = player:fireExplosion(player.x, player.y, 100 / 19, 10 / 4, damage, nil, sprSparks7)

            -- If starstorm is loaded set enemies on fire
            if modloader.checkMod("StarStorm") then
                DOT.addToDamager(bullet, DOT_FIRE, player:get("damage") * damage * 0.3, 3, "Slam", false)
            end

            -- Knockup enemies based on the damage done and shake the screen
            --bullet:set("blaze", 1) don't use this it gives errors
            bullet:set("knockup", 2 + (damage * 2))
            misc.shakeScreen(10)

		end
        
	elseif skill == 3 then
		-- C skill: slide

        if player:getData().slideUp == true then
            player:set("pVspeed", -1 * player:get("pVmax") * 1 * player.yscale)
        else
            -- Set the player's horizontal speed
            player:set("pHspeed", player:get("pHmax") * 3 * player.xscale)

            -- Cancel the ability by jumping
            if player:control("jump") == input.PRESSED then
                player:set("activity_type", 0)
                player:set("activity", 0)
            end
        end
		
	elseif skill == 4 then
		-- V skill: Explosives

        if relevantFrame == 4 then
            
            local explosive = objExplode:create(player.x, player.y)
            explosive:set("parent", player.id)
		end
	
	end
end)

registercallback("onPlayerDeath", function(player)
    if player:getData().chargeBar and player:getData().chargeBar:isValid() then
        player:getData().chargeBar:destroy()
    end

end)