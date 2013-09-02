

Script.Load("lua/PostLoadMod.lua")


function LayMines:GetIsValidRecipient(recipient)
	
    if self:GetParent() == nil and recipient and recipient:isa("Marine") then	//and not GetIsVortexed(recipient) 
    
        local laymines = recipient:GetWeapon(LayMines.kMapName)
        return laymines == nil
        
    end
    
    return false
    
end


Class_Reload("LayMines", {})