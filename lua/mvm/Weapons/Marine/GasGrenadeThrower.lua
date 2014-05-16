

Script.Load("lua/mvm/Weapons/Marine/GrenadeThrower.lua")


local newNetworkVars = {
	grenadesLeft = "integer (0 to 1)",
}


local kModelName = PrecacheAsset("models/marine/grenades/gr_nerve.model")
local kViewModels = GenerateMarineGrenadeViewModelPaths("gr_nerve")
local kAnimationGraph = PrecacheAsset("models/marine/grenades/grenade_view.animation_graph")

function GasGrenadeThrower:GetThirdPersonModelName()
    return kModelName
end

function GasGrenadeThrower:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function GasGrenadeThrower:GetAnimationGraphName()
    return kAnimationGraph
end


function GasGrenadeThrower:OnCreate()

	GrenadeThrower.OnCreate( self )
	
	self.grenadesLeft = 1

end


Class_Reload( "GasGrenadeThrower", newNetworkVars )