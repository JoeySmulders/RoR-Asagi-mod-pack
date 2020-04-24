-- Stack info used by StarStorms detailed Tab Menu. (Item, max stack count, item info, stack info)

-- common
TabMenu.setItemInfo(Item.find("Angel Wings"), nil, "Increases damage while in the air by 20%", "+10% damage")
TabMenu.setItemInfo(Item.find("Suspicious log"), 10, "Shoot out ninja stars every 10 seconds", "-1 seconds")
TabMenu.setItemInfo(Item.find("Mirror shard"), 19, "10% on attack to create a shadow partner for 1 second", "+5% chance")
TabMenu.setItemInfo(Item.find("Broken LAN cable"), nil, "Delay damage taken by 2 seconds", "+1 second delay")

-- uncommon
TabMenu.setItemInfo(Item.find("Soul Taker"), nil, "Hitting an enemy increases damage by 1, damage is lost when you take damage", "+1 damage")
TabMenu.setItemInfo(Item.find("Blood Economy"), nil, "Gain 10% of damage dealt or taken as gold", "10% more gold")
TabMenu.setItemInfo(Item.find("Thieves Hat"), nil, "Boost forward when jumping in midair while holding a direction", "50% of speed added to boost")

-- rare
TabMenu.setItemInfo(Item.find("Punching Bag"), 4, "Reduce damage taken by 80% when standing perfectly still", "+3% reduced damage")
TabMenu.setItemInfo(Item.find("Uranium Bullets"), 6, "Deal 1% of enemy max hp per 100% damage dealt as extra damage", "-10% damage needed per 1% extra damage")
TabMenu.setItemInfo(Item.find("Super Stickies"), nil, "5% chance on hit to attach 3 stickies that deal 600% damage", "+2 stickies")