

Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/TeamColorSkinMixin.lua")
Script.Load("lua/PostLoadMod.lua")

local newNetworkVars = {}

AddMixinNetworkVars(LOSMixin, newNetworkVars)

//-----------------------------------------------------------------------------


local oldJetpackCreate = Jetpack.OnCreate
function Jetpack:OnCreate()
	
	oldJetpackCreate(self)
	
	InitMixin(self, LOSMixin)
	InitMixin(self, TeamColorSkinMixin)
	
end


function Jetpack:GetIsValidRecipient(recipient)
	if HasMixin(recipient, "Team") then
		return 
			not recipient:isa("JetpackMarine") 
			and not recipient:isa("Exo") 
			and self:GetTeamNumber() == recipient:GetTeamNumber()
	end
	
	return false
end


function Jetpack:GetIsPermanent()	//Future Use
    return true
end


//-----------------------------------------------------------------------------


Class_Reload("Jetpack", newNetworkVars)