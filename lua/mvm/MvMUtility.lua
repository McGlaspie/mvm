

function GetEntitiesByLocation( location, entityType )

	assert( location:isa("Location") )
	
	if location and entityType then
		
		local locationEnts = location:GetEntitiesInTrigger()
		local foundEntities = {}
		
		for _, entity in ipairs( locationEnts ) do
			
			if entityType ~= nil then
				if entity:isa( entityType ) then
					table.insert( foundEntities, entity )
				end
			else
				table.insert( foundEntities, entity )
			end
			
		end
		
		return foundEntities
	
	end
	
	return nil

end


function GetEntitiesForTeamByLocation( location, teamNumber, entityType )

	assert( location:isa("Location") )
	
	if location and teamNumber then
		
		local locationEnts = location:GetEntitiesInTrigger()
		local foundEntities = {}
		
		for _, entity in ipairs( locationEnts ) do
			
			if HasMixin(entity, "Team") and entity:GetTeamNumber() == teamNumber then
				
				if entityType ~= nil then
					if entity:isa( entityType ) then
						table.insert( foundEntities, entity )
					end
				else
					table.insert( foundEntities, entity )
				end
				
			end
			
		end
		
		return foundEntities
	
	end
	
	return {}

end


function DestroyEntitiesWithinRangeByTeam( className, origin, range, teamNumber, filterFunc )

    for index, entity in ipairs( GetEntitiesWithinRange(className, origin, range) ) do
        if not filterFunc or not filterFunc(entity) then
			if HasMixin( entity, "Team" ) and entity:GetTeamNumber() == teamNumber then
				DestroyEntity( entity )
			end
        end
    end

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


function MvM_GetMaxSupplyForTeam( teamNumber )	//Would it not make more sense to make this part of the
												//OnUpdate tick for team objects?

    local maxSupply = 0
	
	local teamInfo = GetTeamInfoEntity( teamNumber )
	
	if teamInfo and teamInfo.numCapturedTechPoint then
		
		maxSupply = teamInfo.numCapturedTechPoint * kSupplyPerTechpoint
		
		if kSupplyPerResourceNode > 0 and teamInfo.numCapturedResPoints then
		//Add extra supply per captured resource node
			
			//FIXME This should only be working
			maxSupply = maxSupply + ( teamInfo.numResourceTowers * kSupplyPerResourceNode )
			
		end
		
	end
    
    return maxSupply

end


function MvM_GetSupplyUsedByTeam( teamNumber )
	
    assert(teamNumber)

    local supplyUsed = 0
    
    local teamInfo = GetTeamInfoEntity( teamNumber )
    
	if teamInfo and teamInfo.GetSupplyUsed then
		supplyUsed = teamInfo:GetSupplyUsed()
	end

    return supplyUsed

end


if Server then

	function OnCommanderLogOut(commander)	//OVERRIDES
		
		local client = Server.GetOwner(commander)
		
		if client then
		
			local addTime = math.max(0, 30 - GetGamerules():GetGameTimeChanged())
			
			client.timeUntilResourceBlock = Shared.GetTime() + addTime + kCommanderResourceBlockTime
			client.blockPersonalResources = true
			
		end

	end

end


local kExplosionDirections =
{
    Vector(0, 1, 0),
    Vector(0, -1, 0),
    Vector(1, 0, 0),
    Vector(-1, 0, 0),
    Vector(1, 0, 0),
    Vector(0, 0, 1),
    Vector(0, 0, -1),
}

//FIXME Prevent drawing of decals (visible) when no LOS, but still Create them...mmm, fun...
function CreateExplosionDecals( triggeringEntity, effectName )	//OVERRIDES

    effectName = effectName or "explosion_decal"

    local startPoint = triggeringEntity:GetOrigin() + Vector(0, 0.2, 0)
    for i = 1, #kExplosionDirections do
    
        local direction = kExplosionDirections[i]
        local trace = Shared.TraceRay(startPoint, startPoint + direction * 2, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAll())

        if trace.fraction ~= 1 then
        
            local coords = Coords.GetTranslation(trace.endPoint)
            coords.yAxis = trace.normal
            coords.zAxis = trace.normal:GetPerpendicular()
            coords.xAxis = coords.zAxis:CrossProduct(coords.yAxis)
			
            triggeringEntity:TriggerEffects( effectName, {
				effecthostcoords = coords
			})
        
        end
    
    end

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



