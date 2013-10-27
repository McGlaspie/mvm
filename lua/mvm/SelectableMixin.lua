

Script.Load("lua/SelectableMixin.lua")


Commander.kMarineCircleModelName = PrecacheAsset("models/misc/circle/circle.model")
Commander.kAlienCircleModelName = PrecacheAsset("models/misc/circle/circle_alien.model")


//-----------------------------------------------------------------------------

function SelectableMixin:GetIsSelectable(byTeamNumber)

//Damn dis shit be nasstai' yo
    local isValid = 
		( not HasMixin(self, "LOS") or self:GetIsSighted() )
		or ( HasMixin(self, "Team") and byTeamNumber == self:GetTeamNumber() and not self:isa("PowerPoint") )
		or self:isa("PowerPoint")
	
    if isValid and self.OnGetIsSelectable then
    
        // A table is passed in so that all the OnGetIsSelectable functions
        // have a say in the matter.
        local resultTable = { selectable = true }
        self:OnGetIsSelectable(resultTable, byTeamNumber)
        isValid = resultTable.selectable
        
    end
    
    return isValid
    
end



if Client then

	
	local function GetPlayerCanSeeSelection(player)
        return player:isa("Commander") or player:isa("Spectator")
    end
	

	function SelectableMixin:OnUpdateRender()
    
        local showCircle = false
        local player = Client.GetLocalPlayer()
        if player and HasMixin(player, "Team") and GetPlayerCanSeeSelection(player) then
            showCircle = self:GetIsSelected(player:GetTeamNumber())
        end
        
        if not self.selectionCircleModel and showCircle then
			
            self.selectionCircleModel = Client.CreateRenderModel(RenderScene.Zone_Default)
            local modelName = ConditionalValue(
				self:GetTeamNumber() == kTeam2Index, 
				Commander.kAlienCircleModelName, 
				Commander.kMarineCircleModelName
			)
            self.selectionCircleModel:SetModel(modelName)
            
        end
        
        if self.selectionCircleModel then
            self.selectionCircleModel:SetIsVisible(showCircle)
        end
        
        if showCircle and self.selectionCircleModel then
        
            if not self.selectionCircleCoords then
            
                self.selectionCircleCoords = Coords.GetLookIn(self:GetOrigin() + Vector(0, kZFightingConstant, 0), Vector.xAxis)
                local scale = GetCircleSizeForEntity(self)
                self.selectionCircleCoords:Scale(scale)
                
            end

            self.selectionCircleCoords.origin = self:GetOrigin() + Vector(0, kZFightingConstant, 0)
            self.selectionCircleModel:SetCoords(self.selectionCircleCoords)
            
        end

    end

end