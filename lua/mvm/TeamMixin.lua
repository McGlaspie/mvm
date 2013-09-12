

Script.Load("lua/TeamMixin.lua")


//Just incase local {} isn't overridden
function TeamMixin:GetTeamType()
	
	if self.teamNumber == kTeam1Index or self.teamNumber == kTeam2Index then
		return kMarineTeamType
	end
	
	return kNeutralTeamType
	
end