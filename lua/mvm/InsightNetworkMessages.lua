
Script.Load("lua/InsightNetworkMessages.lua")




function BuildTechPointsMessage( techPoint, powerNodes, eggs )

    local t = { }
    local techPointLocation = techPoint:GetLocationId()
    t.entityIndex = techPoint:GetId()
    t.location = techPointLocation
    t.teamNumber = techPoint.occupiedTeam
    t.techId = kTechId.None
    
    local structure = Shared.GetEntity(techPoint.attachedId)
    
    if structure then
		
		/*
        local eggCount = 0
        for _, egg in ientitylist(eggs) do
        
            if egg:GetLocationId() == techPointLocation and egg:GetIsAlive() and egg:GetIsEmpty() then
                eggCount = eggCount + 1
            end
            
        end
        */
        t.eggCount = 0
        
        for _, powerNode in ientitylist(powerNodes) do
        
            if powerNode:GetLocationId() == techPointLocation then
            
                if powerNode:GetIsSocketed() then
                    t.powerNodeFraction = powerNode:GetHealthScalar()
                else
                    t.powerNodeFraction = -1
                end
                
                break
                
            end
            
        end
        
        t.teamNumber = structure:GetTeamNumber()
        t.techId = structure:GetTechId()
                
        if structure:GetIsAlive() then
        
            -- Structure may not have a GetBuiltFraction() function (Hallucinations for example).
            t.builtFraction = structure.GetBuiltFraction and structure:GetBuiltFraction() or -1
            t.healthFraction= structure:GetHealthScalar()
            
        else
        
            t.builtFraction = -1
            t.healthFraction= -1
            
        end
        
        return t
        
    end
    
    return t
    
end


