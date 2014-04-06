
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")
Script.Load("lua/mvm/DamageMixin.lua")
Script.Load("lua/mvm/TeamMixin.lua")


local newNetworkVars = {}
AddMixinNetworkVars(LOSMixin, newNetworkVars )

local kLifeTime = 1.2

local kGrenadeCameraShakeDistance = 15
local kGrenadeMinShakeIntensity = 0.01
local kGrenadeMaxShakeIntensity = 0.12


local kClusterGrenadeFragmentPoints =
{
    Vector(0.1, 0.12, 0.1),
    Vector(-0.1, 0.12, -0.1),
    Vector(0.1, 0.12, -0.1),
    Vector(-0.1, 0.12, 0.1),
    
    Vector(-0.0, 0.12, 0.1),
    Vector(-0.1, 0.12, 0.0),
    Vector(0.1, 0.12, 0.0),
    Vector(0.0, 0.12, -0.1),
}


//-----------------------------------------------------------------------------


function ClusterGrenade:OnCreate()	//OVERRIDES

    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, DamageMixin)
    
    if Server then
    
        self:AddTimedCallback( ClusterGrenade.Detonate, kLifeTime )
        
    end
    
end


//function ClusterGrenade:OverrideCheckVision()
//	return false
//end

function ClusterGrenade:OverrideVisionRadius()
	return 0
end


local function CreateFragments(self)

    local origin = self:GetOrigin()
    local player = self:GetOwner()
        
    for i = 1, #kClusterGrenadeFragmentPoints do
    
        local creationPoint = origin + kClusterGrenadeFragmentPoints[i]
        local fragment = CreateEntity(ClusterFragment.kMapName, creationPoint, self:GetTeamNumber())
        
        local startVelocity = GetNormalizedVector(creationPoint - origin) * (3 + math.random() * 6) + Vector(0, 4 * math.random(), 0)
        fragment:Setup(player, startVelocity, true, nil, self)
    
    end

end


function ClusterGrenade:Detonate(targetHit)		//OVERRIDES

    CreateFragments(self)

    local hitEntities = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), kClusterGrenadeDamageRadius)
    table.removevalue(hitEntities, self)
	
	if hitEntities and #hitEntities > 0 then
		self:SetIsSighted(true)
		self:SetExcludeRelevancyMask( bit.bor( kRelevantToTeam1, kRelevantToTeam2 ) )
	end
	
    if targetHit then
        table.removevalue(hitEntities, targetHit)
        self:DoDamage(kClusterGrenadeDamage, targetHit, targetHit:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")
    end

    RadiusDamage(hitEntities, self:GetOrigin(), kClusterGrenadeDamageRadius, kClusterGrenadeDamage, self)
    
    local surface = GetSurfaceFromEntity(targetHit)
    
    if GetIsVortexed(self) then
        surface = "ethereal"
    end

    local params = { surface = surface }
    if not targetHit then
        params[kEffectHostCoords] = Coords.GetLookIn( self:GetOrigin(), self:GetCoords().zAxis)
    end
    
    self:TriggerEffects("cluster_grenade_explode", params)
    CreateExplosionDecals(self)
    TriggerCameraShake(self, kGrenadeMinShakeIntensity, kGrenadeMaxShakeIntensity, kGrenadeCameraShakeDistance)
    
    DestroyEntity(self)

end


Class_Reload( "ClusterGrenade", newNetworkVars )

