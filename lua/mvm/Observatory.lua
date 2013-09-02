

Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/TeamColorSkinMixin.lua")
Script.Load("lua/PostLoadMod.lua")


Observatory.kDistressBeaconTime = kDistressBeaconTime
Observatory.kDistressBeaconRange = kDistressBeaconRange
Observatory.kDetectionRange = 22 // From NS1

local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local oldObsCreate = Observatory.OnCreate
function Observatory:OnCreate()

	oldObsCreate(self)
	
	InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, TeamColorSkinMixin)

	if Server then
    
        self.distressBeaconSoundMarine = Server.CreateEntity(SoundEffect.kMapName)
        self.distressBeaconSoundMarine:SetAsset(kDistressBeaconSoundMarine)
        self.distressBeaconSoundMarine:SetRelevancyDistance(kDistressBeaconSoundDistance)
		
        self.distressBeaconSoundAlien = Server.CreateEntity(SoundEffect.kMapName)
        self.distressBeaconSoundAlien:SetAsset(kDistressBeaconSoundAlien)
        self.distressBeaconSoundAlien:SetRelevancyDistance(kDistressBeaconSoundDistance)
        
        if self:GetTeamNumber() == kTeam2Index then
			self.distressBeaconSoundMarine:SetExcludeRelevancyMask(kRelevantToTeam2)
			self.distressBeaconSoundAlien:SetExcludeRelevancyMask(kRelevantToTeam1)
		else
			self.distressBeaconSoundMarine:SetExcludeRelevancyMask(kRelevantToTeam1)
			self.distressBeaconSoundAlien:SetExcludeRelevancyMask(kRelevantToTeam2)
		end
        
    end

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

