

Script.Load("lua/mvm/Commander.lua")

local newNetworkVars = {}


//-----------------------------------------------------------------------------


if Client then
	
	function MarineCommander:GetShowPowerIndicator( locationPowerNode )
		//Note: this may cause lag/glitches when server updated property is changed on PP
		if locationPowerNode then
		
			if self:GetTeamNumber() == kTeam1Index then
				return locationPowerNode.scoutedForTeam1
			elseif self:GetTeamNumber() == kTeam2Index then
				return locationPowerNode.scoutedForTeam2
			end
		
		end
		
		return false
		
	end

end


//-----------------------------------------------------------------------------


Class_Reload( "MarineCommander", newNetworkVars )
