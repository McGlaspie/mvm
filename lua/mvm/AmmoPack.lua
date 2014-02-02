

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


Class_Reload( "AmmoPack", {} )