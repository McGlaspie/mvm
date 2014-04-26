
Script.Load("lua/Commander.lua")
Script.Load("lua/mvm/ScoringMixin.lua")
Script.Load("lua/mvm/BuildingMixin.lua")

if Client then
	Script.Load("lua/mvm/Commander_Client.lua")
end


//-----------------------------------------------------------------------------

//Overridden just to use mvm ScoringMixin....dumb
function Commander:OnInitialized()	//OVERRIDES

    InitMixin(self, OverheadMoveMixin)
    InitMixin(self, MinimapMoveMixin)
    InitMixin(self, HotkeyMoveMixin)
    
    InitMixin(self, BuildingMixin)
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    
    Player.OnInitialized(self)
    
    self:SetIsVisible(false)
    
    if Client then
    
        self.drawResearch = false

        if self:GetIsLocalPlayer() then
            self:SetCurrentTech(kTechId.RootMenu)
        end
        
    end
    
    if Server then
    
        // Wait a short time before sending hotkey groups to make sure
        // client has been replaced by commander
        self.timeToSendHotkeyGroups = Shared.GetTime() + 0.5
        
    end

    self.timeScoreboardPressed = 0
    self.focusGroupIndex = 1
    self.numIdleWorkers = 0
    self.numPlayerAlerts = 0
    self.positionBeforeJump = Vector(0, 0, 0)
    self.selectMode = Commander.kSelectMode.None
    self.commandStationId = Entity.invalidId
    
    self:SetWeaponsProcessMove(false)

end



function Commander:GetCurrentTechButtons(techId, entity)

    local techButtons = self:GetQuickMenuTechButtons(techId)
    
    if not self:GetIsInQuickMenu(techId) and entity then
    
        // Allow selected entities to add/override buttons in the menu (but not top row)
        // only show buttons of friendly units
        if entity:GetTeamNumber() == self:GetTeamNumber() or entity:isa("PowerPoint") then
        
            local selectedTechButtons = entity:GetTechButtons(techId, self:GetTeamType())
            if selectedTechButtons then
            
                for index, id in pairs(selectedTechButtons) do
                   techButtons[4 + index] = id 
                end
                
            end
            
            if techId == kTechId.RootMenu then
            
                if (HasMixin(entity, "Research") and entity:GetIsResearching()) or (HasMixin(entity, "GhostStructure") and entity:GetIsGhostStructure()) then
                
                    local foundCancel = false
                    for b = 1, #techButtons do
                    
                        if techButtons[b] == kTechId.Cancel then
                        
                            foundCancel = true
                            break
                            
                        end
                        
                    end
                    
                    if not foundCancel then
                        techButtons[kRecycleCancelButtonIndex] = kTechId.Cancel
                    end
                
                // add recycle button if not researching / ghost structure mode
                elseif HasMixin(entity, "Recycle") and not entity:GetIsResearching() and entity:GetCanRecycle() and not entity:GetIsRecycled() then
                    techButtons[kRecycleCancelButtonIndex] = kTechId.Recycle
                end
            
            end
        
        end
        
    end
    
    return techButtons
    
end


if Client then
	
	Commander.kTeam2CircleModelName = PrecacheAsset("models/misc/circle/circle_alien.model")
	
	local function CreateCommanderModel(modelName)
    
        return function()
        
            local commModel = Client.CreateRenderModel(RenderScene.Zone_Default)
            commModel:SetModel(modelName)
            commModel:SetIsVisible(false)
            return commModel
            
        end
        
    end
	
	Commander.kSentryOrientationModelNameTeam2 = PrecacheAsset("models/misc/sentry_arc/sentry_arc_team2.model")
	Commander.kSentryRangeModelNameTeam2 = PrecacheAsset("models/misc/sentry_arc/sentry_line_team2.model")
	
	ClientResources.AddResource(
		"CommSentryOrientationTeam2", "Commander", CreateCommanderModel( Commander.kSentryOrientationModelNameTeam2 ), Client.DestroyRenderModel
	)
    ClientResources.AddResource(
		"CommSentryRangeTeam2", "Commander", CreateCommanderModel( Commander.kSentryRangeModelNameTeam2 ), Client.DestroyRenderModel
	)
	
	ClientResources.AddResource(
		"CommTeam2UnitUnderCursor", "MarineCommander", CreateCommanderModel(Commander.kTeam2CircleModelName), Client.DestroyRenderModel
	)
	
	
	local function MvM_CreateSentryBatteryLineModel()
    
        local sentryBatteryLineHelp = DynamicMesh_Create()
        sentryBatteryLineHelp:SetIsVisible(false)
        sentryBatteryLineHelp:SetMaterial(
			ConditionalValue(
				Client.GetLocalPlayer():GetTeamNumber() == kTeam1Index,
					Commander.kMarineLineMaterialName,
					Commander.kAlienLineMaterialName
			)
		)
		
        return sentryBatteryLineHelp
        
    end
    
    ClientResources.AddResource("MvM_CommSentryBatteryLine", "Commander", MvM_CreateSentryBatteryLineModel, DynamicMesh_Destroy)
	
	
