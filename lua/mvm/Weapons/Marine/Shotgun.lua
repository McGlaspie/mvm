
Script.Load("lua/PostLoadMod.lua")

Script.Load("lua/mvm/Balance.lua")
Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")

//-----------------------------------------------------------------------------


function Shotgun:GetRange()
    return 300
end

if Client then

	function Shotgun:GetUIDisplaySettings()
        return { xSize = 256, ySize = 128, script = "lua/mvm/Hud/GUIShotgunDisplay.lua" }
    end
    
end


//-----------------------------------------------------------------------------

Class_Reload("Shotgun", {})