
Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/SelectableMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/ConstructMixin.lua")

//-----------------------------------------------------------------------------


function ResourceTower:OnCreate()	//OVERRIDES

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, ResearchMixin)
    
    if Server then
        InitMixin(self, SpawnBlockMixin)
    end
    
    self:SetLagCompensated(true)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
end


if Server then

	function ResourceTower:CollectResources()

		for _, player in ipairs(GetEntitiesForTeam("Player", self:GetTeamNumber())) do
			if not player:isa("Commander") then
				player:AddResources( kPlayerResPerInterval )
			end
		end
		
		local team = self:GetTeam()
		if team then
			
			team:AddTeamResources( kTeamResourcePerTick, true )
			
		end
		
		self:TriggerEffects("extractor_collect")
		
		local attached = self:GetAttached()
		
		if attached and attached.CollectResources then
			
			// reduces the resource count of the node
			attached:CollectResources()
		
		end

	end
	
end


//-----------------------------------------------------------------------------


Class_Reload("ResourceTower", {})

