

Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
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
	
	//if Client then
		InitMixin(self, ColoredSkinsMixin)
	//end
	
end


local orgExtractorInit = Extractor.OnInitialized
function Extractor:OnInitialized()
	
	orgExtractorInit(self)
	
	//if Client then
		self:InitializeSkin()
	//end
	
end


//if Client then

	function Extractor:InitializeSkin()
		self._activeBaseColor = self:GetBaseSkinColor()
		self._activeAccentColor = self:GetAccentSkinColor()
		self._activeTrimColor = self:GetTrimSkinColor()
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
	
	function Extractor:OnPowerOff()
		self._activeAccentColor = Color(0,0,0,1)
	end
	
	function Extractor:OnPowerOn()
		self._activeAccentColor = self:GetAccentSkinColor()
	end

//end


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