//-------------------------------------
	
	
	function Commander:AddGhostGuide(origin, radius)

		local guide = nil
		
		if #self.reuseGhostGuides > 0 then
			guide = self.reuseGhostGuides[#self.reuseGhostGuides]
			table.remove(self.reuseGhostGuides, #self.reuseGhostGuides)
		end

		// Insert point, circle
		
		if not guide then
			guide = Client.CreateRenderModel(RenderScene.Zone_Default)
		end
		
		local modelName = ConditionalValue(
			self:GetTeamNumber() == kTeam2Index, 
				Commander.kAlienCircleModelName, 
				Commander.kMarineCircleModelName
		)
		
		guide:SetModel(modelName)
		
		local coords = Coords.GetLookIn( origin + Vector(0, kZFightingConstant, 0), Vector(1, 0, 0) )
		coords:Scale( radius * 2 )
		guide:SetCoords( coords )
		guide:SetIsVisible(true)
		
		table.insert(self.ghostGuides, {origin, guide})

	end
	
	
	// Set the context-sensitive mouse cursor 
	// Marine Commander default (like arrow from Starcraft 2, pointing to upper-left, MarineCommanderDefault.dds)
	// Alien Commander default (like arrow from Starcraft 2, pointing to upper-left, AlienCommanderDefault.dds)
	// Valid for friendly action (green "brackets" in Starcraft 2, FriendlyAction.dds)
	// Valid for neutral action (yellow "brackets" in Starcraft 2, NeutralAction.dds)
	// Valid for enemy action (red "brackets" in Starcraft 2, EnemyAction.dds)
	// Build/target default (white crosshairs, BuildTargetDefault.dds)
	// Build/target enemy (red crosshairs, BuildTargetEnemy.dds)
	function Commander:UpdateCursor()

		local playerTeam = self:GetTeamNumber()

		// By default, use side-specific default cursor
		local baseCursor = ConditionalValue(playerTeam == kTeam2Index, "AlienCommanderDefault", "MarineCommanderDefault")
		
		// By default, the "click" spot on the cursor graphic is in the top left corner.
		local hotspot = Vector(0, 0, 0)
		
		// Update highlighted unit under cursor
		local xScalar, yScalar = Client.GetCursorPos()
		
		local entityUnderCursor = nil
		
		if self.entityIdUnderCursor ~= Entity.invalidId then
		
			hotspot = Vector(16, 16, 0)
			
			entityUnderCursor = Shared.GetEntity(self.entityIdUnderCursor)
			baseCursor = "NeutralAction"
			
			if HasMixin(entityUnderCursor, "Team") then
			
				if entityUnderCursor:GetTeamNumber() == self:GetTeamNumber() then
					baseCursor = "FriendlyAction"
				elseif entityUnderCursor:GetTeamNumber() == GetEnemyTeamNumber(self:GetTeamNumber()) then
					baseCursor = "EnemyAction"
				end
				
			end
			
		end
		
		// If we're building or in a targeted mode, use a special targeting cursor
		if GetCommanderGhostStructureEnabled() then
		
			hotspot = Vector(16, 16, 0)
			baseCursor = "BuildTargetDefault"
			
		// Or if we're targeting an ability
		elseif self.currentTechId ~= nil and self.currentTechId ~= kTechId.None then
		
			local techNode = GetTechNode(self.currentTechId)
			
			if techNode ~= nil and techNode:GetRequiresTarget() then
			
				hotspot = Vector(16, 16, 0)
				baseCursor = "BuildTargetDefault"
				
				if entityUnderCursor and HasMixin(entityUnderCursor, "Team") and (entityUnderCursor:GetTeamNumber() == GetEnemyTeamNumber(self:GetTeamNumber())) then
					baseCursor = "BuildTargetEnemy"
				end
				
			end
			
		end
		
		// Set the cursor if it changed
		local cursorTexture = string.format("ui/Cursor_%s.dds", baseCursor)
		if CommanderUI_GetMouseIsOverUI() and self.currentTechId == kTechId.None then
			
			hotspot = Vector(0, 0, 0)
			if playerTeam == kTeam1Index then
				cursorTexture = "ui/Cursor_MenuDefault_team1_hover.dds"
			else
				cursorTexture = "ui/Cursor_MenuDefault_team2_hover.dds"
			end
			
		end
		
		if cursorTexture ~= self.lastCursorTexture then
		
			Client.SetCursor(cursorTexture, hotspot.x, hotspot.y)
			self.lastCursorTexture = cursorTexture
			
		end
		
	end
		
	
	local function MvM_UpdateSentryBatteryLine(self, fromPoint)

		local sentriesNearby = GetEntitiesForTeamWithinRange("Sentry", self:GetTeamNumber(), fromPoint, SentryBattery.kRange)
		Shared.SortEntitiesByDistance(fromPoint, sentriesNearby)
		
		local closestSentry = sentriesNearby[1]
		
		local inRange = false
		
		if closestSentry then
		
			local distance = GetPathDistance(fromPoint, closestSentry:GetOrigin())
			if distance and distance <= SentryBattery.kRange then
				inRange = true
			end
			
		end
		
		if inRange then
		
			local startPoint = fromPoint + Vector(0, kZFightingConstant, 0)
			local endPoint = closestSentry:GetOrigin() + Vector(0, kZFightingConstant, 0)
			local direction = GetNormalizedVector(endPoint - startPoint)
			
			UpdateOrderLine(startPoint, endPoint, ClientResources.GetResource("MvM_CommSentryBatteryLine"))
			
		else
			ClientResources.GetResource("MvM_CommSentryBatteryLine"):SetIsVisible(false)
		end
		
	end
	
	
	local function MvM_UpdateCircleUnderCursor(self)
		
		local unitUnderCursorModel = ClientResources.GetResource( 
			ConditionalValue( self:GetTeamNumber() == kTeam2Index, "CommTeam2UnitUnderCursor", "CommMarineUnitUnderCursor" )
		)
		
		local visibility = false
		
		if self.entityIdUnderCursor ~= Entity.invalidId then
		
			local entity = Shared.GetEntity(self.entityIdUnderCursor)
			if entity ~= nil and HasMixin(entity, "Selectable") then
			
				local scale = GetCircleSizeForEntity(entity)
				
				local coords = Coords.GetLookIn(entity:GetOrigin(), Vector.xAxis)
				coords:Scale(scale)
				unitUnderCursorModel:SetCoords(coords)
				
				visibility = true
				
			end
			
		end
		
		unitUnderCursorModel:SetIsVisible(visibility)
		
	end
	
	
	
	local function MvM_UpdateGhostStructureVisuals(self)
	
		local commSpecifyingOrientation = GetCommanderGhostStructureSpecifyingOrientation()
		
		local sentryRangeModel = ClientResources.GetResource(
			ConditionalValue(
				self:GetTeamNumber() == kTeam1Index,
					"CommSentryRange",
					"CommSentryRangeTeam2"
			)
		)
		sentryRangeModel:SetIsVisible(self.currentTechId == kTechId.Sentry and commSpecifyingOrientation)
		
		ClientResources.GetResource("MvM_CommSentryBatteryLine"):SetIsVisible(self.currentTechId == kTechId.SentryBattery)
		
		local coords = GetCommanderGhostStructureCoords()
		
		local displayOrientation = GetCommanderGhostStructureValid() and commSpecifyingOrientation
		
		local orientationModel = ClientResources.GetResource(
			ConditionalValue(
				self:GetTeamNumber() == kTeam1Index,
					"CommSentryOrientation",
					"CommSentryOrientationTeam2"
			)
		)
		orientationModel:SetIsVisible(displayOrientation)
		
		if displayOrientation then
		
			coords:Scale(Commander.kSentryArcScale)
			coords.zAxis = -coords.zAxis
			orientationModel:SetCoords(coords)
			
		end
		
		if coords and self.currentTechId == kTechId.Sentry then
		
			coords.zAxis = coords.zAxis * Sentry.kRange
			sentryRangeModel:SetCoords(coords)
			
		elseif coords and self.currentTechId == kTechId.SentryBattery then
			MvM_UpdateSentryBatteryLine(self, coords.origin)
		end
		
	end	
	
	
	// Only called when not running prediction
	function Commander:UpdateClientEffects(deltaTime, isLocal)
		
		Player.UpdateClientEffects(self, deltaTime, isLocal)
		
		if isLocal then
		
			self:UpdateMenu()
			
			// Update highlighted unit under cursor.
			local xScalar, yScalar = Client.GetCursorPos()
			local x = xScalar * Client.GetScreenWidth()
			local y = yScalar * Client.GetScreenHeight()
			
			if not GetCommanderGhostStructureEnabled() and not CommanderUI_GetMouseIsOverUI() then
			
				local oldEntityIdUnderCursor = self.entityIdUnderCursor
				self.entityIdUnderCursor = self:GetUnitIdUnderCursor(CreatePickRay(self, x, y))
				
				if self.entityIdUnderCursor ~= Entity.invalidId and oldEntityIdUnderCursor ~= self.entityIdUnderCursor then
					Shared.PlayPrivateSound(self, self:GetHoverSound(), self, 1.0, self:GetOrigin())
				end
				
			else
				self.entityIdUnderCursor = Entity.invalidId
			end
			
			MvM_UpdateGhostStructureVisuals(self)
			
			self:UpdateGhostGuides()
			
			MvM_UpdateCircleUnderCursor(self)
			
			self:UpdateCursor()

			self.lastMouseX = x
			self.lastMouseY = y
			
		end
		
	end


end		//End Client



if Server then
		
		
	local function MvM_HasEnemiesSelected(self)

		for _, unit in ipairs(self:GetSelection()) do
			if unit:GetTeamNumber() ~= self:GetTeamNumber() and not unit:isa("PowerPoint") then
				return true
			end
		end
		
		return false

	end
	
	
	ReplaceLocals( Commander.ProcessTechTreeAction, { HasEnemiesSelected = MvM_HasEnemiesSelected } )


end	//END SERVER



//-----------------------------------------------------------------------------


Class_Reload( "Commander", {} )
