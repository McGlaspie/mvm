

Script.Load("lua/mvm/Weapons/Marine/GrenadeThrower.lua")
Script.Load("lua/mvm/Weapons/Marine/ClusterGrenade.lua")
Script.Load("lua/Weapons/Marine/ClusterGrenadeThrower.lua")


local newNetworkVars = {
	grenadesLeft = "integer (0 to 1)",
}


function ClusterGrenadeThrower:OnCreate()

	GrenadeThrower.OnCreate( self )
	
	self.grenadesLeft = 1

end


Class_Reload( "ClusterGrenadeThrower", newNetworkVars )