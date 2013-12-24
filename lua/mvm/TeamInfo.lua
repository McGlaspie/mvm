


Script.Load("lua/TeamInfo.lua")
Script.Load("lua/PostLoadMod.lua")

local newNetworkVars = {
	supplyUsed = "integer (0 to " .. kMaxSupply .. ")"		//OVERRIDES
}

function TeamInfo:GetRelevantTech()
    return TeamInfo.kRelevantIdMaskMarine, TeamInfo.kRelevantTechIdsMarine
end


Class_Reload("TeamInfo", newNetworkVars)