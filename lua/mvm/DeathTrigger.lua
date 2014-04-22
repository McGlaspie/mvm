

Script.Load("lua/mvm/TechMixin.lua")
Script.Load("lua/Mixins/SignalListenerMixin.lua")



local function KillEntity(self, entity)

    if Server and HasMixin(entity, "Live") and entity:GetIsAlive() and entity:GetCanDie(true) then
    
        local direction = GetNormalizedVector(entity:GetModelOrigin() - self:GetOrigin())
        entity:Kill(self, self, self:GetOrigin(), direction)
        
    end
    
end

local function KillAllInTrigger(self)

    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
        KillEntity(self, entity)
    end
    
end

function DeathTrigger:OnCreate()

    Trigger.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, SignalListenerMixin)
    
    self.enabled = true
    
    self:RegisterSignalListener(function() KillAllInTrigger(self) end, "kill")
    
end


Class_Reload( "DeathTrigger", {} )

