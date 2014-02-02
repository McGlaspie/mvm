

Script.Load("lua/TeamMixin.lua")


function TeamMixin:GetTeamType()	//OVERRIDES
	
	if self.teamNumber == kTeam1Index or self.teamNumber == kTeam2Index then
		return kMarineTeamType
	end
	
	return kNeutralTeamType
	
end


function TeamMixin:GetEffectParams( tableParams )		//OVERRIDES
	
    if not tableParams[kEffectFilterIsMarine] then
        tableParams[kEffectFilterIsMarine] = (self:GetTeamNumber() == kTeam1Index)
    end
    
    if not tableParams[kEffectFilterIsAlien] then
        tableParams[kEffectFilterIsAlien] = (self:GetTeamNumber() == kTeam2Index)
    end
    
end

