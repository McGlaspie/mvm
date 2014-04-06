

Script.Load("lua/mvm/ScriptActor.lua")
Script.Load("lua/mvm/EffectsMixin.lua")
Script.Load("lua/mvm/TeamMixin.lua")

local kDefaultUpdateTime = 0.5

//-----------------------------------------------------------------------------


function CommanderAbility:OnCreate()	//OVERRIDES

	ScriptActor.OnCreate(self)
    
    InitMixin(self, TeamMixin)

end


local orgCreateRepeatEffect = CommanderAbility.CreateRepeatEffect
function CommanderAbility:CreateRepeatEffect()


	if self.CreateRepeatEffectOverride then
		self:CreateRepeatEffectOverride()
	else
		orgCreateRepeatEffect( self )
	end

end


local orgDestroyRepeatEffect = CommanderAbility.DestroyRepeatEffect
function CommanderAbility:DestroyRepeatEffect()

	if self.DestroyRepeatEffectOverride then
		self:DestroyRepeatEffectOverride()
	else
		orgDestroyRepeatEffect( self )
	end

end


local function CommanderAbilityUpdate(self)

    self:CreateRepeatEffect()
    
    local abilityType = self:GetType()
    // Instant types have already been performed in OnInitialized.
    if abilityType ~= CommanderAbility.kType.Instant then
        self:Perform()
    end
    
    local lifeSpanEnded = not self:GetLifeSpan() or (self:GetLifeSpan() + self.timeCreated) <= Shared.GetTime()
    if Server and ( 
			lifeSpanEnded or self:GetAbilityEndConditionsMet() 
			or abilityType == CommanderAbility.kType.OverTime 
			or abilityType == CommanderAbility.kType.Instant
		) then
		
        DestroyEntity(self)
        
    elseif abilityType == CommanderAbility.kType.Repeat then
        return true
    end
    
    return false
    
end


function CommanderAbility:OnInitialized()	//OVERRIDES

    ScriptActor.OnInitialized(self)
    
    if Server then
        self.timeCreated = Shared.GetTime()
    end
    
    if self.timeCreated + kDefaultUpdateTime > Shared.GetTime() then
        self:CreateStartEffect()
    end
    
    self:CreateRepeatEffect()
    
    local callbackRate = nil
    
    if self:GetType() == CommanderAbility.kType.Repeat then
		
        callbackRate = self:GetUpdateTime()
		
    elseif self:GetType() == CommanderAbility.kType.OverTime then
		
        callbackRate = self:GetLifeSpan()
        
    elseif self:GetType() == CommanderAbility.kType.Instant then
		
        self:Perform()
        
        // give some time to ensure propagation of the entity
        callbackRate = 0.1
        
    end
    
    if callbackRate then
		if self.OverrideCallbackUpdateFunction then
			self:AddTimedCallback( self.OverrideCallbackUpdateFunction, callbackRate )
		else
			self:AddTimedCallback( CommanderAbilityUpdate, callbackRate )
		end
    end
    
end


Class_Reload( "CommanderAbility", {} )


