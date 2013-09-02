//=============================================================================
// 
// 
// 
// 
//=============================================================================


function GetIsArcConstructionAllowed(teamNumber)

    local teamInfo = GetTeamInfoEntity(teamNumber)
    if teamInfo then
        return teamInfo:GetNumArcs() < teamInfo:GetNumCapturedTechPoints() * kArcsPerTechpoint
    end
    
    return false

end

//Overrides
function GetIsMarineUnit(entity)
    return entity and HasMixin(entity, "Team") and entity:GetTeamType() == kMarineTeamType
end

//Overrides
function GetIsAlienUnit(entity)
    return entity and HasMixin(entity, "Team") and entity:GetTeamNumber() == kTeam2Index
end

