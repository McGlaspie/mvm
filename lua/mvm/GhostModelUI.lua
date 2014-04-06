
Script.Load("lua/GhostModelUI.lua")

local MvM_gGhostModel = nil
local MvM_gLoadedTechId = nil


function LoadGhostModel(className)

    local pathToFile = "lua/mvm/Hud/Commander/MarineGhostModel.lua"
	
    if MvM_gGhostModel then
        MvM_gGhostModel:Destroy()
        MvM_gGhostModel = nil
    end
	
    Script.Load(pathToFile)
    local creationFunction = _G[className]

    if creationFunction == nil then
    
        Shared.Message("Error: Failed to load ghostmodel class named " .. className)
        return nil
        
    end
	
    MvM_gGhostModel = creationFunction()
    MvM_gGhostModel:Initialize()

end


ReplaceLocals( LoadGhostModel, { gGhostModel = MvM_gGhostModel, gLoadedTechId = MvM_gLoadedTechId } )
ReplaceLocals( OnUpdateRenderGhostModel, { gGhostModel = MvM_gGhostModel, gLoadedTechId = MvM_gLoadedTechId } )