function HandleHitEffect(position, doer, surface, target, showtracer, altMode, damage, direction)	//OVERRIDES

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
			//FIXME This will likely cause alien blood/hit effects
            tableParams[kEffectFilterIsMarine] = target:GetTeamNumber() == kTeam1Index
            tableParams[kEffectFilterIsAlien] = not tableParams[kEffectFilterIsMarine]
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



function BuildClassToGrid()	//Overrides

    local ClassToGrid = { }
    
    ClassToGrid["Undefined"] = { 5, 8 }

    ClassToGrid["TechPoint"] = { 1, 1 }
    ClassToGrid["ResourcePoint"] = { 2, 1 }
    ClassToGrid["Door"] = { 3, 1 }
    ClassToGrid["DoorLocked"] = { 4, 1 }
    ClassToGrid["DoorWelded"] = { 5, 1 }
    ClassToGrid["Grenade"] = { 6, 1 }
    ClassToGrid["PowerPoint"] = { 7, 1 }
    //ClassToGrid["DestroyedPowerPoint"] = { 7, 1 }
    
    ClassToGrid["Scan"] = { 6, 8 }
    ClassToGrid["HighlightWorld"] = { 4, 6 }

    ClassToGrid["ReadyRoomPlayer"] = { 1, 2 }
    ClassToGrid["Marine"] = { 1, 2 }
    ClassToGrid["Exo"] = { 2, 2 }
    ClassToGrid["JetpackMarine"] = { 3, 2 }
    
    ClassToGrid["MAC"] = { 4, 2 }
    ClassToGrid["CommandStationOccupied"] = { 5, 2 }
    ClassToGrid["CommandStationL2Occupied"] = { 6, 2 }
    ClassToGrid["CommandStationL3Occupied"] = { 7, 2 }
    ClassToGrid["Death"] = { 8, 2 }

    ClassToGrid["Skulk"] = { 1, 3 }
    ClassToGrid["Gorge"] = { 2, 3 }
    ClassToGrid["Lerk"] = { 3, 3 }
    ClassToGrid["Fade"] = { 4, 3 }
    ClassToGrid["Onos"] = { 5, 3 }
    ClassToGrid["Drifter"] = { 6, 3 }
    ClassToGrid["HiveOccupied"] = { 7, 3 }
    ClassToGrid["Kill"] = { 8, 3 }

    ClassToGrid["CommandStation"] = { 1, 4 }
    ClassToGrid["Extractor"] = { 4, 4 }
    ClassToGrid["Sentry"] = { 5, 4 }
    ClassToGrid["ARC"] = { 6, 4 }
    ClassToGrid["ARCDeployed"] = { 7, 4 }
    ClassToGrid["SentryBattery"] = { 8, 4 }

    ClassToGrid["InfantryPortal"] = { 1, 5 }
    ClassToGrid["Armory"] = { 2, 5 }
    ClassToGrid["AdvancedArmory"] = { 3, 5 }
    ClassToGrid["AdvancedArmoryModule"] = { 4, 5 }
    ClassToGrid["PhaseGate"] = { 5, 5 }
    ClassToGrid["Observatory"] = { 6, 5 }
    ClassToGrid["RoboticsFactory"] = { 7, 5 }
    ClassToGrid["ArmsLab"] = { 8, 5 }
    ClassToGrid["PrototypeLab"] = { 4, 5 }

    ClassToGrid["HiveBuilding"] = { 1, 6 }
    ClassToGrid["Hive"] = { 2, 6 }
    ClassToGrid["Infestation"] = { 4, 6 }
    ClassToGrid["Harvester"] = { 5, 6 }
    ClassToGrid["Hydra"] = { 6, 6 }
    ClassToGrid["Egg"] = { 7, 6 }
    ClassToGrid["Embryo"] = { 7, 6 }
    
    ClassToGrid["Shell"] = { 8, 6 }
    ClassToGrid["Spur"] = { 7, 7 }
    ClassToGrid["Veil"] = { 8, 7 }

    ClassToGrid["Crag"] = { 1, 7 }
    ClassToGrid["Whip"] = { 3, 7 }
    ClassToGrid["Shade"] = { 5, 7 }
    ClassToGrid["Shift"] = { 6, 7 }

    ClassToGrid["WaypointMove"] = { 1, 8 }
    ClassToGrid["WaypointDefend"] = { 2, 8 }
    ClassToGrid["TunnelEntrance"] = { 3, 8 }
    ClassToGrid["PlayerFOV"] = { 4, 8 }
    
    ClassToGrid["MoveOrder"] = { 1, 8 }
    ClassToGrid["BuildOrder"] = { 2, 8 }
    ClassToGrid["AttackOrder"] = { 2, 8 }
    
    ClassToGrid["SensorBlip"] = { 5, 8 }
    ClassToGrid["EtherealGate"] = { 8, 1 }
    
    ClassToGrid["Player"] = { 7, 8 }
    
    return ClassToGrid
    
