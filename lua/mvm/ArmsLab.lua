
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/PowerConsumerMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/PostLoadMod.lua")
Script.Load("lua/mvm/SupplyUserMixin.lua")


local kHaloCinematicTeam2 = PrecacheAsset("cinematics/marine/arms_lab/arms_lab_holo_team2.cinematic")
local kHaloCinematic = PrecacheAsset("cinematics/marine/arms_lab/arms_lab_holo.cinematic")
local kHaloAttachPoint = "ArmsLab_hologram"


//-----------------------------------------------------------------------------

local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local orgArmsLabCreate = ArmsLab.OnCreate
function ArmsLab:OnCreate()
	
	orgArmsLabCreate(self)

	InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)

	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end

end

local orgArmsLabInit = ArmsLab.OnInitialized
function ArmsLab:OnInitialized()
	
	orgArmsLabInit(self)
	
	if Server then
		InitMixin(self, SupplyUserMixin)
	end
	
	if Client then
		self:InitializeSkin()
	end
	
end


if Client then
	
	function ArmsLab:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
	end

	function ArmsLab:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function ArmsLab:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function ArmsLab:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end
	
	
	function ArmsLab:OnUpdateRender()
    
        if not self.haloCinematic then
        
            self.haloCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
            if self:GetTeamNumber() == kTeam2Index then
				self.haloCinematic:SetCinematic(kHaloCinematicTeam2)
			else
				self.haloCinematic:SetCinematic(kHaloCinematic)
			end
            
            self.haloCinematic:SetParent(self)
            self.haloCinematic:SetAttachPoint(self:GetAttachPointIndex(kHaloAttachPoint))
            self.haloCinematic:SetCoords(Coords.GetIdentity())
            self.haloCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
            
        end
        
        self.haloCinematic:SetIsVisible( self.deployed and self:GetIsPowered() )
        
    end
	
end


//-----------------------------------------------------------------------------

Class_Reload("ArmsLab", newNetworkVars)