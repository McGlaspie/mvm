
Script.Load("lua/mvm/GhostStructureMixin.lua")
Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/DissolveMixin.lua")
Script.Load("lua/mvm/PowerConsumerMixin.lua")
if Client then
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
end


local newNetworkVars = {}

//-----------------------------------------------------------------------------

AddMixinNetworkVars(DetectableMixin, newNetworkVars)
AddMixinNetworkVars(FireMixin, newNetworkVars)

//-----------------------------------------------------------------------------


function Extractor:OnCreate()	//OVERRIDES

	ResourceTower.OnCreate(self)
    
    InitMixin(self, CorrodeMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, HiveVisionMixin)
    InitMixin(self, UpgradableMixin)
	
	InitMixin(self, FireMixin)
	InitMixin(self, DetectableMixin)
	
	if Client then
		InitMixin(self, CommanderGlowMixin)
		InitMixin(self, ColoredSkinsMixin)
	end
	
end


local orgExtractorInit = Extractor.OnInitialized
function Extractor:OnInitialized()
	
	orgExtractorInit(self)
	
	if Client then
		self:InitializeSkin()
	end
	
end


if Client then

	function Extractor:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
	end
	
	function Extractor:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end
	
	function Extractor:GetAccentSkinColor()
		if self:GetIsBuilt() then
			return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
		else
			return Color( 0,0,0 )
		end
	end

	function Extractor:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


function Extractor:OverrideAddSupply( team )
	
	if self:GetIsBuilt() then
		team:AddSupplyUsed( LookupTechData( self:GetTechId(), kTechDataSupply, 0) )
	end

end


function Extractor:GetIsFlameAble()
	return false
end

/*
Future use - override one EMP disable effects added
if Server then

    function Extractor:GetIsCollecting()    
        return ResourceTower.GetIsCollecting(self) and self:GetIsPowered()  
    end
    
end
*/


//-----------------------------------------------------------------------------

Class_Reload("Extractor", newNetworkVars)

