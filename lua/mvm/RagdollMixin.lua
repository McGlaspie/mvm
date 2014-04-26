

Script.Load("lua/RagdollMixin.lua")



function RagdollMixin:__initmixin()
	
	if Server then
		
		self.bypassRagdoll = false
		self.explosiveDeath = false
		
	end

end


local function MvM_GetDamageImpulse(doer, point, self)

	local dmgImpluse = nil

    if doer and point then
    
		local isDoerExplosive = (
			doer:isa("Grenade") or doer:isa("Mine") or doer:isa("ClusterGrenade")
		)
		
		if isDoerExplosive then
		//give ragdoll an extra "kick"
			dmgImpluse = GetNormalizedVector(doer:GetOrigin() - point) * 50 * 2.5
			self.explosiveDeath = true
		else
			dmgImpluse = GetNormalizedVector(doer:GetOrigin() - point) * 5 * 0.01
		end
		
    end
    
    return dmgImpluse
    
end


if Server then

	
	function RagdollMixin:OnKill(attacker, doer, point, direction)
    
        if point then
        
            self.deathImpulse = MvM_GetDamageImpulse(doer, point, self)
            self.deathPoint = Vector(point)
            
            if doer then
                self.doerClassName = doer:GetClassName()
            end
            
        end
        
        local doerClassName = nil
        
        if doer ~= nil then
            doerClassName = doer:GetClassName()
        end
        
        if not self.consumed then
        
            self:TriggerEffects( "death", { 
				classname = self:GetClassName(), 
				effecthostcoords = Coords.GetTranslation( self:GetOrigin() ), 
				doer = doerClassName 
			})
			
        end
        
        // Server does not process any tags when the model is client side animated. assume death animation takes 0.5 seconds and switch then to ragdoll mode.
        if self.GetHasClientModel and self:GetHasClientModel() and (not HasMixin(self, "GhostStructure") or not self:GetIsGhostStructure()) then
        
            CreateRagdoll(self)
			DestroyEntity(self)
            
        end
        
    end


	function RagdollMixin:SetBypassRagdoll(bypass)
        self.bypassRagdoll = bypass
    end

end