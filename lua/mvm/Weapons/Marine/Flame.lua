

Script.Load("lua/mvm/ScriptActor.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/DamageMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")


local newNetworkVars = {}

AddMixinNetworkVars(LOSMixin, newNetworkVars )


function Flame:OnCreate()	//OVERRIDES

    ScriptActor.OnCreate(self)
    
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)	//May cause serious lag hit...
    
end


//function Flame:OverrideCheckVision()
//	return false
//end

function Flame:OverrideVisionRadius()
	return 0
end


if Server then

	function Flame:Detonate(targetHit)
    
    	local player = self:GetOwner()
	    local ents = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), Flame.kDamageRadius)
	    
	    if targetHit ~= nil then
	    	table.insert(ents, targetHit)
	    end
	    
	    for index, ent in ipairs(ents) do
        
            if ent ~= self:GetOwner() or GetGamerules():GetFriendlyFire() then
				
				if ent.GetModelOrigin then
				
					local toEnemy = GetNormalizedVector(ent:GetModelOrigin() - self:GetOrigin())
					self:DoDamage(Flame.kDamage, ent, ent:GetModelOrigin(), toEnemy)
				
				else
				
					local toEnemy = GetNormalizedVector(ent:Origin() - self:GetOrigin())
					self:DoDamage(Flame.kDamage, ent, ent:Origin(), toEnemy)
									
				end
				
                
                
            end
            
	    end
        
    end

end



Class_Reload( "Flame", {} )

