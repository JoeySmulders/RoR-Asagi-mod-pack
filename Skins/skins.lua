local chirr = Survivor.find("Chirr")

local sprites = {
    idle = Sprite.load("MaidChirrIdle", "Skins/Chirr/Maid/idle", 1, 12, 11),
    walk = Sprite.find("Beastmaster_Walk"),
	jump = Sprite.find("Beastmaster_Jump"),
	climb = Sprite.find("Beastmaster_Climb"),
    death = Sprite.find("Beastmaster_Death"),
    -- decoy from Crudely Drawn Buddy
    decoy = Sprite.find("Beastmaster_Decoy"),
}

SurvivorSkin.new(chirr, "Maid Chirr", Sprite.find("Beastmaster_Select"), sprites, Color.BLACK)