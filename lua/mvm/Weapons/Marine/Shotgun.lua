

Script.Load("lua/mvm/Balance.lua")
Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")



// higher numbers reduces the spread
local kMvMSpreadDistance = 18
local kStartOffset = 0
local kMvMSpreadVectors =
{
    GetNormalizedVector(Vector(-0.01, 0.01, kMvMSpreadDistance)),
    
    GetNormalizedVector(Vector(-0.45, 0.45, kMvMSpreadDistance)),
    GetNormalizedVector(Vector(0.45, 0.45, kMvMSpreadDistance)),
    GetNormalizedVector(Vector(0.45, -0.45, kMvMSpreadDistance)),
    GetNormalizedVector(Vector(-0.45, -0.45, kMvMSpreadDistance)),
    
    GetNormalizedVector(Vector(-1, 0, kMvMSpreadDistance)),
    GetNormalizedVector(Vector(1, 0, kMvMSpreadDistance)),
    GetNormalizedVector(Vector(0, -1, kMvMSpreadDistance)),
    GetNormalizedVector(Vector(0, 1, kMvMSpreadDistance)),
    
    GetNormalizedVector(Vector(-0.35, 0, kMvMSpreadDistance)),
    GetNormalizedVector(Vector(0.35, 0, kMvMSpreadDistance)),
    GetNormalizedVector(Vector(0, -0.35, kMvMSpreadDistance)),
    GetNormalizedVector(Vector(0, 0.35, kMvMSpreadDistance)),
    
    GetNormalizedVector(Vector(-0.8, -0.8, kMvMSpreadDistance)),
    GetNormalizedVector(Vector(-0.8, 0.8, kMvMSpreadDistance)),
    GetNormalizedVector(Vector(0.8, 0.8, kMvMSpreadDistance)),
    GetNormalizedVector(Vector(0.8, -0.8, kMvMSpreadDistance)),
    
}

local kViewModels = GenerateMarineViewModelPaths("shotgun")
local kAnimationGraph = PrecacheAsset("models/marine/shotgun/shotgun_view.animation_graph")


//-----------------------------------------------------------------------------


function Shotgun:OnCreate()

    ClipWeapon.OnCreate(self)
    
    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, PointGiverMixin)
    
    self.emptyPoseParam = 0

end

if Client then

    function Shotgun:OnInitialized()
    
        ClipWeapon.OnInitialized(self)
    
    end

end

function Shotgun:GetAnimationGraphName()
    return kAnimationGraph
end

function Shotgun:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end


function Shotgun:GetRange()
    return 300
end

if Client then

	function Shotgun:GetUIDisplaySettings()
        return { xSize = 256, ySize = 128, script = "lua/mvm/Hud/GUIShotgunDisplay.lua" }
    end
    
end


//-----------------------------------------------------------------------------


ReplaceLocals( Shotgun.FirePrimary, { kShotgunDamage = kShotgunDamage, kSpreadVectors = kMvMSpreadVectors } )

Class_Reload("Shotgun", {})

