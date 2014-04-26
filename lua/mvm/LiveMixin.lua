

Script.Load("lua/LiveMixin.lua")



if Client then
    Shared.PrecacheSurfaceShader("cinematics/vfx_materials/heal_marine.surface_shader")
    Shared.PrecacheSurfaceShader("cinematics/vfx_materials/heal_marine_team2.surface_shader")
    Shared.PrecacheSurfaceShader("cinematics/vfx_materials/heal_marine_view.surface_shader")
    Shared.PrecacheSurfaceShader("cinematics/vfx_materials/heal_marine_team2_view.surface_shader")
end

local kHealMaterials =
{
    [kTeam1Index] = "cinematics/vfx_materials/heal_marine.material",
    [kTeam2Index] = "cinematics/vfx_materials/heal_marine_team2.material",
}

local kHealViewMaterials =
{
    [kTeam1Index] = "cinematics/vfx_materials/heal_marine_view.material",
    [kTeam2Index] = "cinematics/vfx_materials/heal_marine_team2_view.material",
}

//-----------------------------------------------------------------------------

local function MvM_GetHealMaterialName(self)

    if HasMixin(self, "Team") then
        return kHealMaterials[self:GetTeamNumber()]
    end

end

local function MvM_GetHealViewMaterialName(self)

    if self.OverrideHealViewMateral then
        return self:OverrideHealViewMateral()
    end
	
    if HasMixin(self, "Team") then
        return kHealViewMaterials[self:GetTeamNumber()]
    end

end

//Below solves PN selection bug, but MAC still cannot repair automatically
//4/25/14 - Is above still an issue?
function LiveMixin:OnGetIsSelectable(result, byTeamNumber)
    result.selectable = (
		result.selectable 
		and self:GetIsAlive() or self:isa("PowerPoint")
	)
end


function LiveMixin:OnUpdateRender()

    local model = HasMixin(self, "Model") and self:GetRenderModel()
    
    local localPlayer = Client.GetLocalPlayer()
    local showHeal = not HasMixin(self, "Cloakable") or not self:GetIsCloaked() or not GetAreEnemies(self, localPlayer)
    
    // Do healing effects for the model
    if model then
    
        if self.healMaterial and self.loadedHealMaterialName ~= MvM_GetHealMaterialName(self) then
        
            RemoveMaterial(model, self.healMaterial)
            self.healMaterial = nil
        
        end
    
        if not self.healMaterial then
            
            self.loadedHealMaterialName = MvM_GetHealMaterialName(self)
            if self.loadedHealMaterialName then
                self.healMaterial = AddMaterial(model, self.loadedHealMaterialName)
            end
        
        else
            self.healMaterial:SetParameter("timeLastHealed", showHeal and self.timeLastHealed or 0)        
        end
    
    end
    
    // Do healing effects for the view model
    if self == localPlayer then
    
        local viewModelEntity = self:GetViewModelEntity()
        local viewModel = viewModelEntity and viewModelEntity:GetRenderModel()
        if viewModel then
        
            if self.healViewMaterial and self.loadedHealViewMaterialName ~= MvM_GetHealViewMaterialName(self) then
            
                RemoveMaterial(viewModel, self.healViewMaterial)
                self.healViewMaterial = nil
            
            end
        
            if not self.healViewMaterial then
                
                self.loadedHealViewMaterialName = MvM_GetHealViewMaterialName(self)
                if self.loadedHealViewMaterialName then
                    self.healViewMaterial = AddMaterial(viewModel, self.loadedHealViewMaterialName)
                end
            
            else
                self.healViewMaterial:SetParameter("timeLastHealed", self.timeLastHealed)        
            end
        
        end
        
    end        
    
    if self.timeLastHealed ~= self.clientTimeLastHealed then
    
        self.clientTimeLastHealed = self.timeLastHealed
        
        if showHeal and (not self:isa("Player") or not self:GetIsLocalPlayer()) then        
            self:TriggerEffects("heal", { false }) //isalien = GetIsAlienUnit(self)
        end
        
        self:TriggerEffects("heal_sound", { false }) //isalien = GetIsAlienUnit(self)
    
    end

end


