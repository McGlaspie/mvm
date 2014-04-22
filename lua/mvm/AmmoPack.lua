

Script.Load("lua/mvm/DropPack.lua")
Script.Load("lua/mvm/PickupableMixin.lua")


//-----------------------------------------------------------------------------



function AmmoPack:OnInitialized()

    DropPack.OnInitialized(self)
    
    self:SetModel( AmmoPack.kModelName )
    
    if Client then
        InitMixin(self, PickupableMixin, { kRecipientType = "Marine" })
    end

end


function AmmoPack:GetIsValidRecipient(recipient)

    local needsAmmo = false
    
    for i = 0, recipient:GetNumChildren() - 1 do
		
        local child = recipient:GetChildAtIndex(i)
        if child:isa("ClipWeapon") and child:GetNeedsAmmo(false) and self:GetTeamNumber() == recipient:GetTeamNumber() then
        
            needsAmmo = true
            break
            
        end
        
    end

    // Ammo packs give ammo to clip as well (so pass true to GetNeedsAmmo())
    return needsAmmo
    
end


Class_Reload( "AmmoPack", {} )