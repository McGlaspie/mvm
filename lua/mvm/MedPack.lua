
Script.Load("lua/mvm/DropPack.lua")
Script.Load("lua/mvm/PickupableMixin.lua")


local kPickupDelay = 0.65	//0.53


function MedPack:OnInitialized()

    DropPack.OnInitialized(self)
    
    self:SetModel(MedPack.kModelName)

    if Client then
        InitMixin(self, PickupableMixin, { kRecipientType = "Marine" })
    end
    
end


function MedPack:GetIsValidRecipient(recipient)
	//and not GetIsVortexed(recipient) 
    return recipient:GetIsAlive() 
			and recipient:GetHealth() < recipient:GetMaxHealth() 
			and ( 
				not recipient.timeLastMedpack or recipient.timeLastMedpack + kPickupDelay <= Shared.GetTime() 
			)
end


Class_Reload( "MedPack", {} )