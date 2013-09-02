//
//	Override of ns2/lua/SensorBlip.lua
//	Adds support for self.teamNumber value
//


Script.Load("lua/PostLoadMod.lua")

local newNetworkVars = {
	teamNumber	= string.format("integer (-1 to %d)", kSpectatorIndex)
}

//-----------------------------------------------------------------------------

function SensorBlip:OnCreate()

	Entity.OnCreate(self)
    
    self.entId = Entity.invalidId
    self.teamNumber = -1
    
    self:SetPropagate(Entity.Propagate_Mask)
    self:UpdateRelevancy()
    
end


function SensorBlip:SetTeamNumber(teamNumber)
	assert(type(teamNumber) == "number")
	self.teamNumber = teamNumber
end


function SensorBlip:GetTeamNumber()
	return self.teamNumber
end


function SensorBlip:UpdateRelevancy()

    self:SetRelevancyDistance(Math.infinity)
	self:SetExcludeRelevancyMask( 
		ConditionalValue( 
			self.teamNumber == kTeam2Index, kRelevantToTeam1, kRelevantToTeam2
		) 
	)
	
end


//-----------------------------------------------------------------------------

Class_Reload("SensorBlip", newNetworkVars)
