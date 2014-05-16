

Script.Load("lua/MarineTeam.lua")
Script.Load("lua/mvm/Marine.lua")
Script.Load("lua/mvm/PlayingTeam.lua")


// How often to send the "No IPs" message to the Marine team in seconds.
local kSendNoIPsMessageRate = 20	//TODO move to balancemisc

local kCannotSpawnSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/commander/need_ip")

local newNetworkVars = {
	hasActiveArmslab = "boolean"
}


//-----------------------------------------------------------------------------


function MarineTeam:OnResetComplete()

    //adjust first power node    
    local initialTechPoint = self:GetInitialTechPoint()
    local powerPoint = GetPowerPointForLocation( initialTechPoint:GetLocationName() )
    
    if powerPoint then
		
		powerPoint:SetConstructionComplete()
		powerPoint.isStartingPoint = true
		
		if self.teamNumber == kTeam1Index then
			powerPoint.scoutedForTeam1 = true
		elseif self.teamNumber == kTeam2Index then
			powerPoint.scoutedForTeam2 = true
		end
		
	else
		
		DebugPrint("ERROR: Failed to retrieve Team[" .. tostring(self.teamNumber) .. "] starting power node")
		
	end
    
end


//OVERRIDES PlayingTeam:GetSupplyUsed()
function MarineTeam:GetSupplyUsed()
    return Clamp(self.supplyUsed, 0, MvM_GetMaxSupplyForTeam( self.teamNumber ) )	//kMaxSupply
end

//OVERRIDES PlayingTeam:AddSupplyUsed()
function MarineTeam:AddSupplyUsed(supplyUsed)
    self.supplyUsed = self.supplyUsed + supplyUsed
end

//OVERRIDES PlayingTeam:RemoveSupplyUsed()
function MarineTeam:RemoveSupplyUsed( supplyUsed )
    self.supplyUsed = self.supplyUsed - supplyUsed
end




