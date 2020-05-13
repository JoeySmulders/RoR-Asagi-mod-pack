-- Add the Buster character
local buster = Survivor.new("Buster")

-- Insert general sprites (idle,walk,jump,climb,death), numbers are amount of frames, x origin and y origin
local sprites = {
    idle = Sprite.load("buster_idle", "Survivors/buster/idle", 1, 5, 6),
    walk = Sprite.load("buster_walk", "Survivors/buster/walk", 7, 5, 6),
	jump = Sprite.load("buster_jump", "Survivors/buster/jump", 1, 5, 6),
	climb = Sprite.load("buster_climb", "Survivors/buster/climb", 2, 5, 6),
    death = Sprite.load("buster_death", "Survivors/buster/death", 3, 9, 6),
    -- decoy from Crudely Drawn Buddy
    decoy = Sprite.load("buster_decoy", "Survivors/buster/decoy", 1, 9, 18),
}

local sprBlast = Sprite.load("buster_blast", "Survivors/buster/blast", 5, 6, 5)
local sprBlast1 = Sprite.load("buster_blast1", "Survivors/buster/blast1", 3, 3, 3)
local sprBlast1left = Sprite.load("buster_blast1left", "Survivors/buster/blast1left", 3, 7, 3)
local sprBlast2 = Sprite.load("buster_blast2", "Survivors/buster/blast2", 3, 10, 3)
local sprBlast2left = Sprite.load("buster_blast2left", "Survivors/buster/blast2left", 3, 10, 3)
local sprBlast3 = Sprite.load("buster_blast3", "Survivors/buster/blast3", 3, 20, 3)
local sprBlast3left = Sprite.load("buster_blast3left", "Survivors/buster/blast3left", 3, 20, 3)
local sprBlast4 = Sprite.load("buster_blast4", "Survivors/buster/blast4", 3, 60, 9)
local sprBlast4left = Sprite.load("buster_blast4left", "Survivors/buster/blast4left", 3, 60, 9)

local sprBar = Sprite.load("buster_bar", "Survivors/buster/bar", 1, 0, 0)
local sprSlam = Sprite.load("buster_slam", "Survivors/buster/dunk", 3, 5, 12)
local sprSlamDunk = Sprite.load("buster_slamDunk", "Survivors/buster/dunkblast", 3, 23, 14)

local sprDash = Sprite.load("buster_dash", "Survivors/buster/dash", 5, 10, 16)
local sprExplosive = Sprite.load("buster_explosive", "Survivors/buster/scarf", 4, 5, 8)
local sprExplosion = Sprite.load("buster_explosion", "Survivors/buster/explosion", 3, 14, 14)

local sprSkills = Sprite.load("buster_skills", "Survivors/buster/skills", 5, 0, 0)

local customBar = Object.find("CustomBar")

-- sounds
local sBusterSkill1 = Sound.load("BusterSkill1", "Survivors/buster/skill1")
local sBusterSkill2 = Sound.load("BusterSkill2", "Survivors/buster/skill2")
local sBusterExplosion = Sound.load("BusterExplosion", "Survivors/buster/explosion")

-- explosion Object
local objExplode = Object.new("ExplosiveScarf")
objExplode.sprite = Sprite.load("ExplosiveScarf", "Survivors/buster/bomb", 1, 5, 5)
objExplode.depth = -14

-- Explosive creation and variables
objExplode:addCallback("create", function(objExplode)
	local objExplodeAc = objExplode:getAccessor()
	objExplodeAc.life = 5 * 60
	objExplodeAc.speed = 0
	objExplodeAc.size = 1
	objExplodeAc.damage = 1
    objExplode.spriteSpeed = 0.25
    objExplode:getData().velocity = -4
end)

objExplode:addCallback("destroy", function(obj)
    local objExplodeAc = obj:getAccessor()
    local parent = Object.findInstance(objExplodeAc.parent)
    
    if parent:isValid() then
        parent:fireExplosion(obj.x, obj.y, (sprExplosion.width) / 19, (sprExplosion.height) / 4, objExplodeAc.damage, sprExplosion, nil, DAMAGER_NO_PROC)
        
        -- Play explosion sound effect
        sBusterExplosion:play(0.9 + math.random() * 0.2)
    end
end)

