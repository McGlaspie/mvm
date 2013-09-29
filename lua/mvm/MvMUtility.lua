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

//Override
function GetIsMarineUnit(entity)
    return entity and HasMixin(entity, "Team") and entity:GetTeamType() == kMarineTeamType
end

//Override
function GetIsAlienUnit(entity)
    return entity and HasMixin(entity, "Team") and entity:GetTeamNumber() == kTeam2Index
end


//Override
function GetAreEnemies(entityOne, entityTwo)
	
    return 
		entityOne and entityTwo 
		and HasMixin(entityOne, "Team") 
		and HasMixin(entityTwo, "Team") 
		and (
            ( 
				entityOne:GetTeamNumber() == kTeam1Index 
				and entityTwo:GetTeamNumber() == kTeam2Index
			) 
			or ( 
				entityOne:GetTeamNumber() == kTeam2Index 
				and entityTwo:GetTeamNumber() == kTeam1Index
			)
		)
end
