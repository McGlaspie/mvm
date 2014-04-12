

Script.Load("lua/TeamJoin.lua")


function TeamJoin:OnTriggerEntered(enterEnt, triggerEnt)

	if enterEnt:isa("Player") then
	
		if self.teamNumber == kTeamReadyRoom then
			//Server.ClientCommand(enterEnt, "spectate")
		elseif self.teamNumber == kTeam1Index then
			Server.ClientCommand(enterEnt, "jointeamone")
		elseif self.teamNumber == kTeam2Index then
			Server.ClientCommand(enterEnt, "jointeamtwo")
		elseif self.teamNumber == kRandomTeamType then
			JoinRandomTeam(enterEnt)
		end
		
	end
		
end


Class_Reload( "TeamJoin", {} )