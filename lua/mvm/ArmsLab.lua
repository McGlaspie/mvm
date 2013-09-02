
Script.Load("lua/mvm/TeamColorSkinMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/PostLoadMod.lua")

//-----------------------------------------------------------------------------

local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local orgArmsLabCreate = ArmsLab.OnCreate
function ArmsLab:OnCreate()
	
	orgArmsLabCreate(self)

	InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, TeamColorSkinMixin)	//Client only?

end

//-----------------------------------------------------------------------------

Class_Reload("ArmsLab", newNetworkVars)