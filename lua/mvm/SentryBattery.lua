
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/ConstructMixin.lua")
Script.Load("lua/mvm/SelectableMixin.lua")
Script.Load("lua/mvm/GhostStructureMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/WeldableMixin.lua")
Script.Load("lua/mvm/DissolveMixin.lua")
Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/mvm/SupplyUserMixin.lua")
Script.Load("lua/mvm/NanoshieldMixin.lua")
Script.Load("lua/mvm/RagdollMixin.lua")

if Client then
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
end


local newNetworkVars = {}

SentryBattery.kRange = 7.0	//TODO Move or reference global from BalanceXYZ

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)
AddMixinNetworkVars(ElectroMagneticMixin, newNetworkVars)


//-----------------------------------------------------------------------------


function GetSentryBatteryInRoom( origin, forTeam )		//OVERRIDES & Global

    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    
    if locationName then
    
        local batteries = Shared.GetEntitiesWithClassname("SentryBattery")
        for b = 0, batteries:GetSize() - 1 do
        
            local battery = batteries:GetEntityAtIndex(b)
            if battery:GetLocationName() == locationName and battery:GetTeamNumber() == forTeam then
                return battery
            end
            
        end
        
    end
    
    return nil
    
end


//FIXME This needs to also account for distance, and not just location, per team
//otherwise two batteries can be placed on the edges of locations, resulting in 6 sentries...rough.
// - Will need additional placement message to denote distance "error"
function GetRoomHasNoSentryBattery( techId, origin, normal, commander )		//OVERRIDES & Global

	local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local validRoom = false
    local forTeam = commander and commander:GetTeamNumber() or nil
    
    if locationName then
    
        validRoom = true
    
        for index, sentryBattery in ientitylist(Shared.GetEntitiesWithClassname("SentryBattery")) do
            
            if sentryBattery:GetLocationName() == locationName and sentryBattery:GetTeamNumber() == forTeam then
                validRoom = false
                break
            end
            
        end
    
    end
    
    return validRoom
    
end




function SentryBattery:OnCreate()	//OVERRIDES

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
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)   //??Big? Shouldn't small be used?...

end



function SentryBattery:OnInitialized()		//OVERRIDES

	ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    if Server then
    
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, SupplyUserMixin)
        //InitMixin(self, InfestationTrackerMixin)
    
    elseif Client then
		
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
        self:InitializeSkin()
        
    end
    
    self:SetModel(SentryBattery.kModelName, kAnimationGraph)

end


function SentryBattery:GetIsVulnerableToEMP()
	return false
end


function SentryBattery:OverrideVisionRadius()
	return 2
end


if Client then
	
	function SentryBattery:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = 0
	end
	
	function SentryBattery:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_BaseColor, kTeam2_BaseColor )
	end
	
	function SentryBattery:GetAccentSkinColor()
		if self:GetIsBuilt() then
			return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_AccentColor, kTeam2_AccentColor )
		else
			return Color( 0,0,0 )   //FIXME construction complete not triggering change
		end
	end
	
	function SentryBattery:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_TrimColor, kTeam2_TrimColor )
	end
	
end


//-----------------------------------------------------------------------------


Class_Reload("SentryBattery", newNetworkVars)

