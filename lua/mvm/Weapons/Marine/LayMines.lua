
Script.Load("lua/mvm/Weapons/Weapon.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")

local newNetworkVars = {}
AddMixinNetworkVars(LOSMixin, newNetworkVars)


function LayMines:OnCreate()	//OVERRIDES

    Weapon.OnCreate(self)
    
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, PickupableWeaponMixin)
    
    self.minesLeft = kNumMines
    self.droppingMine = false
    
end


//function LayMines:OverrideCheckVision()
//	return false
//end

function LayMines:OverrideVisionRadius()
	return 0
end


function LayMines:GetIsValidRecipient(recipient)	//OVERRIDES
	
	//and not GetIsVortexed(recipient) 
    if self:GetParent() == nil and recipient and recipient:isa("Marine") and recipient:GetTeamNumber() == self:GetTeamNumber() then
    
        local laymines = recipient:GetWeapon(LayMines.kMapName)
        return laymines == nil
        
    end
    
    return false
    
end


if Client then

	function LayMines:GetUIDisplaySettings()	//OVERRIDES
        return { xSize = 256, ySize = 417, script = "lua/mvm/Hud/GUIMineDisplay.lua" }
    end
    
end


Class_Reload( "LayMines", newNetworkVars )

