
Script.Load("lua/mvm/TechMixin.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/EffectsMixin.lua")



function PredictedProjectile:OnCreate()

    Entity.OnCreate(self)

    InitMixin(self, EffectsMixin)
    InitMixin(self, TechMixin)
    
    if Server then
    
        InitMixin(self, InvalidOriginMixin)
        InitMixin(self, RelevancyMixin)
        InitMixin(self, OwnerMixin) 
    
    end
    
    self:SetUpdates(true)

end



Class_Reload( "PredictedProjectile", {} )