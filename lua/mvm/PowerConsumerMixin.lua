

Script.Load("lua/PowerConsumerMixin.lua")

local unpoweredColor = Color( 0, 0, 0, 1 )

//-----------------------------------------------------------------------------


function PowerConsumerMixin:OnUpdate(deltaTime)
//Auto-Toggle Model Emissive brightness base on powered state
	
	self.powerSurge = self.timePowerSurgeEnds > Shared.GetTime()
	
	if Client then
		if HasMixin(self, "ColoredSkin") and ( not self:isa("Sentry") and not self:isa("SentryBattery") ) then
			
			self.skinAccentColor = ConditionalValue(
				self:GetIsPowered(),
				self:GetAccentSkinColor(),
				unpoweredColor
			)
		
		end
	end

end

