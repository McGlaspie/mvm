

Script.Load("lua/PowerConsumerMixin.lua")

local unpoweredColor = Color( 0, 0, 0, 1 )

//-----------------------------------------------------------------------------


function PowerConsumerMixin:OnUpdate(deltaTime)
//Auto-Toggle Model Emissive brightness base on powered state
//FIXME PowerSurge doesn't update emissive powered color(s)
	
	self.powerSurge = self.timePowerSurgeEnds > Shared.GetTime()
	
	if Client then
		
		if HasMixin(self, "ColoredSkin") and not self:isa("Player") then
			
			if not self:isa("Sentry") and not self:isa("SentryBattery") then
			
				self.skinAccentColor = ConditionalValue(
					self:GetIsPowered(),
					self:GetAccentSkinColor(),
					unpoweredColor
				)
				
			end
		
		end
		
	end
	

end


function PowerConsumerMixin:OnUpdateRender()

    if self.powerSurge then
    
        if not self.timeLastPowerSurgeEffect or self.timeLastPowerSurgeEffect + 1 < Shared.GetTime() then
			
			if self:GetTeamNumber() == kTeam2Index then
				self:TriggerEffects("power_surge_team2")
			else
				self:TriggerEffects("power_surge")
			end
			
            self.timeLastPowerSurgeEffect = Shared.GetTime()
        
        end
    
    end

end

