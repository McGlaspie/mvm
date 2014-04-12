//
//	MvM Client
//	Any additional loads for MvM are done after normal NS2 Client loaded.
//


decoda_name = "Client"


Script.Load("lua/Client.lua")	//Load normal NS2 Client

Script.Load("lua/mvm/MvMPrecacheList.lua")	//Cache MvM specific assets
Script.Load("lua/mvm_Shared.lua")
Script.Load("lua/mvm/ScoreDisplay.lua")
Script.Load("lua/mvm_ClientUI.lua")

Script.Load("lua/mvm/Voting.lua")
Script.Load("lua/mvm/VotingKickPlayer.lua")
Script.Load("lua/mvm/VotingChangeMap.lua")
Script.Load("lua/mvm/VotingResetGame.lua")
Script.Load("lua/mvm/VotingRandomizeRR.lua")
Script.Load("lua/mvm/VotingForceEvenTeams.lua")

