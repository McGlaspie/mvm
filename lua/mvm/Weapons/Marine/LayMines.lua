
Script.Load("lua/mvm/Weapons/Weapon.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")

local newNetworkVars = {}
AddMixinNetworkVars(LOSMixin, newNetworkVars)

local kDropModelName = PrecacheAsset("models/marine/mine/mine_pile.model")
local kHeldModelName = PrecacheAsset("models/marine/mine/mine_3p.model")


function LayMines:OnCreate()	//OVERRIDES

    Weapon.OnCreate(self)
    
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, PickupableWeaponMixin)
    
    self.minesLeft = kNumMines
    self.droppingMine = false
    
    if Client then
		InitMixin( self, ColoredSkinsMixin)
    end
    
end


function LayMines:OnInitialized()	//OVERRIDES

	Weapon.OnInitialized(self)
    
    self:SetModel(kDropModelName)
	
	if Client then
		self:InitializeSkin()
	end

end


if Client then

	function LayMines:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = 0	//Static
	end
	
	function LayMines:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_BaseColor, kTeam2_BaseColor )
	end

	function LayMines:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_AccentColor, kTeam2_AccentColor )
	end

	function LayMines:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_TrimColor, kTeam2_TrimColor )
	end

end


//function LayMines:OverrideCheckVision()
//	return false
//end

function LayMines:OverrideVisionRadius()
	return 0
end


function LayMines:Dropped( prevOwner )

    Weapon.Dropped( self, prevOwner )
    
    self:SetModel( kDropModelName )
    
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

