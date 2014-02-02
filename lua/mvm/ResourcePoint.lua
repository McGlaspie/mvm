
if Client then
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
end



function ResourcePoint:OnCreate()	//OVERRIDES

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, ObstacleMixin)

    if Client then
        InitMixin(self, CommanderGlowMixin)   
        self.resnodeEffectPlaying = false
    end
    
    // Anything that can be built upon should have this group
    self:SetPhysicsGroup(PhysicsGroup.AttachClassGroup)
    
    // Make the nozzle kinematic so that the player will collide with it.
    self:SetPhysicsType(PhysicsType.Kinematic)
    
    self:SetTechId(kTechId.ResourcePoint)
    
end


Class_Reload( "ResourcePoint", {} )