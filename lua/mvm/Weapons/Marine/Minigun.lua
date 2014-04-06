

local kSpinUpSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_up_2"),
                            [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_up") }

local kSpinDownSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_down_2"),
                              [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_down") }

local kSpinSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_2"),
                          [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin") }

local kSpinTailSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/tail_2"),
                              [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/tail") }

local kHeatUISoundName = PrecacheAsset("sound/NS2.fev/marine/heavy/heat_UI")
local kOverheatedSoundName = PrecacheAsset("sound/NS2.fev/marine/heavy/overheated")

local kOverheatEffect = PrecacheAsset("cinematics/marine/minigun/overheat.cinematic")

// Trigger on the client based on the "shooting" variable below.
local kShellsCinematics = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("cinematics/marine/minigun/mm_left_shell.cinematic"),
                            [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("cinematics/marine/minigun/mm_shell.cinematic") }
local kShellsAttachPoints = { [ExoWeaponHolder.kSlotNames.Left] = "Exosuit_LElbow",
                              [ExoWeaponHolder.kSlotNames.Right] = "Exosuit_RElbow" }

local kMinigunRange = 400
local kMinigunSpread = Math.Radians(5)


local kBulletSize = 0.03

local kHeatUpRate = 0.3		//0.2
local kDualGunHeatUpRate = 0.2	//0.15
local kCoolDownRate = 0.4

local kMinigunMovementSlowdown = 0.6


//-----------------------------------------------------------------------------



local function UpdateOverheated(self, player)

    if not self.overheated and self.heatAmount == 1 then
    
        self.overheated = true
        self:OnPrimaryAttackEnd(player)
        
        if self:GetIsLeftSlot() then
            player:TriggerEffects("minigun_overheated_left")
        elseif self:GetIsRightSlot() then    
            player:TriggerEffects("minigun_overheated_right")
        end    
        
        StartSoundEffectForPlayer(kOverheatedSoundName, player)
        
    end
    
    if self.overheated and self.heatAmount == 0 then
        self.overheated = false
    end
    
end


function Minigun:ProcessMoveOnWeapon(player, input)

    local dt = input.time
    local addAmount = self.shooting and (dt * kHeatUpRate) or -(dt * kCoolDownRate)
    self.heatAmount = math.min(1, math.max(0, self.heatAmount + addAmount))
    
    UpdateOverheated(self, player)
    
    if self.shooting then
    
        local exoWeaponHolder = player:GetActiveWeapon()
        if exoWeaponHolder then
        
            local otherSlotWeapon = self:GetExoWeaponSlot() == ExoWeaponHolder.kSlotNames.Left and exoWeaponHolder:GetRightSlotWeapon() or exoWeaponHolder:GetLeftSlotWeapon()
            if otherSlotWeapon and otherSlotWeapon:isa("Minigun") then
                otherSlotWeapon:AddHeat(dt * kDualGunHeatUpRate)
            end
        
        end
    
    end
    
    if Client and not Shared.GetIsRunningPrediction() then
    
        local spinSound = Shared.GetEntity(self.spinSoundId)
        spinSound:SetParameter("heat", self.heatAmount, 1)
        
        if player:GetIsLocalPlayer() then
        
            local heatUISound = Shared.GetEntity(self.heatUISoundId)
            heatUISound:SetParameter("heat", self.heatAmount, 1)
            
        end
        
    end
    
end


function Minigun:OnUpdateRender()

    PROFILE("Minigun:OnUpdateRender")

    local parent = self:GetParent()
    if parent and parent:GetIsLocalPlayer() then
    
        local viewModel = parent:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() then
        
            viewModel:InstanceMaterials()
            viewModel:GetRenderModel():SetMaterialParameter("heatAmount" .. self:GetExoWeaponSlotName(), self.heatAmount)
            
        end
        
        local heatDisplayUI = self.heatDisplayUI
        if not heatDisplayUI then
			
            heatDisplayUI = Client.CreateGUIView(242, 720)
            heatDisplayUI:Load("lua/mvm/Hud/Exo/GUI" .. self:GetExoWeaponSlotName():gsub("^%l", string.upper) .. "MinigunDisplay.lua")
            heatDisplayUI:SetTargetTexture("*exo_minigun_" .. self:GetExoWeaponSlotName())
            self.heatDisplayUI = heatDisplayUI
            
        end
        
        heatDisplayUI:SetGlobal("heatAmount" .. self:GetExoWeaponSlotName(), self.heatAmount)
        heatDisplayUI:SetGlobal("teamNumber", parent:GetTeamNumber() )
        
    else
    
        if self.heatDisplayUI then
        
            Client.DestroyGUIView(self.heatDisplayUI)
            self.heatDisplayUI = nil
            
        end
        
    end
    
    if self.shellsCinematic then
        self.shellsCinematic:SetIsActive(self.shooting)
    end
    
end


Class_Reload("Minigun", {})