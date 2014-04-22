
Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/ConstructMixin.lua")
Script.Load("lua/mvm/SelectableMixin.lua")
Script.Load("lua/mvm/GhostStructureMixin.lua")
Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/NanoshieldMixin.lua")
Script.Load("lua/mvm/WeldableMixin.lua")
Script.Load("lua/mvm/DissolveMixin.lua")
Script.Load("lua/mvm/PowerConsumerMixin.lua")
Script.Load("lua/mvm/SupplyUserMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/mvm/RagdollMixin.lua")

if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
end


Observatory.kDistressBeaconTime = kDistressBeaconTime
Observatory.kDistressBeaconRange = kDistressBeaconRange
Observatory.kDetectionRange = 22 // From NS1
//TODO Experiment with increasing range to 30-40 or so and making
//Obs more expensive (res & supply). Use this and create "sensor nets"


local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)
AddMixinNetworkVars(ElectroMagneticMixin, newNetworkVars)

local kDistressBeaconSoundFriendlies = PrecacheAsset("sound/NS2.fev/marine/common/distress_beacon_marine")
local kDistressBeaconSoundEnemies = PrecacheAsset("sound/NS2.fev/marine/common/distress_beacon_alien")

local kObservatoryTechButtons = { 
	kTechId.Scan, kTechId.DistressBeacon, kTechId.Detector, kTechId.None,
	kTechId.PhaseTech, kTechId.None, kTechId.None, kTechId.None 
}

kAnimationGraph = PrecacheAsset("models/marine/observatory/observatory.animation_graph")


//-----------------------------------------------------------------------------

function Observatory:OnCreate()		//OVERRIDES

	ScriptActor.OnCreate(self)

    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, FlinchMixin)
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
    InitMixin(self, DetectorMixin)
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
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup) 

	
	if Server then
    
        self.distressBeaconSoundFriendlies = Server.CreateEntity(SoundEffect.kMapName)
        self.distressBeaconSoundFriendlies:SetAsset( kDistressBeaconSoundFriendlies )
        self.distressBeaconSoundFriendlies:SetRelevancyDistance( Math.infinity )
        self.distressBeaconSoundFriendlies:SetKeepAlive(true)	//allow this ent to be reused
		
        self.distressBeaconSoundEnemies = Server.CreateEntity(SoundEffect.kMapName)
        self.distressBeaconSoundEnemies:SetAsset( kDistressBeaconSoundEnemies )
        self.distressBeaconSoundEnemies:SetRelevancyDistance( Math.infinity )
		self.distressBeaconSoundEnemies:SetKeepAlive(true)
        
    end

end


function Observatory:OnInitialized()	//OVERRIDES

	ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    self:SetModel(Observatory.kModelName, kAnimationGraph)
    
    if Server then
    
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        //InitMixin(self, InfestationTrackerMixin)
        
        InitMixin(self, SupplyUserMixin)
        
        if self:GetTeamNumber() == kTeam2Index then
			self.distressBeaconSoundFriendlies:SetExcludeRelevancyMask(kRelevantToTeam2)
			self.distressBeaconSoundEnemies:SetExcludeRelevancyMask(kRelevantToTeam1)
		else
			self.distressBeaconSoundFriendlies:SetExcludeRelevancyMask(kRelevantToTeam1)
			self.distressBeaconSoundEnemies:SetExcludeRelevancyMask(kRelevantToTeam2)
		end
		
		local obsOrigin = self:GetOrigin()
		self.distressBeaconSoundFriendlies:SetOrigin( obsOrigin )
		self.distressBeaconSoundEnemies:SetOrigin( obsOrigin )
    
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        //InitMixin(self, HiveVisionMixin)
        
        self:InitializeSkin()
        
    end
    
    InitMixin(self, IdleMixin)

end


function Observatory:OnDestroy()	//OVERRIDES

    ScriptActor.OnDestroy(self)
    
    if Server then
    
        DestroyEntity(self.distressBeaconSoundFriendlies)
        DestroyEntity(self.distressBeaconSoundEnemies)
        self.distressBeaconSoundFriendlies = nil
		self.distressBeaconSoundEnemies = nil
        
    end
    
end


function Observatory:OverrideVisionRadius()
	return 5
end

function Observatory:GetIsVulnerableToEMP()
	return false
end


function Observatory:GetTechButtons(techId)	//OVERRIDES

    if techId == kTechId.RootMenu then
        return kObservatoryTechButtons
    end
    
    return nil
    
end


if Client then
	
	function Observatory:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = 0
	end

	function Observatory:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function Observatory:GetAccentSkinColor()
		if self:GetIsBuilt() then
			return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
		else
			return Color( 0,0,0 )
		end
	end

	function Observatory:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end
	
	function Observatory:GetAtlasIndex()
		return 0
	end

end


local function TriggerMarineBeaconEffects( self )

	for index, player in ipairs( GetEntitiesForTeam("Player", self:GetTeamNumber()) ) do
		
        if player:GetIsAlive() and (player:isa("Marine") or player:isa("Exo")) then
            player:TriggerEffects("player_beacon")
        end
    
    end

