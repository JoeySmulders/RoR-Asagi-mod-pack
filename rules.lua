local spitefulOnhit = Rule.new("Spiteful on hit")
spitefulOnhit.id = 1
spitefulOnhit.type = "choice"
spitefulOnhit.default = 1
spitefulOnhit.tooltip = "Change the amount of spiteballs generated on hit"
spitefulOnhit.options = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 100}

local turbo = Rule.new("Turbo Artifact speed")
turbo.id = 2
turbo.type = "choice"
turbo.default = 1.2
turbo.tooltip = "Change the speed of the game by this multiplier"
turbo.options = {0.5, 1, 1.2, 1.5, 2, 3}

local spitefulBounce = Rule.new("Spiteful on bounce")
spitefulBounce.id = 3
spitefulBounce.type = "checkbox"
spitefulBounce.default = true
spitefulBounce.tooltip = "Enable extra spiteball being generated when both spite and spiteful are enabled"

local test2 = Rule.new("Placeholder 2")

local spitefulOnbounce = Rule.new("Amount generated on bounce")
spitefulOnbounce.id = 5
spitefulOnbounce.type = "choice"
spitefulOnbounce.default = 1
spitefulOnbounce.tooltip = "How many extra spiteballs are generated on each bounce"
spitefulOnbounce.options = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 100}
spitefulOnbounce.isSub = 3

local test3 = Rule.new("Placeholder 3")

local spitefulPlayerDeath = Rule.new("Player death creates spite")
spitefulPlayerDeath.id = 7
spitefulPlayerDeath.type = "choice"
spitefulPlayerDeath.default = 50
spitefulPlayerDeath.tooltip = "How many friendly spite balls are created on player death"
spitefulPlayerDeath.options = {0, 1, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 1000}

