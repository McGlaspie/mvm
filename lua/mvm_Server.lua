//
//	Marine vs Marine - NS2 Mod
//	Copyright 2013 - Brock 'McGlaspie' Gillespie
//

decoda_name = "Server"


Script.Load("lua/Server.lua")

Script.Load("lua/mvm_Shared.lua")
Script.Load("lua/mvm/TechData.lua")
Script.Load("lua/mvm/TargetCache.lua")
Script.Load("lua/mvm/MarineTeam.lua")

Script.Load("lua/mvm/bots/Bot.lua")

Script.Load("lua/mvm/VoteManager.lua")
Script.Load("lua/mvm/Voting.lua")
Script.Load("lua/mvm/VotingKickPlayer.lua")
Script.Load("lua/mvm/VotingChangeMap.lua")
Script.Load("lua/mvm/VotingResetGame.lua")
Script.Load("lua/mvm/VotingRandomizeRR.lua")
Script.Load("lua/mvm/VotingForceEvenTeams.lua")
