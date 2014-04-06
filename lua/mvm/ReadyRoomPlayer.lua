
if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
end


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
    
    if Client then
		InitMixin(self, ColoredSkinsMixin)
	end
    
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
		
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = self:GetSkinAtlasIndex()
		
		self.skinColoringEnabled = ( self.previousTeamNumber == kTeam1Index or self.previousTeamNumber == kTeam2Index )
		
	end
	
	
	function ReadyRoomPlayer:GetSkinAtlasIndex()
		
		if self.previousTeamNumber == kTeam1Index or self.previousTeamNumber == kTeam2Index then
			return self.previousTeamNumber - 1
		end
		
		return 0
		
	end
	
	
	function ReadyRoomPlayer:GetBaseSkinColor()
	
		if self.previousTeamNumber == kTeam1Index or self.previousTeamNumber == kTeam2Index then
			return ConditionalValue(
				self.previousTeamNumber == kTeam1Index,
				kTeam1_BaseColor,
				kTeam2_BaseColor
			)
		end
		
		return kNeutral_BaseColor
		
	end
	
	
	function ReadyRoomPlayer:GetAccentSkinColor()
		
		if self.previousTeamNumber == kTeam1Index or self.previousTeamNumber == kTeam2Index then
			return ConditionalValue(
				self.previousTeamNumber == kTeam1Index,
				kTeam1_AccentColor,
				kTeam2_AccentColor
			)
		end
		
		return kNeutral_AccentColor
		
	end
	
	
	function ReadyRoomPlayer:GetTrimSkinColor()
		
		if self.previousTeamNumber == kTeam1Index or self.previousTeamNumber == kTeam2Index then
			return ConditionalValue(
				self.previousTeamNumber == kTeam1Index,
				kTeam1_TrimColor,
				kTeam2_TrimColor
			)
		end
		
		return kNeutral_TrimColor
		
	end
	

end	//End Client



//-----------------------------------------------------------------------------


Class_Reload( "ReadyRoomPlayer", {} )

