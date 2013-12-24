

Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/PowerConsumerMixin.lua")
Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/PostLoadMod.lua")
Script.Load("lua/mvm/SupplyUserMixin.lua")


local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)


//-----------------------------------------------------------------------------


local orgArmoryCreate = Armory.OnCreate
function Armory:OnCreate()
	
	orgArmoryCreate(self)

	InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
	
	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end
	
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
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function Armory:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

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
			
			self.advancedArmoryUpgrade = true
			local team = self:GetTeam()
			if team then
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

