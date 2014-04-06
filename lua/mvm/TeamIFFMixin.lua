//
//	Team Identify Friend or Foe Mixin
//		author: Brock 'McGlaspie' Gillespie
//		@McGlaspie - mcglaspie@gmail.com
//
//=============================================================================

if Client then

//TODO Create shader very similar to EquipmentOutline but fainter
// - Fade with distance or inverse?
//Shared.PrecacheSurfaceShader("shaders/TeamIFFOutline.surface_shader")


TeamIFFMixin = CreateMixin( TeamIFFMixin )
TeamIFFMixin.type = "IFF"


TeamIFFMixin.expectedMixins = {
	Model = "Needed for setting material parameters",
	Team = "Required to determine which team for toggle and color"
}


TeamIFFMixin.expectedCallbacks = {
	GetTeamNumber = "Get team index"
}

TeamIFFMixin.optionalCallbacks = {}


function TeamIFFMixin:__initmixin()

	self.iffGlowOutline = false

end



function TeamIFFMixin:UpdateHighlight()	//FIXME Rework this to only highlight friendly UNITS (Not structures)

	local player = Client.GetLocalPlayer()
    local visible = player ~= nil and not player:isa("Commander")
	
	// Don't show enemy structures as glowing
    if visible and self.GetTeamNumber and ( player:GetTeamNumber() == GetEnemyTeamNumber(self:GetTeamNumber() ) ) then
        visible = false
    end
    
    // Update the visibility status.
    if visible ~= self.iffGlowOutline then
    
        local model = self:GetRenderModel()
        if model ~= nil then

            local isAlien = GetIsAlienUnit(player)        
            if visible then
                if isAlien then
                    HiveVision_AddModel( model )
                else
                    EquipmentOutline_AddModel( model )
                end
            else
                HiveVision_RemoveModel( model )
                EquipmentOutline_RemoveModel( model )
            end
         
            self.iffGlowOutline = visible    
            
        end
        
    end
    

end


function TeamIFFMixin:OnKillClient()
end


function TeamIFFMixin:OnUpdateRender()

    PROFILE("TeamIFFMixin:OnUpdateRender")
    self:UpdateHighlight()
    
end


end	//End Client

