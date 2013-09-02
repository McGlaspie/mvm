
Script.Load("lua/PostLoadMod.lua")


if Server then
	
	function Grenade:Detonate(targetHit)
    
        // Do damage to nearby targets.
        //GetEntitiesWithMixinForTeamWithinRange("Live", GetEnemyTeamNumber(self:GetTeamNumber()), 
        //local hitEntities = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), kGrenadeLauncherGrenadeDamageRadius)
        local hitEntities = Shared.GetEntitiesWithTagInRange(
			"Live", self:GetOrigin(), kGrenadeLauncherGrenadeDamageRadius, 
			function(entity)
				return 
					( HasMixin(entity, "Team") 
					and entity:GetTeamNumber() ~= self:GetTeamNumber()
					and entity ~= self:GetOwner() )
					or ( entity:isa("PowerPoint") and entity:GetIsBuilt() )
			end
		)
        
        // Remove grenade and add firing player.
        table.removevalue(hitEntities, self)
        
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

Class_Reload("Grenade", {})

