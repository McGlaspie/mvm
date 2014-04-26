
Script.Load("lua/mvm/CommandStructure.lua")

Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/WeldableMixin.lua")
Script.Load("lua/mvm/GhostStructureMixin.lua")
Script.Load("lua/mvm/NanoshieldMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/mvm/RagdollMixin.lua")

if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
end


//-----------------------------------------------------------------------------


local newNetworkVars = {}

AddMixinNetworkVars( FireMixin, newNetworkVars )
AddMixinNetworkVars( DetectableMixin, newNetworkVars )
AddMixinNetworkVars( ElectroMagneticMixin, newNetworkVars )


local kAnimationGraph = PrecacheAsset("models/marine/command_station/command_station.animation_graph")
local kLoginAttachPoint = "login"

//-----------------------------------------------------------------------------


function CommandStation:OnCreate()	//OVERRIDES
	
	CommandStructure.OnCreate(self)
    
    InitMixin(self, CorrodeMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, ParasiteMixin)

	InitMixin(self, FireMixin)
	InitMixin(self, DetectableMixin)
	InitMixin(self, ElectroMagneticMixin)

	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end

end


function CommandStation:OnInitialized()

	CommandStructure.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, HiveVisionMixin)
    
    self:SetModel(CommandStation.kModelName, kAnimationGraph)
    
    if Server then
    
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
    
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        
        self:InitializeSkin()
        
    end
    
    InitMixin(self, IdleMixin)

end


function CommandStation:OverrideVisionRadius()
	return 5
end


function CommandStation:GetIsVulnerableToEMP()
	return false
end


//Team Skins 
if Client then
	
	function CommandStation:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
	end
	
	function CommandStation:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_BaseColor, kTeam2_BaseColor )
	end

	function CommandStation:GetAccentSkinColor()
		if self:GetIsBuilt() then
			return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_AccentColor, kTeam2_AccentColor )
		else
			return Color( 0,0,0 )
		end
	end
	
	function CommandStation:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_TrimColor, kTeam2_TrimColor )
	end
	
end
//End Team Skins


local kHelpArrowsCinematicName = PrecacheAsset("cinematics/marine/commander_arrow.cinematic")
local kHelpArrowsCinematicNameTeam2 = PrecacheAsset("cinematics/marine/commander_arrow_team2.cinematic")
PrecacheAsset("models/misc/commander_arrow.model")
PrecacheAsset("models/misc/commander_arrow_team2.model")

if Client then

    function CommandStation:GetHelpArrowsCinematicName()
        return ConditionalValue(
            self:GetTeamNumber() == kTeam1Index,
            kHelpArrowsCinematicName,
            kHelpArrowsCinematicNameTeam2
        )
    end
    
end


local kCommandStationState = enum( { "Normal", "Locked", "Welcome" } )

function CommandStation:OnUpdateRender()    //OVERRIDES

	PROFILE("CommandStation:OnUpdateRender")

    CommandStructure.OnUpdateRender(self)
    
    local model = self:GetRenderModel()
    if model then
    
        local state = kCommandStationState.Normal
        local player = Client.GetLocalPlayer()
        
        if player:GetTeamNumber() ~= kSpectatorIndex then
        
			if self:GetIsOccupied() and self:GetTeamNumber() == player:GetTeamNumber() then
			
				state = kCommandStationState.Welcome
				
			elseif GetTeamHasCommander( self:GetTeamNumber() ) or self:GetTeamNumber() ~= player:GetTeamNumber() then
			
				state = kCommandStationState.Locked
				
			end
			
		else
			
			if GetTeamHasCommander( self:GetTeamNumber() ) then
				state = kCommandStationState.Locked
			else
				state = kCommandStationState.Welcome
			end
			
		end
        
        local accentColor = self:GetBaseSkinColor()
        
        model:SetMaterialParameter("displayColorAccentR", accentColor.r )
        model:SetMaterialParameter("displayColorAccentG", accentColor.g )
        model:SetMaterialParameter("displayColorAccentB", accentColor.b )
        model:SetMaterialParameter("state", state)
        
    end

end


//-----------------------------------------------------------------------------


if Server then
	
	local function MvM_KillPlayersInside(self)
		// Now kill any other players that are still inside the command station so they're not stuck!
		// Draw debug box if players are players on inside aren't dying or players on the outside are
		//DebugCircle(self:GetKillOrigin(), CommandStation.kCommandStationKillConstant, Vector(0, 1, 0), 1, 1, 1, 1, 1)
		for index, player in ipairs( GetEntitiesWithinRange("Player", self:GetOrigin(), 3.25) ) do
			if not player:isa("Commander") and not player:isa("Spectator") then
				if self:GetIsPlayerInside(player) and player:GetId() ~= self.playerIdStartedLogin then
					player:Kill(self, self, self:GetOrigin())
				end
			end
		end
	end
	
	
	//Overrides vanilla - kills oppossing team's comm otherwise
	function CommandStation:LoginPlayer( player )
		local commander = CommandStructure.LoginPlayer(self, player)
		MvM_KillPlayersInside( self )
	end
	
	
end


//-----------------------------------------------------------------------------


Class_Reload("CommandStation", newNetworkVars)

