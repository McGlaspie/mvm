
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")
Script.Load("lua/mvm/DamageMixin.lua")


local kLifeTime = 1.2

local kGrenadeCameraShakeDistance = 12	//15
local kGrenadeMinShakeIntensity = 0.01
local kGrenadeMaxShakeIntensity = 0.12

local kGrenadeDetonationTriggerRange = 2.25


local newNetworkVars = {}

AddMixinNetworkVars(LOSMixin, newNetworkVars )


//-----------------------------------------------------------------------------


function PulseGrenade:OnCreate()	//OVERRIDES

    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    
    if Server then
    
        self:AddTimedCallback(PulseGrenade.Detonate, kLifeTime)
        
    end
    
end


//function PulseGrenade:OverrideCheckVision()
//	return false
//end

function PulseGrenade:OverrideVisionRadius()
	return 0
end

function PulseGrenade:GetDamageType()
	return kPulseGrenadeDamageType
end

function PulseGrenade:GetDeathIconIndex()
	return kDeathMessageIcon.PulseGrenade
end


//Leaving this because things like Armory energy recharge can be effected
local function EnergyDamage(hitEntities, origin, radius, damage)

    for _, entity in ipairs(hitEntities) do
    
        if entity.GetEnergy and entity.SetEnergy then
        
            local targetPoint = HasMixin(entity, "Target") and entity:GetEngagementPoint() or entity:GetOrigin()
            local energyToDrain = damage *  (1 - Clamp( (targetPoint - origin):GetLength() / radius, 0, 1))
            entity:SetEnergy(entity:GetEnergy() - energyToDrain)
        
        end
		
		//TODO Add EMP's affected?
        
    end

end


function PulseGrenade:Detonate( targetHit )	//OVERRIDES
	
    local hitEntities = GetEntitiesWithMixinForTeamWithinRange(
		"Live", 
		GetEnemyTeamNumber(self:GetTeamNumber()), 
		self:GetOrigin(), 
		kPulseGrenadeDamageRadius
	)
	
    table.removevalue(hitEntities, self)
	
	if hitEntities and #hitEntities > 0 then
		self:SetIsSighted(true)
		self:SetExcludeRelevancyMask( bit.bor( kRelevantToTeam1, kRelevantToTeam2 ) )
	end
	
    if targetHit then
		
        table.removevalue(hitEntities, targetHit)
        self:DoDamage(kPulseGrenadeDamage, targetHit, targetHit:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")
        
        if targetHit.SetElectrified then
            targetHit:SetElectrified(kElectrifiedDuration)
        end
        
    end
    
    RadiusDamage( hitEntities, self:GetOrigin(), kPulseGrenadeDamageRadius, kPulseGrenadeDamage, self )
    //EnergyDamage( hitEntities, self:GetOrigin(), kPulseGrenadeEnergyDamageRadius, kPulseGrenadeEnergyDamage )

    local surface = GetSurfaceFromEntity(targetHit)

    local params = { surface = surface }
    if not targetHit then
        params[kEffectHostCoords] = Coords.GetLookIn( self:GetOrigin(), self:GetCoords().zAxis)
    end
    
    self:TriggerEffects("pulse_grenade_explode", params)    
    CreateExplosionDecals(self)
    TriggerCameraShake(self, kGrenadeMinShakeIntensity, kGrenadeMaxShakeIntensity, kGrenadeCameraShakeDistance)
 
    DestroyEntity(self)

end


if Server then

    function PulseGrenade:OnUpdate(deltaTime)
    
        PredictedProjectile.OnUpdate(self, deltaTime)

        for _, enemy in ipairs( GetEntitiesWithMixinForTeamWithinRange(
				"Live", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kGrenadeDetonationTriggerRange
			) ) do
        
            if enemy:GetIsAlive() then
                self:Detonate()
                break
            end
        
        end

    end

end


//-----------------------------------------------------------------------------


Class_Reload( "PulseGrenade", newNetworkVars )
