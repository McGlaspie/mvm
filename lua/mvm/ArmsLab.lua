
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/PostLoadMod.lua")

//-----------------------------------------------------------------------------

local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local orgArmsLabCreate = ArmsLab.OnCreate
function ArmsLab:OnCreate()
	
	orgArmsLabCreate(self)

	InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)

	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end

end

local orgArmsLabInit = ArmsLab.OnInitialized
function ArmsLab:OnInitialized()
	
	orgArmsLabInit(self)
	
	if Client then
		self:InitializeSkin()
	end
	
end


if Client then
	
	function ArmsLab:InitializeSkin()
		self._activeBaseColor = self:GetBaseSkinColor()
		self._activeAccentColor = self:GetAccentSkinColor()
		self._activeTrimColor = self:GetTrimSkinColor()
	end

	function ArmsLab:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function ArmsLab:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function ArmsLab:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


//-----------------------------------------------------------------------------

Class_Reload("ArmsLab", newNetworkVars)