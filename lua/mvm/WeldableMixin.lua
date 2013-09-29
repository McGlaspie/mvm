


Script.Load("lua/WeldableMixin.lua")


function WeldableMixin:OnWeld(doer, elapsedTime, player)

    if self:GetCanBeWelded(doer) then
    
		local weldAmount = 0
		
        if self.OnWeldOverride then
            self:OnWeldOverride(doer, elapsedTime)
        elseif doer:isa("MAC") then
			weldAmount = MAC.kRepairHealthPerSecond * elapsedTime
        elseif doer:isa("Welder") then
			weldAmount = doer:GetRepairRate(self) * elapsedTime
        end
        
        if HasMixin(self, "Fire") and self:GetIsOnFire() then
			weldAmount = weldAmount * kWhileBurningWeldEffectReduction
        end
        
        self:AddHealth( weldAmount )
        
        if player and player.OnWeldTarget then
            player:OnWeldTarget(self)
        end
        
    end
    
end


