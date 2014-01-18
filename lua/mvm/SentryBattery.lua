

Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/PostLoadMod.lua")
Script.Load("lua/mvm/SupplyUserMixin.lua")

local newNetworkVars = {}


AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)
AddMixinNetworkVars(ElectroMagneticMixin, newNetworkVars)


//-----------------------------------------------------------------------------


local oldSentryBatteryCreate = SentryBattery.OnCreate
function SentryBattery:OnCreate()

	oldSentryBatteryCreate(self)
	
	InitMixin(self, FireMixin)
	InitMixin(self, DetectableMixin)
	InitMixin(self, ElectroMagneticMixin)
    
    if Client then
		InitMixin(self, ColoredSkinsMixin)
    end

end

local orgSentryBattInit = SentryBattery.OnInitialized
function SentryBattery:OnInitialized()

	orgSentryBattInit(self)
	
	if Server then
		InitMixin(self, SupplyUserMixin)
	end
	
	if Client then
		self:InitializeSkin()
	end

end


function SentryBattery:GetIsVulnerableToEMP()
	return true
end


if Client then
	
	function SentryBattery:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
	end
	
	function SentryBattery:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_BaseColor, kTeam2_BaseColor )
	end
	
	function SentryBattery:GetAccentSkinColor()
		if self:GetIsBuilt() then
			return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_AccentColor, kTeam2_AccentColor )
		else
			return Color( 0,0,0 )
		end
	end
	
	function SentryBattery:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_TrimColor, kTeam2_TrimColor )
	end
	
end



//FIXME This needs to also account for distance, and not just location, per team
function GetRoomHasNoSentryBattery(techId, origin, normal, commander)

    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local validRoom = false
    
    if locationName then
    
        validRoom = true
		
        for index, sentryBattery in ientitylist(Shared.GetEntitiesWithClassname("SentryBattery")) do	//FIXME Filter by Team
            
            if sentryBattery:GetLocationName() == locationName  and sentryBattery:GetTeamNumber() == commander:GetTeamNumber() then
				validRoom = false
				break
			end
            
        end
    
    end
    
    return validRoom

end


//-----------------------------------------------------------------------------


Class_Reload("SentryBattery", newNetworkVars)

