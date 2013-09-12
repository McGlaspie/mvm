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

	orgArcInit()

	// Prioritize targetting non-Eggs first.
	self.targetSelector = TargetSelector():Init(
		self,
		ARC.kFireRange,
		false, 
		{ 
			kMarineStaticTargets, 
			kMarineMobileTargets 
		},
		{
			self.FilterTarget(self),
			TeamTargetFilter( self:GetTeamNumber() )
		}
		//TODO Auto-Prioritization of targets
	)
	
	InitMixin(self, ControllerMixin)
        
	self:CreateController(PhysicsGroup.WhipGroup)

end


if Client then

	//Team Skins 
	function ARC:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function ARC:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function ARC:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end
	//End Team Skins

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
