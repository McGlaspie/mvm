



function LayMines:GetIsValidRecipient(recipient)
	
    if self:GetParent() == nil and recipient and recipient:isa("Marine") then	//and not GetIsVortexed(recipient) 
    
        local laymines = recipient:GetWeapon(LayMines.kMapName)
        return laymines == nil
        
    end
    
    return false
    
end


if Client then

	function LayMines:GetUIDisplaySettings()
        return { xSize = 256, ySize = 417, script = "lua/mvm/Hud/GUIMineDisplay.lua" }
    end
    
end


Class_Reload("LayMines", {})