-- Explosive function called every step
objExplode:addCallback("step", function(objExplode)
	local objExplodeAc = objExplode:getAccessor()

    if not objExplode:getData().stickied == true then
        objExplode.angle = objExplode.angle + objExplode:getData().rotation

        objExplode.y = objExplode.y + objExplode:getData().velocity
        objExplode.x = objExplode.x + objExplode:getData().xVelocity

        objExplode:getData().velocity = objExplode:getData().velocity + 0.1
    end

    local enemy = enemies:findNearest(objExplode.x, objExplode.y)

    if enemy and (objExplode:collidesWith(enemy, objExplode.x, objExplode.y) or objExplode:getData().stickied) then
        if objExplode:getData().sticky == true then
            objExplode.x = enemy.x + objExplode:getData().stickyOffset
            objExplode.y = enemy.y + objExplode:getData().stickyOffset
            objExplodeAc.damage = 3
            if objExplode:getData().stickied ~= true then
                objExplodeAc.life = 2 * 60
                objExplode:getData().stickied = true
            end
            
        else          
            objExplode:destroy()
        end
    end

    if objExplode:isValid() then
        if objExplodeAc.life == 0 then
            objExplode:destroy()
        elseif objExplode:collidesMap(objExplode.x, objExplode.y) and not objExplode:getData().stickied == true then
            objExplode:destroy()
        else
            objExplodeAc.life = objExplodeAc.life - 1
        end
    end

end)


-- Description and skill icons
buster:setLoadoutInfo(
[[&y&Buster&!& is a master of explosives, he fearlessly charges into battle
This survivor focuses on using positioning and timing to deliver high damage at close ranges]]
, sprSkills)

-- Character select skill descriptions
buster:setLoadoutSkill(1, "Blast Strike", 
[[Charge up a strike and release it to deal &y&up to 500% damage&!&.
The attack can be &b&charged during other actions&!&, but deals &r&self damage if left at full charge&!&.]])

buster:setLoadoutSkill(2, "Blazing Slam", 
[[Immediately drop down and slam the ground, dealing &y&up to 300% damage&!& based on distance fallen.
On impact, &y&launches enemies into the air&!& while setting them &y&ablaze for 30% of the damage dealt&!&.]])

buster:setLoadoutSkill(3, "Slide Boost", 
[[&y&Slide a short distance&!& in the direction you are walking, or &y&up into the air&!& while not moving.
&b&Instantly charges Blast Strike to full&!& when used while charging, and &b&jumping cancels the slide&!&.]])

buster:setLoadoutSkill(4, "Explosive Scarf", 
[[Release &y&10 explosives&!& around you that will detonate when hitting the ground or an enemy for &y&100% damage each&!&.]])

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
    player:survivorSetInitialStats(130, 9, 0.01)

    -- set player skill icons (last number is cooldown in frames)
    player:setSkill(1,
    "Blast Strike",
    "Charge up a strike for up to 500% damage",
    sprSkills, 1,
    0.5 * 60
    )

    player:setSkill(2,
    "Blazing Slam",
    "Slam into the ground for up to 300% damage, knocking up enemies and setting them ablaze",
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
    "Release 10 explosives around you, detonating after hitting the ground or an enemy for 100% damage",
    sprSkills, 4,
    10 * 60
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
    "Sticky Explosive Scarf",
    "Release 10 explosives around you, detonating after hitting the ground for 100% damage or sticking to enemies for 300% damage",
    sprSkills, 5,
    10 * 60
    )
end)

-- Only perform the actual skill once the player sends a packet telling them to do it
playerBlast = net.Packet("Buster Blast Sync", function(player)
    if player:get("activity") == 0 then
        -- Activate Z skill
        player:survivorActivityState(1, sprBlast, 0.20, true, true)
    end
    player:getData().blastCharging = false
    player:getData().chargeDamage = false
    if player:getData().chargeBar and player:getData().chargeBar:isValid() then
        player:getData().chargeBar:destroy()
    end

    if net.host then
        playerBlast:sendAsHost(net.EXCLUDE, player)
    end
end)


