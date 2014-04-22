// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======//// lua\GUISpectator.lua//// Created by: Jon 'Huze' Hughes (jon@jhuze.com)//// Spectator: Loads all the insight GUI elements//// ========= For more information, visit us at http://www.unknownworlds.com =====================
class 'GUISpectator' (GUIScript)function GUISpectator:Initialize()    if self.guiUnitFrames == nil then        self.guiUnitFrames = GetGUIManager():CreateGUIScriptSingle("GUIInsight_PlayerFrames")    end    if self.guiTopBar == nil then        self.guiTopBar = GetGUIManager():CreateGUIScriptSingle("mvm/Hud/GUIInsight_TopBar")    end    if self.guiTechPoints == nil then        self.guiTechPoints = GetGUIManager():CreateGUIScriptSingle("mvm/Hud/GUIInsight_TechPoints")    end        if self.guiLocation == nil then        self.guiLocation = GetGUIManager():CreateGUIScriptSingle("GUIInsight_Location")    end        if self.guiAlertQueue == nil then        self.guiAlertQueue = GetGUIManager():CreateGUIScriptSingle("GUIInsight_AlertQueue")    end        if self.guiPenTool == nil then        self.guiPenTool = GetGUIManager():CreateGUIScriptSingle("GUIInsight_PenTool")    end
    if self.guiGraphs == nil then        self.guiGraphs = GetGUIManager():CreateGUIScriptSingle("GUIInsight_Graphs")    end    if self.guiMarineProduction == nil then        self.guiMarineProduction = GetGUIManager():CreateGUIScript("GUIProduction")        self.guiMarineProduction:SetSpectatorLeft()        self.guiMarineProduction:SetTeam(kTeam1Index)            end
    if self.guiAlienProduction == nil then        self.guiAlienProduction = GetGUIManager():CreateGUIScript("GUIProduction")        self.guiAlienProduction:SetSpectatorRight()        self.guiAlienProduction:SetTeam(kTeam2Index)    end
    
    //if self.eggInfo == nil then    //    self.eggInfo = GetGUIManager():CreateGUIScript("GUIEggDisplay")    //end    
    end    function GUISpectator:Uninitialize()    if self.guiUnitFrames then            GetGUIManager():DestroyGUIScriptSingle("GUIInsight_PlayerFrames")        self.guiUnitFrames = nil            end        if self.guiTopBar then            GetGUIManager():DestroyGUIScriptSingle("mvm/Hud/GUIInsight_TopBar")        self.guiTopBar = nil            end        if self.guiTechPoints then            GetGUIManager():DestroyGUIScriptSingle("mvm/Hud/GUIInsight_TechPoints")        self.guiTechPoints = nil            end        if self.guiLocation then            GetGUIManager():DestroyGUIScriptSingle("GUIInsight_Location")        self.guiLocation = nil            end        if self.guiAlertQueue then            GetGUIManager():DestroyGUIScriptSingle("GUIInsight_AlertQueue")        self.guiAlertQueue = nil            end        if self.guiPenTool then            GetGUIManager():DestroyGUIScriptSingle("GUIInsight_PenTool")        self.guiPenTool = nil            end
    
    if self.guiGraphs then        GetGUIManager():DestroyGUIScriptSingle("GUIInsight_Graphs")        self.guiGraphs = nil    end
    
    if self.guiBlueTeamProduction then        GetGUIManager():DestroyGUIScript(self.guiBlueTeamProduction)        self.guiBlueTeamProduction = nil    end
    
    if self.guiGoldTeamProduction then        GetGUIManager():DestroyGUIScript(self.guiGoldTeamProduction)        self.guiGoldTeamProduction = nil    end
    
    //if self.eggInfo then    //    GetGUIManager():DestroyGUIScript(self.eggInfo)    //    self.eggInfo = nil    //end
        if self.guiGraphs then
            GetGUIManager():DestroyGUIScriptSingle("GUIInsight_Graphs")        self.guiGraphs = nil
            end
    
    if self.guiMarineProduction then
            GetGUIManager():DestroyGUIScript(self.guiBlueTeamProduction)        self.guiBlueTeamProduction = nil
            end
    
    if self.guiAlienProduction then
            GetGUIManager():DestroyGUIScript(self.guiGoldTeamProduction)        self.guiGoldTeamProduction = nil
            end
    endfunction GUISpectator:SetIsVisible(visible)    self.guiUnitFrames:SetIsVisible(visible)    self.guiTopBar:SetIsVisible(visible)    self.guiTechPoints:SetIsVisible(visible)    self.guiLocation:SetIsVisible(visible)    self.guiAlertQueue:SetIsVisible(visible)    self.guiBlueTeamProduction:SetIsVisible(visible)    self.guiGoldTeamProduction:SetIsVisible(visible)    self.guiPenTool:SetIsVisible(visible)    end


