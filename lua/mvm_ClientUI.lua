// ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\ClientUI.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// Creates and evaluates validity of UI scripts on the Client.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

ClientUI = { }

// Below are the rules for what scripts should be active when the local player is on certain teams.
local kTeamTypes = { "all", kTeamReadyRoom, kTeam1Index, kTeam2Index, kSpectatorIndex }
local kShowOnTeam = { }
kShowOnTeam["all"] = { 
	GUIFeedback = true, 
	GUIScoreboard = true, 
	["mvm/GUIDeathMessages"] = true, 
	["mvm/GUIChat"] = true,
	GUIVoiceChat = true, //May need to update for hacking
	["mvm/GUIMinimapFrame"] = true, 
	GUIMapAnnotations = true,
	GUICommunicationStatusIcons = true, 
	["mvm/GUIUnitStatus"] = true, 
	GUIDeathScreen = true,
	GUITipVideo = false, 
	GUIVoteMenu = true, 
	GUIStartVoteMenu = true,
	GUIGatherOverlay = true //does gather even work for mods?
}


kShowOnTeam[kTeamReadyRoom] = { GUIReadyRoomOrders = true } // , GUIPlayerRanking = true }
kShowOnTeam[kTeam1Index] = { }
kShowOnTeam[kTeam2Index] = { }
kShowOnTeam[kSpectatorIndex] = { 
	["mvm/GUIGameEnd"] = true, 
	["mvm/Hud/GUISpectator"] = true 
}

local kBothAlienAndMarine = { 
	GUICrosshair = true, 
	["mvm/GUINotifications"] = true, 
	GUIDamageIndicators = true, 
	["mvm/GUIGameEnd"] = true, 
	["mvm/GUIWorldText"] = true,
	GUIPing = true, 
	GUIWaitingForAutoTeamBalance = true, 
	["mvm/GUITechMap"] = true 
}

for n, e in pairs(kBothAlienAndMarine) do
    kShowOnTeam[kTeam1Index][n] = e
    kShowOnTeam[kTeam2Index][n] = e
end

function AddClientUIScriptForTeam(showOnTeam, scriptName)
    kShowOnTeam[showOnTeam][scriptName] = true
end

// Below are the rules for what scripts should be active when the local player is a certain class.
local kShowAsClass = { }
kShowAsClass["Marine"] = { 
	["mvm/Hud/Marine/GUIMarineHUD"] = true, 
	GUIPoisonedFeedback = false, 
	["mvm/Hud/GUIPickups"] = true,
	["mvm/Hud/GUISensorBlips"] = true, 
	["mvm/Hud/GUIObjectiveDisplay"] = true, 
	["mvm/Hud/GUIProgressBar"] = true, 
	["mvm/Hud/GUIRequestMenu"] = true,
	["mvm/GUIWaypoints"] = true,
	["mvm/Hud/GUIDistressBeacon"] = false
}

kShowAsClass["JetpackMarine"] = { 
	["mvm/Hud/Marine/GUIJetpackFuel"] = true 
}
//kShowAsClass["InfiltratorMarine"] = { }	-	Future use
kShowAsClass["Exo"] = { 
	["mvm/Hud/Exo/GUIExoThruster"] = true,
	["mvm/Hud/Marine/GUIMarineHUD"] = true, 
	["mvm/Hud/Exo/GUIExoHUD"] = true, 
	["mvm/Hud/GUIProgressBar"] = true, 
	["mvm/Hud/GUIRequestMenu"] = true, 
	["mvm/GUIWaypoints"] = true, 
	["mvm/Hud/Exo/GUIExoEject"] = true,
	["mvm/Hud/GUIDistressBeacon"] = false
}

kShowAsClass["MarineSpectator"] = { GUIRequestMenu = true }

kShowAsClass["Commander"] = { 
	["mvm/GUICommanderOrders"] = true
}
kShowAsClass["MarineCommander"] = { 
	GUICommanderTutorial = true, 
	["mvm/Hud/GUISensorBlips"] = true, 
	["mvm/Hud/GUIDistressBeacon"] = true 
}


kShowAsClass["Alien"] = { 
	GUIObjectiveDisplay = false, 
	GUIProgressBar = false, 
	GUIRequestMenu = false, 
	GUIWaypoints = false, 
	GUIAlienHUD = false,
	GUIEggDisplay = false, 
	GUIRegenerationFeedback = false, 
	GUIBioMassDisplay = false, 
	GUIUpgradeChamberDisplay = false,
	GUIAuraDisplay = false 
}
kShowAsClass["AlienSpectator"] = { GUIRequestMenu = false }
kShowAsClass["Fade"] = { GUIFadeVortex = false }
kShowAsClass["AlienCommander"] = { 
	GUICommanderTutorial = false, 
	GUIEggDisplay = false, 
	GUICommanderPheromoneDisplay = false, 
	GUIBioMassDisplay = false 
}



kShowAsClass["ReadyRoomPlayer"] = { }
kShowAsClass["TeamSpectator"] = { }
kShowAsClass["Spectator"] = { }




