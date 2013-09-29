


Script.Load("lua/TeamInfo.lua")
Script.Load("lua/PostLoadMod.lua")



function TeamInfo:GetRelevantTech()
    return TeamInfo.kRelevantIdMaskMarine, TeamInfo.kRelevantTechIdsMarine
end


Class_Reload("TeamInfo", {})