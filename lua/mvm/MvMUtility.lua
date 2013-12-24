//=============================================================================
// 
// 
// 
// 
//=============================================================================



function GetEntitiesForTeamByLocation( location, teamNumber )

	assert( location:isa("Location") )
	
	if location and teamNumber then
		
		//Print("GetEntitiesForTeamByLocation( " .. location:GetName() .. ", " .. tostring(teamNumber) .. ")")
		
		local locationEnts = location:GetEntitiesInTrigger()
		local entities = {}
		
		for _, entity in ipairs(locationEnts) do
		    
			Print("\t entity:isa(" .. entity:GetClassName() .. ")")
			
			if HasMixin(entity, "Team") and entity:GetTeamNumber() == teamNumber then
				table.insert(entities, entity)
			end
			
		end
		
		return entities
	
	end
	
	return {}

end



function GetIsArcConstructionAllowed(teamNumber)

    local teamInfo = GetTeamInfoEntity(teamNumber)
    if teamInfo then
        return teamInfo:GetNumArcs() < teamInfo:GetNumCapturedTechPoints() * kArcsPerTechpoint
    end
    
    return false

end

//OVERRIDES
function GetIsMarineUnit(entity)
    return entity and HasMixin(entity, "Team") and entity:GetTeamType() == kMarineTeamType
end

//OVERRIDES
function GetIsAlienUnit(entity)
    return entity and HasMixin(entity, "Team") and entity:GetTeamNumber() == kTeam2Index
end


//OVERRIDES
function GetAreEnemies(entityOne, entityTwo)
	
    return 
		entityOne and entityTwo 
		and HasMixin(entityOne, "Team") 
		and HasMixin(entityTwo, "Team") 
		and (
				( entityOne:GetTeamNumber() == kTeam1Index and entityTwo:GetTeamNumber() == kTeam2Index	) 
			or 
				( entityOne:GetTeamNumber() == kTeam2Index and entityTwo:GetTeamNumber() == kTeam1Index	)
		)
	
end



//OVERRIDES
function MvM_GetMaxSupplyForTeam(teamNumber)	//Would it not make more sense to make this part of the
												//OnUpdate tick for team objects?
												
//FIXME When looking at ANY captured(enemy) point (Tech or Res) max supply is lowered by 5	
	
    local maxSupply = 0
	
    if Server then
    
        local team = GetGamerules():GetTeam(teamNumber)
        if team and team.GetNumCapturedTechPoints then
            maxSupply = team:GetNumCapturedTechPoints() * kSupplyPerTechpoint
        end
        
    else
        
        local teamInfoEnt = GetTeamInfoEntity(teamNumber)
        if teamInfoEnt and teamInfoEnt.GetNumCapturedTechPoints then
            maxSupply = teamInfoEnt:GetNumCapturedTechPoints() * kSupplyPerTechpoint
        end

    end
    
    
    if kSupplyPerResourceNode > 0 then
	//Add extra supply per captured resource node
		
		local capturedResNodes = GetEntitiesForTeam("Extractor", teamNumber)
		
		for _, node in ipairs(capturedResNodes) do
			maxSupply = maxSupply + kSupplyPerResourceNode
		end
		
	end
	
	
    return maxSupply

end

//OVERRIDES
function MvM_GetSupplyUsedByTeam( teamNumber )
	
    assert(teamNumber)

    local supplyUsed = 0
    
    if Server then
		
        local team = GetGamerules():GetTeam(teamNumber)
        if team and team.GetSupplyUsed then
            supplyUsed = team:GetSupplyUsed() 
        end
		
    else
        
        local teamInfoEnt = GetTeamInfoEntity(teamNumber)
        if teamInfoEnt and teamInfoEnt.GetSupplyUsed then
            supplyUsed = teamInfoEnt:GetSupplyUsed()
        end
    
    end    

    return supplyUsed

end





//Copy of original
local function HandleImpactDecal(position, doer, surface, target, showtracer, altMode, damage, direction, decalParams)

    // when we hit a target project some blood on the geometry behind
    //DebugLine(position, position + direction * kBloodDistance, 3, 1, 0, 0, 1)
    if direction then
    
        local trace =  Shared.TraceRay(position, position + direction * kBloodDistance, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(target))
        if trace.fraction ~= 1 then   

            decalParams[kEffectHostCoords] = Coords.GetTranslation(trace.endPoint)
            decalParams[kEffectHostCoords].yAxis = trace.normal
            decalParams[kEffectHostCoords].zAxis = direction
            decalParams[kEffectHostCoords].xAxis = decalParams[kEffectHostCoords].yAxis:CrossProduct(decalParams[kEffectHostCoords].zAxis)
            decalParams[kEffectHostCoords].zAxis = decalParams[kEffectHostCoords].xAxis:CrossProduct(decalParams[kEffectHostCoords].yAxis)

            decalParams[kEffectHostCoords].zAxis:Normalize()
            decalParams[kEffectHostCoords].xAxis:Normalize()
            
            //DrawCoords(decalParams[kEffectHostCoords])
            
            if not target then
                decalParams[kEffectSurface] = trace.surface        
            end
            
            GetEffectManager():TriggerEffects("damage_decal", decalParams)
         
        end
    
    end

end



function HandleHitEffect(position, doer, surface, target, showtracer, altMode, damage, direction)

    local tableParams = { }
    tableParams[kEffectHostCoords] = Coords.GetTranslation(position)
    if doer then
        tableParams[kEffectFilterDoerName] = doer:GetClassName()
    end
    tableParams[kEffectSurface] = surface
    tableParams[kEffectFilterInAltMode] = altMode
    
    if target then
    
        tableParams[kEffectFilterClassName] = target:GetClassName()
        
        if target.GetTeamNumber then
			
            tableParams[kEffectFilterIsMarine] = true
            //Would ne to re-enable below if Invasion mode added
            //tableParams[kEffectFilterIsAlien] = target:GetTeamNumber() == kAlienTeamType
            
        end
        
    else
		
        tableParams[kEffectFilterIsMarine] = false
        tableParams[kEffectFilterIsAlien] = false
        
    end
    
    // Don't play the hit cinematic, those are made for third person.
    if target ~= Client.GetLocalPlayer() then
        GetEffectManager():TriggerEffects("damage", tableParams)
    end
    
    // Always play sound effect.
    GetEffectManager():TriggerEffects("damage_sound", tableParams)
    
    if showtracer == true and doer then
    
        local tracerStart = (doer.GetBarrelPoint and doer:GetBarrelPoint()) or (doer.GetEyePos and doer:GetEyePos()) or doer:GetOrigin()
        
        local tracerVelocity = GetNormalizedVector(position - tracerStart) * kTracerSpeed
        CreateTracer(tracerStart, position, tracerVelocity, doer)
        
    end
    
    if damage > 0 and target and target.OnTakeDamageClient then
        target:OnTakeDamageClient(damage, doer, position)
    end
    
    HandleImpactDecal(position, doer, surface, target, showtracer, altMode, damage, direction, tableParams)

end
