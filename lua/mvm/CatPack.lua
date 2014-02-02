
Script.Load("lua/mvm/DropPack.lua")
Script.Load("lua/mvm/PickupableMixin.lua")


function CatPack:OnInitialized()

    DropPack.OnInitialized(self)
    
    self:SetModel(CatPack.kModelName)
    
    InitMixin(self, PickupableMixin, { kRecipientType = {"Marine", "Exo"} })
    
    if Server then
        self:_CheckForPickup()
    end

end

