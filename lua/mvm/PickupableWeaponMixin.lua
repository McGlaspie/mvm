
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/mvm/EquipmentOutline.lua")


function PickupableWeaponMixin:GetIsValidRecipient( recipient )
    return self:GetParent() == nil and self:GetTeamNumber() == recipient:GetTeamNumber()
end

