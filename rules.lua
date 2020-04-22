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
turbo.options = {0.5, 1, 1.2, 1.25, 1.3, 1.4, 1.5, 1.75, 2, 3, 10}

local spitefulBounce = Rule.new("Spiteful on bounce")
spitefulBounce.id = 3
spitefulBounce.type = "checkbox"
spitefulBounce.default = true
spitefulBounce.tooltip = "Enable extra spiteball being generated when both spite and spiteful are enabled"

local teleportChallenge = Rule.new("Teleport Challenge")
teleportChallenge.id = 4
teleportChallenge.type = "checkbox"
teleportChallenge.default = true
teleportChallenge.tooltip = "Allow using the teleporter again while the boss is active to spawn another boss and gain a clover"

local spitefulOnbounce = Rule.new("Amount generated on bounce")
spitefulOnbounce.id = 5
spitefulOnbounce.type = "choice"
spitefulOnbounce.default = 1
spitefulOnbounce.tooltip = "How many extra spiteballs are generated on each bounce"
spitefulOnbounce.options = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 100}
spitefulOnbounce.isSub = 3

local crate = Rule.new("Crate Respawn")
crate.id = 6
crate.type = "checkbox"
crate.default = true
crate.tooltip = "Respawn a command crate if the user using it dies"

local spitefulPlayerDeath = Rule.new("Player death creates spite")
spitefulPlayerDeath.id = 7
spitefulPlayerDeath.type = "choice"
spitefulPlayerDeath.default = 50
spitefulPlayerDeath.tooltip = "How many friendly spite balls are created on player death"
spitefulPlayerDeath.options = {0, 1, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 1000}

local crateBackout = Rule.new("Crate Backout")
crateBackout.id = 8
crateBackout.type = "checkbox"
crateBackout.default = true
crateBackout.tooltip = "Jumping while using a command crate will back out of using it"

local crateTeleporter = Rule.new("Crate on Teleporter")
crateTeleporter.id = 9
crateTeleporter.type = "checkbox"
crateTeleporter.default = true
crateTeleporter.tooltip = "Using a command crate that is overlapping with the teleporter will no longer activate the teleporter"