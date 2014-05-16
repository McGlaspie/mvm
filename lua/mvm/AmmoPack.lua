

Script.Load("lua/mvm/DropPack.lua")
Script.Load("lua/mvm/PickupableMixin.lua")

if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
end


//-----------------------------------------------------------------------------

local orgAmmoPackCreate = AmmoPack.OnCreate
function AmmoPack:OnCreate()

	orgAmmoPackCreate(self)

	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end

end


function AmmoPack:OnInitialized()

    DropPack.OnInitialized(self)
    
    self:SetModel( AmmoPack.kModelName )
    
    if Client then
		
        InitMixin(self, PickupableMixin, { kRecipientType = "Marine" })
        
        self:InitializeSkin()
        
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


if Client then
	
	function AmmoPack:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = 0
	end
	
	function AmmoPack:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end
	
	function AmmoPack:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function AmmoPack:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end		//End Client



function AmmoPack:OnUpdate( deltaTime )

	if Client then
		if self:GetTeamNumber() ~= PlayerUI_GetTeamNumber() then
			self.skinAccentColor = Color(0,0,0,0)
		else
			self.skinAccentColor = self:GetAccentSkinColor()
		end
	end
	
	if Server then
		DropPack.OnUpdate( self, deltaTime )
	end

end


Class_Reload( "AmmoPack", {} )


