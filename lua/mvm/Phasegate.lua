
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
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/mvm/PowerConsumerMixin.lua")
Script.Load("lua/mvm/SupplyUserMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/mvm/NanoshieldMixin.lua")
Script.Load("lua/mvm/RagdollMixin.lua")

if Client then
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
end


local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)
AddMixinNetworkVars(ElectroMagneticMixin, newNetworkVars)


local kAnimationGraph = PrecacheAsset("models/marine/phase_gate/phase_gate.animation_graph")

local kUpdateInterval = 0.1
// Can only teleport a player every so often
local kDepartureRate = 0.2

local kPushRange = 3
local kPushImpulseStrength = 40

//-----------------------------------------------------------------------------


function PhaseGate:OnCreate()	//OVERRIDES

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
    
    // Compute link state on server and propagate to client for looping effects
    self.linked = false
    self.phase = false
    self.deployed = false
    self.destLocationId = Entity.invalidId
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)

end


function PhaseGate:OnInitialized()		//OVERRIDES

	ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    self:SetModel(PhaseGate.kModelName, kAnimationGraph)
    
    if Server then
    
        self:AddTimedCallback(PhaseGate.Update, kUpdateInterval)
        self.timeOfLastPhase = nil
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        //InitMixin(self, InfestationTrackerMixin)
        InitMixin(self, MinimapConnectionMixin)
        InitMixin(self, SupplyUserMixin)
    
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
        self:InitializeSkin()
        
    end
    
    InitMixin(self, IdleMixin)

end


function PhaseGate:GetIsVulnerableToEMP()
	return false
end

function PhaseGate:OverrideVisionRadius()
	return 3
end


if Client then

	function PhaseGate:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
	end

	function PhaseGate:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function PhaseGate:GetAccentSkinColor()
		if self:GetIsBuilt() then
			return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
		else
			return Color( 0,0,0 )
		end
	end

	function PhaseGate:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


function PhaseGate:OnUpdateRender()

    PROFILE("PhaseGate:OnUpdateRender")

    if self.clientLinked ~= self.linked then
        self.clientLinked = self.linked
        
        local effects = ConditionalValue( self.linked and self:GetIsVisible(), "phase_gate_linked", "phase_gate_unlinked")
        if self:GetTeamNumber() == kTeam2Index then
			effects = ConditionalValue( self.linked and self:GetIsVisible(), "phase_gate_linked_team2", "phase_gate_unlinked_team2")
        end
        
        //FIXME Gate effect visible to enemy commanders without LOS on gate entity...
        //if HasMixin(self, "LOS") and HasMixin(self:GetLastViewer(), "Team")
        self:TriggerEffects(effects)
        
    end

end

//-----------------------------------------------------------------------------

Class_Reload("PhaseGate", newNetworkVars)

