
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
Script.Load("lua/mvm/NanoshieldMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/mvm/RagdollMixin.lua")

if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
end


local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)
AddMixinNetworkVars(ElectroMagneticMixin, newNetworkVars)


local kUpdateLoginTime = 0.3
local kAnimationGraph = PrecacheAsset("models/marine/prototype_lab/prototype_lab.animation_graph")


//-----------------------------------------------------------------------------


function PrototypeLab:OnCreate()	//OVERRIDES
	
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
    InitMixin(self, RagdollMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)
    
    InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, ElectroMagneticMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
        InitMixin(self, ColoredSkinsMixin)
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
    self.loginEastAmount = 0
    self.loginNorthAmount = 0
    self.loginWestAmount = 0
    self.loginSouthAmount = 0
    
    self.timeScannedEast = 0
    self.timeScannedNorth = 0
    self.timeScannedWest = 0
    self.timeScannedSouth = 0

    self.loginNorthAmount = 0
    self.loginEastAmount = 0
    self.loginSouthAmount = 0
    self.loginWestAmount = 0
    
    self.deployed = false
    
end

/*
function PrototypeLab:OnInitialized()	//OVERRIDES

	ScriptActor.OnInitialized(self)
    
    self:SetModel(PrototypeLab.kModelName, kAnimationGraph)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    if Server then
    
        self.loggedInArray = {false, false, false, false}
        self:AddTimedCallback(PrototypeLab.UpdateLoggedIn, kUpdateLoginTime)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        //InitMixin(self, InfestationTrackerMixin)
        InitMixin(self, SupplyUserMixin)
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
		self:InitializeSkin()
		
    end

end
*/
local orgProtoInit = PrototypeLab.OnInitialized
function PrototypeLab:OnInitialized()

	orgProtoInit(self)
	
	if Client then
		self:InitializeSkin()
	end

end


function PrototypeLab:OverrideVisionRadius()
	return 3
end

function PrototypeLab:GetIsVulnerableToEMP()
	return false
end


function PrototypeLab:GetTechButtons(techId)
    return { 
		kTechId.JetpackTech, kTechId.None, kTechId.None, kTechId.None, 
		kTechId.ExosuitTech, kTechId.DualMinigunTech, kTechId.None, kTechId.None 
	} // kTechId.DualRailgunTech
end


if Client then
	
	function PrototypeLab:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = 0
	end

	function PrototypeLab:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function PrototypeLab:GetAccentSkinColor()
		if self:GetIsBuilt() then
			return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
		else
			return Color( 0,0,0 )
		end
	end

	function PrototypeLab:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


//-----------------------------------------------------------------------------

Class_Reload("PrototypeLab", newNetworkVars)
