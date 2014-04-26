
Script.Load("lua/mvm/DropPack.lua")
Script.Load("lua/mvm/PickupableMixin.lua")

if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
end


local kPickupDelay = 0.7		//v3.2 beta 0.65	//0.53


local orgMedpackCreate = MedPack.OnCreate
function MedPack:OnCreate()

	orgMedpackCreate(self)
	
	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end

end


function MedPack:OnInitialized()

    DropPack.OnInitialized(self)
    
    self:SetModel(MedPack.kModelName)

    if Client then
        
		InitMixin(self, PickupableMixin, { kRecipientType = "Marine" })
        
        self:InitializeSkin()
        
    end
    
end


function MedPack:GetIsValidRecipient(recipient)
	//and not GetIsVortexed(recipient) 
    return recipient:GetIsAlive() 
			and recipient:GetHealth() < recipient:GetMaxHealth() 
			and ( 
				not recipient.timeLastMedpack or recipient.timeLastMedpack + kPickupDelay <= Shared.GetTime() 
			)
			and self:GetTeamNumber() == recipient:GetTeamNumber()
end


if Client then
	
	function MedPack:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = 0
	end
	
	function MedPack:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end
	
	function MedPack:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function MedPack:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end		//End Client



Class_Reload( "MedPack", {} )

