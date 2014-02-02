
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
if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
end
Script.Load("lua/mvm/SupplyUserMixin.lua")


local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)
AddMixinNetworkVars(DissolveMixin, newNetworkVars)


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



local orgArmoryInit = Armory.OnInitialized
function Armory:OnInitialized()

	orgArmoryInit(self)
	
	if Client then
		self:InitializeSkin()
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


if Server then

	local function AddChildModel(self)
		
		local scriptActor = CreateEntity(ArmoryAddon.kMapName, nil, self:GetTeamNumber())
		scriptActor:SetParent(self)
		scriptActor:SetAttachPoint(Armory.kAttachPoint)
		
		return scriptActor
		
	end

	function Armory:OnResearch(researchId)
		
		if researchId == kTechId.AdvancedArmoryUpgrade then

			// Create visual add-on
			local advancedArmoryModule = AddChildModel(self)
			
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
	
end	//End Server


Class_Reload("Armory", newNetworkVars)

