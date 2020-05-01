-- Add the Buster character
local buster = Survivor.new("Buster")

-- Insert general sprites (idle,walk,jump,climb,death), numbers are amount of frames, x origin and y origin
local sprites = {
    idle = Sprite.load("buster_idle", "Survivors/buster/idle", 1, 5, 6),
    walk = Sprite.load("buster_walk", "Survivors/buster/walk", 7, 4, 6),
	jump = Sprite.load("buster_jump", "Survivors/buster/jump", 1, 5, 6),
	climb = Sprite.load("buster_climb", "Survivors/buster/climb", 2, 5, 6),
    death = Sprite.load("buster_death", "Survivors/buster/death", 8, 48, 13),
    -- decoy from Crudely Drawn Buddy
    decoy = Sprite.load("buster_decoy", "Survivors/buster/decoy", 1, 9, 18),
}

local sprBlast = Sprite.load("buster_blast", "Survivors/buster/blast", 10, 0, 0)
local sprSkills = Sprite.load("buster_skills", "Survivors/buster/skills", 5, 0, 0)

-- Description and skill icons
buster:setLoadoutInfo(
[[&y&Buster&!& is a master of explosives, he fearlessly charges into battle]]
, sprSkills)

-- Character select skill descriptions
buster:setLoadoutSkill(1, "Blast Strike", 
[[Charge up a strike and release it to deal up to 500% damage]])

buster:setLoadoutSkill(2, "Blazing Slam", 
[[Immediately drop down and slam the ground, dealing up to 300% damage and launching enemies into the air while setting them ablaze.]])

buster:setLoadoutSkill(3, "Slide Boost", 
[[Slide a short distance in the direction you are walking, or up in the air while standing still
Instantly charges the Charge Punch to full and cancels other actions when used]])

buster:setLoadoutSkill(4, "Explosive Scarf", 
[[Release 10 explosives around you, that will detonate after 1 second for 250% damage each]])

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
    "Charge up for up to 500% damage",
    sprSkills, 1,
    0.5 * 60
    )

    player:setSkill(2,
    "Blazing Slam",
    "Slam into the ground for up to 300% damage",
    sprSkills, 2,
    3 * 60
    )

    player:setSkill(3,
    "Slide Boost",
    "Slide along the ground or boost into the air depending on movement",
    sprSkills, 3,
    1 * 60
    )

    player:setSkill(4,
    "Explosive Scarf",
    "Release 10 explosives around you, detonating after 1 second for 250% damage",
    sprSkills, 4,
    6 * 60
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
    if player:control("ability1") == input.NEUTRAL and player:getData().blastCharging == true then
        if player:get("activity") == 0 then
            -- Activate Z skill
            player:survivorActivityState(1, sprBlast, 0.25, true, true)
        end
        player:getData().blastCharging = false
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
        end
        if skill == 1 and player:getData().blastCharging == true then
            player:getData().blastCharge = player:getData().blastCharge + 1
        end


		if skill == 2 then
			-- X skill
            player:survivorActivityState(2, sprSlam, 0.25, true, true)
		elseif skill == 3 then
			-- C skill
            player:survivorActivityState(3, sprSlide, 0.25, false, false)
            player:getData().blastCharge = 100 -- Insert full bar
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

                    -- Input some variables based on how long you charged
					local bullet = player:fireExplosion(player.x + player.xscale * 50, player.y, 100 / 19, 10 / 4, 5, nil, sprSparks7)
                    
				end
			end
			
			-- Play explosion sound effect
			
		end
		
		
	elseif skill == 2 then
		-- X skill: slam

        -- Slam down
		if relevantFrame == 4 then

		end
        
	elseif skill == 3 then
		-- C skill: slide

		if relevantFrame == 8 then
			-- Ran on the last frame of the animation
			
		else
			-- Ran all other frames of the animation

		end
		
		
		
	elseif skill == 4 then
		-- V skill: Skull charge

		if relevantFrame == 4 then
		

		end
	
	end
end)
