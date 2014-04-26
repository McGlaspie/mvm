
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


function PredictedProjectile:OnDestroy()

    if self.projectileController then
        
        self.projectileController:Uninitialize()
        self.projectileController = nil
        
    end
    
    if self.renderModel then
    
        Client.DestroyRenderModel(self.renderModel)
        self.renderModel = nil
    
    end
    
    if self.projectileCinematic then
    
        Client.DestroyCinematic(self.projectileCinematic)
        self.projectileCinematic = nil
    
    end
    
    if Client then
		
        local owner = Shared.GetEntity(self.ownerId)
		//Bug caused by client moving to spec?
        if owner and owner == Client.GetLocalPlayer() and self.projectileId ~= nil and HasMixin( owner, "PredictedProjectile" ) then        
            owner:SetProjectileDestroyed(self.projectileId)   
        end

    end    

end



Class_Reload( "PredictedProjectile", {} )