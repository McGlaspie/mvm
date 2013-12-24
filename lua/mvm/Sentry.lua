

Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/PostLoadMod.lua")
Script.Load("lua/mvm/SupplyUserMixin.lua")

//-----------------------------------------------------------------------------

local kSpinUpSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_spin_up")
local kSpinDownSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_spin_down")

local kAnimationGraph = PrecacheAsset("models/marine/sentry/sentry.animation_graph")

local kAttackSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_fire_loop")

local kSentryScanSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_scan")


// Balance
Sentry.kPingInterval = 6			//5
Sentry.kFov = 160
Sentry.kMaxPitch = 80 				// 160 total
Sentry.kMaxYaw = Sentry.kFov / 2

Sentry.kBaseROF = kSentryAttackBaseROF
Sentry.kRandROF = kSentryAttackRandROF
Sentry.kSpread = Math.Radians(6)
Sentry.kBulletsPerSalvo = kSentryAttackBulletsPerSalvo
Sentry.kBarrelScanRate = 90      		// Degrees per second to scan back and forth with no target
Sentry.kBarrelMoveRate = 180			//150    // Degrees per second to move sentry orientation towards target or back to flat when targeted
Sentry.kRange = 38.5					//NS2 - 20
Sentry.kReorientSpeed = .5	//0.05

Sentry.kTargetAcquireTime = 0.25
Sentry.kConfuseDuration = 4
Sentry.kAttackEffectIntervall = 0.2
Sentry.kConfusedAttackEffectInterval = kConfusedSentryBaseROF

local newNetworkVars = {}

AddMixinNetworkVars(DetectableMixin, newNetworkVars)
AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(ElectroMagneticMixin, newNetworkVars)


//-----------------------------------------------------------------------------


//local oldSentryCreate = Sentry.OnCreate
function Sentry:OnCreate()		//OVERRIDES

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    //InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, StunMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    //InitMixin(self, VortexAbleMixin)
    //InitMixin(self, ParasiteMixin)
	
	InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, ElectroMagneticMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
        InitMixin(self, ColoredSkinsMixin)
    end
    
    self.desiredYawDegrees = 0
    self.desiredPitchDegrees = 0
    self.barrelYawDegrees = 0
    self.barrelPitchDegrees = 0

    self.confused = false
    self.attachedToBattery = false
    
    if Server then

        self.attackSound = Server.CreateEntity(SoundEffect.kMapName)
        self.attackSound:SetParent(self)
        self.attackSound:SetAsset(kAttackSoundName)
        
    elseif Client then
    
        self.timeLastAttackEffect = Shared.GetTime()
        
        // Play a "ping" sound effect every Sentry.kPingInterval while scanning.
        local function PlayScanPing(sentry)
        
            if GetIsUnitActive(self) and not self.attacking and self.attachedToBattery then
                local player = Client.GetLocalPlayer()
                Shared.PlayPrivateSound(player, kSentryScanSoundName, nil, 1, sentry:GetModelOrigin())
            end
            return true
            
        end
        
        self:AddTimedCallback(PlayScanPing, Sentry.kPingInterval)
        
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
	
end




//local orgSentryInit = Sentry.OnInitialized
function Sentry:OnInitialized()			//OVERRIDES
	
    ScriptActor.OnInitialized(self)
    
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, WeldableMixin)
    
    //InitMixin(self, LaserMixin)
    
    self:SetModel(Sentry.kModelName, kAnimationGraph)
    
    self:SetUpdates(true)
    
    if Server then 
    
        InitMixin(self, SleeperMixin)
        
        self.timeLastTargetChange = Shared.GetTime()
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, SupplyUserMixin)
        
        // TargetSelectors require the TargetCacheMixin for cleanup.
        InitMixin(self, TargetCacheMixin)
        
        
        // configure how targets are selected and validated
        self.targetSelector = TargetSelector():Init(
			self,
			Sentry.kRange, 
			true,
			ConditionalValue(
				self:GetTeamNumber() == kTeam1Index,
				{ kMarineTeam2MobileTargets, kMarineTeam2StaticTargets },
				{ kMarineTeam1MobileTargets, kMarineTeam1StaticTargets }
			),
			{ 
				PitchTargetFilter(self,  -Sentry.kMaxPitch, Sentry.kMaxPitch), 
				CloakTargetFilter()
			},
			{
				IsaPrioritizer("Marine"), HarmfulPrioritizer(), AllPrioritizer()
			}
		)
		
        InitMixin(self, StaticTargetMixin)
        //InitMixin(self, InfestationTrackerMixin)
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)   
        //InitMixin(self, HiveVisionMixin)
		
		self:InitializeSkin()
		
	end

