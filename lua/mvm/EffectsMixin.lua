

Script.Load("lua/EffectsMixin.lua")



function EffectsMixin:TriggerEffects(effectName, tableParams)

    PROFILE("EffectsMixin:TriggerEffects")
    
    assert(effectName and effectName ~= "")
    tableParams = tableParams or { }
    
    self:GetEffectParams(tableParams)
    
    //Allowable callback for "injecting" last minute params
	GetEffectManager():TriggerEffects(effectName, tableParams, self)
    
end


if Server then
	
	
    local function MvMUpdateSpawnEffect(self)
        
        local selfTeam = 0
        if HasMixin(self, "Team") then
            selfTeam = self:GetTeamNumber()
        end
        
        if not self.spawnEffectTriggered then
        //Visibility is handled in LOSMixin on relevant implementing classes
            self:TriggerEffects("spawn", { 
                classname = self:GetClassName(), ismarine = ( selfTeam == kTeam1Index ), isalien = ( selfTeam == kTeam2Index )
            })
            
            self.spawnEffectTriggered = true
            
        end

    end
    
    
    function EffectsMixin:OnProcessMove()
        if self.spawnEffectTriggered ~= true then	//Traps, no need to run on all updates once complete
			MvMUpdateSpawnEffect( self )
        end
    end
	
	
    function EffectsMixin:OnUpdate()
        if self.spawnEffectTriggered ~= true then	//Traps, no need to run on all updates once complete
			MvMUpdateSpawnEffect( self )
        end
    end
    

end

