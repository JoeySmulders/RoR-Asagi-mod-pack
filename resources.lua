enemies = ParentObject.find("Enemies", "Vanilla")
elite = EliteType.findAll("Vanilla")

originalElites = {
	elite.Blazing,
	elite.Overloading,
	elite.Frenzied,
	elite.Leeching,
	elite.Volatile
}

-- function stuff that I totally didn't steal
function distance ( x1, y1, x2, y2 )
	local dx = x1 - x2
	local dy = y1 - y2
	return math.sqrt ( dx * dx + dy * dy )
end

function angleDif(current, target)
    return ((((current - target) % 360) + 540) % 360) - 180
end