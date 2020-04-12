-- See if you can do this in a way that isn't just stealing starstorms code
pobj = {}
for _, parentObject in ipairs(ParentObject.findAll("Vanilla")) do
	pobj[parentObject:getName()] = parentObject
end

-- Add the Night character
local night = Survivor.new("Night")

-- Insert general sprites (idle,walk,jump,climb,death), numbers are amount of frames, x origin and y origin
local sprites = {
    idle = Sprite.load("night_idle", "night/idle", 1, 5, 7),
    walk = Sprite.load("night_walk", "night/walk", 6, 5, 7),
	jump = Sprite.load("night_jump", "night/jump", 1, 5, 7),
	climb = Sprite.load("night_climb", "night/climb", 2, 5, 7),
    death = Sprite.load("night_death", "night/death", 8, 48, 13),
    -- decoy from Crudely Drawn Buddy
    decoy = Sprite.load("night_decoy", "night/decoy", 1, 9, 18),
}

-- Insert attack sprites
local sprSlash = Sprite.load("night_slash", "night/sprSlash", 7, 6, 9)
local sprThrow = Sprite.load("night_throw", "night/shoot2", 5, 4, 11)
local sprSlide = Sprite.load("night_slide", "night/shoot3", 9, 6, 8)
local sprSkull = Sprite.load("night_skull", "night/shoot4", 15, 4, 19)

local sprSkills = Sprite.load("night_skills", "night/skills", 5, 0, 0)

-- Description and skill icons
night:setLoadoutInfo(
[[&y&Night&!& is a ...]]
, sprSkills)

-- Character select skill descriptions
night:setLoadoutSkill(1, "Slash", 
[[Slash with the scythe for &y&175% damage&!&.]])

night:setLoadoutSkill(2, "Throw Scythe", 
[[Throw the scythe forward. After hitting an enemy it will stay and spin in place, 
damaging all enemies for &y&150% damage per second&!&, then &y&exploding for 300% damage&!&]])

night:setLoadoutSkill(3, "Slide", 
[[Slide along the ground, &y&becoming invincible and pushing enemies with you, stunning them&!&.]])

night:setLoadoutSkill(4, "Homing Skulls", 
[[&y&Charge up&!& when the button is held down. 
When the button is released, create multiple flaming skulls that home into enemies
and explode on contact for &y&200% damage&!&.]])

-- Extra menu sprite
night.idleSprite = sprites.idle

-- character skill name color
night.loadoutColor = Color.fromRGB(137, 30, 43)

-- Sprite for character select
night.loadoutSprite = Sprite.load("night_select", "night/select", 4, 2, 0)

-- Character walk animation on title screen
night.titleSprite = sprites.walk

-- Quote displayed when beating the game
night.endingQuote = "god i'm cute"

-- Scythe Object
local objScythe = Object.new("NightScythe")
objScythe.sprite = Sprite.load("NightScythe", "Night/scythe", 1, 5, 6)
objScythe.depth = 0.1
local enemies = pobj.enemies

-- Scythe creation and variables
objScythe:addCallback("create", function(objScythe)
	local objScytheAc = objScythe:getAccessor()
	objScytheAc.parent = player
	objScytheAc.life = 4 * 60
	objScytheAc.speed = 2
	objScytheAc.size = 1
	objScytheAc.damage = 0.6
	objScythe.spriteSpeed = 0.25
end)


-- Scythe function called every step
objScythe:addCallback("step", function(objScythe)
	local objScytheAc = objScythe:getAccessor()
	local parent = Object.findInstance(objScytheAc.parent)

	local enemy = enemies:findNearest(objScythe.x, objScythe.y)

	-- Check direction to see which way to spin
	if objScytheAc.direction == 0 then
		objScythe.angle = objScythe.angle - 20	
	else
		objScythe.angle = objScythe.angle + 20		
	end

	-- Create an explosion the size of the sprite every 12 game ticks if the scythe has stopped moving
	if objScytheAc.life % 12 == 0 and objScytheAc.speed == 0 then
		scytheHit = parent:fireExplosion(objScythe.x, objScythe.y, objScythe.sprite.width / 19, objScythe.sprite.height / 4, objScytheAc.damage, nil, nil)
		scytheHit:set("knockback", 4)
	end

	-- If the scythe collides with an enemy it stops moving
	if enemy then
		if objScytheAc.parent and objScythe:collidesWith(enemy, objScythe.x, objScythe.y) and enemy:get("team") ~= parent:get("team") then
			objScytheAc.speed = 0
		end
	end

	-- Destroy the scythe when lifetime reaches 0
	if objScytheAc.life == 0 then
		parent:fireExplosion(objScythe.x, objScythe.y, (objScythe.sprite.width * 3) / 19, (objScythe.sprite.height * 3) / 4, objScytheAc.damage * 10, nil, nil)
		objScythe:destroy()
	else
		objScytheAc.life = objScytheAc.life - 1
	end

end)