function MarineTeam:InitTechTree()	//OVERRIDES
   
   PlayingTeam.InitTechTree(self)
    
    // Marine tier 1
    self.techTree:AddBuildNode(kTechId.CommandStation,            kTechId.None,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.Extractor,                 kTechId.None,                kTechId.None)
    
    self.techTree:AddUpgradeNode(kTechId.ExtractorArmor)
    
    // Count recycle like an upgrade so we can have multiples
    self.techTree:AddUpgradeNode(kTechId.Recycle, kTechId.None, kTechId.None)
    
    self.techTree:AddPassive(kTechId.Welding)
    self.techTree:AddPassive(kTechId.SpawnMarine)
    self.techTree:AddPassive(kTechId.CollectResources, kTechId.Extractor)
    self.techTree:AddPassive(kTechId.Detector)
    
    self.techTree:AddSpecial(kTechId.TwoCommandStations)
    self.techTree:AddSpecial(kTechId.ThreeCommandStations)
    
    // When adding marine upgrades that morph structures, make sure to add to GetRecycleCost() also
    self.techTree:AddBuildNode(kTechId.InfantryPortal,            kTechId.CommandStation,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.Sentry,                    kTechId.RoboticsFactory,     kTechId.SentryBattery, true)
    self.techTree:AddBuildNode(kTechId.Armory,                    kTechId.CommandStation,      kTechId.None)  
    self.techTree:AddBuildNode(kTechId.ArmsLab,                   kTechId.CommandStation,                kTechId.None)  
    self.techTree:AddManufactureNode( kTechId.MAC,                kTechId.RoboticsFactory,                kTechId.None,  true) 
	
    self.techTree:AddBuyNode(kTechId.Axe,                         kTechId.None,              kTechId.None)
    self.techTree:AddBuyNode(kTechId.Pistol,                      kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Rifle,                       kTechId.None,                kTechId.None)

    self.techTree:AddBuildNode(kTechId.SentryBattery,             kTechId.RoboticsFactory,      kTechId.None)      
    
    self.techTree:AddOrder(kTechId.Defend)
    self.techTree:AddOrder(kTechId.FollowAndWeld)
    
    // Commander abilities
    self.techTree:AddResearchNode(kTechId.NanoShieldTech)
    self.techTree:AddResearchNode(kTechId.CatPackTech)
    
    self.techTree:AddTargetedActivation(kTechId.NanoShield,       kTechId.NanoShieldTech)
    self.techTree:AddTargetedActivation(kTechId.Scan,             kTechId.Observatory)
    self.techTree:AddTargetedActivation(kTechId.PowerSurge,       kTechId.RoboticsFactory)
    self.techTree:AddTargetedActivation(kTechId.MedPack,          kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.AmmoPack,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.CatPack,          kTechId.CatPackTech) 

    // Armory upgrades
    self.techTree:AddUpgradeNode(kTechId.AdvancedArmoryUpgrade,  kTechId.Armory)
    
    // arms lab upgrades
    
    self.techTree:AddResearchNode(kTechId.Armor1,                 kTechId.ArmsLab)
    self.techTree:AddResearchNode(kTechId.Armor2,                 kTechId.Armor1, kTechId.None)
    self.techTree:AddResearchNode(kTechId.Armor3,                 kTechId.Armor2, kTechId.None)
    self.techTree:AddResearchNode(kTechId.Armor4,                 kTechId.Armor3, kTechId.None)
    self.techTree:AddResearchNode(kTechId.NanoArmor,              kTechId.None)
    //Note: NanoArmor is supposed to Heal Armor Only...but with MACs, and Welders...why?
    self.techTree:AddResearchNode(kTechId.Weapons1,               kTechId.ArmsLab)
    self.techTree:AddResearchNode(kTechId.Weapons2,               kTechId.Weapons1, kTechId.None)
    self.techTree:AddResearchNode(kTechId.Weapons3,               kTechId.Weapons2, kTechId.None)
    self.techTree:AddResearchNode(kTechId.Weapons4,               kTechId.Weapons3, kTechId.None)
    
    // Marine tier 2
    self.techTree:AddBuildNode(kTechId.AdvancedArmory,            kTechId.Armory, kTechId.None )
    self.techTree:AddResearchNode(kTechId.PhaseTech,              kTechId.Observatory, kTechId.None )
    self.techTree:AddBuildNode(kTechId.PhaseGate,                 kTechId.PhaseTech, kTechId.None, true )
	
    self.techTree:AddBuildNode(kTechId.Observatory,               kTechId.InfantryPortal,       kTechId.Armory)      
    self.techTree:AddActivation(kTechId.DistressBeacon,           kTechId.Observatory)         
    
    // Door actions
    self.techTree:AddBuildNode(kTechId.Door, kTechId.None, kTechId.None)
    self.techTree:AddActivation(kTechId.DoorOpen)
    self.techTree:AddActivation(kTechId.DoorClose)
    self.techTree:AddActivation(kTechId.DoorLock)
    self.techTree:AddActivation(kTechId.DoorUnlock)
    
    // Weapon-specific
    self.techTree:AddResearchNode(kTechId.ShotgunTech,					kTechId.Armory,              kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.Shotgun,					kTechId.ShotgunTech,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropShotgun,			kTechId.ShotgunTech,         kTechId.None)
    
    self.techTree:AddResearchNode(kTechId.GrenadeLauncherTech,			kTechId.AdvancedArmory, kTechId.None )
    self.techTree:AddTargetedBuyNode(kTechId.GrenadeLauncher,			kTechId.AdvancedArmory, kTechId.GrenadeLauncherTech, kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropGrenadeLauncher,	kTechId.AdvancedArmory, kTechId.GrenadeLauncherTech, kTechId.None)
    
    self.techTree:AddResearchNode(kTechId.GrenadeTech,					kTechId.Armory, kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.ClusterGrenade,			kTechId.GrenadeTech, kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.GasGrenade,				kTechId.GrenadeTech, kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.PulseGrenade,				kTechId.GrenadeTech, kTechId.None)
    
    self.techTree:AddResearchNode(kTechId.FlamethrowerTech,				kTechId.AdvancedArmory, kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.Flamethrower,				kTechId.AdvancedArmory, kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropFlamethrower,		kTechId.AdvancedArmory, kTechId.None)
    
    self.techTree:AddResearchNode(kTechId.MinesTech,					kTechId.Armory,           kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.DemoMines,					kTechId.MinesTech,        kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropDemoMines,			kTechId.MinesTech,        kTechId.None)
    
    self.techTree:AddTargetedBuyNode(kTechId.Welder,					kTechId.Armory,        kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropWelder,				kTechId.Armory,        kTechId.None)
    
    //MAC
    //self.techTree:AddActivation( kTechId.MACEMP )
    
    // ARCs
    self.techTree:AddBuildNode(kTechId.RoboticsFactory,                    kTechId.InfantryPortal,                 kTechId.None)  
    self.techTree:AddUpgradeNode(kTechId.UpgradeRoboticsFactory,           kTechId.Armory,              kTechId.RoboticsFactory) 
    self.techTree:AddBuildNode(kTechId.ARCRoboticsFactory,                 kTechId.Armory,              kTechId.RoboticsFactory)
    
    self.techTree:AddTechInheritance(kTechId.RoboticsFactory, kTechId.ARCRoboticsFactory)
   
    self.techTree:AddManufactureNode(kTechId.ARC,    kTechId.ARCRoboticsFactory,     kTechId.None, true)        
    self.techTree:AddActivation(kTechId.ARCDeploy)
    self.techTree:AddActivation(kTechId.ARCUndeploy)
    
    // Robotics factory menus
    self.techTree:AddMenu(kTechId.RoboticsFactoryARCUpgradesMenu)
    self.techTree:AddMenu(kTechId.RoboticsFactoryMACUpgradesMenu)
    
    self.techTree:AddMenu(kTechId.WeaponsMenu)
    
    // Marine tier 3
    self.techTree:AddBuildNode(kTechId.PrototypeLab,          kTechId.AdvancedArmory,              kTechId.None)        

    // Jetpack
    self.techTree:AddResearchNode(kTechId.JetpackTech,           kTechId.PrototypeLab, kTechId.None)
    self.techTree:AddBuyNode(kTechId.Jetpack,                    kTechId.JetpackTech, kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropJetpack,    kTechId.JetpackTech, kTechId.None)
    
    // Exosuit
    self.techTree:AddResearchNode(kTechId.ExosuitTech,           kTechId.PrototypeLab, kTechId.None)
    self.techTree:AddBuyNode(kTechId.Exosuit,                    kTechId.ExosuitTech, kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropExosuit,     kTechId.ExosuitTech, kTechId.None)
    self.techTree:AddResearchNode(kTechId.DualMinigunTech,       kTechId.ExosuitTech, kTechId.TwoCommandStations)
    self.techTree:AddResearchNode(kTechId.DualMinigunExosuit,    kTechId.DualMinigunTech, kTechId.TwoCommandStations)
    self.techTree:AddResearchNode(kTechId.ClawRailgunExosuit,    kTechId.ExosuitTech, kTechId.None)
    self.techTree:AddResearchNode(kTechId.DualRailgunTech,       kTechId.ExosuitTech, kTechId.TwoCommandStations)
    self.techTree:AddResearchNode(kTechId.DualRailgunExosuit,    kTechId.DualMinigunTech, kTechId.TwoCommandStations)
    
    self.techTree:AddBuyNode(kTechId.UpgradeToDualMinigun, kTechId.DualMinigunTech, kTechId.TwoCommandStations)
    self.techTree:AddBuyNode(kTechId.UpgradeToDualRailgun, kTechId.DualMinigunTech, kTechId.TwoCommandStations)

    self.techTree:AddActivation(kTechId.SocketPowerNode,    kTechId.None,   kTechId.None)
    
    self.techTree:SetComplete()