function AddClientUIScriptForClass(className, scriptName)

    kShowAsClass[className] = kShowAsClass[className] or { }
    kShowAsClass[className][scriptName] = true
    
end

local scripts = { }
local scriptCreationEventListeners = { }

function ClientUI.GetScript(name)
    return scripts[name]
end

function ClientUI.DestroyUIScripts()

    for name, script in pairs(scripts) do
        GetGUIManager():DestroyGUIScript(script)
    end
    scripts = { }
    
end

function ClientUI.AddScriptCreationEventListener(listener)
    table.insert(scriptCreationEventListeners, listener)
end

local function CheckPlayerIsOnTeam(forPlayer, teamType)
    return teamType == "all" or forPlayer:GetTeamNumber() == teamType
end

local removeScripts = { }
local function RemoveScripts(forPlayer)

    for name, script in pairs(scripts) do
    
        local shouldExist = false
        if forPlayer then
        
            // Determine if this script should exist based on the team the forPlayer is on.
            for t = 1, #kTeamTypes do
            
                local teamType = kTeamTypes[t]
                if CheckPlayerIsOnTeam(forPlayer, teamType) then
                
                    if kShowOnTeam[teamType][name] then
                    
                        shouldExist = true
                        break
                        
                    end
                    
                end
                
            end
            
            // Determine if this script should exist based on the class the forPlayer is.
            if not shouldExist then
            
                for class, scriptTable in pairs(kShowAsClass) do
                
                    if forPlayer:isa(class) then
                    
                        if scriptTable[name] then
                        
                            // Most scripts are not allowed in the Ready Room regardless of player class.
                            shouldExist = true
                            if CheckPlayerIsOnTeam(forPlayer, kTeamReadyRoom) then
                                shouldExist = (kShowOnTeam[kTeamReadyRoom][name] or kShowOnTeam["all"][name])
                            end
                            
                            break
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
        if not shouldExist then
            table.insert(removeScripts, name)
        end
        
    end
    
    if #removeScripts > 0 then
    
        for s = 1, #removeScripts do
        
            local script = scripts[removeScripts[s]]
            GetGUIManager():DestroyGUIScript(script)
            scripts[removeScripts[s]] = nil
            
        end
        removeScripts = { }
        
    end
    
end

local function NotifyListenersOfScriptCreation(scriptName, script)

    for i = 1, #scriptCreationEventListeners do
        scriptCreationEventListeners[i](scriptName, script)
    end
    
end

local function AddScripts(forPlayer)

    if forPlayer then
    
        for t = 1, #kTeamTypes do
        
            local teamType = kTeamTypes[t]
            if CheckPlayerIsOnTeam(forPlayer, teamType) then
            
                for name, exists in pairs(kShowOnTeam[teamType]) do
                
                    if exists and scripts[name] == nil then
                    
                        scripts[name] = GetGUIManager():CreateGUIScript(name)
                        NotifyListenersOfScriptCreation(name, scripts[name])
                        
                    end
                    
                end
                
            end
            
        end
        
        for class, scriptTable in pairs(kShowAsClass) do
        
            if forPlayer:isa(class) then
            
                for name, exists in pairs(scriptTable) do
                
                    // Most scripts are not allowed in the Ready Room regardless of player class.
                    local allowed = exists
                    if CheckPlayerIsOnTeam(forPlayer, kTeamReadyRoom) then
                        allowed = allowed and (kShowOnTeam[kTeamReadyRoom][name] or kShowOnTeam["all"][name])
                    end
                    
                    if allowed and scripts[name] == nil then
                    
                        scripts[name] = GetGUIManager():CreateGUIScript(name)
                        NotifyListenersOfScriptCreation(name, scripts[name])
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
end

local function NotifyScriptsOfPlayerChange(forPlayer)

    for name, script in pairs(scripts) do
    
        if script.OnLocalPlayerChanged then
            script:OnLocalPlayerChanged(forPlayer)
        end
        
    end
    
end

function ClientUI.EvaluateUIVisibility(forPlayer)

    RemoveScripts(forPlayer)
    AddScripts(forPlayer)
    
    NotifyScriptsOfPlayerChange(forPlayer)
    
end

local function PrintUIScripts()

    for name, script in pairs(scripts) do
        Shared.Message(name)
    end
    
end
Event.Hook("Console_print_client_ui", PrintUIScripts)

function PreLoadGUIScripts()

    for team, uiScripts in pairs(kShowOnTeam) do
    
        for name, enabled in pairs(uiScripts) do
            
            if enabled then
                Script.Load("lua/" .. name .. ".lua")
            end
            
        end 

    end   

    for name, enabled in pairs(kBothAlienAndMarine) do
        
        if enabled then
            Script.Load("lua/" .. name .. ".lua")
        end
        
    end
    
    for class, uiScripts in pairs(kShowAsClass) do

        for name, enabled in pairs(uiScripts) do
            
            if enabled then
                Script.Load("lua/" .. name .. ".lua")
            end
            
        end
    
    end

end
