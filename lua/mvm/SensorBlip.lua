//
//	Override of ns2/lua/SensorBlip.lua
//	Adds support for self.teamNumber value
//


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
    
    if self.teamNumber == kTeam1Index then
		self:SetExcludeRelevancyMask( kRelevantToTeam2 )
	elseif self.teamNumber == kTeam2Index then
		self:SetExcludeRelevancyMask( kRelevantToTeam1 )
	else
		//????
	end
	
end


function SensorBlip:Update(entity)

    if entity.GetEngagementPoint then
        self:SetOrigin( entity:GetEngagementPoint() )
    else
        self:SetOrigin( entity:GetModelOrigin() )
    end
    
    self.teamNumber = entity:GetTeamNumber()
    self.entId = entity:GetId()
    
    self:UpdateRelevancy()	//hacky
    
end


//-----------------------------------------------------------------------------

Class_Reload("SensorBlip", newNetworkVars)
