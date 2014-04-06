
Script.Load("lua/mvm/GhostStructureMixin.lua")
Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/DissolveMixin.lua")
Script.Load("lua/mvm/PowerConsumerMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/mvm/NanoshieldMixin.lua")

if Client then
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
end


local newNetworkVars = {}

AddMixinNetworkVars(DetectableMixin, newNetworkVars)
AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(ElectroMagneticMixin, newNetworkVars)


local kAnimationGraph = PrecacheAsset("models/marine/extractor/extractor.animation_graph")


//-----------------------------------------------------------------------------


function Extractor:OnCreate()	//OVERRIDES

	ResourceTower.OnCreate(self)
    
    InitMixin(self, CorrodeMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)
    //InitMixin(self, HiveVisionMixin)
    InitMixin(self, UpgradableMixin)
	
	InitMixin(self, FireMixin)
	InitMixin(self, DetectableMixin)
	InitMixin(self, ElectroMagneticMixin)
	
	if Client then
		InitMixin(self, CommanderGlowMixin)
		InitMixin(self, ColoredSkinsMixin)
	end
	
end


function Extractor:OnInitialized()		//OVERRIDES
	
	ResourceTower.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    self:SetModel(Extractor.kModelName, kAnimationGraph)
    
    if Server then
    
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        //InitMixin(self, InfestationTrackerMixin)
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        self:InitializeSkin()
        
    end
    
    InitMixin(self, IdleMixin)
	
end


function Extractor:OverrideVisionRadius()
	return 3
end

function Extractor:GetIsVulnerableToEMP()
	return false
end


if Client then

	function Extractor:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
	end
	
	function Extractor:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end
	
	function Extractor:GetAccentSkinColor()
		if self:GetIsBuilt() then
			return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
		else
			return Color( 0,0,0 )
		end
	end

	function Extractor:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


function Extractor:OverrideAddSupply( team )
	
	if self:GetIsBuilt() then
		team:AddSupplyUsed( LookupTechData( self:GetTechId(), kTechDataSupply, 0) )
	end

end


function Extractor:GetIsFlameAble()
	return false
end

/*
Future use - override one EMP disable effects added
if Server then

    function Extractor:GetIsCollecting()    
        return ResourceTower.GetIsCollecting(self) and self:GetIsPowered()  
    end
    
end
*/


//-----------------------------------------------------------------------------

Class_Reload("Extractor", newNetworkVars)

