-- Menu stuff
local red = 0
local green = 0
local blue = 0
local rainbowTimer = 0

-- Show version on title screen
callback.register("globalRoomStart", function(room)
	local function drawName()
		if room == Room.find("Start") then
			local width, height = graphics.getGameResolution()

			rainbowTimer = rainbowTimer + 1

			if rainbowTimer > 20 then
				red = math.random(0, 255)
				green = math.random(0, 255)
				blue = math.random(0, 255)
				
				rainbowTimer = 0
			end

			graphics.color(Color.fromRGB(red, green, blue))
			--graphics.color(Color.fromHex(0x808080))

			local yOffset = 0

			if modloader.checkMod("StarStorm") then
				yOffset = 10
			end

			graphics.print("Turbo Edition " .. modloader.getModVersion("Turbo Edition"), width - 3, 3 + yOffset, graphics.FONT_SMALL, graphics.ALIGN_RIGHT)
		end
	end

	graphics.bindDepth(-99, drawName)
end)


