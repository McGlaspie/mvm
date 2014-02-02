

Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/mvm/Weapons/Weapon.lua")
Script.Load("lua/mvm/Weapons/BulletsMixin.lua")


//-----------------------------------------------------------------------------


//Override - enforce usage of MvM's BulletMixin
function ClipWeapon:OnCreate()

    Weapon.OnCreate(self)
    
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


function ClipWeapon:SetTeamNumber( teamNumber )
	self.teamNumber = teamNumber
end


// Play tracer sound/effect every %d bullets
function ClipWeapon:GetTracerEffectFrequency()
    return 1	//0.5
end


//-----------------------------------------------------------------------------


Class_Reload("ClipWeapon", {})