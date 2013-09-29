

Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/PostLoadMod.lua")

local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local oldIPcreate = InfantryPortal.OnCreate
function InfantryPortal:OnCreate()

	oldIPcreate(self)
	
	InitMixin(self, FireMixin)
	InitMixin(self, DetectableMixin)

	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end

end


local orgInfantryPortalInit = InfantryPortal.OnInitialized
function InfantryPortal:OnInitialized()

	orgInfantryPortalInit(self)
	
	if Client then
		self:InitializeSkin()
	end

end


if Client then

	function InfantryPortal:InitializeSkin()
		self._activeBaseColor = self:GetBaseSkinColor()
		self._activeAccentColor = self:GetAccentSkinColor()
		self._activeTrimColor = self:GetTrimSkinColor()
	end

	function InfantryPortal:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end
	
	function InfantryPortal:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function InfantryPortal:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


//-----------------------------------------------------------------------------

Class_Reload("InfantryPortal", newNetworkVars)

