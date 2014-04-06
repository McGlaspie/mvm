
Script.Load("lua/mvm/ScriptActor.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/PickupableMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")



local newNetworkVars = {}

AddMixinNetworkVars(LOSMixin, newNetworkVars)

//-----------------------------------------------------------------------------


function Jetpack:OnCreate()		//OVERRIDES
	
	ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, SelectableMixin)
    
    InitMixin(self, PickupableMixin, { kRecipientType = "Marine" })
	InitMixin(self, EntityChangeMixin)
	InitMixin(self, LOSMixin)
	
	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end
	
end

local orgJetpackInit = Jetpack.OnInitialized
function Jetpack:OnInitialized()
	
	orgJetpackInit(self)

	if Client then
		self:InitializeSkin()
	end

end


if Client then

	function Jetpack:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = 0
	end

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

