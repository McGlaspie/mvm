

Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/PostLoadMod.lua")
Script.Load("lua/mvm/SupplyUserMixin.lua")

//-----------------------------------------------------------------------------

local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)
AddMixinNetworkVars(ElectroMagneticMixin, newNetworkVars)


//-----------------------------------------------------------------------------


local orgArcCreate = ARC.OnCreate
function ARC:OnCreate()
	
	orgArcCreate(self)

    InitMixin(self, DetectableMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, ElectroMagneticMixin)
	
	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end
	
	self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.WhipGroup)	//So it triggers mines
 
end


local orgArcInit = ARC.OnInitialized
function ARC:OnInitialized()
	
	orgArcInit(self)
	
	if Server then
		
	    self.targetSelector = nil
	    
		self.targetSelector = TargetSelector():Init(	//OVERRIDES?
			self,
			ARC.kFireRange,
			false, 
			ConditionalValue(
				self:GetTeamNumber() == kTeam1Index,
				{ kMarineTeam2StaticTargets },
				{ kMarineTeam1StaticTargets }
			),
			{ 
				self.FilterTarget(self), CloakTargetFilter()
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
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = 0	//Static
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

//This might prove too strong
function ARC:GetIsVulnerableToEMP()		//Only vulnerable when deploying/deployed
	return self.deployMode ~= ARC.kDeployMode.Undeployed
end


function ARC:OnEmpDamaged()
	
	if Client then
		self:_UpdateElectrifiedEffects()
	end
	
	if Server then
		self:TriggerEffects("arc_stop_charge")
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
	
	
	function ARC:GetCanFireAtTargetActual(target, targetPoint)   	//OVERRIDES 
		
		if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage() then        
			return false
		end
		
		if not target:GetIsSighted() and not GetIsTargetDetected(target) then
			return false
		end
		
		local distToTarget = (target:GetOrigin() - self:GetOrigin()):GetLengthXZ()
		if (distToTarget > ARC.kFireRange) or (distToTarget < ARC.kMinFireRange) then
			return false
		end
		
		if self:GetIsUnderEmpEffect() then
			return false
		end
		
		return true
		
	end
	
	
	local function MvM_PerformAttack(self)

		if self.targetPosition and not self:GetIsUnderEmpEffect() then
		
			self:TriggerEffects("arc_firing")    
			// Play big hit sound at origin
			
			// don't pass triggering entity so the sound / cinematic will always be relevant for everyone
			GetEffectManager():TriggerEffects("arc_hit_primary", {effecthostcoords = Coords.GetTranslation(self.targetPosition)})
			
			local hitEntities = GetEntitiesWithMixinWithinRange("Live", self.targetPosition, ARC.kSplashRadius)

			// Do damage to every target in range
			RadiusDamage(hitEntities, self.targetPosition, ARC.kSplashRadius, kARCDamage, self, true)

			// Play hit effect on each
			for index, target in ipairs(hitEntities) do
			
				if HasMixin(target, "Effects") then
					target:TriggerEffects("arc_hit_secondary")
				end 
			   
			end
			
			TEST_EVENT("ARC attacked entity")
			
		end
		
		// reset target position and acquire new target
		self.targetPosition = nil
		
	end
	
	
	ReplaceLocals( ARC.OnTag, { PerformAttack = MvM_PerformAttack } )
	
end


//-----------------------------------------------------------------------------


Class_Reload("ARC", newNetworkVars)
