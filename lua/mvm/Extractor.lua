

Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/PowerConsumerMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")

local newNetworkVars = {}

//-----------------------------------------------------------------------------

AddMixinNetworkVars(DetectableMixin, newNetworkVars)
AddMixinNetworkVars(FireMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local oldExtractorCreate = Extractor.OnCreate
function Extractor:OnCreate()

	oldExtractorCreate(self)
	
	InitMixin(self, FireMixin)
	InitMixin(self, DetectableMixin)
	
	if Client then
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
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function Extractor:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
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

