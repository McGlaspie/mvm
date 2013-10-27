

Script.Load("lua/PostLoadMod.lua")

Script.Load("lua/mvm/Weapons/Weapon.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")
Script.Load("lua/mvm/LiveMixin.lua")


local newNetworkVars = {}


local kWelderEffectRate = 0.45
local kWelderFireDelay = 0.5
local kWeldRange = 2.4

local kFireLoopingSound = PrecacheAsset("sound/NS2.fev/marine/welder/weld")

local kHealScoreAdded = 2
// Every kAmountHealedForPoints points of damage healed, the player gets
// kHealScoreAdded points to their score.
local kAmountHealedForPoints = 600

//-----------------------------------------------------------------------------


function Welder:GetIsValidRecipient(recipient)

	if self:GetParent() == nil and recipient and recipient:isa("Marine") then	//and not GetIsVortexed(recipient) 
    
        local welder = recipient:GetWeapon(Welder.kMapName)
        return welder == nil
        
    end
    
    return false
    
end


//Removed GetIsVortexed check
function Welder:OnPrimaryAttack(player)

	PROFILE("Welder:OnPrimaryAttack")
    
    if not self.welding then
    
        self:TriggerEffects("welder_start")
        self.timeWeldStarted = Shared.GetTime()
        
        if Server then
            self.loopingFireSound:Start()
        end
        
    end
    
    self.welding = true
    local hitPoint = nil
    
    //May get buggy aspects to kWelderFireDelay & kWelderWeldDelay usage...
    if self.timeLastWeld + kWelderFireDelay < Shared.GetTime () then
    
        hitPoint = self:PerformWeld(player)
        self.timeLastWeld = Shared.GetTime()
        
    end
    
    if not self.timeLastWeldEffect or self.timeLastWeldEffect + kWelderEffectRate < Shared.GetTime() then
    
        self:TriggerEffects("welder_muzzle")
        self.timeLastWeldEffect = Shared.GetTime()
        
    end

end


local function PrioritizeDamagedFriends(weapon, player, newTarget, oldTarget)
    return not oldTarget or (HasMixin(newTarget, "Team") and newTarget:GetTeamNumber() == player:GetTeamNumber() and (HasMixin(newTarget, "Weldable") and newTarget:GetCanBeWelded(weapon)))
end

function Welder:PerformWeld(player)

    local attackDirection = player:GetViewCoords().zAxis
    local success = false
    // prioritize friendlies
    local didHit, target, endPoint, direction, surface = CheckMeleeCapsule(self, player, 0, self:GetRange(), nil, true, 1, PrioritizeDamagedFriends)
    
    if didHit and target and HasMixin(target, "Live") then
        
        if GetAreEnemies(player, target) then
            self:DoDamage(kWelderDamagePerSecond * kWelderFireDelay, target, endPoint, attackDirection)
            success = true
        elseif ( player:GetTeamNumber() == target:GetTeamNumber() or target:isa("PowerPoint") ) and HasMixin(target, "Weldable") then
        
            if target:GetHealthScalar() < 1 then
                
                local prevHealthScalar = target:GetHealthScalar()
                local prevHealth = target:GetHealth()
                local prevArmor = target:GetArmor()
                target:OnWeld(self, kWelderFireDelay, player)
                success = prevHealthScalar ~= target:GetHealthScalar()
                
                if success then
                
                    local addAmount = (target:GetHealth() - prevHealth) + (target:GetArmor() - prevArmor)
                    
                    if not target:isa("PowerPoint") then
						player:AddContinuousScore("WeldHealth", addAmount, kAmountHealedForPoints, kHealScoreAdded)
					end
                    
                    // weld owner as well
                    player:SetArmor(player:GetArmor() + kWelderFireDelay * kSelfWeldAmount)
                    
                end
                
            end
            
            if HasMixin(target, "Construct") and target:GetCanConstruct(player) then
                target:Construct(kWelderFireDelay, player)
            end
            
        end
        
    end
    
    if success then    
        return endPoint
    end
    
end




if Client then

    function Welder:GetUIDisplaySettings()
        return { xSize = 512, ySize = 512, script = "lua/mvm/Hud/GUIWelderDisplay.lua" }
    end
    
end


//-----------------------------------------------------------------------------


Class_Reload("Welder", newNetworkVars)

