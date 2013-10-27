

Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/mvm/PowerConsumerMixin.lua")
Script.Load("lua/PostLoadMod.lua")


local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local oldProtoLabCreate = PrototypeLab.OnCreate
function PrototypeLab:OnCreate()
	
	oldProtoLabCreate(self)
	
	InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    
    if Client then
		InitMixin(self, ColoredSkinsMixin)
	end
    
end

local orgProtoInit = PrototypeLab.OnInitialized
function PrototypeLab:OnInitialized()

	orgProtoInit(self)
	
	if Client then
		self:InitializeSkin()
	end

end


if Client then
	
	function PrototypeLab:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = 0
	end

	function PrototypeLab:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function PrototypeLab:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function PrototypeLab:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


//-----------------------------------------------------------------------------

Class_Reload("PrototypeLab", newNetworkVars)
