
Script.Load("lua/mvm/Weapons/BulletsMixin.lua")

local kChargeSound = PrecacheAsset("sound/NS2.fev/marine/heavy/railgun_charge")

local kChargeTime = 2
// The Railgun will automatically shoot if it is charged for too long.
local kChargeForceShootTime = 2.2
local kRailgunRange = 800	//400
local kRailgunSpread = Math.Radians(0)
local kBulletSize = 0.3
local kRailgunMovementSlowdown = 0.8

local kRailgunChargeTime = 1.4


//-----------------------------------------------------------------------------


function Railgun:OnCreate()	//OVERRIDE

    Entity.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, BulletsMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, EffectsMixin)
    
    self.timeChargeStarted = 0
    self.railgunAttacking = false
    self.lockCharging = false
    self.timeOfLastShot = 0
    
    if Client then
    
        InitMixin(self, ClientWeaponEffectsMixin)
        self.chargeSound = Client.CreateSoundEffect(Shared.GetSoundIndex(kChargeSound))
        self.chargeSound:SetParent(self:GetId())
        
    end

end

//Update below to change charge behaviors (independent?)
function Railgun:OnPrimaryAttack(player)

    if not self.lockCharging and self.timeOfLastShot + kRailgunChargeTime <= Shared.GetTime() then
    
        if not self.railgunAttacking then
        
            self.timeChargeStarted = Shared.GetTime()
            
            // lock the second gun
            
            local exoWeaponHolder = player:GetActiveWeapon()
            if exoWeaponHolder then
            
                local otherSlotWeapon = self:GetExoWeaponSlot() == ExoWeaponHolder.kSlotNames.Left and exoWeaponHolder:GetRightSlotWeapon() or exoWeaponHolder:GetLeftSlotWeapon()
                if otherSlotWeapon and otherSlotWeapon:isa("Railgun") and not otherSlotWeapon.railgunAttacking then
                    otherSlotWeapon:LockGun()
                end
            
            end
            
        end
        self.railgunAttacking = true
        
    end
    
end




function Railgun:OnUpdateRender()

    PROFILE("Railgun:OnUpdateRender")
    
    local chargeAmount = self:GetChargeAmount()
    local parent = self:GetParent()
    if parent and parent:GetIsLocalPlayer() then
    
        local viewModel = parent:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() then
        
            viewModel:InstanceMaterials()
            local renderModel = viewModel:GetRenderModel()
            renderModel:SetMaterialParameter("chargeAmount" .. self:GetExoWeaponSlotName(), chargeAmount)
            renderModel:SetMaterialParameter("timeSinceLastShot" .. self:GetExoWeaponSlotName(), Shared.GetTime() - self.timeOfLastShot)
            
        end
        
        local chargeDisplayUI = self.chargeDisplayUI
        if not chargeDisplayUI then
        
            chargeDisplayUI = Client.CreateGUIView(246, 256)
            chargeDisplayUI:Load("lua/mvm/Hud/Exo/GUI" .. self:GetExoWeaponSlotName():gsub("^%l", string.upper) .. "RailgunDisplay.lua")
            chargeDisplayUI:SetTargetTexture("*exo_railgun_" .. self:GetExoWeaponSlotName())
            self.chargeDisplayUI = chargeDisplayUI
            
        end
        
        chargeDisplayUI:SetGlobal("teamNumber" , self:GetTeamNumber() )
        chargeDisplayUI:SetGlobal("chargeAmount" .. self:GetExoWeaponSlotName(), chargeAmount)
        chargeDisplayUI:SetGlobal("timeSinceLastShot" .. self:GetExoWeaponSlotName(), Shared.GetTime() - self.timeOfLastShot)
        
    else
    
        if self.chargeDisplayUI then
        
            Client.DestroyGUIView(self.chargeDisplayUI)
            self.chargeDisplayUI = nil
            
        end
        
    end
    
    if self.chargeSound then
    
        local playing = self.chargeSound:GetIsPlaying()
        if not playing and chargeAmount > 0 then
            self.chargeSound:Start()
        elseif playing and chargeAmount <= 0 then
            self.chargeSound:Stop()
        end
        
        self.chargeSound:SetParameter("charge", chargeAmount, 1)
        
    end
    
end



//-----------------------------------------------------------------------------

Class_Reload("Railgun", {})