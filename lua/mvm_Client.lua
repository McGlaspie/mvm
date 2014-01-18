//
//	MvM Client
//	Any additional loads for MvM are done after normal NS2 Client loaded.
//


decoda_name = "Client"


Script.Load("lua/PreLoadMod.lua")

Script.Load("lua/Client.lua")	//Load normal NS2 Client


Script.Load("lua/mvm_Shared.lua")
Script.Load("lua/mvm/MapEntityLoader.lua")
Script.Load("lua/mvm_ClientUI.lua")
//ClientResources?

Script.Load("lua/PostLoadMod.lua")



function MvM_OnMapLoadEntity(className, groupName, values)
    LoadMapEntity(className, groupName, values)
end


Event.Hook("MapLoadEntity", MvM_OnMapLoadEntity)

