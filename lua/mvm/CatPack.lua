
Script.Load("lua/mvm/DropPack.lua")
Script.Load("lua/mvm/PickupableMixin.lua")

if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
end


local orgCatpackCreate = CatPack.OnCreate
function CatPack:OnCreate()

	orgCatpackCreate(self)
	
	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end

end


function CatPack:OnInitialized()

    DropPack.OnInitialized(self)
    
    self:SetModel(CatPack.kModelName)
    
    InitMixin(self, PickupableMixin, { kRecipientType = {"Marine", "Exo"} })
    
    if Server then
        self:_CheckForPickup()
    end
    
    if Client then
		self:InitializeSkin()
    end

end


function CatPack:GetIsValidRecipient(recipient)
	//not GetIsVortexed(recipient) 
    return self:GetTeamNumber() == recipient:GetTeamNumber() 
		and (recipient.GetCanUseCatPack and recipient:GetCanUseCatPack())    
end


if Client then
	
	function CatPack:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = 0
	end
	
	function CatPack:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end
	
	function CatPack:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function CatPack:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end		//End Client




Class_Reload( "CatPack", {} )

