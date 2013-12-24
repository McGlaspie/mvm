//
//	Pseudo-Override of ns2/lua/TargetCache.lua
//	Add new rule for teamNumber checking for target vailidity
//

Script.Load("lua/TargetCache.lua")


function TeamTargetFilter( attackerTeam )
    
	return
		function(target, targetPoint)
			return HasMixin(target, "Team") and GetAreEnemies( attackerTeam, target ) and target:GetTeamType() ~= kNeutralTeamType
		end
	
end

