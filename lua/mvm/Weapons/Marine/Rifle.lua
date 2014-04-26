

Script.Load("lua/mvm/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")
Script.Load("lua/mvm/LiveMixin.lua")

local newNetworkVars = {}

local kNumberOfVariants = 3
local kRange = 100
local kButtRange = 1.1


//-----------------------------------------------------------------------------


function Rifle:OnCreate()	//OVERRIDES

    ClipWeapon.OnCreate(self)
    
    InitMixin(self, PickupableWeaponMixin)
    //InitMixin(self, EntityChangeMixin)
    InitMixin(self, LiveMixin)
    
    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    elseif Server then
        self.soundVariant = Shared.GetRandomInt(1, kNumberOfVariants)
        self.soundType = self.soundVariant
    end
    
end


function Rifle:GetSpread()
    return ClipWeapon.kCone4Degrees	//3		//Move to Balance
end


function Rifle:GetDamageType()	//doesn't seem to do damned thing, not called
	
	if self:GetSecondaryAttacking() then
		return kRifleMeleeDamageType
	end
	
	return kRifleDamageType

end

function Rifle:PerformMeleeAttack(player)

    player:TriggerEffects("rifle_alt_attack")
    
    AttackMeleeCapsule(self, player, kRifleMeleeDamage, kButtRange, nil, true)
    
end


local function UpdateSoundType(self, player)

    local upgradeLevel = 0
    
    if player.GetWeaponUpgradeLevel then
		playerWepLevel = player:GetWeaponUpgradeLevel()	- 1	//Seems dumb, but keeps 4-Tier wep 
															//levels in 3 tier bound. Also only
															//makes sound change on Level1 or higher
        upgradeLevel = math.max(0, playerWepLevel - 1)
    end
	
    self.soundType = self.soundVariant + upgradeLevel * kNumberOfVariants

end

function Rifle:OnPrimaryAttack(player)

    if not self:GetIsReloading() then
    
        if Server then
            UpdateSoundType(self, player)
        end
        
        ClipWeapon.OnPrimaryAttack(self, player)
        
    end    

end


if Client then
	
	function Rifle:GetUIDisplaySettings()
        return { xSize = 256, ySize = 417, script = "lua/mvm/Hud/GUIRifleDisplay.lua" }
    end
    
end


//-----------------------------------------------------------------------------


Class_Reload("Rifle", newNetworkVars)
