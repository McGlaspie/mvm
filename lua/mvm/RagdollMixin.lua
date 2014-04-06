

Script.Load("lua/RagdollMixin.lua")



local function MvM_GetDamageImpulse(doer, point)

    if doer and point then
        return GetNormalizedVector(doer:GetOrigin() - point) * 1.5 * 0.01
    end
    
    return nil
    
end


function RagdollMixin:OnTakeDamage(damage, attacker, doer, point)

    // Apply directed impulse to physically simulated objects, according to amount of damage.
    if self:GetPhysicsModel() ~= nil and self:GetPhysicsType() == PhysicsType.Dynamic then
		
		local damageImpulse = MvM_GetDamageImpulse(doer, point)
		
		if damageImpulse and doer and doer:GetDamageType() == kDamageType.Splash then
			damageImpulse = damageImpluse * 200
        end
        
        if damageImpulse then
            self:GetPhysicsModel():AddImpulse( point, damageImpulse )
        end
        
    end
    
end


