

Script.Load("lua/mvm/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")
Script.Load("lua/mvm/LiveMixin.lua")

local newNetworkVars = {}


//-----------------------------------------------------------------------------

function Rifle:GetSpread()
    return ClipWeapon.kCone4Degrees	//3
end


if Client then
	
	function Rifle:GetUIDisplaySettings()
        return { xSize = 256, ySize = 417, script = "lua/mvm/Hud/GUIRifleDisplay.lua" }
    end
    
end

//-----------------------------------------------------------------------------

Class_Reload("Rifle", newNetworkVars)