buster:addCallback("step", function(player)
    -- If the charge bar exists, increase the blastCharge timer
    if player:getData().chargeBar and player:getData().chargeBar:isValid() then
        if player:getData().blastCharge < 180 then
            player:getData().blastCharge = player:getData().blastCharge + (1 * player:get("attack_speed"))
        end
        -- If the timer is almost at the end, change the color and start taking damage
        if player:getData().chargeBar:get("time") < 2 then
            player:getData().chargeBar:set("barColor", Color.fromRGB(198,69,36).gml)
            player:getData().chargeBar:set("time", 2)
            player:getData().chargeDamage = true
        end
    end

    -- If the skill button is released, get rid of the charge bar and perform the attack if the player is capable of attacking
    if not net.online or net.localPlayer == player then
        if player:control("ability1") == input.NEUTRAL and player:getData().blastCharging == true then
            if player:get("activity") == 0 then
                -- Activate Z skill
                player:survivorActivityState(1, sprBlast, 0.20, true, true)
            end
            player:getData().blastCharging = false
            player:getData().chargeDamage = false
            if player:getData().chargeBar and player:getData().chargeBar:isValid() then
                player:getData().chargeBar:destroy()
            end

            if net.host then
                playerBlast:sendAsHost(net.ALL, nil)
            else
                playerBlast:sendAsClient()
            end
        end
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
            player:survivorActivityState(2, sprSlam, 0.10, true, true)
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
                if player:getData().chargeBar and player:getData().chargeBar:isValid() then
                    player:getData().chargeBar:set("time", 5)
                end
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

            local audio = 1
			-- The "survivorFireHeavenCracker" method handles the effects of the item Heaven Cracker
			-- If the effect is triggered, it returns the fired bullet, otherwise it returns nil
			if player:survivorFireHeavenCracker(1) == nil then
				-- The player's "sp" variable is the attack multiplier given by Shattered Mirror
                for i = 0, player:get("sp") do
                    local damage = 0
                    local sprite = sprBlast1
                    
                    -- Deal more damage based on how charged the attack is
                    if player:getData().blastCharge >= 180 then
                        damage = 5
                        audio = 2
                        if player:getFacingDirection() == 180 then
                            sprite = sprBlast4left
                        else
                            sprite = sprBlast4
                        end
                        
                    elseif player:getData().blastCharge > 120 then
                        damage = 3
                        audio = 1.5
                        if player:getFacingDirection() == 180 then
                            sprite = sprBlast3left
                        else
                            sprite = sprBlast3
                        end

                    elseif player:getData().blastCharge > 60 then
                        damage = 2
                        audio = 1.25
                        if player:getFacingDirection() == 180 then
                            sprite = sprBlast2left
                        else
                            sprite = sprBlast2
                        end

                    else
                        damage = 1
                        audio = 1
                        if player:getFacingDirection() == 180 then
                            sprite = sprBlast1left
                        else
                            sprite = sprBlast1
                        end
                        
                    end

                    -- Input some variables based on how long you charged
                    local bullet = player:fireExplosion(player.x + player.xscale * (sprite.width / 2), player.y + 1, (sprite.width / 2) / 19, sprite.height / 4, damage, sprite, sprSparks7)
                    bullet.spriteSpeed = 0.2
                    misc.shakeScreen(damage)
                    
				end
			end
			
			-- Play explosion sound effect
            sBusterSkill1:play(0.9 + math.random() * 0.2, audio)
		end
		
		
	elseif skill == 2 then
		-- X skill: slam

        -- Slam down
        if relevantFrame == 2 then
            
            -- Check if there is ground 150 pixels below the player, then teleport to that position
            local yOffset = 2
            local i = 0
            while not player:collidesMap(player.x, player.y + yOffset) do
                player.y = player.y + yOffset
                i = i + 1
                if i > 150 then
                    break
                end
            end

            local damage = 1 + (i / 75)

            local bullet = player:fireExplosion(player.x, player.y, sprSlamDunk.width / 19, sprSlamDunk.height / 4, damage, sprSlamDunk, sprSparks7)
            bullet.spriteSpeed = 0.2

            -- If starstorm is loaded set enemies on fire, maybe make it do more damage without it but ehhhhh why aren't you using it
            if modloader.checkMod("StarStorm") then
                DOT.addToDamager(bullet, DOT_FIRE, player:get("damage") * damage * 0.3, 3, "Slam", false)
            end

            -- Knockup enemies based on the damage done and shake the screen
            --bullet:set("blaze", 1) don't use this it gives errors
            bullet:set("knockup", (damage * 4))
            misc.shakeScreen(10)

            sBusterSkill2:play(0.9 + math.random() * 0.2, 1.75)


        end
        
	elseif skill == 3 then
		-- C skill: slide

        -- If going up, just give a vertical boost and end the ability
        if player:getData().slideUp == true then
            player:set("pVspeed", -1 * player:get("pVmax") * 1.5 * player.yscale)
            player:set("activity_type", 0)
            player:set("activity", 0)
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

        if relevantFrame == 3 then
            local xVelocity = -1
            for i = 1, 10, 1 do
                local explosive = objExplode:create(player.x, player.y)
                explosive:getData().xVelocity = xVelocity
                explosive:set("parent", player.id)
                explosive:getData().rotation = math.random(-5,5)
                xVelocity = xVelocity + 0.2
                if player:get("scepter") > 0 then
                    explosive:getData().stickyOffset = math.random(-5,5)
                    explosive:getData().sticky = true
                end
            end
		end
	
	end
end)


registercallback("onPlayerDeath", function(player)
    if player:getData().chargeBar and player:getData().chargeBar:isValid() then
        player:getData().chargeBar:destroy()
    end

end)