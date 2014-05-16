
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
Script.Load("lua/mvm/NanoshieldMixin.lua")
Script.Load("lua/mvm/SupplyUserMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/mvm/RagdollMixin.lua")

if Client then
	
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
	
end


local kDeployTime = 3
local kLoginAndResupplyTime = 0.3

//Colorize below? What color? Green? Team-Accent?
local kHealthIndicatorModelName = PrecacheAsset("models/marine/armory/health_indicator.model")

local kAnimationGraph = PrecacheAsset("models/marine/armory/armory.animation_graph")

// west/east = x/-x
// north/south = -z/z
local indexToUseOrigin = {
	Vector(Armory.kResupplyUseRange, 0, 0), 	// West
	Vector(0, 0, -Armory.kResupplyUseRange),	// North
	Vector(0, 0, Armory.kResupplyUseRange),		// South
	Vector(-Armory.kResupplyUseRange, 0, 0)		// East
}


local function OnDeploy(self)
	self.deployed = true
	return false
end


// Check if friendly players are nearby and facing armory and heal/resupply them
local function LoginAndResupply(self)

	self:UpdateLoggedIn()
	
	// Make sure players are still close enough, alive, marines, etc.
	// Give health and ammo to nearby players.
	if MvM_GetIsUnitActive(self) then
		self:ResupplyPlayers()
	end
	
	return true
	
end


local function UpdateArmoryAnim(self, extension, loggedIn, scanTime, timePassed)

    local loggedInName = "log_" .. extension
    local loggedInParamValue = ConditionalValue(loggedIn, 1, 0)

    if extension == "n" then
        self.loginNorthAmount = Clamp(Slerp(self.loginNorthAmount, loggedInParamValue, timePassed * 2), 0, 1)
    elseif extension == "s" then
        self.loginSouthAmount = Clamp(Slerp(self.loginSouthAmount, loggedInParamValue, timePassed * 2), 0, 1)
    elseif extension == "e" then
        self.loginEastAmount = Clamp(Slerp(self.loginEastAmount, loggedInParamValue, timePassed * 2), 0, 1)
    elseif extension == "w" then
        self.loginWestAmount = Clamp(Slerp(self.loginWestAmount, loggedInParamValue, timePassed * 2), 0, 1)
    end
    
    local scannedName = "scan_" .. extension
    self.scannedParamValue = self.scannedParamValue or { }
    self.scannedParamValue[extension] = ConditionalValue(scanTime == 0 or (Shared.GetTime() > scanTime + 3), 0, 1)
    
end


local newNetworkVars = {}

AddMixinNetworkVars( FireMixin, newNetworkVars )
AddMixinNetworkVars( DetectableMixin, newNetworkVars )
AddMixinNetworkVars( DissolveMixin, newNetworkVars )
AddMixinNetworkVars( ElectroMagneticMixin, newNetworkVars )


//-----------------------------------------------------------------------------


function Armory:OnCreate()	//OVERRIDES

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
    InitMixin(self, RagdollMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)
    
    InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, ElectroMagneticMixin)    
	
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
    // False if the player that's logged into a side is only nearby, true if
    // the pressed their key to open the menu to buy something. A player
    // must use the armory once "logged in" to be able to buy anything.
    self.loginEastAmount = 0
    self.loginNorthAmount = 0
    self.loginWestAmount = 0
    self.loginSouthAmount = 0
    
    self.loggedInWest = false
    self.loggedInNorth = false
    self.loggedInSouth = false
    self.loggedInEast = false
    
    self.timeScannedEast = 0
    self.timeScannedNorth = 0
    self.timeScannedWest = 0
    self.timeScannedSouth = 0
    
    self.deployed = false
    
    
    if Server then
		self.advancedArmoryUpgrade = false
	end
	
	if Client then
		
        InitMixin(self, CommanderGlowMixin)
        InitMixin(self, ColoredSkinsMixin)
        
        self.showHealthIndicator = false
        
    end
    
end


function Armory:OnInitialized()	//OVERRIDES

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Armory.kModelName, kAnimationGraph)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)

    if Server then    
    
        self.loggedInArray = { false, false, false, false }
        
        // Use entityId as index, store time last resupplied
        self.resuppliedPlayers = { }
		
        self:AddTimedCallback( LoginAndResupply, kLoginAndResupplyTime )
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        InitMixin(self, SupplyUserMixin)
        
    elseif Client then
    
        self:OnInitClient()
		
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end
    
    InitMixin(self, IdleMixin)
	
	if Client then
		self:InitializeSkin()
	end

