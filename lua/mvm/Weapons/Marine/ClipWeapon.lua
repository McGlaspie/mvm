

Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/mvm/Weapons/Weapon.lua")
Script.Load("lua/mvm/Weapons/BulletsMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")


local newNetworkVars = {}

AddMixinNetworkVars(LOSMixin, newNetworkVars )


//-----------------------------------------------------------------------------


function ClipWeapon:OnCreate()	//OVERRIDE

    Weapon.OnCreate(self)
    
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    
    self.primaryAttacking = false
    self.secondaryAttacking = false
    self.blockingPrimary = false
    self.blockingSecondary = false
    self.timeAttackStarted = 0
    self.timeAttackEnded = 0
    self.deployed = false
    self.lastTimeSprinted = 0
    
    InitMixin(self, BulletsMixin)
    
end


function ClipWeapon:OverrideCheckVision()
	return false
end

function ClipWeapon:OverrideVisionRadius()
	return 0
end


// Play tracer sound/effect every %d bullets
function ClipWeapon:GetTracerEffectFrequency()
    return 0.5
end


//-----------------------------------------------------------------------------


Class_Reload( "ClipWeapon", newNetworkVars )

