

Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/mvm/TeamColorSkinMixin.lua")
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
    InitMixin(self, TeamColorSkinMixin)

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

