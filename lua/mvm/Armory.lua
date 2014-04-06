
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

if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
end



local newNetworkVars = {}

AddMixinNetworkVars( FireMixin, newNetworkVars )
AddMixinNetworkVars( DetectableMixin, newNetworkVars )
AddMixinNetworkVars( DissolveMixin, newNetworkVars )
AddMixinNetworkVars( ElectroMagneticMixin, newNetworkVars )


local kLoginAndResupplyTime = 0.3


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
    
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
        InitMixin(self, ColoredSkinsMixin)
    end
    

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
    
    self.timeScannedEast = 0
    self.timeScannedNorth = 0
    self.timeScannedWest = 0
    self.timeScannedSouth = 0
    
    self.deployed = false
    
    
    if Server then
		self.advancedArmoryUpgrade = false
	end
	
    
end


// Check if friendly players are nearby and facing armory and heal/resupply them
local function LoginAndResupply(self)

    self:UpdateLoggedIn()
    
    // Make sure players are still close enough, alive, marines, etc.
    // Give health and ammo to nearby players.
    if GetIsUnitActive(self) then
        self:ResupplyPlayers()
    end
    
    return true
    
end

/*
function Armory:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Armory.kModelName, kAnimationGraph)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)

    if Server then    
    
        self.loggedInArray = { false, false, false, false }
        
        // Use entityId as index, store time last resupplied
        self.resuppliedPlayers = { }

        self:AddTimedCallback(LoginAndResupply, kLoginAndResupplyTime)
        
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
        
        self:InitializeSkin()
        
    end
    
    InitMixin(self, IdleMixin)
    
end
*/

local orgArmoryInit = Armory.OnInitialized
function Armory:OnInitialized()

	orgArmoryInit(self)
	
	if Client then
		self:InitializeSkin()
	end

end


function Armory:GetIsVulnerableToEMP()
	return false
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
			return Color( 0,0,0 )
		end
	end

	function Armory:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


function Armory:GetTechButtons(techId)

	local techButtons = nil

    techButtons = { kTechId.ShotgunTech, kTechId.MinesTech, kTechId.GrenadeTech, kTechId.None,
                    kTechId.None, kTechId.GrenadeLauncherTech, kTechId.None, kTechId.None }
	
    // Show button to upgraded to advanced armory
    if self:GetTechId() == kTechId.Armory and self:GetResearchingId() ~= kTechId.AdvancedArmoryUpgrade then
        techButtons[kMarineUpgradeButtonIndex] = kTechId.AdvancedArmoryUpgrade
    end
	
    return techButtons

end


function Armory:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    /*
    if techId == kTechId.HeavyRifleTech then
        allowed = allowed and self:GetTechId() == kTechId.AdvancedArmory
    end
    */
    
    return allowed, canAfford

end


if Server then

	local function AddChildModel(self)
		
		local scriptActor = CreateEntity(ArmoryAddon.kMapName, nil, self:GetTeamNumber())
		scriptActor:SetParent(self)
		scriptActor:SetAttachPoint(Armory.kAttachPoint)
		
		return scriptActor
		
	end
    
    
	function Armory:OnResearchComplete(researchId)

        if researchId == kTechId.AdvancedArmoryUpgrade then
        
            self:SetTechId(kTechId.AdvancedArmory)
            
            local techTree = self:GetTeam():GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.AdvancedWeaponry)
            
            if researchNode then     
       
                researchNode:SetResearchProgress(1.0)
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
                researchNode:SetResearched(true)
                techTree:QueueOnResearchComplete(kTechId.AdvancedWeaponry, self)
                
                local team = self:GetTeam()
                if team then
                    self.advancedArmoryUpgrade = true
                    team:AddSupplyUsed( kAdvancedArmorySupply )
                end
                
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
        if (player:GetHealth() < player:GetMaxHealth()) then

            // third param true = ignore armor
            player:AddHealth(Armory.kHealAmount, false, true)
            
            self:TriggerEffects("armory_health", {
                effecthostcoords = Coords.GetTranslation( player:GetOrigin() ),
                ismarine = ( armoryTeam == kTeam1Index ), isalien = ( armoryTeam == kTeam2Index )
            })
            
            TEST_EVENT("Armory resupplied health")
            
            resuppliedPlayer = true
            /*
            if HasMixin(player, "ParasiteAble") and player:GetIsParasited() then
            
                player:RemoveParasite()
                TEST_EVENT("Armory removed Parasite")
                
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
	
	
end	//End Server


Class_Reload("Armory", newNetworkVars)


//-----------------------------------------------------------------------------


local orgArmoryAddonCreate = ArmoryAddon.OnCreate
function ArmoryAddon:OnCreate()

    orgArmoryAddonCreate( self )
    
    if Client then
        InitMixin(self, ColoredSkinsMixin)
    end

end

local orgArmoryAddonInit = ArmoryAddon.OnInitialized
function ArmoryAddon:OnInitialized()

    orgArmoryAddonInit( self )

    if Client then
        self:InitializeSkin()
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


Class_Reload( "ArmoryAddon", {} )

