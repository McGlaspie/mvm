

Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/PostLoadMod.lua")

local newNetworkVars = {}

AddMixinNetworkVars(LOSMixin, newNetworkVars)

//-----------------------------------------------------------------------------


local oldJetpackCreate = Jetpack.OnCreate
function Jetpack:OnCreate()
	
	oldJetpackCreate(self)
	
	InitMixin(self, LOSMixin)
	
	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end
	
end


if Client then

	function Jetpack:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function Jetpack:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function Jetpack:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


function Jetpack:GetIsValidRecipient(recipient)
	if HasMixin(recipient, "Team") then
		return 
			not recipient:isa("JetpackMarine") 
			and not recipient:isa("Exo") 
			and self:GetTeamNumber() == recipient:GetTeamNumber()
	end
	
	return false
end


function Jetpack:GetIsPermanent()	//Future Use
    return true
end


//-----------------------------------------------------------------------------


Class_Reload("Jetpack", newNetworkVars)