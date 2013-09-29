/**
 *
 */
//=============================================================================

Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/PostLoadMod.lua")

//-----------------------------------------------------------------------------

local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local orgArcCreate = ARC.OnCreate
function ARC:OnCreate()
	
	orgArcCreate(self)

    InitMixin(self, DetectableMixin)
    InitMixin(self, FireMixin)
	
	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end
	
	self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.WhipGroup)
 
end


local orgArcInit = ARC.OnInitialized
function ARC:OnInitialized()
	
	orgArcInit(self)
	
	if Server then
	
		self.targetSelector = TargetSelector():Init(	//OVERRIDE
			self,
			ARC.kFireRange,
			false, 
			{ kMarineStaticTargets, kMarineMobileTargets },
			{ 
				self.FilterTarget(self), 
				TeamTargetFilter( self:GetTeamNumber() ),
				CloakTargetFilter()
				//PitchTargetFilter(self,  -Sentry.kMaxPitch, Sentry.kMaxPitch)	- Will be needed when direct fire mode added
			}
			//TODO Auto-Prioritization of targets
		)
		
		
		InitMixin(self, ControllerMixin)
        
		self:CreateController(PhysicsGroup.WhipGroup)
		
	end
	
	if Client then
		self:InitializeSkin()
	end

end


if Client then

	function ARC:InitializeSkin()
		self._activeBaseColor = self:GetBaseSkinColor()
		self._activeAccentColor = self:GetAccentSkinColor()
		self._activeTrimColor = self:GetTrimSkinColor()
	end
	
	function ARC:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_BaseColor, kTeam2_BaseColor )
	end

	function ARC:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_AccentColor, kTeam2_AccentColor )
	end

	function ARC:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_TrimColor, kTeam2_TrimColor )
	end

end


//-----------------------------------------------------------------------------


if Server then

	// Required by ControllerMixin.
	function ARC:GetControllerSize()
		return GetTraceCapsuleFromExtents( self:GetExtents() )    
	end

	// Required by ControllerMixin.
	function ARC:GetMovePhysicsMask()
		return PhysicsMask.Movement
	end

end


//-----------------------------------------------------------------------------


Class_Reload("ARC", newNetworkVars)
