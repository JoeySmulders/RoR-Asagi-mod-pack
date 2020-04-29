-- Stack info used by StarStorms detailed Tab Menu. (Item, max stack count, item info, stack info)

-- common
TabMenu.setItemInfo(Item.find("Angel Wings"), nil, "Increases damage while in the air by 20%", "+7.5% damage")
TabMenu.setItemInfo(Item.find("Suspicious log"), 10, "Shoot out 8 ninja stars that deal 30% damage every 10 seconds", "-1 seconds")
TabMenu.setItemInfo(Item.find("Mirror shard"), 19, "10% on attack to create a shadow partner for 1 second", "+5% chance")
TabMenu.setItemInfo(Item.find("Broken LAN cable"), 6, "Delay damage taken by 1 second and reduce it by 10%", "+1 second delay, +2% reduced damage")

-- uncommon
TabMenu.setItemInfo(Item.find("Soul Taker"), nil, "Hitting an enemy increases damage by 1 (up to 100), damage is lost when you take damage", "+1 damage, +10 damage cap")
TabMenu.setItemInfo(Item.find("Blood Economy"), nil, "Gain 10% of damage dealt or taken as gold", "10% more gold")
TabMenu.setItemInfo(Item.find("Thieves Hat"), nil, "Boost forward when jumping in midair while holding a direction", "50% of speed added to boost")
TabMenu.setItemInfo(Item.find("Party Shroom"), nil, "Heal 5 hp per second to self and nearby allies", "+3hp per second, +10 radius")
TabMenu.setItemInfo(Item.find("Fan of Blades"), nil, "25% on hit to launch a blade at the hit enemy. The blade deals 100% + 25% for each prior blade that hit the target", "+25% initial damage")

-- rare
TabMenu.setItemInfo(Item.find("Punching Bag"), 4, "Reduce damage taken by 50% when standing perfectly still", "+5% reduced damage")
TabMenu.setItemInfo(Item.find("Uranium Bullets"), nil, "Deal 1% of enemy max hp per hit", "+0.5% enemy max hp")
TabMenu.setItemInfo(Item.find("Super Stickies"), nil, "5% chance on hit to attach 3 stickies that deal 600% damage", "+2 stickies")
TabMenu.setItemInfo(Item.find("Cursed Longsword"), nil, "Home in on the first target that comes close to you, then continiously deal 50% damage", "+25% damage")