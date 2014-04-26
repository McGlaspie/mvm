
Script.Load("lua/mvm/ScoringMixin.lua")
Script.Load("lua/MarineVariantMixin.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/Mixins/CrouchMoveMixin.lua")
Script.Load("lua/Mixins/LadderMoveMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
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
    
    //Below (as in NS2) is always setting default model. If a player was copied
    //after the OnClientUpdate change kicked in (just before or during team join)
    //the variant data could be lost, and the server think one AnimationGraphState
    //was set but the client another. Resulting in T-pose players.
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