end


if Client then
	
	function Sentry:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = 0
	end

	function Sentry:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function Sentry:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end
	
	function Sentry:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


function Sentry:OnWeldOverride(entity, elapsedTime)

    local welded = false
    
    // faster repair rate for sentries, promote use of welders
    local weldAmount = 0
    if entity:isa("Welder") then
        weldAmount = kWelderSentryRepairRate * elapsedTime        
    elseif entity:isa("MAC") then
        weldAmount = MAC.kRepairHealthPerSecond * elapsedTime
    end
    
    if HasMixin(self, "Fire") and self:GetIsOnFire() then
		weldAmount = weldAmount * kWhileBurningWeldEffectReduction
    end
    
    if weldAmount > 0 then
		self:AddHealth(weldAmount)
    end
    
end


local orgSentryUpdate = Sentry.OnUpdate
function Sentry:OnUpdate(time)

	orgSentryUpdate(self, time)
	
	if Client then
	
		if HasMixin(self, "ColoredSkin") then
		
			self.skinAccentColor = ConditionalValue(
				self.attachedToBattery,
				self:GetAccentSkinColor(),
				Color( 0, 0, 0, 1 )
			)
		
		end
		
	end
	
end


function Sentry:GetIsAffectedByWeaponUpgrades()	//"seems" to work
	return true
end


function Sentry:GetIsVulnerableToEMP()
	return true
end


if Server then
	
	function Sentry:OnEmpDamaged()
		self:Confuse( Sentry.kConfuseDuration )
	end
	
	
	//FIXME Crouching marine seems to destroy accuracy
	//TODO Add weapon damage upgrades
	function Sentry:FireBullets()	//OVERRIDES (Removed Umbra check)

        local fireCoords = Coords.GetLookIn(Vector(0,0,0), self.targetDirection)     
        local startPoint = self:GetBarrelPoint()
		
        for bullet = 1, Sentry.kBulletsPerSalvo do
			
            local spreadDirection = CalculateSpread( fireCoords, Sentry.kSpread, math.random )
            local endPoint = startPoint + spreadDirection * Sentry.kRange
            local trace = Shared.TraceRay( startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(self) )
            
            if trace.fraction < 1 then
				
                local damage = kSentryDamage
                local surface = trace.surface
                
                // Disable friendly fire.
                trace.entity = ( not trace.entity or GetAreEnemies( trace.entity, self) ) and trace.entity or nil
                
                local direction = ( trace.endPoint - startPoint ):GetUnit()
                //Print("Sentry %d doing %.2f damage to %s (ramp up %.2f)", self:GetId(), damage, SafeClassName(trace.entity), rampUpFraction)
                self:DoDamage( damage, trace.entity, trace.endPoint, direction, surface, false, math.random() < 0.2 )
                                
            end
            
            bulletsFired = true
            
        end
        
    end
    
    
    local function UpdateConfusedState(self, target)
		
        if not self.confused then	//and target 
			
            if self:GetIsOnFire() then
				self:Confuse( Sentry.kConfuseDuration )
			else
				self.confused = false
			end
			
            
        elseif self.confused then
			
            if self.timeConfused < Shared.GetTime() then
                self.confused = false
            end
            
        end

    end
    
    
    local function UpdateBatteryState(self)
		
        local time = Shared.GetTime()
        
        if self.lastBatteryCheckTime == nil or (time > self.lastBatteryCheckTime + 0.5) then
        
            self.attachedToBattery = false	// Update if we're powered or not
            
            local ents = GetEntitiesForTeamWithinRange("SentryBattery", self:GetTeamNumber(), self:GetOrigin(), SentryBattery.kRange)
            for index, ent in ipairs(ents) do
            
                if GetIsUnitActive(ent) then
                    self.attachedToBattery = true
                    break
                end
                
            end
            
            self.lastBatteryCheckTime = time
            
        end
        
    end    
    

end	//Server


//-----------------------------------------------------------------------------


Class_Reload("Sentry", newNetworkVars)