-- Skull object
local objSkull = Object.new("NightSkull")
objSkull.sprite = Sprite.load("NightSkull", "Night/skull", 1, 7, 10)
objSkull.depth = 1

-- Skull creation and variables
objSkull:addCallback("create", function(objSkull)
	local objSkullAc = objSkull:getAccessor()
	objSkullAc.life = (8 + math.random()) * 60
	objSkullAc.speed = 0
	objSkullAc.size = 1
	objSkullAc.damage = 2
	objSkull.spriteSpeed = 0.25
	objSkull.angle = math.random(0,360)
end)

-- Skull function called every step
objSkull:addCallback("step", function(objSkull)
	local objSkullAc = objSkull:getAccessor()
	local parent = Object.findInstance(objSkullAc.parent)
	local realSpeed = 3
	local rotationSpeed = 3
	local enemy = enemies:findNearest(objSkull.x, objSkull.y)

	local mathX = 0
	local mathY = 0

	-- Code to make it rotate towards the closest enemy and fly in the direction it's facing
	if enemy then
		mathX = enemy.x - objSkull.x
		mathY = enemy.y	- objSkull.y 

		local goalAngle = math.atan2(mathY, mathX) * 180 / math.pi

		-- Change this for a real equation so it works 100% consistent.
		if goalAngle > objSkull.angle then
			objSkull.angle = objSkull.angle + rotationSpeed
		else
			objSkull.angle = objSkull.angle - rotationSpeed
		end

	else
		-- Rotate in a circle until it finds a target
		objSkull.angle = objSkull.angle + rotationSpeed
	end

	local xDirection = math.cos(objSkull.angle * math.pi / 180)
	local yDirection = math.sin(objSkull.angle * math.pi / 180)

	objSkull.x = objSkull.x + xDirection * realSpeed
	objSkull.y = objSkull.y + yDirection * realSpeed

	-- If the skull collides with an enemy it explodes
	if enemy then
		if objSkullAc.parent and objSkull:collidesWith(enemy, objSkull.x, objSkull.y) then
			parent:fireExplosion(objSkull.x, objSkull.y, (objSkull.sprite.width * 3) / 19, (objSkull.sprite.height * 3) / 4, objSkullAc.damage, nil, nil)

			-- If the player has Scepter, create a scythe
			if parent:get("scepter") > 0 then
				local scythe = objScythe:create(objSkull.x, objSkull.y)
				scythe:set("parent", parent.id)
				scythe:set("direction", 0)
				scythe:set("speed", 0)
				
			end

			objSkull:destroy()
		end
	end
	if objSkullAc.life <= 0 then
		objSkull:destroy()
	else
		objSkullAc.life = objSkullAc.life - 1
	end

end)

night:addCallback("init", function(player)
    -- Set player animations
    player:setAnimations(sprites)

    -- survivor starting stats (health, damage, regen)
    player:survivorSetInitialStats(110, 10, 0.02)

    -- set player skill icons (last number is cooldown in frames)
    player:setSkill(1,
    "Slash",
    "Slash with the scythe for 175% damage.",
    sprSkills, 1,
    0.5 * 60
    )

    player:setSkill(2,
    "Throw Scythe",
    "Throw the scythe forward, spinning in place after hitting an enemy for 150% damage per second then exploding for 300% damage",
    sprSkills, 2,
    7 * 60
    )

    player:setSkill(3,
    "Slide",
    "Slide along the ground, becoming invincible and pushing enemies with you.",
    sprSkills, 3,
    6 * 60
    )

    player:setSkill(4,
    "Homing Skulls",
    "Charge up while holding the button, then release multiple skulls that home into enemies for 200% damage",
    sprSkills, 4,
    12 * 60
    )

end)

-- Increase character stats on levelup
night:addCallback("levelUp", function(player)
    -- (health, damage, regen, armor)
    player:survivorLevelUpStats(25, 4, 0.002, 1)
end)

-- Change skill 4 description when scepter is picked up
night:addCallback("scepter", function(player)
    player:setSkill(4,
    "Red Hell Skulls",
    "Charge up while holding the button, then release multiple skulls that home into enemies for 200% damage and create scythes that deal 150% damage per second",
    sprSkills, 5,
    12 * 60
    )
end)

