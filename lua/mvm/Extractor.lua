

Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/TeamColorSkinMixin.lua")

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
	InitMixin(self, TeamColorSkinMixin)
	
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

