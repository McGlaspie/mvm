//=============================================================================
// VERY simple model multi-skin mixin. This Requires all of the pre-cached
// shader files to work correctly.
// 
// Created By: Brock 'McGlaspie' Gillespie
//				mcglaspie@gmail.com
//
//=============================================================================


TeamColorSkinMixin = CreateMixin( TeamColorSkinMixin )
TeamColorSkinMixin.type = "TeamColor"


if Client then
	Shared.PrecacheSurfaceShader("models/marine/marine_teamColor.surface_shader")
	Shared.PrecacheSurfaceShader("shaders/Emissive_Colored.surface_shader")
	Shared.PrecacheSurfaceShader("shaders/ExoMinigunView_Colored.surface_shader")
	Shared.PrecacheSurfaceShader("shaders/Model_Colored.surface_shader")
	Shared.PrecacheSurfaceShader("shaders/Model_emissive_alpha_Colored.surface_shader")
	Shared.PrecacheSurfaceShader("shaders/Model_emissive_Colored.surface_shader")
end

//-----------------------------------------------------------------------------

TeamColorSkinMixin.expectedMixins = 
{
	Team = "To determine which color to apply to entity in a team",
	Model = "Needed for setting material parameter"
	//EntityChange = "Required so setting team skins can be run again"
}

TeamColorSkinMixin.expectedCallbacks = 
{
	GetTeamNumber = "Need team number for material parameter"
}

TeamColorSkinMixin.optionalCallbacks = {}

//-----------------------------------------------------------------------------

function TeamColorSkinMixin:__initmixin()
end


//Can below be used to handle RR skins?
//function TeamColorSkinMixin:OnEntityChange(oldId, newId)
//end

//Limit to Client only? Already limited?
//...would break RR skin-support IF not using previous team #'s
function TeamColorSkinMixin:OnUpdateRender()
	
	PROFILE("TeamColorSkinMixin:OnUpdateRender()")
	
	local team = 0
	if self:isa("ReadyRoomPlayer") and self.previousTeamNumber then
		team = self.previousTeamNumber	//Used by RR players
	else
		team = self:GetTeamNumber()
	end
	
	if team ~= kTeamReadyRoom and team ~= kTeamInvalid then
		
		local model = self:GetRenderModel()
		if model then
			model:SetMaterialParameter("TeamNumber", team)	//Note: This will apply to all child materials
		end		
		
		//Handle Attachment based equipment
		if self.GetHasEquipment and self:GetHasEquipment() then
		
			if self:isa("JetpackMarine") then
			//Handle specialized equipment by type	
			
				local jetpack = self:GetJetpack()
				
				if jetpack then
					local jpModel = jetpack:GetRenderModel()
					if jpModel then
						jpModel:SetMaterialParameter("TeamNumber", team)
						//Note: above will apply to all child materials
					end
				end
				
			//TODO Add support for Infiltration Kit
			//elseif self:isa("InfiltratorMarine") then
			
			end
			
		end
		
		
		if Client then
		
			if ( self:isa("Marine") or self:isa("Exo") ) and self == Client.GetLocalPlayer() then
				local viewEnt = self:GetViewModelEntity()
				if viewEnt then
					local viewModel = viewEnt:GetRenderModel()
					if viewModel then
						viewModel:SetMaterialParameter("TeamNumber", team)	//Note: This will apply to all child materials
					end
				end
			end
			
		end
		
		
	end
	
end

