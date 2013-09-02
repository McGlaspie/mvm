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


