

Script.Load("lua/PowerConsumerMixin.lua")


//-----------------------------------------------------------------------------


local unpoweredColor = Color( 0, 0, 0, 1 )

function PowerConsumerMixin:OnUpdate( deltaTime )
	
	if Server then
        self.powerSurge = self.timePowerSurgeEnds > Shared.GetTime()
    end
	
	if Client and HasMixin(self, "ColoredSkins") then
		
		if not self:isa("Sentry") and not self:isa("Player") then
			
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
			
			local surgeEffectTeam = self:GetTeamNumber()
			
			self:TriggerEffects( "power_surge", {
                ismarine = ( surgeEffectTeam == kTeam1Index ), isalien = ( surgeEffectTeam == kTeam2Index )
            })
			
            self.timeLastPowerSurgeEffect = Shared.GetTime()
        
        end
    
    end
    
    if HasMixin( self, "ColoredSkins" ) and not self:GetIsAlive() then
		
		self.skinAccentColor = unpoweredColor	//FIXME preventing dissolve from being colorized
		
		if HasMixin( self, "Dissolve" ) then
			if self.dissolveStart ~= nil and self.dissolveStart <= Shared.GetTime() then
				self.skinAcentColor = self:GetAccentSkinColor()
			end
		end
		
	end

end

