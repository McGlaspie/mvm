
Script.Load("lua/Commander.lua")


if Client then
	Script.Load("lua/mvm/Commander_Client.lua")
end


//-----------------------------------------------------------------------------


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