end


local function CheckForNoIPs(self)

    PROFILE("MarineTeam:CheckForNoIPs")

    if Shared.GetTime() - self.lastTimeNoIPsMessageSent >= kSendNoIPsMessageRate then
		
        self.lastTimeNoIPsMessageSent = Shared.GetTime()
        local ips = GetEntitiesForTeam("InfantryPortal", self:GetTeamNumber())
        if #ips == 0 then
        
            self:ForEachPlayer(function(player) StartSoundEffectForPlayer(kCannotSpawnSound, player) end)
            SendTeamMessage(self, kTeamMessageTypes.CannotSpawn)
            
        end
        
    end
    
end


local function GetArmorLevel(self)

    local armorLevels = 0
    
    local techTree = self:GetTechTree()
    if techTree then
    
		if techTree:GetHasTech(kTechId.Armor4) then
            armorLevels = 4
        elseif techTree:GetHasTech(kTechId.Armor3) then
            armorLevels = 3
        elseif techTree:GetHasTech(kTechId.Armor2) then
            armorLevels = 2
        elseif techTree:GetHasTech(kTechId.Armor1) then
            armorLevels = 1
        end
    
    end
    
    if not self.haveActiveArmslab then
		armorLevels = 0
    end
    
    return armorLevels

end


function MarineTeam:Update(timePassed)

    PROFILE("MarineTeam:Update")

    PlayingTeam.Update(self, timePassed)
    
    // Update distress beacon mask
    self:UpdateGameMasks(timePassed)    
	
    if GetGamerules():GetGameStarted() then
        
		CheckForNoIPs(self)
        
        self.haveActiveArmslab = GetTeamHasActiveArmsLab( self:GetTeamNumber() )
        
    end
    
    local armorLevel = GetArmorLevel(self)
    //XXX Will have to update this if anything else gets armor upgrades. ARC? Strucutres?
    for index, player in ipairs( GetEntitiesForTeam("Player", self:GetTeamNumber() ) ) do
        player:UpdateArmorAmount(armorLevel)
    end
    
end


function MarineTeam:GetTotalInRespawnQueue()
	
	local queueSize = #self.respawnQueue
	local numPlayers = 0
	
	//FIXME Add players in spawning sequence from IPs
	for i = 1, #self.respawnQueue do
    //Poll queue
        local player = Shared.GetEntity(self.respawnQueue[i])
        if player then
            numPlayers = numPlayers + 1
        end
    
    end
    
    local allIPs = GetEntitiesForTeam( "InfantryPortal", self:GetTeamNumber() )
    if #allIPs > 0 then
		
		for _, ip in ipairs( allIPs ) do
		
			if MvM_GetIsUnitActive(ip) then
				
				if ip.queuedPlayerId ~= nil and ip.queuedPlayerId ~= Entity.invalidId then
					numPlayers = numPlayers + 1
				end
				
			end
		
		end
		
    end
    
    return numPlayers
	
end



//-----------------------------------------------------------------------------


Class_Reload( "MarineTeam", newNetworkVars )

