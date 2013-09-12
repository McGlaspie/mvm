

Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/PostLoadMod.lua")

local newNetworkVars = {}

//-----------------------------------------------------------------------------

AddMixinNetworkVars(LOSMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local oldExosuitCreate = Exosuit.OnCreate
function Exosuit:OnCreate()

	oldExosuitCreate(self)
	
	InitMixin(self, LOSMixin)
	
	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end

end


if Client then

	//Team Skins 
	function Exosuit:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function Exosuit:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function Exosuit:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end
	//End Team Skins

end


function Exosuit:GetIsValidRecipient(recipient)
	
	if HasMixin(recipient, "Team") then
		return not recipient:isa("Exo") and self:GetTeamNumber() == recipient:GetTeamNumber()
	end
	
	return false
	
end


//-----------------------------------------------------------------------------

Class_Reload("Exosuit", newNetworkVars)

