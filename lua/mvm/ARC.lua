
Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/SelectableMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/DamageMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/WeldableMixin.lua")
Script.Load("lua/mvm/DissolveMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/SupplyUserMixin.lua")
Script.Load("lua/mvm/NanoshieldMixin.lua")

if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
	//TODO Add IFFMixin
end




//-----------------------------------------------------------------------------


local newNetworkVars = {}

AddMixinNetworkVars( FireMixin, newNetworkVars )
AddMixinNetworkVars( DetectableMixin, newNetworkVars )
AddMixinNetworkVars( ElectroMagneticMixin, newNetworkVars )
AddMixinNetworkVars( DissolveMixin, newNetworkVars )


// Balance
ARC.kHealth                 = kARCHealth
ARC.kStartDistance          = 4
ARC.kAttackDamage           = kARCDamage
ARC.kFireRange              = kARCRange         // From NS1
ARC.kMinFireRange           = kARCMinRange
ARC.kSplashRadius           = 7
ARC.kUpgradedSplashRadius   = 13
ARC.kMoveSpeed              = 2.0
ARC.kCombatMoveSpeed        = 1.0	//0.8
ARC.kFov                    = 360
ARC.kBarrelMoveRate         = 100
ARC.kMaxPitch               = 45
ARC.kMaxYaw                 = 180
ARC.kCapsuleHeight = .05
ARC.kCapsuleRadius = .5


if Server then
	
	local kMoveParam = "move_speed"
	local kMuzzleNode = "fxnode_arcmuzzle"
	
end


//-----------------------------------------------------------------------------



function ARC:OnCreate()		//OVERRIDES

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, DoorMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, UpgradableMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, PathingMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, WebableMixin)
    InitMixin(self, ParasiteMixin)
    
    InitMixin(self, DetectableMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, ElectroMagneticMixin)
    
    if Server then
    
        InitMixin(self, RepositioningMixin)
        InitMixin(self, SleeperMixin)
        
        self.targetPosition = nil
        self.targetedEntity = Entity.invalidId
        
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
        InitMixin(self, ColoredSkinsMixin)
    end
    
    self.deployMode = ARC.kDeployMode.Undeployed
    
    self:SetLagCompensated(true)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.WhipGroup)	//So it triggers mines
    
end

/*
function ARC:OnInitialized()	//OVERRIDES
	
    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    self:SetModel(ARC.kModelName, kAnimationGraph)
    
    if Server then
    
        local angles = self:GetAngles()
        self.desiredPitch = angles.pitch
        self.desiredRoll = angles.roll
    
        InitMixin(self, MobileTargetMixin)
        InitMixin(self, SupplyUserMixin)
        
        // TargetSelectors require the TargetCacheMixin for cleanup.
        InitMixin(self, TargetCacheMixin)
        
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

        
        self:SetPhysicsType(PhysicsType.Kinematic)
        
        // Cannons start out mobile
        self:SetMode(ARC.kMode.Stationary)
        
        self.undeployedArmor = kARCArmor
        self.deployedArmor = kARCDeployedArmor
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
    
        self.desiredForwardTrackPitchDegrees = 0
        
        //InitMixin(self, InfestationTrackerMixin)
        
        InitMixin(self, ControllerMixin)
        self:CreateController(PhysicsGroup.WhipGroup)
    
    elseif Client then
    
        self.lastModeClient = self.mode
        
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
        self:InitializeSkin()
    
    end
    
    self:SetUpdates(true)
    
    InitMixin(self, IdleMixin)

end
*/

local orgArcInit = ARC.OnInitialized
function ARC:OnInitialized()

	orgArcInit( self )
		
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


if Server then
	
	function ARC:UpdateMoveOrder( deltaTime )	//OVERRIDES

		local currentOrder = self:GetCurrentOrder()
		ASSERT(currentOrder)
		
		self:SetMode( ARC.kMode.Moving )  
		
		local moveSpeed = ConditionalValue(
			self:GetIsUnderEmpEffect() or self:GetIsOnFire(),
			ARC.kCombatMoveSpeed,
			ARC.kMoveSpeed
		)
		
		local maxSpeedTable = { maxSpeed = moveSpeed }
		self:ModifyMaxSpeed( maxSpeedTable )
		
		self:MoveToTarget( PhysicsMask.AIMovement, currentOrder:GetLocation(), maxSpeedTable.maxSpeed, deltaTime )
		
		self:AdjustPitchAndRoll()
		
		if self:IsTargetReached( currentOrder:GetLocation(), kAIMoveOrderCompleteDistance ) then
		    
			self:CompletedCurrentOrder()
			self:SetPoseParam( "move_speed" , 0)
			
			// If no more orders, we're done
			if self:GetCurrentOrder() == nil then
				self:SetMode( ARC.kMode.Stationary )
			end
			
		else
			self:SetPoseParam( "move_speed", .5 )
		end
		
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
	
	function ARC:GetControllerPhysicsGroup()
		return PhysicsGroup.WhipGroup	//???
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
