
Script.Load("lua/mvm/ScoringMixin.lua")


//-----------------------------------------------------------------------------


function ReadyRoomPlayer:OnCreate()	//OVERRIDES

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, LadderMoveMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kDefaultFov })
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    InitMixin(self, MarineVariantMixin )
    
    Player.OnCreate(self)
    
end


function ReadyRoomPlayer:OnInitialized()	//OVERRIDES

    Player.OnInitialized(self)
    
    self:SetModel( MarineVariantMixin.kDefaultModelName, MarineVariantMixin.kMarineAnimationGraph )
    
    if Client then
		self:InitializeSkin()
    end
    
end


if Client then
	
	function ReadyRoomPlayer:InitializeSkin()
		self.skinBaseColor = kNeutral_BaseColor
		self.skinAccentColor = kNeutral_AccentColor
		self.skinTrimColor = kNeutral_TrimColor
		self.skinAtlasIndex = 0
		self.skinColoringEnabled = true
	end
	
	function ReadyRoomPlayer:GetSkinAtlasIndex()
		return 0
	end
	
	function ReadyRoomPlayer:GetBaseSkinColor()
		return kNeutral_BaseColor
	end
	
	function ReadyRoomPlayer:GetAccentSkinColor()
		return kNeutral_AccentColor
	end
	
	function ReadyRoomPlayer:GetTrimSkinColor()
		return kNeutral_TrimColor
	end
	

end	//End Client



//-----------------------------------------------------------------------------


Class_Reload( "ReadyRoomPlayer", {} )

