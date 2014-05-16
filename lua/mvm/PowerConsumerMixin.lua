

Script.Load("lua/PowerConsumerMixin.lua")


//-----------------------------------------------------------------------------

local kDissolveAccentOnLimit = 0.18
local unpoweredColor = Color( 0, 0, 0, 1 )


//FIXME Make routine in this func a optional callback via mixin def
function PowerConsumerMixin:OnUpdate( deltaTime )

	PROFILE("PowerConsumerMixin:OnUpdate")
	
	if Server then
        self.powerSurge = self.timePowerSurgeEnds > Shared.GetTime()
    end
	
	if Client then

		if self.GetAccentSkinColor and self.GetIsAlive then
			
			if not self:isa("Sentry") and not self:isa("SentryBattery") and not self:isa("Player") and self:GetIsAlive() then
				
				self.skinAccentColor = ConditionalValue(
					self:GetIsPowered(),
					self:GetAccentSkinColor(),
					unpoweredColor
				)
			
			end
			
		end
		
	end
	
	if self.powerSurge then		
		
        if not self.timeLastPowerSurgeEffect or self.timeLastPowerSurgeEffect + 0.5 < Shared.GetTime() then
			
			local surgeEffectTeam = self:GetTeamNumber()
			
			self:TriggerEffects( "power_surge", {
                ismarine = ( surgeEffectTeam == kTeam1Index ), isalien = ( surgeEffectTeam == kTeam2Index )
            })
			
            self.timeLastPowerSurgeEffect = Shared.GetTime()
			
			if Client then
			
				if self.GetAccentSkinColor and self:GetIsAlive() then
					self.skinAccentColor = self:GetAccentSkinColor()
				end
			
			end
			
        end
    
    end
    
    
    if Client then
		
		if self.GetAccentSkinColor and not self:GetIsAlive() then
			
			if self.dissolveAmount and self.dissolveAmount < kDissolveAccentOnLimit then
				self.skinAccentColor = unpoweredColor
			end
			
		end
		
	end
	
end

/*
function PowerConsumerMixin:OnUpdateRender()
	PROFILE("PowerConsumerMixin:OnUpdateRender")
end
*/
