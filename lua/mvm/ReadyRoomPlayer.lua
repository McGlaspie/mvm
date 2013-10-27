
if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
end


//-----------------------------------------------------------------------------


local orgRRplayerCreate = ReadyRoomPlayer.OnCreate
function ReadyRoomPlayer:OnCreate()

	orgRRplayerCreate(self)

	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end

end


local orgRRplayerInit = ReadyRoomPlayer.OnInitialized
function ReadyRoomPlayer:OnInitialized()
	
	orgRRplayerInit(self)
	
	if Client then
		self:InitializeSkin()
	end

end


if Client then
	
	function ReadyRoomPlayer:InitializeSkin()
		
		Print("ReadyRoomPlayer:InitializeSkin() - self.previousTeamNumber =" .. self.previousTeamNumber )
		
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = 0
		
		if self.previousTeamNumber == kTeam1Index or self.previousTeamNumber == kTeam2Index then
			self.skinColoringEnabled = true
		else
			self.skinColoringEnabled = false
		end
		
	end
	
	function ReadyRoomPlayer:GetSkinAtlasIndex()
		
		if self.previousTeamNumber == kTeam1Index then
			return 1
		elseif self.previousTeamNumber == kTeam2Index then
			return 2
		else
			return 0
		end
		
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
	
	
	function ReadyRoomPlayer:OnTeamChange()
		self:InitializeSkin()
	end
	

end	//End Client



//-----------------------------------------------------------------------------

Class_Reload("ReadyRoomPlayer", {})

