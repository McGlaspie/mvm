

Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/TeamColorSkinMixin.lua")
Script.Load("lua/PostLoadMod.lua")

local newNetworkVars = {}

//-----------------------------------------------------------------------------

AddMixinNetworkVars(LOSMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local oldExosuitCreate = Exosuit.OnCreate
function Exosuit:OnCreate()

	oldExosuitCreate(self)
	
	InitMixin(self, LOSMixin)
    InitMixin(self, TeamColorSkinMixin)

end


function Exosuit:GetIsValidRecipient(recipient)
	
	if HasMixin(recipient, "Team") then
		return not recipient:isa("Exo") and self:GetTeamNumber() == recipient:GetTeamNumber()
	end
	
	return false
	
end


//-----------------------------------------------------------------------------

Class_Reload("Exosuit", newNetworkVars)

