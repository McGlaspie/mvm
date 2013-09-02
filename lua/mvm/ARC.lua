/**
 *
 */
//=============================================================================

Script.Load("lua/mvm/TeamColorSkinMixin.lua")
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

	InitMixin(self, TeamColorSkinMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, FireMixin)
    //weldable?
	
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
