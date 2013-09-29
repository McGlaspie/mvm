
Script.Load("lua/PostLoadMod.lua")

Script.Load("lua/mvm/Balance.lua")
Script.Load("lua/mvm/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")
//Script.Load("lua/mvm/Weapons/Marine/Grenade.lua")
Script.Load("lua/mvm/LiveMixin.lua")


//-----------------------------------------------------------------------------


function GrenadeLauncher:GetNumStartClips()
    return 8
end


if Client then

    function GrenadeLauncher:GetUIDisplaySettings()
        return { xSize = 256, ySize = 256, script = "lua/mvm/Hud/GUIGrenadelauncherDisplay.lua" }
    end
    
end


//-----------------------------------------------------------------------------


Class_Reload("GrenadeLauncher", {})
