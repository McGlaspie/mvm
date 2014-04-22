

Script.Load("lua/mvm/TechMixin.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/DamageMixin.lua")


function Claw:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    
    self.clawAttacking = false
    
end


Class_Reload( "Claw", {} )