
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/ConstructMixin.lua")
Script.Load("lua/mvm/SelectableMixin.lua")
Script.Load("lua/mvm/GhostStructureMixin.lua")
Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/WeldableMixin.lua")
Script.Load("lua/mvm/DissolveMixin.lua")
Script.Load("lua/mvm/PowerConsumerMixin.lua")
Script.Load("lua/mvm/SupplyUserMixin.lua")
if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
end


local newNetworkVars = {}


AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

local kOpenSound = PrecacheAsset("sound/NS2.fev/marine/structures/roboticsfactory_open")
local kCloseSound = PrecacheAsset("sound/NS2.fev/marine/structures/roboticsfactory_close")


//-----------------------------------------------------------------------------


function RoboticsFactory:OnCreate()	//OVERRIDES

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
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)
    
    InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
        InitMixin(self, ColoredSkinsMixin)
    end

    self:SetLagCompensated(true)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
        
    self.open = false

end


local orgRoboFactInit = RoboticsFactory.OnInitialized
function RoboticsFactory:OnInitialized()

	orgRoboFactInit(self)
	
	if Client then
		self:InitializeSkin()
	end

end


function RoboticsFactory:OnTag(tagName)
    
    PROFILE("RoboticsFactory:OnTag")

    if self.open and self.researchId ~= Entity.invalidId and tagName == "end" then
		
		if self.researchId == kTechId.MAC or self.researchId == kTechId.ARC then
		
			//ensure supply is removed before entity is spawned due to create delay
			local team = self:GetTeam()
			if team then
				team:RemoveSupplyUsed(  LookupTechData( self.researchId, kTechDataSupply, 0) )
			end
		
		end
		
        // Create structure
        self:ManufactureEntity()
        
        self:ClearResearch()
        
        // Close up
        self.open = false
        
    end
    
    if tagName == "open_start" then
        StartSoundEffectAtOrigin( kOpenSound, self:GetOrigin() )
    elseif tagName == "close_start" then
        StartSoundEffectAtOrigin( kCloseSound, self:GetOrigin() )
    end
    
end

// Actual creation of entity happens delayed.
function RoboticsFactory:OverrideCreateManufactureEntity(techId)

    if techId == kTechId.ARC or techId == kTechId.MAC then
		
		//ensure supply is added back during deployment delay
		local team = self:GetTeam()
		if team then
			team:AddSupplyUsed(  LookupTechData( techId, kTechDataSupply, 0) )
		end
		
        self.researchId = techId
        self.open = true
        
    end
    
end


if Client then
	
	function RoboticsFactory:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
	end

	function RoboticsFactory:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function RoboticsFactory:GetAccentSkinColor()
		if self:GetIsBuilt() then
			return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
		else
			return Color( 0,0,0 )
		end
	end

	function RoboticsFactory:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


//-----------------------------------------------------------------------------


Class_Reload("RoboticsFactory", newNetworkVars)

