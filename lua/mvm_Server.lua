//
//	Marine vs Marine - NS2 Mod
//	Copyright 2013 - Brock 'McGlaspie' Gillespie
//

decoda_name = "Server"

Print(" \t MVM SERVER ")

Script.Load("lua/PreLoadMod.lua")
Script.Load("lua/Server.lua")


Script.Load("lua/mvm_Shared.lua")
Script.Load("lua/mvm/TargetCache.lua")

Script.Load("lua/mvm/MarineTeam.lua")

Script.Load("lua/PostLoadMod.lua")