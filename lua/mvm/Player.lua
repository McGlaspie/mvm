
Script.Load("lua/mvm/TechData.lua")

if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
end


local newNetworkVars = {
	previousTeamNumber	= string.format("integer (%d to %d)", kTeamInvalid, kSpectatorIndex ),
	commanderLoginTime = "time"
}


//-----------------------------------------------------------------------------


local orgPlayerCreate = Player.OnCreate
function Player:OnCreate()

	orgPlayerCreate(self)
	
	if Client then
		InitMixin( self, ColoredSkinsMixin )
	end

end


local orgPlayerInit = Player.OnInitialized
function Player:OnInitialized()

	orgPlayerInit(self)
	
	if Client then
		self:InitializeSkin()
	end

end


if Client then
	
	function Player:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		
		if self.previousTeamNumber == kTeam1Index or self.previousTeamNumber == kTeam2Index then
			self.skinAtlasIndex = self:GetTeamNumber() - 1
		else
			self.skinAtlasIndex = 0
		end
	end
	
	function Player:GetBaseSkinColor()
		if self.previousTeamNumber == kTeam1Index or self.previousTeamNumber == kTeam2Index then
			return ConditionalValue( self.previousTeamNumber == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
		else
			return kNeutral_BaseColor
		end
	end

	function Player:GetAccentSkinColor()
		if self.previousTeamNumber == kTeam1Index or self.previousTeamNumber == kTeam2Index then
			return ConditionalValue( self.previousTeamNumber == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
		else
			return kNeutral_AccentColor
		end
	end
	
	function Player:GetTrimSkinColor()
		if self.previousTeamNumber == kTeam1Index or self.previousTeamNumber == kTeam2Index then
			return ConditionalValue( self.previousTeamNumber == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
		else 
			return kNeutral_TrimColor
		end	
	end

end



function Player:AddResources(amount)	//OVERRIDES

    local resReward = 0
	
    if amount <= 0 or not self.blockPersonalResources then	//Shared.GetCheatsEnabled() or (

        resReward = math.min(amount, kMaxPersonalResources - self:GetResources())
        local oldRes = self.resources
        self:SetResources(self:GetResources() + resReward)
    
    end
    
    return resReward
    
end


function Player:GetLoginTime()		//OVERRIDES
	return self.commanderLoginTime
end

//Previous team member for RR skinning (on game ends)
//????: Add game-end check also? If player explicity joins RR, then RR model should not skin
if Server then
	
	local oldPlayerCopyData = Player.CopyPlayerDataFrom
	function Player:CopyPlayerDataFrom( player )
	
		oldPlayerCopyData( self, player )
		
		self.previousTeamNumber = player.previousTeamNumber
		self.commanderLoginTime = player.commanderLoginTime
		
	end
	
	
	function Player:OnCommanderStructureLogin( commandStructure )
		self.commanderLoginTime = Shared.GetTime()
	end

end



if Client then
	
	
	function Player:ShowMap(showMap, showBig, forceReset)
		
		self.minimapVisible = showMap and showBig
		
		ClientUI.GetScript("mvm/GUIMinimapFrame"):ShowMap(showMap)
		ClientUI.GetScript("mvm/GUIMinimapFrame"):SetBackgroundMode(
			( showBig and GUIMinimapFrame.kModeBig ) 
			or GUIMinimapFrame.kModeMini, 
			forceReset
		)
		
	end
	
	
	
	//function PlayerUI_GetLocationPower()	- Update once power is team based
	//end

	function Player:GetShowCrossHairText()		//FIXME This looks wrong...
		return self:GetTeamType() == kMarineTeamType //or self:GetTeamNumber() == kAlienTeamType
	end

	
	function PlayerUI_GetOrderPath()

		local player = Client.GetLocalPlayer()
		if player then
		
			/*
			TODO Adjust below to support "Command Directives" feature
			
			if player:isa("Alien") then
			
				local playerOrigin = player:GetOrigin()
				local pheromone = GetMostRelevantPheromone(playerOrigin)
				if pheromone then
				
					local points = PointArray()
					local isReachable = Pathing.GetPathPoints(playerOrigin, pheromone:GetOrigin(), points)
					if isReachable then
						return points
					end
					
				end
				
			else
			*/
			
			if HasMixin(player, "Orders") then
			
				local currentOrder = player:GetCurrentOrder()
				if currentOrder then
				
					local targetLocation = currentOrder:GetLocation()
					local points = PointArray()
					local isReachable = Pathing.GetPathPoints(player:GetOrigin(), targetLocation, points)
					if isReachable then
						return points
					end
					
				end
				
			end
			
		end
		
		return nil
		
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
					
					return healthFraction, text, objectiveInfoEnt:GetTeamNumber(), objectiveInfoEnt:GetTeamNumber()
					
				end
				
			end
			
			player.showingObjective = false
			
		end
		
	end
	
	
	local function LocalIsFriendlyMarineComm(player, unit)
		return player:isa("MarineCommander") and unit:isa("Player")
	end
	
	
	local function LocalIsFriendlyCommander(player, unit)
		return player:isa("Commander") and ( unit:isa("Player") or (HasMixin(unit, "Selectable") and unit:GetIsSelected(player:GetTeamNumber())) )
	end
		

	local kUnitStatusDisplayRange = 30	//Org: 13	-todo move to balance misc
	local kUnitStatusCommanderDisplayRange = 50
	local kDefaultHealthOffset = 1.2

	function PlayerUI_GetUnitStatusInfo()

		local unitStates = { }
		
		local player = Client.GetLocalPlayer()
		
		if player and not player:GetBuyMenuIsDisplaying() and ( not player.GetDisplayUnitStates or player:GetDisplayUnitStates() ) then
			
			local eyePos = player:GetEyePos()
			local crossHairTarget = player:GetCrossHairTarget()
			
			local range = kUnitStatusDisplayRange
			 
			if player:isa("Commander") then
				range = kUnitStatusCommanderDisplayRange
			end
			
			local healthOffsetDirection = player:isa("Commander") and Vector.xAxis or Vector.yAxis
			
			for index, unit in ipairs( GetEntitiesWithMixinWithinRange("UnitStatus", eyePos, range ) ) do
			
				// checks here if the model was rendered previous frame as well
				local status = unit:GetUnitStatus(player)
				if unit:GetShowUnitStatusFor(player) then       

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
						local distance = (origin - eyePos):GetLength()
						
						local healthBarOffset = kDefaultHealthOffset
						
						local getHealthbarOffset = unit.GetHealthbarOffset
						if getHealthbarOffset then
							healthBarOffset = getHealthbarOffset(unit)
						end
						
						local healthBarOrigin = origin + healthOffsetDirection * healthBarOffset
						
						local worldOrigin = Vector(origin)
						origin = Client.WorldToScreen(origin)
						healthBarOrigin = Client.WorldToScreen(healthBarOrigin)
						
						if unit == crossHairTarget then
						
							healthBarOrigin.y = math.max(GUIScale(180), healthBarOrigin.y)
							healthBarOrigin.x = Clamp(healthBarOrigin.x, GUIScale(320), Client.GetScreenWidth() - GUIScale(320))
							
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
						if (unit:GetMapName() == TechPoint.kMapName or unit:GetMapName() == ResourcePoint.kPointMapName) 
							and unit.GetAttached and (unit:GetAttached() ~= nil) then
							
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
						
						local badgeTextures = ""
						
						if HasMixin(unit, "Player") then
							if unit.GetShowBadgeOverride and not unit:GetShowBadgeOverride() then
								badgeTextures = {}
							else
								badgeTextures = Badges_GetBadgeTextures(unit:GetClientIndex(), "unitstatus") or {}
							end
						end
						
						local hasWelder = false 
						if distance < 10 then    
							hasWelder = unit:GetHasWelder(player)
						end
						
						local abilityFraction = 0
						if player:isa("Commander") then        
							abilityFraction = unit:GetAbilityFraction()
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
							IsCrossHairTarget = (unit == crossHairTarget and visibleToPlayer) or LocalIsFriendlyCommander(player, unit),
							TeamType = kNeutralTeamType,
							ForceName = unit:isa("Player") and not GetAreEnemies(player, unit),
							BadgeTextures = badgeTextures,
							HasWelder = hasWelder,
							IsPlayer = unit:isa("Player"),
							IsSteamFriend = unit:isa("Player") and unit:GetIsSteamFriend() or false,
							AbilityFraction = abilityFraction
						
						}
						
						if unit.GetTeamNumber then
							unitState.IsFriend = (unit:GetTeamNumber() == player:GetTeamNumber())
							unitState.TeamNumber = unit:GetTeamNumber()
						end
						
						if unit.GetTeamType then
							unitState.TeamType = unit:GetTeamType()
						end
						
						table.insert(unitStates, unitState)
					
					end
					
				end
			 
			 end
			
		end
		
		return unitStates

	end


	function PlayerUI_IsOnMarineTeam()
		
		local player = Client.GetLocalPlayer()
		if player and HasMixin(player, "Team") then
			return player:GetTeamNumber() == kTeam1Index
		end
		
		return false    
		
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
	
	
	function PlayerUI_GetIsTechMapVisible()

		local script = ClientUI.GetScript("mvm/GUITechMap")
		return script ~= nil and script:GetIsVisible()

	end
	
	
	function PlayerUI_GetIsBeaconing()
		
		local player = Client.GetLocalPlayer()
		
		if player then
			return player:GetGameEffectMask(kGameEffect.Beacon)
		end
		
		return false

	end
	
	
	
	local kMinimapBlipTeamAlien = kMinimapBlipTeam.Alien
	local kMinimapBlipTeamMarine = kMinimapBlipTeam.Marine
	local kMinimapBlipTeamFriendAlien = kMinimapBlipTeam.FriendAlien
	local kMinimapBlipTeamFriendMarine = kMinimapBlipTeam.FriendMarine
	local kMinimapBlipTeamInactiveAlien = kMinimapBlipTeam.InactiveAlien
	local kMinimapBlipTeamInactiveMarine = kMinimapBlipTeam.InactiveMarine
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
			local GetIsSteamFriend = Client.GetIsSteamFriend
			local ClientIndexToSteamId = GetSteamIdForClientIndex
			local GetIsMapBlipActive = MapBlip.GetIsActive
			
			for index = 0, mapBlipList:GetSize() - 1 do
			
				local blip = GetEntityAtIndex(mapBlipList, index)
				if blip ~= nil and blip.ownerEntityId ~= playerId then
		  
					local blipTeam = kMinimapBlipTeamNeutral
					local blipTeamNumber = GetMapBlipTeamNumber(blip)
					local isSteamFriend = false
					
					if blip.clientIndex and blip.clientIndex > 0 and blipTeamNumber ~= GetEnemyTeamNumber(playerTeam) then

						local steamId = ClientIndexToSteamId(blip.clientIndex)
						if steamId then
							isSteamFriend = GetIsSteamFriend(steamId)
						end
						
					end
					
					if not GetIsMapBlipActive(blip) then

						if blipTeamNumber == kTeam1Index then
							blipTeam = kMinimapBlipTeamInactiveMarine
						elseif blipTeamNumber == kTeam2Index then
							blipTeam = kMinimapBlipTeamInactiveAlien
						end
						
					elseif isSteamFriend then
						
						if blipTeamNumber == kTeam1Index then
							blipTeam = kMinimapBlipTeamFriendMarine
						elseif blipTeamNumber == kTeam2Index then
							blipTeam = kMinimapBlipTeamFriendAlien
						end
					
					else
						
						if blipTeamNumber == kTeam1Index then
							blipTeam = kMinimapBlipTeamMarine
						elseif blipTeamNumber== kTeam2Index then
							blipTeam = kMinimapBlipTeamAlien
						end
						
					end  
					
					local i = numBlips * 10
					local blipOrig = GetMapBlipOrigin(blip)
					blipsData[i + 1] = blipOrig.x
					blipsData[i + 2] = blipOrig.z
					blipsData[i + 3] = GetMapBlipRotation(blip)
					blipsData[i + 4] = 0
					blipsData[i + 5] = 0
					blipsData[i + 6] = GetMapBlipType(blip)
					blipsData[i + 7] = blipTeam
					blipsData[i + 8] = GetMapBlipIsInCombat(blip)
					blipsData[i + 9] = isSteamFriend
					blipsData[i + 10] = blip.isHallucination == true
					
					numBlips = numBlips + 1
					
				end
				
			end
			
			for index, blip in ientitylist(Shared.GetEntitiesWithClassname("SensorBlip") ) do
			
				local blipOrigin = blip:GetOrigin()
				
				local i = numBlips * 10
				
				blipsData[i + 1] = blipOrigin.x
				blipsData[i + 2] = blipOrigin.z
				blipsData[i + 3] = 0
				blipsData[i + 4] = 0
				blipsData[i + 5] = 0
				blipsData[i + 6] = kMinimapBlipType.SensorBlip
				blipsData[i + 7] = kMinimapBlipTeamEnemy
				blipsData[i + 8] = false
				blipsData[i + 9] = false
				blipsData[i + 10] = false
				
				numBlips = numBlips + 1
				
			end
			
			local orders = GetRelevantOrdersForPlayer(player)
			for o = 1, #orders do
			
				local order = orders[o]
				local blipOrigin = order:GetLocation()
				
				local blipType = kMinimapBlipType.MoveOrder
				local orderType = order:GetType()
				if orderType == kTechId.Construct or orderType == kTechId.AutoConstruct then
					blipType = kMinimapBlipType.BuildOrder
				elseif orderType == kTechId.Attack then
					blipType = kMinimapBlipType.AttackOrder
				end
				
				local i = numBlips * 10
				
				blipsData[i + 1] = blipOrigin.x
				blipsData[i + 2] = blipOrigin.z
				blipsData[i + 3] = 0
				blipsData[i + 4] = 0
				blipsData[i + 5] = 0
				blipsData[i + 6] = blipType
				blipsData[i + 7] = kMinimapBlipTeamFriendly
				blipsData[i + 8] = false
				blipsData[i + 9] = false
				blipsData[i + 10] = false
				
				numBlips = numBlips + 1
				
			end
			
			if GetPlayerIsSpawning() then
			
				local spawnPosition = GetDesiredSpawnPosition()
				
				if spawnPosition then
				
					local i = numBlips * 10
				
					blipsData[i + 1] = spawnPosition.x
					blipsData[i + 2] = spawnPosition.z
					blipsData[i + 3] = 0
					blipsData[i + 4] = 0
					blipsData[i + 5] = 0
					blipsData[i + 6] = kMinimapBlipType.MoveOrder
					blipsData[i + 7] = kMinimapBlipTeamFriendly
					blipsData[i + 8] = false
					blipsData[i + 9] = false
					blipsData[i + 10] = false
					
					numBlips = numBlips + 1
				
				end
			
			end
			/*
			if player:isa("Fade") then
			
				local vortexAbility = player:GetWeapon(Vortex.kMapName)
				if vortexAbility then
				
					local gate = vortexAbility:GetEtherealGate()
					if gate then
					
						local i = numBlips * 10
					
						local blipOrig = gate:GetOrigin()
					
						blipsData[i + 1] = blipOrig.x
						blipsData[i + 2] = blipOrig.z
						blipsData[i + 3] = 0
						blipsData[i + 4] = 0
						blipsData[i + 5] = 0
						blipsData[i + 6] = kMinimapBlipType.EtherealGate
						blipsData[i + 7] = kMinimapBlipTeam.Friendly
						blipsData[i + 8] = false
						blipsData[i + 9] = false
						blipsData[i + 10] = false
						
						numBlips = numBlips + 1
						
					end
				
				end
			
			end
			*/
			local highlightPos = GetHighlightPosition()
			if highlightPos then

					local i = numBlips * 10

					blipsData[i + 1] = highlightPos.x
					blipsData[i + 2] = highlightPos.z
					blipsData[i + 3] = 0
					blipsData[i + 4] = 0
					blipsData[i + 5] = 0
					blipsData[i + 6] = kMinimapBlipType.HighlightWorld
					blipsData[i + 7] = kMinimapBlipTeam.Friendly
					blipsData[i + 8] = false
					blipsData[i + 9] = false
					blipsData[i + 10] = false
					
					numBlips = numBlips + 1
				
			end
			
		end

		return blipsData

	end
	

	function PlayerUI_GetTeamSupply()
	
		local playerTeam = Client.GetLocalPlayer():GetTeamNumber()
		local teamSupply = MvM_GetSupplyUsedByTeam( playerTeam )
		local teamMaxSupply = MvM_GetMaxSupplyForTeam( playerTeam )
		
		return string.format("TEAM SUPPLY: %s of %s", teamSupply, teamMaxSupply)	//TODO Change to be a String Locale lookup
	
	end


end	//Client


//-----------------------------------------------------------------------------


Class_Reload("Player", newNetworkVars)

