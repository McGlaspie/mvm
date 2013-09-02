
Script.Load("lua/PickupableWeaponMixin.lua")


function PickupableWeaponMixin:GetIsValidRecipient(recipient)
    return self:GetParent() == nil and self:GetTeamNumber() == recipient:GetTeamNumber()
end

