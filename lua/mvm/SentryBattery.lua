

Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/PostLoadMod.lua")


local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)


//-----------------------------------------------------------------------------


local oldSentryBatteryCreate = SentryBattery.OnCreate
function SentryBattery:OnCreate()

	oldSentryBatteryCreate(self)
	
	InitMixin(self, FireMixin)
	InitMixin(self, DetectableMixin)
    
    if Client then
		InitMixin(self, ColoredSkinsMixin)
    end

end

local orgSentryBattInit = SentryBattery.OnInitialized
function SentryBattery:OnInitialized()

	orgSentryBattInit(self)
	
	if Client then
		self:InitializeSkin()
	end

end


if Client then
	
	function SentryBattery:InitializeSkin()
		self._activeBaseColor = self:GetBaseSkinColor()
		self._activeAccentColor = self:GetAccentSkinColor()
		self._activeTrimColor = self:GetTrimSkinColor()
	end
	
	function SentryBattery:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_BaseColor, kTeam2_BaseColor )
	end
	
	function SentryBattery:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_AccentColor, kTeam2_AccentColor )
	end
	
	function SentryBattery:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_TrimColor, kTeam2_TrimColor )
	end
	
end




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