end


function Armory:GetIsVulnerableToEMP()
	return false
end

local blackColor = Color( 0,0,0,0 )
function Armory:OnKill(attacker, doer, point, direction)

	if Client then
		self.skinAccentColor = blackColor
	end

end


if Client then
	
	function Armory:InitializeSkin()
		
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = 0
		
	end

	function Armory:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end
	
	function Armory:GetAccentSkinColor()
		if self:GetIsBuilt() then
			return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
		else
			return blackColor
		end
	end
	
	function Armory:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end
	
	
	function Armory:OnUse(player, elapsedTime, useSuccessTable)	//OVERRIDES

		self:UpdateArmoryWarmUp()
		
		if MvM_GetIsUnitActive(self) and not Shared.GetIsRunningPrediction() and not player.buyMenu and self:GetWarmupCompleted() then
		
			if Client.GetLocalPlayer() == player then
				
				Client.SetCursor("ui/Cursor_MarineCommanderDefault.dds", 0, 0)
				
				// Play looping "active" sound while logged in
				// Shared.PlayPrivateSound(player, Armory.kResupplySound, player, 1.0, Vector(0, 0, 0))
				
				if player:GetTeamNumber() == kTeam2Index then
					MouseTracker_SetIsVisible(true, "ui/Cursor_MenuDefault.dds", true)
				else
					MouseTracker_SetIsVisible(true, "ui/Cursor_MarineCommanderDefault.dds", true)
				end
				
				// tell the player to show the lua menu
				player:BuyMenu(self)
				
			end
			
		end
		
	end	

end


function Armory:GetItemList(forPlayer)	//OVERRIDES
    
    local itemList = {   
        kTechId.DemoMines, 
        kTechId.Shotgun,
        kTechId.Welder,
        kTechId.ClusterGrenade,
        kTechId.GasGrenade,
        kTechId.PulseGrenade
    }
    
    if self:GetTechId() == kTechId.AdvancedArmory then
    
	    itemList = {   
	        kTechId.DemoMines,
	        kTechId.Shotgun,
	        kTechId.Welder,
            kTechId.ClusterGrenade,
            kTechId.GasGrenade,
            kTechId.PulseGrenade,
	        kTechId.GrenadeLauncher,
	        kTechId.Flamethrower,
	    }
	    
    end
    
    return itemList
    
end


function Armory:UpdateLoggedIn()
	
	local players = GetEntitiesForTeamWithinRange(
		"Marine", 
		self:GetTeamNumber(), 
		self:GetOrigin(), 
		2 * Armory.kResupplyUseRange
	)
	
	local armoryCoords = self:GetAngles():GetCoords()
	
	for i = 1, 4 do
	
		local newState = false
		
		if MvM_GetIsUnitActive(self) then
		
			local worldUseOrigin = self:GetModelOrigin() + armoryCoords:TransformVector(indexToUseOrigin[i])
		
			for playerIndex, player in ipairs(players) do
			
				// See if valid player is nearby
				//local isPlayerVortexed = HasMixin(player, "VortexAble") and player:GetIsVortexed()
				//not isPlayerVortexed and 
				if player:GetIsAlive() and (player:GetModelOrigin() - worldUseOrigin):GetLength() < Armory.kResupplyUseRange then
				
					newState = true
					break
					
				end
				
			end
			
		end
		
		if newState ~= self.loggedInArray[i] then
		
			if newState then
				self:TriggerEffects("armory_open")
			else
				self:TriggerEffects("armory_close")
			end
			
			self.loggedInArray[i] = newState
			
		end
		
	end
	
	// Copy data to network variables (arrays not supported)    
	self.loggedInWest = self.loggedInArray[1]
	self.loggedInNorth = self.loggedInArray[2]
	self.loggedInSouth = self.loggedInArray[3]
	self.loggedInEast = self.loggedInArray[4]

end


function Armory:GetTechButtons(techId)

	local techButtons = nil

    techButtons = { kTechId.ShotgunTech, kTechId.MinesTech, kTechId.GrenadeTech, kTechId.None,
                    kTechId.None, kTechId.None, kTechId.None, kTechId.None }
	
    // Show button to upgraded to advanced armory
    if self:GetTechId() == kTechId.Armory and self:GetResearchingId() ~= kTechId.AdvancedArmoryUpgrade then
        techButtons[kMarineUpgradeButtonIndex] = kTechId.AdvancedArmoryUpgrade
    end
    
    if self:GetTechId() == kTechId.AdvancedArmory then
		techButtons[5] = kTechId.GrenadeLauncherTech
    end
	
    return techButtons

