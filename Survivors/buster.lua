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

local sprBlast = Sprite.load("buster_blast", "Survivors/buster/blast", 10, 0, 0)
local sprBar = Sprite.load("buster_bar", "Survivors/buster/bar", 1, 0, 0)

local sprSlam = Sprite.load("buster_slam", "Survivors/buster/dunk", 5, 0, 0)

local sprDash = Sprite.load("buster_dash", "Survivors/buster/dash", 5, 0, 0)

local sprSkills = Sprite.load("buster_skills", "Survivors/buster/skills", 5, 0, 0)


local customBar = Object.find("CustomBar")

-- Description and skill icons
buster:setLoadoutInfo(
[[&y&Buster&!& is a master of explosives, he fearlessly charges into battle]]
, sprSkills)

-- Character select skill descriptions
buster:setLoadoutSkill(1, "Blast Strike", 
[[Charge up a strike and release it to deal up to 1000% damage
The attack can be charged while moving, but deals self damage if left at full charge]])

buster:setLoadoutSkill(2, "Blazing Slam", 
[[Immediately drop down and slam the ground, dealing up to 400% damage and launching enemies into the air while setting them ablaze.]])

buster:setLoadoutSkill(3, "Slide Boost", 
[[Slide a short distance in the direction you are walking, or up in the air while standing still
Instantly charges the Blast Strike to full and cancels other actions when used]])

buster:setLoadoutSkill(4, "Explosive Scarf", 
[[Release 10 explosives around you that will detonate after 1 second for 250% damage each]])

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
    player:survivorSetInitialStats(130, 12, 0.01)

    -- set player skill icons (last number is cooldown in frames)
    player:setSkill(1,
    "Blast Strike",
    "Charge up for up to 1000% damage",
    sprSkills, 1,
    0.5 * 60
    )

    player:setSkill(2,
    "Blazing Slam",
    "Slam into the ground for up to 400% damage",
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
    "Release 10 explosives around you, detonating after 1 second for 250% damage",
    sprSkills, 4,
    8 * 60
    )

end)

-- Increase character stats on levelup
buster:addCallback("levelUp", function(player)
    -- (health, damage, regen, armor)
    player:survivorLevelUpStats(30, 4, 0.001, 1)
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
            player:getData().chargeBar:set("time", 10)
            player:getData().chargeDamage = true
        end
    end
    -- If the skill button is released, get rid of the charge bar and perform the attack if the player is capable of attacking
    if player:control("ability1") == input.NEUTRAL and player:getData().blastCharging == true then
        if player:get("activity") == 0 then
            -- Activate Z skill
            player:survivorActivityState(1, sprBlast, 0.25, true, true)
        end
        player:getData().blastCharging = false
        player:getData().chargeDamage = false
        player:getData().chargeBar:destroy()
    end

    -- Deal damage to the player if the charge is at full
    if player:getData().chargeDamage == true then
        if player:getData().chargeDamageTimer <= 0 then
            local damage = player:get("hp") * 0.2
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
			bar:set("time", 3 * 60)
			bar:set("maxtime", 3 * 60)
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
                player:getData().blastCharge = 100 -- Insert full bar
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
                    -- Deal more damage based on how charged the attack is
                    if player:getData().blastCharge == 180 then
                        damage = 10
                    elseif player:getData().blastCharge > 120 then
                        damage = 5
                    elseif player:getData().blastCharge > 60 then
                        damage = 3
                    else
                        damage = 1
                    end

                    -- Input some variables based on how long you charged
                    local bullet = player:fireExplosion(player.x + player.xscale * 50, player.y, 100 / 19, 10 / 4, damage, nil, sprSparks7)
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
                if i > 200 then
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
            bullet:set("knockup", damage * 3)
            misc.shakeScreen(10)

		end
        
	elseif skill == 3 then
		-- C skill: slide

        if player:getData().slideUp == true then
            player:set("pVspeed", -1 * player:get("pVmax") * 1 * player.yscale)
        else
            -- Set the player's horizontal speed
            player:set("pHspeed", player:get("pHmax") * 2.5 * player.xscale)

            -- Cancel the ability by jumping
            if player:control("jump") == input.PRESSED then
                player:set("activity_type", 0)
                player:set("activity", 0)
            end
        end
		
	elseif skill == 4 then
		-- V skill: Explosives

		if relevantFrame == 4 then
		

		end
	
	end
end)
