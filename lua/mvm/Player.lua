
Script.Load("lua/PostLoadMod.lua")


local newNetworkVars = {
	//Add previousTeamNumber?
}

//-----------------------------------------------------------------------------

if Client then
	
	
	function Player:ShowMap(showMap, showBig, forceReset)
		self.minimapVisible = showMap and showBig
		
		ClientUI.GetScript("mvm/GUIMinimapFrame"):ShowMap(showMap)
		ClientUI.GetScript("mvm/GUIMinimapFrame"):SetBackgroundMode((showBig and GUIMinimapFrame.kModeBig) or GUIMinimapFrame.kModeMini, forceReset)
	end
	
	
	
	//function PlayerUI_GetLocationPower()	- Update once power is team based
	//end

	function Player:GetShowCrossHairText()		//FIXME This looks wrong...
		return self:GetTeamType() == kMarineTeamType //or self:GetTeamNumber() == kAlienTeamType
	end

	function PlayerUI_GetOrderPath()
	
		local player = Client.GetLocalPlayer()
		
		if player then
			if HasMixin(player, "Orders") then
			
				local currentOrder = player:GetCurrentOrder()
				if currentOrder then
					local targetLocation = currentOrder:GetLocation()
					local points = {}
					local isReachable = Pathing.GetPathPoints(player:GetOrigin(), targetLocation, points)
					
					if isReachable then
						return points
					end
				end
			end
		end
	
	end
	
	
	local kEnemyObjectiveRange = 30
	function PlayerUI_GetObjectiveInfo()

		local player = Client.GetLocalPlayer()
		
		if player then
		
			if player.crossHairHealth and player.crossHairText then  
			
				player.showingObjective = true
				return player.crossHairHealth / 100, player.crossHairText .. " " .. ToString(player.crossHairHealth) .. "%", player.crossHairTeamType
				
			end
			
			// check command structures in range (enemy or friend) and return health % and name
			local objectiveInfoEnts = EntityListToTable( Shared.GetEntitiesWithClassname("ObjectiveInfo") )
			local playersTeam = player:GetTeamNumber()
			
			local function SortByHealthAndTeam(ent1, ent2)
				return ent1:GetHealthScalar() < ent2:GetHealthScalar() and ent1.teamNumber == playersTeam
			end
			
			table.sort(objectiveInfoEnts, SortByHealthAndTeam)
			
			for _, objectiveInfoEnt in ipairs(objectiveInfoEnts) do
			
				if objectiveInfoEnt:GetIsInCombat() and ( playersTeam == objectiveInfoEnt:GetTeamNumber() or (player:GetOrigin() - objectiveInfoEnt:GetOrigin()):GetLength() < kEnemyObjectiveRange ) then

					local healthFraction = math.max(0.01, objectiveInfoEnt:GetHealthScalar())

					player.showingObjective = true
					
					local text = StringReformat(Locale.ResolveString("OBJECTIVE_PROGRESS"),
												{ location = objectiveInfoEnt:GetLocationName(),
												  name = GetDisplayNameForTechId(objectiveInfoEnt:GetTechId()),
												  health = math.ceil(healthFraction * 100) })
					
					return healthFraction, text, objectiveInfoEnt:GetTeamType(), objectiveInfoEnt:GetTeamNumber()
					
				end
				
			end
			
			player.showingObjective = false
			
		end
		
	end
	
	
	local function LocalIsFriendlyMarineComm(player, unit)
		return player:isa("MarineCommander") and unit:isa("Player")
	end
	
	
	local kUnitStatusDisplayRange = 20	//Org: 13
	local kUnitStatusCommanderDisplayRange = 50
	local kDefaultHealthOffset = Vector(0, 1.2, 0)
	
	function PlayerUI_GetUnitStatusInfo()

		local unitStates = { }
		
		local player = Client.GetLocalPlayer()
		
		if player and not player:GetBuyMenuIsDisplaying() and (not player.GetDisplayUnitStates or player:GetDisplayUnitStates()) then
		
			local eyePos = player:GetEyePos()
			local crossHairTarget = player:GetCrossHairTarget()
			
			local range = kUnitStatusDisplayRange
			 
			if player:isa("Commander") then
				range = kUnitStatusCommanderDisplayRange
			end
		
			for index, unit in ipairs( GetEntitiesWithMixinWithinRange("UnitStatus", eyePos, range) ) do
			
				// checks here if the model was rendered previous frame as well
				local status = unit:GetUnitStatus(player)
				if unit:GetShowUnitStatusFor(player) and (unit:isa("Player") or status ~= kUnitStatus.None or unit == crossHairTarget) then       

					// Get direction to blip. If off-screen, don't render. Bad values are generated if 
					// Client.WorldToScreen is called on a point behind the camera.
					local origin = nil
					local getEngagementPoint = unit.GetEngagementPoint
					if getEngagementPoint then
						origin = getEngagementPoint(unit)
					else
						origin = unit:GetOrigin()
					end
					
					local normToEntityVec = GetNormalizedVector(origin - eyePos)
					local normViewVec = player:GetViewAngles():GetCoords().zAxis
				   
					local dotProduct = normToEntityVec:DotProduct(normViewVec)
					
					if dotProduct > 0 then

						local statusFraction = unit:GetUnitStatusFraction(player)
						local description = unit:GetUnitName(player)
						local action = unit:GetActionName(player)
						local hint = unit:GetUnitHint(player)
						
						local healthBarOrigin = origin + kDefaultHealthOffset
						local getHealthbarOffset = unit.GetHealthbarOffset
						if getHealthbarOffset then
							healthBarOrigin = origin + getHealthbarOffset(unit)
						end
						
						local worldOrigin = Vector(origin)
						origin = Client.WorldToScreen(origin)
						healthBarOrigin = Client.WorldToScreen(healthBarOrigin)
						
						if unit == crossHairTarget then
							healthBarOrigin.y = math.max(GUIScale(180), healthBarOrigin.y)
						end

						local health = 0
						local armor = 0

						local visibleToPlayer = true                        
						if HasMixin(unit, "Cloakable") and GetAreEnemies(player, unit) then
						
							if unit:GetIsCloaked() or (unit:isa("Player") and unit:GetCloakFraction() > 0.2) then                    
								visibleToPlayer = false
							end
							
						end
						
						// Don't show tech points or nozzles if they are attached
						if (unit:GetMapName() == TechPoint.kMapName or unit:GetMapName() == ResourcePoint.kPointMapName) and unit.GetAttached and (unit:GetAttached() ~= nil) then
							visibleToPlayer = false
						end
						
						if HasMixin(unit, "Live") and (not unit.GetShowHealthFor or unit:GetShowHealthFor(player)) then
						
							health = unit:GetHealthFraction()                
							if unit:GetArmor() == 0 then
								armor = 0
							else 
								armor = unit:GetArmorScalar()
							end

						end
						
						local badge = ""
						
						if HasMixin(unit, "Badge") then
							badge = unit:GetBadgeIcon() or ""
						end
						
						local unitState = {
							
							Position = origin,
							WorldOrigin = worldOrigin,
							HealthBarPosition = healthBarOrigin,
							Status = status,
							Name = description,
							Action = action,
							Hint = hint,
							StatusFraction = statusFraction,
							HealthFraction = health,
							ArmorFraction = armor,
							IsCrossHairTarget = (unit == crossHairTarget and visibleToPlayer) or LocalIsFriendlyMarineComm(player, unit),
							TeamType = kNeutralTeamType,
							TeamNumber = kReadyRoomIndex,
							ForceName = unit:isa("Player") and not GetAreEnemies(player, unit),
							OnScreen = onScreen,
							BadgeTexture = badge
						
						}
						
						if unit.GetTeamNumber then
							unitState.IsFriend = (unit:GetTeamNumber() == player:GetTeamNumber())
						end
						
						if unit.GetTeamType then
							unitState.TeamType = unit:GetTeamType()
						end
						
						if unit.GetTeamNumber then
							unitState.TeamNumber = unit:GetTeamNumber()
						end
						
						table.insert(unitStates, unitState)
					
					end
					
				end
			 
			 end
			
		end
		
		return unitStates

	end

	function PlayerUI_IsOnAlienTeam()
		local player = Client.GetLocalPlayer()
		if player and HasMixin(player, "Team") then
			return player:GetTeamNumber() == kTeam2Index
		end
		
		return false
	end
	
	function PlayerUI_GetTeamNumber()
		local player = Client.GetLocalPlayer()
		
		if player and HasMixin(player, "Team") then    
			return player:GetTeamNumber()    
		end
		
		return 0
	end
	
	
	
	local kMinimapBlipTeamAlien = kMinimapBlipTeam.Alien
	local kMinimapBlipTeamMarine = kMinimapBlipTeam.Marine
	local kMinimapBlipTeamFriendly = kMinimapBlipTeam.Friendly
	local kMinimapBlipTeamEnemy = kMinimapBlipTeam.Enemy
	local kMinimapBlipTeamNeutral = kMinimapBlipTeam.Neutral
	
	function PlayerUI_GetStaticMapBlips()

		PROFILE("PlayerUI_GetStaticMapBlips")
		
		local player = Client.GetLocalPlayer()
		local blipsData = { }
		local numBlips = 0
		
		if player then
		
			local playerTeam = player:GetTeamNumber()
			local playerNoTeam = playerTeam == kRandomTeamType or playerTeam == kNeutralTeamType
			local playerEnemyTeam = GetEnemyTeamNumber(playerTeam)
			local playerId = player:GetId()
			
			local mapBlipList = Shared.GetEntitiesWithClassname("MapBlip")
			local GetEntityAtIndex = mapBlipList.GetEntityAtIndex
			local GetMapBlipTeamNumber = MapBlip.GetTeamNumber
			local GetMapBlipOrigin = MapBlip.GetOrigin
			local GetMapBlipRotation = MapBlip.GetRotation
			local GetMapBlipType = MapBlip.GetType
			local GetMapBlipIsInCombat = MapBlip.GetIsInCombat
			
			for index = 0, mapBlipList:GetSize() - 1 do
			
				local blip = GetEntityAtIndex(mapBlipList, index)
				if blip ~= nil and blip.ownerEntityId ~= playerId then
				
					local blipTeam = kMinimapBlipTeamNeutral
					local blipTeamNumber = GetMapBlipTeamNumber(blip)
					
					if blipTeamNumber == kMarineTeamType then
						blipTeam = kMinimapBlipTeamMarine
					elseif blipTeamNumber== kAlienTeamType then
						blipTeam = kMinimapBlipTeamAlien
					/*
					else
						if blipTeamNumber == playerTeam then
							blipTeam = minimapBlipTeamFriendly
						elseif blipTeamNumber == playerEnemyTeam then
							blipTeam = minimapBlipTeamEnemy
						end
					*/
					end
					
					local i = numBlips * 8
					local blipOrig = GetMapBlipOrigin(blip)
					blipsData[i + 1] = blipOrig.x
					blipsData[i + 2] = blipOrig.z
					blipsData[i + 3] = GetMapBlipRotation(blip)
					blipsData[i + 4] = 0
					blipsData[i + 5] = 0
					blipsData[i + 6] = GetMapBlipType(blip)
					blipsData[i + 7] = blipTeam
					blipsData[i + 8] = GetMapBlipIsInCombat(blip)
					
					numBlips = numBlips + 1
					
				end
				
			end
			
			for index, blip in ientitylist(Shared.GetEntitiesWithClassname("SensorBlip")) do
			
				local blipOrigin = blip:GetOrigin()
			 
				local i = numBlips * 8
			 
				blipsData[i + 1] = blipOrigin.x
				blipsData[i + 2] = blipOrigin.z
				blipsData[i + 3] = 0
				blipsData[i + 4] = 0
				blipsData[i + 5] = 0
				blipsData[i + 6] = kMinimapBlipType.SensorBlip
				blipsData[i + 7] = kMinimapBlipTeamEnemy
				blipsData[i + 8] = false
				
				numBlips = numBlips + 1
				
			end
			
			local orders = GetRelevantOrdersForPlayer(player)
			for o = 1, #orders do
			
				local order = orders[o]
				local blipOrigin = order:GetLocation()
				
				local blipType = kMinimapBlipType.MoveOrder
				local orderType = order:GetType()
				if orderType == kTechId.Construct then
					blipType = kMinimapBlipType.BuildOrder
				elseif orderType == kTechId.Attack then
					blipType = kMinimapBlipType.AttackOrder
				end
			
				local i = numBlips * 8
				  
				blipsData[i + 1] = blipOrigin.x
				blipsData[i + 2] = blipOrigin.z
				blipsData[i + 3] = 0
				blipsData[i + 4] = 0
				blipsData[i + 5] = 0
				blipsData[i + 6] = blipType
				blipsData[i + 7] = kMinimapBlipTeamFriendly
				blipsData[i + 8] = false
				
				numBlips = numBlips + 1
				
			end
			
		end
		
		return blipsData
		
	end


