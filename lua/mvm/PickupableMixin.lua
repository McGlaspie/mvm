

Script.Load("lua/PickupableMixin.lua")
Script.Load("lua/mvm/EquipmentOutline.lua")


local kCheckForPickupRate = 0.1
local kPickupRange = 1





function PickupableMixin:__initmixin()

    if Server then
    
        if not self.GetCheckForRecipient or self:GetCheckForRecipient() then
            self:AddTimedCallback(PickupableMixin._CheckForPickup, kCheckForPickupRate)
        end
        
        if not self.GetIsPermanent or not self:GetIsPermanent() then
            self:AddTimedCallback(PickupableMixin._DestroySelf, kItemStayTime)
        end
        
    end
    
end


function PickupableMixin:OnUpdate(deltaTime)	//OVERRIDES
	
    if Client then
		EquipmentOutline_UpdateModel(self)
    end

end


