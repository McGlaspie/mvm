

local kCircleModelNameTeam2 = PrecacheAsset("models/misc/circle/placement_circle_marine_team2.model")

//-----------------------------------------------------------------------------

function MarineGhostModel:Initialize()

    GhostModel.Initialize(self)
    
    if not self.circleModel then
        self.circleModel = Client.CreateRenderModel(RenderScene.Zone_Default)
        
        local player = Client.GetLocalPlayer()
        
        if player:GetTeamNumber() == kTeam2Index then
			self.circleModel:SetModel(kCircleModelNameTeam2)
		else
			self.circleModel:SetModel(kCircleModelName)
		end
    end
    
end

//-----------------------------------------------------------------------------

Class_Reload("MarineGhostModel", {})
