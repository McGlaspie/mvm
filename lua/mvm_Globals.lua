//
//	Override of ns2/lua/Globals.lua
//	This does not overwrite all values in global file. Just select
//	few variables specific to MvM


kTeam1Type = kMarineTeamType
kTeam2Type = kMarineTeamType

//Note: the game end text is pulled from gamestring file
kTeam1Name = "Blue Team"
kTeam2Name = "Gold Team"


kInventoryIconsTexture = "ui/inventory_icons.dds"
kInventoryIconsTextureTeam2 = "ui/inventory_icons_team2.dds"


//MvM: Change later for Team Directives, or add new
// How far from the order location must units be to complete it.
kAIMoveOrderCompleteDistance = 0.01
kPlayerMoveOrderCompleteDistance = 1.5


kPlayerLOSDistance = 30		//NS2: 20	????: Performance hit through blips?
kStructureLOSDistance = 5	//NS2 3.5


// 
// ColorSkinMixin Globals
// This file is only here to separate these settings into its own file.
// Typically for most mods, these settings would be placed in Global.lua
//

kTeam1_BaseColor = Color(0.302, 0.859, 1, 1)
kTeam1_AccentColor = Color(0.756, 0.982, 1, 1)
kTeam1_TrimColor = Color(0.5, 0.5, 0.5, 1)

kTeam2_BaseColor = Color(0.61, 0.43, 0.16, 1)
kTeam2_AccentColor = Color(1.0, 0.0, 0.0, 1)
kTeam2_TrimColor = Color(0.32, 0.2, 0.2, 1)

