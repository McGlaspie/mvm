
local kCircleModelName = PrecacheAsset("models/misc/circle/placement_circle_marine.model")
local kCircleModelNameTeam2 = PrecacheAsset("models/misc/circle/placement_circle_marine_team2.model")

local kElectricTexture = "ui/electric.dds"
local kIconSize = GUIScale(Vector(32, 32, 0))
local kHalfIconSize = kIconSize * 0.5
local kIconOffset = GUIScale(100)


//-----------------------------------------------------------------------------


function MarineGhostModel:Initialize()

    GhostModel.Initialize(self)
    
    if not self.circleModel then
		
        self.circleModel = Client.CreateRenderModel(RenderScene.Zone_Default)
        
        local player = Client.GetLocalPlayer()
        
        if player and player:GetTeamNumber() == kTeam2Index then
			self.circleModel:SetModel( kCircleModelNameTeam2 )
		else
			self.circleModel:SetModel( kCircleModelName )
		end
		
    end
    
    if not self.powerIcon then
    
        self.powerIcon = GUI.CreateItem()
        self.powerIcon:SetTexture( kElectricTexture )
        self.powerIcon:SetSize( kIconSize )
        self.powerIcon:SetIsVisible(false)
    
    end
    
end



//-----------------------------------------------------------------------------


Class_Reload("MarineGhostModel", {})