end	//Client


//-------------------------------------


if Server then

	local oldPlayerCreate = Player.OnCreate
	function Player:OnCreate()
		
		oldPlayerCreate(self)
		
		//Server-side only, not networkvar
		self.previousTeamNumber = 0	//Will need to update for all CopyX cases
		
	end
	
	
	function Player:Replace(mapName, newTeamNumber, preserveWeapons, atOrigin, extraValues)
		
		local team = self:GetTeam()
		if team == nil then
			return self
		end
		
		local teamNumber = team:GetTeamNumber()
		local client = Server.GetOwner(self)
		local teamChanged = newTeamNumber ~= nil and newTeamNumber ~= self:GetTeamNumber()
		
		// Add new player to new team if specified
		// Both nil and -1 are possible invalid team numbers.
		if newTeamNumber ~= nil and newTeamNumber ~= -1 then
			teamNumber = newTeamNumber
		end
		
		local player = CreateEntity(mapName, atOrigin or Vector(self:GetOrigin()), teamNumber, extraValues)
		
		//Save last team for RR model skinning
		player.previousTeamNumber = ConditionalValue( teamChanged, teamNumber, 0 )
		
		// Save last player map name so we can show player of appropriate form in the ready room if the game ends while spectating
		player.previousMapName = self:GetMapName()
		
		// The class may need to adjust values before copying to the new player (such as gravity).
		self:PreCopyPlayerData()
		
		// If the atOrigin is specified, set self to that origin before
		// the copy happens or else it will be overridden inside player.
		if atOrigin then
			self:SetOrigin(atOrigin)
		end
		// Copy over the relevant fields to the new player, before we delete it
		player:CopyPlayerDataFrom(self)
		
		// Make model look where the player is looking
		player.standingBodyYaw = Math.Wrap( self:GetAngles().yaw, 0, 2*math.pi )
		
		if not player:GetTeam():GetSupportsOrders() and HasMixin(player, "Orders") then
			player:ClearOrders()
		end
		
		// Remove newly spawned weapons and reparent originals
		if preserveWeapons then
		
			player:DestroyWeapons()
			
			local allWeapons = { }
			local function AllWeapons(weapon) table.insert(allWeapons, weapon) end
			ForEachChildOfType(self, "Weapon", AllWeapons)
			
			for i, weapon in ipairs(allWeapons) do
				player:AddWeapon(weapon)
			end
			
		end
		
		// Notify others of the change     
		self:SendEntityChanged(player:GetId())
		
		// Update scoreboard because of new entity and potentially new team
		player:SetScoreboardChanged(true)
		
		// This player is no longer controlled by a client.
		self.client = nil
		
		// Remove any spectators currently spectating this player.
		self:RemoveSpectators(player)
		
		// Only destroy the old player if it is not a ragdoll.
		// Ragdolls will eventually destroy themselve.
		if not HasMixin(self, "Ragdoll") or not self:GetIsRagdoll() then
			DestroyEntity(self)
		end
		
		player:SetControllerClient(client)
		
		// There are some cases where the spectating player isn't set to nil.
		// Handle any edge cases here (like being dead when the game is reset).
		// In some cases, client will be nil (when the map is changing for example).
		if client and not player:isa("Spectator") then
			client:SetSpectatingPlayer(nil)
		end
		
		// Must happen after the client has been set on the player.
		player:InitializeBadges()
		
		// Log player spawning
		if teamNumber ~= 0 then
			PostGameViz(string.format("%s spawned", SafeClassName(self)), self)
		end
		
		return player
	
	end
	

end

//-----------------------------------------------------------------------------

Class_Reload("Player", newNetworkVars)

