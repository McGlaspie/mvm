

Script.Load("lua/mvm/Weapons/Weapon.lua")

//-----------------------------------------------------------------------------

function Builder:GetSprintAllowed()
    return false
end

if Client then

    function Builder:GetUIDisplaySettings()
        return { xSize = 512, ySize = 512, script = "lua/mvm/Hud/GUIWelderDisplay.lua", textureNameOverride = "welder" }
    end
    
end

//-----------------------------------------------------------------------------

Class_Reload("Builder", {})