end


function Armory:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    /*
    if techId == kTechId.HeavyRifleTech then
        allowed = allowed and self:GetTechId() == kTechId.AdvancedArmory
    end		//Add GLTech here instead of GetTechButtons?
    */
    
    return allowed, canAfford

end


local kUpVector = Vector(0, 1, 0)

function Armory:OnUpdate(deltaTime)	//OVERRIDES

    if Client then
        self:UpdateArmoryWarmUp()
    end
    
    if MvM_GetIsUnitActive(self) and self.deployed then
    
        // Set pose parameters according to if we're logged in or not
        UpdateArmoryAnim(self, "e", self.loggedInEast, self.timeScannedEast, deltaTime)
        UpdateArmoryAnim(self, "n", self.loggedInNorth, self.timeScannedNorth, deltaTime)
        UpdateArmoryAnim(self, "w", self.loggedInWest, self.timeScannedWest, deltaTime)
        UpdateArmoryAnim(self, "s", self.loggedInSouth, self.timeScannedSouth, deltaTime)
        
    end
    
    ScriptActor.OnUpdate(self, deltaTime)
    
    if Client then
    
		self.showHealthIndicator = false
		
		local player = Client.GetLocalPlayer()
		
		if player then    
			self.showHealthIndicator = MvM_GetIsUnitActive(self) and GetAreFriends(self, player) and (
					player:GetHealth() / player:GetMaxHealth() 
				) ~= 1 and 
				player:GetIsAlive() and not player:isa("Commander") 
		end
		
		if not self.healthIndicator then
		
			self.healthIndicator = Client.CreateRenderModel(RenderScene.Zone_Default)  
			self.healthIndicator:SetModel(kHealthIndicatorModelName)
			
		end
		
		// rotate model if visible
		if self.showHealthIndicator then
		
			local time = Shared.GetTime()
			local zAxis = Vector(math.cos(time), 0, math.sin(time))

			local coords = Coords.GetLookIn(self:GetOrigin() + 2.9 * kUpVector, zAxis)
			self.healthIndicator:SetCoords(coords)
		
		end
		
		self.healthIndicator:SetIsVisible(self.showHealthIndicator)
		
    end
    
    
end



