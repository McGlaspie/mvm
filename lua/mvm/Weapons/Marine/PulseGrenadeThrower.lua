
Script.Load("lua/mvm/Weapons/Marine/GrenadeThrower.lua")
Script.Load("lua/mvm/Weapons/Marine/PulseGrenade.lua")


local newNetworkVars = {
	grenadesLeft = "integer (0 to 1)",
}



function PulseGrenadeThrower:OnCreate()

    GrenadeThrower.OnCreate( self )
    
    self.grenadesLeft = 1
    
end


Class_Reload( "PulseGrenadeThrower", newNetworkVars )