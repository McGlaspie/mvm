
Script.Load("lua/mvm/Weapons/Marine/GrenadeThrower.lua")
Script.Load("lua/mvm/Weapons/Marine/PulseGrenade.lua")


local newNetworkVars = {
	grenadesLeft = "integer (0 to 1)",
}


local kModelName = PrecacheAsset("models/marine/grenades/gr_pulse.model")
local kViewModels = GenerateMarineGrenadeViewModelPaths("gr_pulse")
local kAnimationGraph = PrecacheAsset("models/marine/grenades/grenade_view.animation_graph")

function PulseGrenadeThrower:GetThirdPersonModelName()
    return kModelName
end

function PulseGrenadeThrower:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function PulseGrenadeThrower:GetAnimationGraphName()
    return kAnimationGraph
end

function PulseGrenadeThrower:OnCreate()

    GrenadeThrower.OnCreate( self )
    
    self.grenadesLeft = 1
    
end


Class_Reload( "PulseGrenadeThrower", newNetworkVars )