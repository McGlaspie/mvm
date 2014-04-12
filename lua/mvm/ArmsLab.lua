
Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/SelectableMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/ConstructMixin.lua")
Script.Load("lua/mvm/GhostStructureMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/WeldableMixin.lua")
Script.Load("lua/mvm/DissolveMixin.lua")
Script.Load("lua/mvm/PowerConsumerMixin.lua")
Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/SupplyUserMixin.lua")
Script.Load("lua/mvm/NanoshieldMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/mvm/RagdollMixin.lua")

if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
end

local kAnimationGraph = PrecacheAsset("models/marine/arms_lab/arms_lab.animation_graph")

local kHaloCinematicTeam2 = PrecacheAsset("cinematics/marine/arms_lab/arms_lab_holo_team2.cinematic")
local kHaloCinematic = PrecacheAsset("cinematics/marine/arms_lab/arms_lab_holo.cinematic")
local kHaloAttachPoint = "ArmsLab_hologram"


//-----------------------------------------------------------------------------


local newNetworkVars = {}

AddMixinNetworkVars( FireMixin, newNetworkVars )
AddMixinNetworkVars( DetectableMixin, newNetworkVars )
AddMixinNetworkVars( ElectroMagneticMixin, newNetworkVars )


//-----------------------------------------------------------------------------


function ArmsLab:OnCreate()		//OVERRIDES
	
	ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
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
        self.deployed = false
        
        InitMixin(self, ColoredSkinsMixin)
        
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)

end


function ArmsLab:OnInitialized()	//OVERRIDES
	
	ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    if Server then
    
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
    
    self:SetModel(ArmsLab.kModelName, kAnimationGraph)
	
end


function ArmsLab:OverrideVisionRadius()
	return 2
end


function ArmsLab:GetIsVulnerableToEMP()
	return false
end


if Client then
	
	function ArmsLab:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
	end

	function ArmsLab:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function ArmsLab:GetAccentSkinColor()
		if self:GetIsBuilt() then
			return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
		else
			return Color( 0,0,0 )
		end
	end

	function ArmsLab:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end
	
	
	function ArmsLab:OnUpdateRender()
    
        if not self.haloCinematic then
        
            self.haloCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
            if self:GetTeamNumber() == kTeam2Index then
				self.haloCinematic:SetCinematic(kHaloCinematicTeam2)
			else
				self.haloCinematic:SetCinematic(kHaloCinematic)
			end
            
            self.haloCinematic:SetParent(self)
            self.haloCinematic:SetAttachPoint(self:GetAttachPointIndex(kHaloAttachPoint))
            self.haloCinematic:SetCoords(Coords.GetIdentity())
            self.haloCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
            
        end
        
        self.haloCinematic:SetIsVisible( self.deployed and self:GetIsPowered() )
        
        //ColoredSkinsMixin:OnUpdateRender(self, deltaTime)	//??
        
    end
	
end


//-----------------------------------------------------------------------------

Class_Reload("ArmsLab", newNetworkVars)