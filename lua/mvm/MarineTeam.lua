

Script.Load("lua/MarineTeam.lua")


//-----------------------------------------------------------------------------


function MarineTeam:OnResetComplete()

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


//-----------------------------------------------------------------------------


Class_Reload("MarineTeam", {})

