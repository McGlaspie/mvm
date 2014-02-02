

Script.Load("lua/mvm/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")
Script.Load("lua/mvm/LiveMixin.lua")

//-----------------------------------------------------------------------------


function Pistol:GetHasSecondary(player)
    return false
end


if Client then

	function Pistol:GetUIDisplaySettings()
        return { xSize = 256, ySize = 256, script = "lua/mvm/Hud/GUIPistolDisplay.lua" }
    end
    
end

//-----------------------------------------------------------------------------

Class_Reload("Pistol", {})