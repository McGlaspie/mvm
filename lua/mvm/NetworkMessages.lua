

Script.Load("lua/NetworkMessages.lua")

Script.Load("lua/mvm/TechTreeConstants.lua")
Script.Load("lua/mvm/InsightNetworkMessages.lua")


//-----------------------------------------------------------------------------


local kScoreUpdate = {
    points = "integer (0 to " .. kMaxScore .. ")",
    res = "integer (0 to " .. kMaxPersonalResources .. ")",
    wasKill = "boolean"
}
Shared.RegisterNetworkMessage("MvM_ScoreUpdate", kScoreUpdate)


local kTeamConcededMessage = {
    teamNumber = string.format("integer (-1 to %d)", kRandomTeamType)
}
Shared.RegisterNetworkMessage("MvM_TeamConceded", kTeamConcededMessage)


if Client then
	
	local function MvM_OnScoreUpdate(message)
	//It's absurd that you have to register a new network message, override a mixin, and make this hook
	//just to be able to call a local (to mod) function. FFS...
		MvM_ScoreDisplayUI_SetNewScore(message.points, message.res, message.wasKill)
	end
	
	Client.HookNetworkMessage("MvM_ScoreUpdate", MvM_OnScoreUpdate)

	
	
	function MvM_OnTeamConceded(message)
		
		if message.teamNumber == kMarineTeamType then
			ChatUI_AddSystemMessage(Locale.ResolveString("TEAM_MARINES_CONCEDED"))
		else
			ChatUI_AddSystemMessage(Locale.ResolveString("TEAM_ALIENS_CONCEDED"))
		end
		
	end
	
	Client.HookNetworkMessage("MvM_TeamConceded", MvM_OnTeamConceded)
	
	

end