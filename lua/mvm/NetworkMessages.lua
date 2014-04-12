

Script.Load("lua/NetworkMessages.lua")

//Script.Load("lua/mvm/TechTreeConstants.lua")
Script.Load("lua/mvm/InsightNetworkMessages.lua")


//-----------------------------------------------------------------------------


local kScoreUpdate =
{
    points = "integer (0 to " .. kMaxScore .. ")",
    res = "integer (0 to " .. kMaxPersonalResources .. ")",
    wasKill = "boolean"
}
Shared.RegisterNetworkMessage("MvM_ScoreUpdate", kScoreUpdate)


if Client then
	
	local function MvM_OnScoreUpdate(message)
	//It's absurd that you have to register a new network message, override a mixin, and make this hook
	//just to be able to call a local (to mod) function. FFS...
		MvM_ScoreDisplayUI_SetNewScore(message.points, message.res, message.wasKill)
	end
	
	Client.HookNetworkMessage("MvM_ScoreUpdate", MvM_OnScoreUpdate)

end