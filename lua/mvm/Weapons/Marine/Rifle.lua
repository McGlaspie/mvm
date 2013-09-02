
Script.Load("lua/PostLoadMod.lua")


local newNetworkVars = {}


//-----------------------------------------------------------------------------

function Rifle:GetSpread()
    return ClipWeapon.kCone3Degrees
end

//-----------------------------------------------------------------------------

Class_Reload("Rifle", newNetworkVars)
