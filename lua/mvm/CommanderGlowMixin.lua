

Script.Load("lua/CommanderGlowMixin.lua")



function CommanderGlowMixin:UpdateHighlight()	//OVERRIDES

    // Show glowing outline for commander, to pick it out of the darkness
    local player = Client.GetLocalPlayer()
    local visible = player ~= nil and (player:isa("Commander"))
    
    // Don't show enemy structures as glowing
    if visible and self.GetTeamNumber and ( player:GetTeamNumber() == GetEnemyTeamNumber(self:GetTeamNumber()) ) then
        visible = false
    end
	
    // Update the visibility status.
    if visible ~= self.commanderGlowOutline then
    
        local model = self:GetRenderModel()
        
        if model ~= nil then
			//Removed usage of HiveVision_XYZ
            if visible then
                EquipmentOutline_AddModel( model )
            else
                EquipmentOutline_RemoveModel( model )
            end
         
            self.commanderGlowOutline = visible    
            
        end
        
    end
    
end