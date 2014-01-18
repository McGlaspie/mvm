

Script.Load("lua/PowerConsumerMixin.lua")


//-----------------------------------------------------------------------------


local unpoweredColor = Color( 0, 0, 0, 1 )

function PowerConsumerMixin:OnUpdate( deltaTime )
	
	self.powerSurge = self.timePowerSurgeEnds > Shared.GetTime()
	
	if Client and HasMixin(self, "ColoredSkins") then
		
		if not self:isa("Sentry") and not self:isa("SentryBattery") and not self:isa("Player") then
			
			self.skinAccentColor = ConditionalValue(
				self:GetIsPowered(),
				self:GetAccentSkinColor(),
				unpoweredColor
			)
		
		end
		
	end
	
end


function PowerConsumerMixin:OnUpdateRender()
	
    if self.powerSurge then		
		
        if not self.timeLastPowerSurgeEffect or self.timeLastPowerSurgeEffect + 1 < Shared.GetTime() then
			
			local surgeEffect = ConditionalValue(
				self:GetTeamNumber() == kTeam2Index,
				"power_surge_team2",
				"power_surge"
			)
			
			self:TriggerEffects( surgeEffect )
			
            self.timeLastPowerSurgeEffect = Shared.GetTime()
        
        end
    
    end

end

