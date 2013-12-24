

Script.Load("lua/MarineTeam.lua")
Script.Load("lua/mvm/Marine.lua")

//-----------------------------------------------------------------------------


function MarineTeam:OnResetComplete()	//FIXME This is NOT resetting nodes...

    //adjust first power node    
    local initialTechPoint = self:GetInitialTechPoint()
    local powerPoint = GetPowerPointForLocation( initialTechPoint:GetLocationName() )
    
    powerPoint:SetConstructionComplete()
	
	if self.teamNumber == kTeam1Index then
		powerPoint.scoutedForTeam1 = true
	elseif self.teamNumber == kTeam2Index then
		powerPoint.scoutedForTeam2 = true
	end
	
	powerPoint:UpdateRelevancy()
	
    /*
    for index, powerPoint in ientitylist( Shared.GetEntitiesWithClassname("PowerPoint") ) do
    
        if powerPoint:GetLocationName() == initialTechPoint:GetLocationName() then
            powerPoint:SetConstructionComplete()
            
            if self.teamNumber == kTeam1Index then
				powerPoint.scoutedForTeam1 = true
            elseif self.teamNumber == kTeam2Index then
				powerPoint.scoutedForTeam2 = true
            end
            
            powerPoint:UpdateRelevancy()
            
        end
        
    end
    */
end


//OVERRIDES PlayingTeam:GetSupplyUsed()
function MarineTeam:GetSupplyUsed()
    return Clamp(self.supplyUsed, 0, MvM_GetMaxSupplyForTeam( self.teamNumber ) )	//kMaxSupply
end

//OVERRIDES PlayingTeam:AddSupplyUsed()
function MarineTeam:AddSupplyUsed(supplyUsed)
    self.supplyUsed = self.supplyUsed + supplyUsed
end

//OVERRIDES PlayingTeam:RemoveSupplyUsed()
function MarineTeam:RemoveSupplyUsed(supplyUsed)
    self.supplyUsed = self.supplyUsed - supplyUsed
end




//-----------------------------------------------------------------------------


Class_Reload("MarineTeam", {})