end



// All damage is routed through here.
function CanEntityDoDamageTo(attacker, target, cheats, devMode, friendlyFire, damageType)	//OVERRIDES

    if GetGameInfoEntity():GetState() == kGameState.NotStarted then
        return false
    end
    
    if target:isa("Clog") then
        return true
    end
    
    if not HasMixin(target, "Live") then
        return false
    end
    
    if target:isa("ARC") and damageType == kDamageType.Splash then
        return true
    end
    
    if not target:GetCanTakeDamage() then
        return false
    end
    
    if target == nil or (target.GetDarwinMode and target:GetDarwinMode()) then
        return false
    elseif cheats or devMode then
        return true
    elseif attacker == nil then
        return true
    end
    
    // You can always do damage to yourself.
    if attacker == target then
        return true
    end
    
    // Command stations can kill even friendlies trapped inside.
    if attacker ~= nil and attacker:isa("CommandStation") then
        return true
    end
    
    // Your own grenades can hurt you.
    if attacker:isa("Grenade") then
    
        local owner = attacker:GetOwner()
        if owner and owner:GetId() == target:GetId() then
            return true
        end
        
    end
    
    // Same teams not allowed to hurt each other unless friendly fire enabled.
    local teamsOK = true
    if attacker ~= nil then
        teamsOK = GetAreEnemies(attacker, target) or friendlyFire
	end
	
	if target:isa("PowerPoint") and attacker ~= nil then
		teamsOK = true
    end
    
    
    // Allow damage of own stuff when testing.
    return teamsOK
    
end



function MvM_GetIsUnitActive( unit, debug )		//OVERRIDES

    local powered = not HasMixin(unit, "PowerConsumer") or not unit:GetRequiresPower() or unit:GetIsPowered()
    local alive = not HasMixin(unit, "Live") or unit:GetIsAlive()
    local isBuilt = not HasMixin(unit, "Construct") or unit:GetIsBuilt()
    local isRecycled = HasMixin(unit, "Recycle") and (unit:GetIsRecycled() or unit:GetIsRecycling())
    
    if debug then
        Print("------------ GetIsUnitActive(%s) -----------------", ToString(unit))
        Print("powered: %s", ToString(powered))
        Print("alive: %s", ToString(alive))
        Print("isBuilt: %s", ToString(isBuilt))
        Print("isRecycled: %s", ToString(isRecycled))
        Print("-----------------------------")
    end
    
    //not GetIsVortexed(unit) and 
    return powered and alive and isBuilt and not isRecycled	//??? Add IsShocked?
    
end