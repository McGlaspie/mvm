
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


Class_Reload("Commander", {})