end



local function GetIsPlayerNearby(self, player, toOrigin)
    return (player:GetOrigin() - toOrigin):GetLength() < Observatory.kDistressBeaconRange
end


local function GetPlayersToBeacon(self, toOrigin)

    local players = { }
    
    for index, player in ipairs( self:GetTeam():GetPlayers() ) do
		
        // Don't affect Commanders
        if player:isa("Marine") or player:isa("Exo") then
        
            // Don't respawn players that are already nearby.
            if not GetIsPlayerNearby(self, player, toOrigin) then
                table.insert(players, player)
            end
            
        end
        
    end
    
    return players
    
end


// Spawn players at nearest Command Station to Observatory - not initial marine start like in NS1. Allows relocations and more versatile tactics.
local function RespawnPlayer(self, player, distressOrigin)

    // Always marine capsule (player could be dead/spectator)
    local extents = HasMixin(player, "Extents") and player:GetExtents() or LookupTechData(kTechId.Marine, kTechDataMaxExtents)
    local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)
    local range = Observatory.kDistressBeaconRange
    local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, distressOrigin, 2, range, EntityFilterAll())
    
    if spawnPoint then
    
        player:SetOrigin(spawnPoint)
        if player.TriggerBeaconEffects then
            player:TriggerBeaconEffects()
        end
        
    else
        Print("Observatory:RespawnPlayer(): Couldn't find space to respawn player.")
    end
    
    return spawnPoint ~= nil
    
end


function Observatory:CancelDistressBeacon()

    self.distressBeaconTime = nil
    self.distressBeaconSoundFriendlies:Stop()
    self.distressBeaconSoundEnemies:Stop()

end


function Observatory:PerformActivation(techId, position, normal, commander)	//OVERRIDES

    local success = false
    
    if MvM_GetIsUnitActive(self) then
    
        if techId == kTechId.DistressBeacon then
            return self:TriggerDistressBeacon()
        end
        
    end
    
    return ScriptActor.PerformActivation(self, techId, position, normal, commander)
    
end


function Observatory:PerformDistressBeacon()	//OVERRIDES

    self.distressBeaconSoundFriendlies:Stop()
    self.distressBeaconSoundEnemies:Stop()
    
    local anyPlayerWasBeaconed = false
    local successfullPositions = {}
    local successfullExoPositions = {}
    local failedPlayers = {}
    
    local distressOrigin = self:GetDistressOrigin()
    if distressOrigin then
    
        for index, player in ipairs(GetPlayersToBeacon(self, distressOrigin)) do
        
            local success, respawnPoint = RespawnPlayer(self, player, distressOrigin)
            if success then
            
                anyPlayerWasBeaconed = true
                if player:isa("Exo") then
                    table.insert(successfullExoPositions, respawnPoint)
                end
                    
                table.insert(successfullPositions, respawnPoint)
                
            else
                table.insert(failedPlayers, player)
            end
            
        end
        
        // Also respawn players that are spawning in at infantry portals near command station (use a little extra range to account for vertical difference)
        for index, ip in ipairs(GetEntitiesForTeamWithinRange("InfantryPortal", self:GetTeamNumber(), distressOrigin, kInfantryPortalAttachRange + 1)) do
        
            ip:FinishSpawn()
            local spawnPoint = ip:GetAttachPointOrigin("spawn_point")
            table.insert(successfullPositions, spawnPoint)
            
        end
        
    end
    
    local usePositionIndex = 1
    local numPosition = #successfullPositions

    for i = 1, #failedPlayers do
    
        local player = failedPlayers[i]  
    
        if player:isa("Exo") then        
            player:SetOrigin(successfullExoPositions[math.random(1, #successfullExoPositions)])        
        else
              
            player:SetOrigin(successfullPositions[usePositionIndex])
            if player.TriggerBeaconEffects then
                player:TriggerBeaconEffects()
            end
            
            usePositionIndex = Math.Wrap(usePositionIndex + 1, 1, numPosition)
            
        end    
    
    end

    if anyPlayerWasBeaconed then
        self:TriggerEffects("distress_beacon_complete")
    end
    
end


function Observatory:TriggerDistressBeacon()	//OVERRIDES

    local success = false
    
    if not self:GetIsBeaconing() then

        self.distressBeaconSoundFriendlies:Start()
        self.distressBeaconSoundEnemies:Start()

        local origin = self:GetDistressOrigin()
        
        if origin then

            // Beam all faraway players back in a few seconds!
            self.distressBeaconTime = Shared.GetTime() + Observatory.kDistressBeaconTime
            
            if Server then
            
                TriggerMarineBeaconEffects(self)
                
                local location = GetLocationForPoint(self:GetDistressOrigin())
                local locationName = location and location:GetName() or ""
                local locationId = Shared.GetStringIndex(locationName)
                SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Beacon, locationId)
                
            end
            
            success = true
        
        end
    
    end
    
    return success, not success
    
end



//-----------------------------------------------------------------------------


Class_Reload( "Observatory", newNetworkVars )

