

Script.Load("lua/GhostStructureMixin.lua")


if Client then
	Shared.PrecacheSurfaceShader("cinematics/vfx_materials/ghoststructure_team1.surface_shader")
	Shared.PrecacheSurfaceShader("cinematics/vfx_materials/ghoststructure_team2.surface_shader")
end

//-----------------------------------------------------------------------------

local function SharedUpdate_MvM(self, deltaTime)

    if Server and self:GetIsGhostStructure() then
		
        // check for enemies in range and destroy the structure, return resources to team
        local enemies = GetEntitiesForTeamWithinRange(
			"Player", 
			GetEnemyTeamNumber(self:GetTeamNumber()), 
			self:GetOrigin() + Vector(0, 0.3, 0), 
			GhostStructureMixin.kGhostStructureCancelRange
		)
        
        for _, enemy in ipairs (enemies) do
        
            if enemy:GetIsAlive() then
            
                ClearGhostStructure(self)
                break
                
            end
            
        end
        
    elseif Client then
    
        local model = nil
        if HasMixin(self, "Model") then
            model = self:GetRenderModel()
        end
        
        if model then

            if self:GetIsGhostStructure() then
            
                self:SetOpacity(0, "ghostStructure")
				
                if not self.ghostStructureMaterial then
                
					if self:GetTeamNumber() == kTeam1Index then
					
						self.ghostStructureMaterial = AddMaterial(model, "cinematics/vfx_materials/ghoststructure_team1.material")
						
					elseif self:GetTeamNumber() == kTeam2Index then
					
						self.ghostStructureMaterial = AddMaterial(model, "cinematics/vfx_materials/ghoststructure_team2.material")
						
					end
					
                end
				
            else
				
                self:SetOpacity(1, "ghostStructure")
            
                if RemoveMaterial(model, self.ghostStructureMaterial) then
                    self.ghostStructureMaterial = nil
                end

            end
            
        end
        
    end
    
end


//Actual overrides for MvM
function GhostStructureMixin:OnUpdate(deltaTime)
    SharedUpdate_MvM(self, deltaTime)
end

function GhostStructureMixin:OnProcessMove(input)
    SharedUpdate_MvM(self, input.time)
end

