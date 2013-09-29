

Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/PostLoadMod.lua")

//-----------------------------------------------------------------------------

// Balance
Sentry.kPingInterval = 6			//5
Sentry.kFov = 160
Sentry.kMaxPitch = 80 				// 160 total
Sentry.kMaxYaw = Sentry.kFov / 2

Sentry.kBaseROF = kSentryAttackBaseROF
Sentry.kRandROF = kSentryAttackRandROF
Sentry.kSpread = Math.Radians(6)
Sentry.kBulletsPerSalvo = kSentryAttackBulletsPerSalvo
Sentry.kBarrelScanRate = 60      		// Degrees per second to scan back and forth with no target
Sentry.kBarrelMoveRate = 160			//150    // Degrees per second to move sentry orientation towards target or back to flat when targeted
Sentry.kRange = 38.5					//NS2 - 20
Sentry.kReorientSpeed = .05

Sentry.kTargetAcquireTime = 0.15
Sentry.kConfuseDuration = 4
Sentry.kAttackEffectIntervall = 0.2
Sentry.kConfusedAttackEffectInterval = kConfusedSentryBaseROF

local newNetworkVars = {}

AddMixinNetworkVars(DetectableMixin, newNetworkVars)
AddMixinNetworkVars(FireMixin, newNetworkVars)


//-----------------------------------------------------------------------------


local oldSentryCreate = Sentry.OnCreate
function Sentry:OnCreate()

	oldSentryCreate(self)
	
	InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    
    if Client then
		InitMixin(self, ColoredSkinsMixin)
	end
	
end

local orgSentryInit = Sentry.OnInitialized
function Sentry:OnInitialized()

	orgSentryInit(self)
	
	if Client then
		self:InitializeSkin()
	end
	
	if Server then
		
		self.targetSelector = TargetSelector():Init(
			self,
			Sentry.kRange, 
			true,
			{ kMarineStaticTargets, kMarineMobileTargets },
			{ 
				PitchTargetFilter(self,  -Sentry.kMaxPitch, Sentry.kMaxPitch), 
				CloakTargetFilter(),
				TeamTargetFilter( self:GetTeamNumber() )
			}
		)
		
	end

end


if Client then
	
	function Sentry:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
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

if Client then

	local orgSentryUpdate = Sentry.OnUpdate
	function Sentry:OnUpdate(time)
	
		orgSentryUpdate(self, time)
		
		if HasMixin(self, "ColoredSkin") then
		
			self.skinAccentColor = ConditionalValue(
				self.attachedToBattery,
				self:GetAccentSkinColor(),
				Color( 0, 0, 0, 1 )
			)
		
		end
	
	end

end

if Server then

	function Sentry:FireBullets()	//Removed Umbra checking

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
    
    
    // check for spores in our way every 0.3 seconds
    local function UpdateConfusedState(self, target)
		
        if not self.confused and target then
            if self:GetIsOnFire() then
				self:Confuse( Sentry.kConfuseDuration )
			else
				self.confused = false
			end
			//TODO Add EMP temp shutdown (like powered down)
            
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
