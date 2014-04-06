

Script.Load("lua/mvm/Commander.lua")

local newNetworkVars = {}


//-----------------------------------------------------------------------------


if Client then
	
	function MarineCommander:GetShowPowerIndicator( locationPowerNode )		//OVERRIDES
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


if Server then
	
	//FIXME Prevent ALL surge, regardless of team
	function MarineCommander:TriggerPowerSurge(position, entity, trace)		//OVERRIDES
			
		if trace and trace.entity and HasMixin(trace.entity, "PowerConsumer") then
			
			if HasMixin( trace.entity, "Team") and trace.entity:GetTeamNumber() == self:GetTeamNumber() then
			
				trace.entity:SetPowerSurgeDuration(kPowerSurgeDuration)
				return true
				
			end
			
		end
    
    return false

end

end


//-----------------------------------------------------------------------------


Class_Reload( "MarineCommander", newNetworkVars )
