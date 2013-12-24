

decoda_name = "Predict"


Script.Load("lua/PreLoadMod.lua")


Script.Load("lua/Shared.lua")
Script.Load("lua/mvm_Shared.lua")

Script.Load("lua/Predict.lua")

Script.Load("lua/mvm/MapEntityLoader.lua")


Script.Load("lua/PostLoadMod.lua")


function MvM_OnMapLoadEntity(className, groupName, values)
    LoadMapEntity(className, groupName, values)
end

Event.Hook("MapLoadEntity", MvM_OnMapLoadEntity)