

Script.Load("lua/CommAbilities/Marine/NanoShield.lua")


//-----------------------------------------------------------------------------


function NanoShield:Perform()	//OVERRIDES

    //local entities = GetEntitiesWithMixinForTeamWithinRange("NanoShieldAble", self:GetTeamNumber(), self:GetOrigin(), NanoShield.kSearchRange)
    local entities = GetEntitiesWithMixinWithinRange("NanoShieldAble", self:GetOrigin(), NanoShield.kSearchRange)
    
    local CheckFunc = function(entity)
		if ( HasMixin( entity, "Team") and entity:GetTeamNumber() == self:GetTeamNumber() ) or entity:isa("PowerPoint") then
			return entity:GetCanBeNanoShielded()
		else
			return false
		end
    end
    
    local closest = self:GetClosestFromTable(entities, CheckFunc)
    
    if closest then
    
        closest:ActivateNanoShield()
        self.success = true
        TEST_EVENT("NanoShield activated")
        
    end

end


//-----------------------------------------------------------------------------

Class_Reload("NanoShield", {})

