

Script.Load("lua/mvm/Commander_Buttons.lua")
Script.Load("lua/mvm/Commander_Ping.lua")


//-----------------------------------------------------------------------------



function CommanderUI_MenuButtonRequiresTarget(index)

	//Print("CommanderUI_MenuButtonRequiresTarget()")

    local techId = GetTechIdFromButtonIndex(index)
    //Print(" \t techId = " .. tostring( techId ) )
    
    local techTree = GetTechTree()
    local requiresTarget = false
    
    if(tech ~= 0 and techTree) then
    
        local techNode = techTree:GetTechNode(techId)
        
        if(techNode ~= nil) then
        
            // Buy nodes require a target for the commander
            requiresTarget = techNode:GetRequiresTarget() or techNode:GetIsBuy() or techNode:GetIsEnergyBuild()
            
        end
        
    end
	
	//Print("\t requiresTarget = " .. tostring(requiresTarget))
	
    return requiresTarget
    
end



local function MvM_SetupHud(self)

    MouseTracker_SetIsVisible(true, nil, true)
    
    self:InitializeMenuTechButtons()
    
    self.entityIdUnderCursor = Entity.invalidId
    
    local alertsScript = GetGUIManager():CreateGUIScriptSingle("mvm/Hud/GUICommanderAlerts")
    // Every Player already has a GUIMinimap.
    local minimapScript = ClientUI.GetScript("mvm/GUIMinimapFrame")
    
    local selectionPanelScript = GetGUIManager():CreateGUIScriptSingle("mvm/Hud/GUISelectionPanel")
    
    self.buttonsScript = GetGUIManager():CreateGUIScript( "mvm/GUICommanderButtonsMarines" )
    self.buttonsScript:GetBackground():AddChild(selectionPanelScript:GetBackground())
    minimapScript:SetButtonsScript(self.buttonsScript)
    
    local hotkeyIconScript = GetGUIManager():CreateGUIScriptSingle("mvm/Hud/GUIHotkeyIcons")
    local logoutScript = GetGUIManager():CreateGUIScriptSingle("mvm/Hud/GUICommanderLogout")
    GetGUIManager():CreateGUIScriptSingle("mvm/Hud/GUIResourceDisplay")
    
    local minimapButtons = GetGUIManager():CreateGUIScriptSingle("mvm/GUIMinimapButtons")
    minimapScript:GetBackground():AddChild(minimapButtons:GetBackground())
    
    minimapScript:GetBackground():AddChild(hotkeyIconScript:GetBackground())
    self.managerScript = GetGUIManager():CreateGUIScript("GUICommanderManager")
    
    //local worldbuttons = GetGUIManager():CreateGUIScriptSingle("GUICommanderHelpWidget")
    
    self.production = GetGUIManager():CreateGUIScript("mvm/GUIProduction")
    //self.production:SetTeam( self:GetTeamType() )
    self.production:SetTeam( self:GetTeamNumber() )
    minimapScript:GetBackground():AddChild( self.production:GetBackground() )
    
    // The manager needs to know about other commander UI scripts for things like
    // making sure mouse clicks don't click through UI elements.
    self.managerScript:AddChildScript(alertsScript)
    self.managerScript:AddChildScript(minimapScript)
    self.managerScript:AddChildScript(selectionPanelScript)
    self.managerScript:AddChildScript(self.buttonsScript)
    self.managerScript:AddChildScript(hotkeyIconScript)
    self.managerScript:AddChildScript(logoutScript)
    self.managerScript:AddChildScript(minimapButtons)
    //self.managerScript:AddChildScript(worldbuttons)
    
    self.commanderTooltip = GetGUIManager():CreateGUIScriptSingle("mvm/Hud/GUICommanderTooltip")
    
    self.commanderTooltip:Register(self.buttonsScript)
    //self.commanderTooltip:Register(worldbuttons)
    
    self.buttonsScript.background:AddChild( self.commanderTooltip:GetBackground() )
    
    // Calling SetBackgroundMode() will sometimes access self.managerScript through
    // CommanderUI_GetUIClickable() so call after self.managerScript is created above.
    minimapScript:SetBackgroundMode(GUIMinimapFrame.kModeMini)
    
    self.hudSetup = true
    
end



function Commander:OnDestroy()

    Player.OnDestroy(self)
    
    if self.hudSetup == true then
		
        GetGUIManager():DestroyGUIScriptSingle("mvm/Hud/GUICommanderAlerts")
        GetGUIManager():DestroyGUIScriptSingle("mvm/Hud/GUISelectionPanel")
        GetGUIManager():DestroyGUIScriptSingle("mvm/GUIMinimapButtons")
        
        GetGUIManager():DestroyGUIScript(self.buttonsScript)
        self.buttonsScript = nil
        
        GetGUIManager():DestroyGUIScriptSingle("mvm/Hud/GUIHotkeyIcons")
        GetGUIManager():DestroyGUIScriptSingle("mvm/Hud/GUICommanderLogout")
        GetGUIManager():DestroyGUIScriptSingle("mvm/Hud/GUIResourceDisplay")
        GetGUIManager():DestroyGUIScript(self.production)
        self.production = nil
        
        GetGUIManager():DestroyGUIScript(self.managerScript)
        self.managerScript = nil
        
        //GetGUIManager():DestroyGUIScriptSingle("GUICommanderHelpWidget")
        
        GetGUIManager():DestroyGUIScriptSingle("mvm/Hud/GUICommanderTooltip")
        
        self:DestroyGhostGuides()
        
        self.hudSetup = false
        
        MouseTracker_SetIsVisible(false)
        
    end
    
end



//-----------------------------------------------------------------------------

ReplaceLocals( Commander.OnInitLocalClient, {
	SetupHud = MvM_SetupHud
})

Class_Reload( "Commander", {} )