if Server then

	local function AddChildModel(self)
		
		local scriptActor = CreateEntity(ArmoryAddon.kMapName, nil, self:GetTeamNumber())
		scriptActor:SetParent(self)
		scriptActor:SetAttachPoint(Armory.kAttachPoint)
		
		return scriptActor
		
	end


	function Armory:OnConstructionComplete()
		self:AddTimedCallback(OnDeploy, kDeployTime)
	end
    
    
	function Armory:OnResearchComplete(researchId)

        if researchId == kTechId.AdvancedArmoryUpgrade then
        
            self:SetTechId(kTechId.AdvancedArmory)
            
            local techTree = self:GetTeam():GetTechTree()
            
            local ftResearchNode = techTree:GetTechNode(kTechId.FlamethrowerTech)
            if ftResearchNode then
            
				ftResearchNode:SetResearchProgress(1.0)
                techTree:SetTechNodeChanged(ftResearchNode, string.format("researchProgress = %.2f", self.researchProgress))
                ftResearchNode:SetResearched(true)
				techTree:QueueOnResearchComplete(kTechId.FlamethrowerTech, self)
            
            end
            
            local team = self:GetTeam()
			if team then
				self.advancedArmoryUpgrade = true
				team:AddSupplyUsed( kAdvancedArmorySupply )
			end
            
        end
        
    end
	
	
	function Armory:OverrideRemoveSupply( team )

		if team then
			
			if self.advancedArmoryUpgrade then
				
				local supplyAmount = kArmorySupply + kAdvancedArmorySupply
				team:RemoveSupplyUsed( supplyAmount )
				
			else
				team:RemoveSupplyUsed( LookupTechData( self:GetTechId(), kTechDataSupply, 0) )
			end
		
		end

	end
	
	
	
    function Armory:ResupplyPlayer( player )  //OVERRIDES
        
        local resuppliedPlayer = false
        local armoryTeam = self:GetTeamNumber()
        
        // Heal player first
        if ( player:GetHealth() < player:GetMaxHealth() ) then

            // third param true = ignore armor
            player:AddHealth( Armory.kHealAmount, false, true, false, self )
            
            self:TriggerEffects("armory_health", {
                effecthostcoords = Coords.GetTranslation( player:GetOrigin() ),
                ismarine = ( armoryTeam == kTeam1Index ), isalien = ( armoryTeam == kTeam2Index )
            })
            
            TEST_EVENT("Armory resupplied health")
            
            resuppliedPlayer = true
            /* Removed - too easy to armory hump and dimish FT
            if HasMixin(player, "Fire") and player:GetIsOnFire() and not player:isa("Exo") then
				
                player:SetGameEffectMask(kGameEffect.OnFire, false)
                //TEST_EVENT("Armory removed Fire")
                
            end
            */
            
            if player:isa("Marine") and player.poisoned then
            
                player.poisoned = false
                TEST_EVENT("Armory cured Poison")
                
            end
            
        end

        // Give ammo to all their weapons, one clip at a time, starting from primary
        local weapons = player:GetHUDOrderedWeaponList()
        
        for index, weapon in ipairs(weapons) do
        
            if weapon:isa("ClipWeapon") then
            
                if weapon:GiveAmmo(1, false) then
                
                    self:TriggerEffects("armory_ammo", {
                        effecthostcoords = Coords.GetTranslation(player:GetOrigin()),
                        ismarine = ( armoryTeam == kTeam1Index ), isalien = ( armoryTeam == kTeam2Index )
                    })
                    
                    resuppliedPlayer = true
                    
                    TEST_EVENT("Armory resupplied health/armor")
                    
                    break
                    
                end 
                       
            end
            
        end
            
        if resuppliedPlayer then
        
            // Insert/update entry in table
            self.resuppliedPlayers[player:GetId()] = Shared.GetTime()
            
            // Play effect
            //self:PlayArmoryScan(player:GetId())

        end

    end
    
    
    function Armory:OverrideVisionRadius()
		return 2
    end
    
    
    function Armory:OnResearch(researchId)
		
		if researchId == kTechId.AdvancedArmoryUpgrade then

			// Create visual add-on
			local advancedArmoryModule = AddChildModel(self)
			advancedArmoryModule.isAddonPowered = self:GetIsPowered()
			
		end
		
	end
    
    
    function Armory:UpdateResearch()
		
		local researchId = self:GetResearchingId()
		
		if researchId == kTechId.AdvancedArmoryUpgrade then
		
			local techTree = self:GetTeam():GetTechTree()    
			local researchNode = techTree:GetTechNode(kTechId.AdvancedArmory)    
			researchNode:SetResearchProgress(self.researchProgress)
			techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
			
		end

	end
    
    
    function Armory:OnPowerOff()
		
		if self:GetTechId() == kTechId.AdvancedArmory then
			//This is a shitty way to go about this. A hashmap or table def would be better.
			//wrapped in getter/setter/info calls for all children. Allow fetch by XYZ (Name, Class, etc)
			for i = 0, self:GetNumChildren() - 1 do	
                local child = self:GetChildAtIndex(i)
                if child:isa("ArmoryAddon") then
					child.isAddonPowered = false
                end
                
            end
            
		end
		
    end
    
    function Armory:OnPowerOn()
		if self:GetTechId() == kTechId.AdvancedArmory then
			for i = 0, self:GetNumChildren() - 1 do	
                local child = self:GetChildAtIndex(i)
                if child:isa("ArmoryAddon") then
					child.isAddonPowered = true
                end
                
            end
		end
    end
	
	
end	//End Server


Class_Reload("Armory", newNetworkVars)


//=============================================================================


local addonNetworkVars = {
	isAddonPowered = "boolean"
}

function ArmoryAddon:OnCreate()		//OVERRIDES

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, TeamMixin)
    
    if Server then
        self.creationTime = Shared.GetTime()
    end
    
    self.isAddonPowered = false
	
    gArmoryHealthHeight = 1.7
    
    if Client then
        InitMixin(self, ColoredSkinsMixin)
    end

end


function ArmoryAddon:OnInitialized()		//OVERRIDES

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Armory.kAdvancedArmoryChildModel, Armory.kAdvancedArmoryAnimationGraph)

    if Client then
        self:InitializeSkin()
    end

end

local blackColor = Color(0,0,0,0)
function ArmoryAddon:OnUpdateRender()

	if Client then
	
		if self.isAddonPowered == false then
			self.skinAccentColor = blackColor
		else
			self.skinAccentColor = self:GetAccentSkinColor()
		end
	
	end

end


if Client then

    function ArmoryAddon:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = 0
	end

	function ArmoryAddon:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end
    
	function ArmoryAddon:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function ArmoryAddon:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


Class_Reload( "ArmoryAddon", addonNetworkVars )

