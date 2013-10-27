



function Minigun:OnUpdateRender()

    PROFILE("Minigun:OnUpdateRender")

    local parent = self:GetParent()
    if parent and parent:GetIsLocalPlayer() then
    
        local viewModel = parent:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() then
        
            viewModel:InstanceMaterials()
            viewModel:GetRenderModel():SetMaterialParameter("heatAmount" .. self:GetExoWeaponSlotName(), self.heatAmount)
            
        end
        
        local heatDisplayUI = self.heatDisplayUI
        if not heatDisplayUI then
			
            heatDisplayUI = Client.CreateGUIView(242, 720)
            heatDisplayUI:Load("lua/mvm/Hud/Exo/GUI" .. self:GetExoWeaponSlotName():gsub("^%l", string.upper) .. "MinigunDisplay.lua")
            heatDisplayUI:SetTargetTexture("*exo_minigun_" .. self:GetExoWeaponSlotName())
            self.heatDisplayUI = heatDisplayUI
            
        end
        
        heatDisplayUI:SetGlobal("heatAmount" .. self:GetExoWeaponSlotName(), self.heatAmount)
        heatDisplayUI:SetGlobal("teamNumber", parent:GetTeamNumber() )
        
    else
    
        if self.heatDisplayUI then
        
            Client.DestroyGUIView(self.heatDisplayUI)
            self.heatDisplayUI = nil
            
        end
        
    end
    
    if self.shellsCinematic then
        self.shellsCinematic:SetIsActive(self.shooting)
    end
    
end


Class_Reload("Minigun", {})