
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")
Script.Load("lua/mvm/DamageMixin.lua")
Script.Load("lua/mvm/PredictedProjectile.lua")


local newNetworkVars = {}

AddMixinNetworkVars(LOSMixin, newNetworkVars )


//-----------------------------------------------------------------------------


function Grenade:OnCreate()		//OVERRIDES

    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)	//ClientModel?
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)

    if Server then    
        self:AddTimedCallback( Grenade.Detonate, kGrenadeLifetime )        
    end
    
end


//function Grenade:OverrideCheckVision()
//	return false
//end

function Grenade:OverrideVisionRadius()
	return 0
end


if Server then
	
	function Grenade:Detonate(targetHit)
    
        // Do damage to nearby targets.
        //GetEntitiesWithMixinForTeamWithinRange("Live", GetEnemyTeamNumber(self:GetTeamNumber()), 
        //local hitEntities = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), kGrenadeLauncherGrenadeDamageRadius)
        local hitEntities = Shared.GetEntitiesWithTagInRange(
			"Live", self:GetOrigin(), kGrenadeLauncherGrenadeDamageRadius, 
			function(entity)
				return 
					( 
						HasMixin(entity, "Team") 
						and entity:GetTeamNumber() ~= self:GetTeamNumber()
						and entity ~= self:GetOwner() 
					)
					//or ( entity:isa("PowerPoint") and entity:GetIsBuilt() )
			end
		)
        
        // Remove grenade and add firing player.
        table.removevalue(hitEntities, self)
        
        if hitEntities and #hitEntities > 0 then
			self:SetIsSighted(true)
			self:SetExcludeRelevancyMask( bit.bor( kRelevantToTeam1, kRelevantToTeam2 ) )
        end
        
        // full damage on direct impact
        if targetHit then
            table.removevalue(hitEntities, targetHit)
            self:DoDamage(kGrenadeLauncherGrenadeDamage, targetHit, targetHit:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")
        end
        
        local owner = self:GetOwner()
        // It is possible this grenade does not have an owner.
        if owner then
            table.insertunique(hitEntities, owner)
        end
        
        RadiusDamage(hitEntities, self:GetOrigin(), kGrenadeLauncherGrenadeDamageRadius, kGrenadeLauncherGrenadeDamage, self)
        
        // TODO: use what is defined in the material file
        local surface = GetSurfaceFromEntity(targetHit)
        
        local params = {surface = surface}
        if not targetHit then
            params[kEffectHostCoords] = Coords.GetLookIn( self:GetOrigin(), self:GetCoords().zAxis)
        end
        
        self:TriggerEffects("grenade_explode", params)
        
        CreateExplosionDecals(self)
        
        DestroyEntity(self)
        
    end

end	//Server


//-----------------------------------------------------------------------------


Class_Reload( "Grenade", newNetworkVars )

