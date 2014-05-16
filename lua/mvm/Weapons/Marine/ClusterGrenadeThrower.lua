

Script.Load("lua/mvm/Weapons/Marine/GrenadeThrower.lua")
Script.Load("lua/mvm/Weapons/Marine/ClusterGrenade.lua")
Script.Load("lua/Weapons/Marine/ClusterGrenadeThrower.lua")


local newNetworkVars = {
	grenadesLeft = "integer (0 to 1)",
}

local kModelName = PrecacheAsset("models/marine/grenades/gr_cluster.model")
local kViewModels = GenerateMarineGrenadeViewModelPaths("gr_cluster")
local kAnimationGraph = PrecacheAsset("models/marine/grenades/grenade_view.animation_graph")

function ClusterGrenadeThrower:GetThirdPersonModelName()
    return kModelName
end

function ClusterGrenadeThrower:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function ClusterGrenadeThrower:GetAnimationGraphName()
    return kAnimationGraph
end

function ClusterGrenadeThrower:OnCreate()

	GrenadeThrower.OnCreate( self )
	
	self.grenadesLeft = 1

end


Class_Reload( "ClusterGrenadeThrower", newNetworkVars )