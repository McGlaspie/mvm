

Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/TeamColorSkinMixin.lua")
Script.Load("lua/PostLoadMod.lua")


local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local oldProtoLabCreate = PrototypeLab.OnCreate
function PrototypeLab:OnCreate()
	oldProtoLabCreate()
	
	InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, TeamColorSkinMixin)
    
end

function PrototypeLab:GetTechButtons(techId)

    return { 
		kTechId.JetpackTech, 
		kTechId.ExosuitTech, 
		kTechId.DualMinigunTech, 
		kTechId.ClawRailgunTech 	//TODO Duel-Rail
	}
    
end

function PrototypeLab:GetItemList()
	//TODO Duel-Rail
    return { kTechId.Jetpack, kTechId.Exosuit, kTechId.DualMinigunExosuit, kTechId.ClawRailgunExosuit }
end

//-----------------------------------------------------------------------------

Class_Reload("PrototypeLab", newNetworkVars)
