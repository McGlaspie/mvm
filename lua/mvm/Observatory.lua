

Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/mvm/PowerConsumerMixin.lua")
Script.Load("lua/PostLoadMod.lua")


Observatory.kDistressBeaconTime = kDistressBeaconTime
Observatory.kDistressBeaconRange = kDistressBeaconRange
Observatory.kDetectionRange = 22 // From NS1

local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

local kDistressBeaconSoundMarine = PrecacheAsset("sound/NS2.fev/marine/common/distress_beacon_marine")
local kDistressBeaconSoundAlien = PrecacheAsset("sound/NS2.fev/marine/common/distress_beacon_alien")

local kObservatoryTechButtons = { kTechId.Scan, kTechId.DistressBeacon, kTechId.Detector, kTechId.None,
                                   kTechId.PhaseTech, kTechId.None, kTechId.None, kTechId.None }
                                   


//-----------------------------------------------------------------------------

local oldObsCreate = Observatory.OnCreate
function Observatory:OnCreate()

	oldObsCreate(self)
	
	InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    
    if Client then
		InitMixin(self, ColoredSkinsMixin)
	end

	if Server then
    
        self.distressBeaconSoundMarine = Server.CreateEntity(SoundEffect.kMapName)
        self.distressBeaconSoundMarine:SetAsset(kDistressBeaconSoundMarine)
        self.distressBeaconSoundMarine:SetRelevancyDistance(Math.infinity)
		
        self.distressBeaconSoundAlien = Server.CreateEntity(SoundEffect.kMapName)
        self.distressBeaconSoundAlien:SetAsset(kDistressBeaconSoundAlien)
        self.distressBeaconSoundAlien:SetRelevancyDistance(Math.infinity)
        
        if self:GetTeamNumber() == kTeam2Index then
			self.distressBeaconSoundMarine:SetExcludeRelevancyMask(kRelevantToTeam2)
			self.distressBeaconSoundAlien:SetExcludeRelevancyMask(kRelevantToTeam1)
		else
			self.distressBeaconSoundMarine:SetExcludeRelevancyMask(kRelevantToTeam1)
			self.distressBeaconSoundAlien:SetExcludeRelevancyMask(kRelevantToTeam2)
		end
        
    end

end

local orgObsInit = Observatory.OnInitialized
function Observatory:OnInitialized()

	orgObsInit(self)
	
	if Client then
		self:InitializeSkin()
	end

end


if Client then
	
	function Observatory:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
	end

	function Observatory:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function Observatory:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function Observatory:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
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
    
        // Don't affect Commanders or Heavies
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



function Observatory:TriggerDistressBeacon()

    local success = false
    
    if not self:GetIsBeaconing() then

        self.distressBeaconSoundMarine:Start()
        self.distressBeaconSoundAlien:Start()
        
        local origin = self:GetDistressOrigin()
        
        if origin then
        
            self.distressBeaconSoundMarine:SetOrigin(origin)
            self.distressBeaconSoundAlien:SetOrigin(origin)
            
            // Beam all faraway players back in a few seconds!
            self.distressBeaconTime = Shared.GetTime() + Observatory.kDistressBeaconTime
            
			if HasMixin(self, "Fire") and self:GetIsOnFire() then
				self.distressBeaconTime = self.distressBeaconTime + kBurningObsDistressBeaconDelay
			end
			

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

Class_Reload("Observatory", newNetworkVars)

