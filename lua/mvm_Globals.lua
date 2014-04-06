//
//	Override of ns2/lua/Globals.lua
//	This does not overwrite all values in global file. Just select
//	few variables specific to MvM


kTeam1Type = kMarineTeamType
kTeam2Type = kMarineTeamType

//Note: the game end text is pulled from gamestring file
kTeam1Name = "Blue Team"
kTeam2Name = "Gold Team"

//TODO Remove below
kInventoryIconsTexture = "ui/inventory_icons.dds"


//MvM: Change later for Team Directives, or add new
// How far from the order location must units be to complete it.
kAIMoveOrderCompleteDistance = 0.01
kPlayerMoveOrderCompleteDistance = 1.5

kMaxRelevancyDistance = 50	//NS2 40 - This WILL have performance impact

kPlayerLOSDistance = 30		//NS2: 20	????: Performance hit through blips?
kStructureLOSDistance = 5	//NS2 3.5



kNameTagFontColors = { 
	[kTeam1Index] = kMarineFontColor,
	[kTeam2Index] = kAlienFontColor,
    [kTeamReadyRoom] = kNeutralFontColor 
}

kNameTagFontNames = { 
	[kTeam1Index] = kMarineFontName,
	[kTeam2Index] = kAlienFontName,
	[kTeamReadyRoom] = kNeutralFontName 
}

kHealthBarColors = { 
	[kTeam1Index] = Color(0.725, 0.921, 0.949, 1),
	[kTeam2Index] = Color(0.776, 0.364, 0.031, 1),
	[kTeamReadyRoom] = Color(1, 1, 1, 1) 
}

kArmorBarColors = { 
	[kTeam1Index] = Color(0.078, 0.878, 0.984, 1),
	[kTeam2Index] = Color(0.576, 0.194, 0.011, 1),
	[kTeamReadyRoom] = Color(0.5, 0.5, 0.5, 1) 
}

kIconColors = {
    [kTeam1Index] = Color(0.8, 0.96, 1, 1),
    [kTeam2Index] = Color(1, 0.9, 0.4, 1),
    [kTeamReadyRoom] = Color(1, 1, 1, 1),
}


kMinimapBlipType = enum({
	'Undefined', 'TechPoint', 'ResourcePoint', 'Scan', 'EtherealGate', 'HighlightWorld',
	'Sentry', 'CommandStation',
	'Extractor', 'InfantryPortal', 'Armory', 'AdvancedArmory', 'PhaseGate', 'Observatory',
	'RoboticsFactory', 'ArmsLab', 'PrototypeLab',
	'Hive', 'Harvester', 'Hydra', 'Egg', 'Embryo', 'Crag', 'Whip', 'Shade', 'Shift', 'Shell', 'Veil', 'Spur', 'TunnelEntrance',
	'Marine', 'JetpackMarine', 'Exo', 'Skulk', 'Lerk', 'Onos', 'Fade', 'Gorge',
	'Door', 'PowerPoint', 'DestroyedPowerPoint',
	'ARC', 'Drifter', 'MAC', 'Infestation', 'InfestationDying', 'MoveOrder', 'AttackOrder', 'BuildOrder', 'SensorBlip', 'SentryBattery' 
})

kMinimapBlipTeam = enum({
	'Friendly', 'Enemy', 'Neutral', 
	'Alien', 'Marine', 
	'FriendAlien', 'FriendMarine', 
	'InactiveAlien', 'InactiveMarine' 
})

//FIXME change IsPulsed to Shocked
kGameEffect = CreateBitMask( {"InUmbra", "Fury", "Cloaked", "Parasite", "NearDeath", "OnFire", "OnInfestation", "Beacon", "Energize", "IsPulsed" } )
kGameEffectMax = bit.lshift( 1, GetBitMaskNumBits(kGameEffect) )



// Death message indices 
kDeathMessageIcon = enum( { 
	'None', 
	'Rifle', 'RifleButt', 'Pistol', 'Axe', 'Shotgun',
	'Flamethrower', 'ARC', 'Grenade', 'Sentry', 'Welder',
	'Bite', 'HydraSpike', 'Spray', 'Spikes', 'Parasite',
	'SporeCloud', 'Swipe', 'BuildAbility', 'Whip', 'BileBomb',
	'Mine', 'Gore', 'Spit', 'Jetpack', 'Claw',
	'Minigun', 'Vortex', 'LerkBite', 'Umbra', 
	'Xenocide', 'Blink', 'Leap', 'Stomp',
	'Consumed', 'GL', 'Recycled', 'Babbler', 'Railgun', 'BabblerAbility', 'GorgeTunnel', 'BoneShield',
	'ClusterGrenade', 'GasGrenade', 'PulseGrenade', 'Stab', 'WhipBomb',
})



// 
// ColorSkinMixin Globals
// This file is only here to separate these settings into its own file.
// Typically for most mods, these settings would be placed in Global.lua
//
kTeam1_BaseColor = Color(0.042, 0.06, 0.095, 1)
//kTeam1_BaseColor = Color(0.048, 0.178, 0.484, 1)
kTeam1_AccentColor = Color(0.756, 0.982, 1, 1)
kTeam1_TrimColor = Color(0.725, 0.921, 0.949, 1)

kTeam2_BaseColor = Color(0.14, 0.074, 0.015, 1)
kTeam2_AccentColor = Color(1.0, 0.0, 0.0, 1)
kTeam2_TrimColor = Color(0.179, 0.141, 0.095, 1)

kNeutral_BaseColor = Color( 0.5, 0.5, 0.5, 1 )
kNeutral_AccentColor = Color( 1, 1, 1, 1 )
kNeutral_TrimColor = Color( 0, 0, 0, 1 )
//TODO Devise color [sets] for UI based shaders

