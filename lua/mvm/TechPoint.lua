

if Client then
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
end



function TechPoint:OnCreate()	//OVERRIDES

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    // Anything that can be built upon should have this group
    self:SetPhysicsGroup(PhysicsGroup.AttachClassGroup)
    
    // Make the nozzle kinematic so that the player will collide with it.
    self:SetPhysicsType(PhysicsType.Kinematic)
    
    // Defaults to 1 but the mapper can adjust this setting in the editor.
    // The higher the chooseWeight, the more likely this point will be randomly chosen for a team.
    self.chooseWeight = 1
    
    self.extendAmount = 0
    
end


if Server then

	function TechPoint:SpawnCommandStructure( teamNumber )	//OVERRIDES		
		return CreateEntityForTeam( kTechId.CommandStation, Vector(self:GetOrigin()), teamNumber)
	end

end


Class_Reload("TechPoint", {})

