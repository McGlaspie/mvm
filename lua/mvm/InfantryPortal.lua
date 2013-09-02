

Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/mvm/TeamColorSkinMixin.lua")
Script.Load("lua/PostLoadMod.lua")

local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local oldIPcreate = InfantryPortal.OnCreate
function InfantryPortal:OnCreate()

	oldIPcreate(self)
	
	InitMixin(self, FireMixin)
	InitMixin(self, DetectableMixin)
    InitMixin(self, TeamColorSkinMixin)

end

//-----------------------------------------------------------------------------

Class_Reload("InfantryPortal", newNetworkVars)

