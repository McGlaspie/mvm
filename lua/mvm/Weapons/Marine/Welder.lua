

Script.Load("lua/PostLoadMod.lua")


local newNetworkVars = {}

local kWelderEffectRate = 0.45
local kWelderFireDelay = 0.5


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


//-----------------------------------------------------------------------------


Class_Reload("Welder", newNetworkVars)

