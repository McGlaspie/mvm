

Script.Load("lua/mvm/Weapons/Marine/GrenadeThrower.lua")


local newNetworkVars = {
	grenadesLeft = "integer (0 to 1)",
}


function GasGrenadeThrower:OnCreate()

	GrenadeThrower.OnCreate( self )
	
	self.grenadesLeft = 1

end


Class_Reload( "GasGrenadeThrower", newNetworkVars )