-- Called when the player tries to use a skill 
night:addCallback("useSkill", function(player, skill)
	-- Make sure the player isn't doing anything when pressing the button
	if player:get("activity") == 0 then
		-- Set the player's state (skill index, animation, animation speed (times 60 fps), scalespeed (true for scaling with attack speed), resetHSpeed (true if you can't move on the ground during it))
		if skill == 1 then
			-- Z skill
			player:survivorActivityState(1, sprSlash, 0.25, true, true)
		elseif skill == 2 then
			-- X skill
			player:survivorActivityState(2, sprThrow, 0.25, true, true)
		elseif skill == 3 then
			-- C skill
			player:survivorActivityState(3, sprSlide, 0.25, false, false)
		elseif skill == 4 then
			-- V skill
			player:survivorActivityState(4, sprSkull, 0.25, true, true)
		end
		
		-- Put the skill on cooldown
		player:activateSkillCooldown(skill)
	end
end)

-- Called each frame the player is in a skill state
night:addCallback("onSkill", function(player, skill, relevantFrame)
	-- The 'relevantFrame' argument is set to the current animation frame only when the animation frame is changed
	-- Otherwise, it will be 0

	if skill == 1 then 
		-- Z skill: slash
		
		if relevantFrame == 4 then
			-- Code is ran when the 4th frame of the animation starts
			
			-- The "survivorFireHeavenCracker" method handles the effects of the item Heaven Cracker
			-- If the effect is triggered, it returns the fired bullet, otherwise it returns nil
			if player:survivorFireHeavenCracker(1) == nil then
				-- The player's "sp" variable is the attack multiplier given by Shattered Mirror
				for i = 0, player:get("sp") do
					-- Fires an explosion 13 pixels in front of the player with a width multiplier of 8, height multiplier of 2,
					-- dealing 1.75 damage and using the sprite "sparks7" from the base game as its hit sprite
					local bullet = player:fireExplosion(player.x + player.xscale * 13, player.y, 0.8, 2, 1.75, nil, sprSparks7)
					bullet:set("max_hit_number", 5)
					if i ~= 0 then
						-- Makes the damage text pop up higher if firing multiple attacks at once
						bullet:set("climb", i * 8)
					end
				end
			end
			
			-- Play slash sound effect
			
		end
		
		
	elseif skill == 2 then
		-- X skill: throw

		if relevantFrame == 4 then
			local scythe = objScythe:create(player.x, player.y)
			scythe:set("direction", player:getFacingDirection())
			scythe:set("parent", player.id)
		end
        
	elseif skill == 3 then
		-- C skill: slide

		-- "Push" enemies with you while sliding (See if it's possible to make collision hitbox larger so you don't move past small enemies at high speeds)
		for _, enemy in ipairs(enemies:findAll()) do
			if enemy and player:collidesWith(enemy, player.x, player.y) then
				if not enemy:isBoss() then
					if player:getFacingDirection() == 0 then
						if not enemy:collidesMap(enemy.x + 10, enemy.y) then
							enemy.x = enemy.x + player:get("pHspeed")
						end
					else
						if not enemy:collidesMap(enemy.x - 10, enemy.y) then
							enemy.x = enemy.x + player:get("pHspeed")
						end
					end
				end
			end
		end

		if relevantFrame == 7 then
			-- Stun enemies for 2 second
			slideExplosion = player:fireExplosion(player.x, player.y, (player.sprite.width * 2) / 19, (player.sprite.height * 2) / 4, 1, nil, nil)
			slideExplosion:set("stun", 1.34)
		end

		if relevantFrame == 8 then
			-- Ran on the last frame of the animation
			
			-- Reset the player's invincibility
			if player:get("invincible") <= 5 then
				player:set("invincible", 0)
			end
		else
			-- Ran all other frames of the animation

			-- Make the player invincible
			-- Only set the invincibility when below a certain value to make sure we don't override other invincibility effects
			if player:get("invincible") < 5 then
				player:set("invincible", 5)
			end
			
			-- Set the player's horizontal speed
			player:set("pHspeed", player:get("pHmax") * 3 * player.xscale)
		end
		
		
		
	elseif skill == 4 then
		-- V skill: Skull charge

		if relevantFrame == 4 then
			local xOffset = -80
			local yOffset = 40
			for i = 1, 6, 1 do

				if i <= 3 then
					yOffset = yOffset + 20
				end
				if i > 4 then
					yOffset = yOffset - 20
				end


				local skull = objSkull:create(player.x + xOffset, player.y - yOffset)
				skull:set("parent", player.id)


				xOffset = xOffset + 40
			end
		end
	
	end
end)
