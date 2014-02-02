

Script.Load("lua/PickupableMixin.lua")
Script.Load("lua/mvm/EquipmentOutline.lua")


function PickupableMixin:OnUpdate(deltaTime)	//OVERRIDES
	
    if Client then
		EquipmentOutline_UpdateModel(self)
    end

end


