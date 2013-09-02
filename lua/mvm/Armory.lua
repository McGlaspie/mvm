//
//
//=============================================================================

Script.Load("lua/mvm/TeamColorSkinMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/PostLoadMod.lua")

//-----------------------------------------------------------------------------

local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local orgArmoryCreate = Armory.OnCreate
function Armory:OnCreate()
	
	orgArmoryCreate(self)

	InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, TeamColorSkinMixin)	//Client only?

end

//-----------------------------------------------------------------------------

Class_Reload("Armory", newNetworkVars)