//=============================================================================
//
// Colored Skins Mixin
// 		Author: Brock 'McGlaspie' Gillespie
//
//	This Mixin is only applicable to Clients and should not be loaded in any
//	other Lua VM (I.e. Server or Predict). The expectedCallbacks should be
//	wrapped in a "if Client" condition as a result.
//
// Note: This does NOT apply a material to a given model. It REQUIRES that a
// material with the Color Skins shader program is already being used by the
// entity implementing this mixin. Also, it is import to note this does not
// currently have support for screen fx. It is for texture mapped in-world
// objects only.
//
//=============================================================================

if Client then
	Shared.PrecacheSurfaceShader("shaders/colored_skins.surface_shader")
	Shared.PrecacheSurfaceShader("shaders/colored_skins_noemissive.surface_shader")
end

//TODO Move below and create additional utility functions
//Debugging and/or for when "complex" material parameter values allowed
local function ColorAsParam( color )
	return string.format("(%0.3f, %0.3f, %0.3f)", color.r, color.g, color.b )
end

//-----------------------------------------------------------------------------


ColoredSkinsMixin = CreateMixin( ColoredSkinsMixin )
ColoredSkinsMixin.type = "ColoredSkin"


ColoredSkinsMixin.expectedMixins = 
{
	Model = "Needed for setting material parameter"
}

ColoredSkinsMixin.expectedCallbacks = 
{
	GetBaseSkinColor = "Should return a Color object. This is applied to albedo textures",
	GetAccentSkinColor = "Should return a Color object. This is applied to emissive textures",
	GetTrimSkinColor = "Should return Color object"

}

ColoredSkinsMixin.optionalCallbacks = {}

//-----------------------------------------------------------------------------

//Initial color values are defined when implementing Entity is initialized.
//This does not prevent these colors from being updated according to a
//specific case or game condition. Generally, you do NOT want to be getting
//a "fresh" (I.e. calling Get****SkinColor() every time OnUpdateRender() is
//run. This causes an FPS drop and will increase the more skinned entities
//that are on screen.
function ColoredSkinsMixin:__initmixin()
	
	self._activeBaseColor = Color(0, 0, 0, 0)
	self._activeAccentColor = Color(0, 0, 0, 0)
	self._activeTrimColor = Color(0, 0, 0, 0)
	
	self._activeBaseColor = self:GetBaseSkinColor()
	self._activeAccentColor = self:GetAccentSkinColor()
	self._activeTrimColor = self:GetTrimSkinColor()
	
end



//Limit to Client only? Already limited?
//...would break RR skin-support IF not using previous team #'s
function ColoredSkinsMixin:OnUpdateRender()
	
	PROFILE("ColoredSkinsMixin:OnUpdateRender()")
	
	//Handle generic entities - Players, Structures, etc.
	local model = self:GetRenderModel()
	
	local baseColor = self._activeBaseColor
	local accentColor = self._activeAccentColor
	local trimColor = self._activeTrimColor
	
	if model then
		
		/*
		//Example of how color layers can be set via code
		
		local ts = math.floor( Shared.GetTime() )
		if math.fmod( ts , 5 ) == 0 and ts < 60 then
			
			local rc = {
				[1] = Color(1, 1, 0),
				[2] = Color(0, 1, 0),
				[3] = Color(1, 0, 0),
				[4] = Color(0, 0, 1),
				[5] = Color(1, 1, 1)
			}
			
			self._activeBaseColor = LerpColor( self._activeBaseColor, rc[ math.random(1,5) ] , 0.025 )
			self._activeAccentColor = LerpColor( self._activeAccentColor, rc[ math.random(5,1) ] , 0.5 )
			
		else
			
			self._activeBaseColor = LerpColor( self._activeBaseColor, kTeam2_BaseColor, 0.001 )
			self._activeAccentColor = LerpColor( self._activeAccentColor, kTeam2_AccentColor , 0.01 )
			
		end
		*/
		
		//Note: This will apply to all child materials
		//		That means for players (I.e. A marine) the male_face.material 
		//		and male_visor.material need the colored_skins.surface_shader)
		//		set as the shader file in said materials. Each entity needs to
		//		be setup accordingly. Setting the color once will propogate to
		//		"child" materials.
		
		//The RGB values MUST be added to materials due to non Vector/Float3/Color parameters
		//being valid to setting a parameter value. Just a limitation of current material system.
		//The Alpha value of the Color object is not used, nor supported by the shader(s).
		
		//If these values do NOT have a distinct color. The implementing Entity WILL appear black
		//Because no color specified will amount to setting Color(0,0,0) as the material parameter
		
		model:SetMaterialParameter( "modelColorBaseR", baseColor.r )
		model:SetMaterialParameter( "modelColorBaseG", baseColor.g )
		model:SetMaterialParameter( "modelColorBaseB", baseColor.b )
		
		model:SetMaterialParameter( "modelColorAccentR", accentColor.r )
		model:SetMaterialParameter( "modelColorAccentG", accentColor.g )
		model:SetMaterialParameter( "modelColorAccentB", accentColor.b )
		
		model:SetMaterialParameter( "modelColorTrimR", trimColor.r )
		model:SetMaterialParameter( "modelColorTrimG", trimColor.g )
		model:SetMaterialParameter( "modelColorTrimB", trimColor.b )
		
	end		
	
	
	//Handle "Special" cases from here on -------------------------------------
	
	//Attachment based equipment
	if self.GetHasEquipment and self:GetHasEquipment() then
		
		//Handle equipment by type	
		if self:isa("JetpackMarine") then
		
			local jetpack = self:GetJetpack()
			
			if jetpack then
			
				local jpModel = jetpack:GetRenderModel()
				
				if jpModel then
					
					jpModel:SetMaterialParameter( "modelColorBaseR", baseColor.r )
					jpModel:SetMaterialParameter( "modelColorBaseG", baseColor.g )
					jpModel:SetMaterialParameter( "modelColorBaseB", baseColor.b )
					
					jpModel:SetMaterialParameter( "modelColorAccentR", accentColor.r )
					jpModel:SetMaterialParameter( "modelColorAccentG", accentColor.g )
					jpModel:SetMaterialParameter( "modelColorAccentB", accentColor.b )
					
					jpModel:SetMaterialParameter( "modelColorTrimR", trimColor.r )
					jpModel:SetMaterialParameter( "modelColorTrimG", trimColor.g )
					jpModel:SetMaterialParameter( "modelColorTrimB", trimColor.b )
					
				end
				
			end
		
		end
		
	end
	
	if ( self:isa("Marine") or self:isa("Exo") ) and self == Client.GetLocalPlayer() then	//Don't run on World objects
	
		local viewEnt = self:GetViewModelEntity()
	
		if viewEnt then
		
			local viewModel = viewEnt:GetRenderModel()
			
			if viewModel then
				
				viewModel:SetMaterialParameter( "modelColorBaseR", baseColor.r )
				viewModel:SetMaterialParameter( "modelColorBaseG", baseColor.g )
				viewModel:SetMaterialParameter( "modelColorBaseB", baseColor.b )
				
				viewModel:SetMaterialParameter( "modelColorAccentR", accentColor.r )
				viewModel:SetMaterialParameter( "modelColorAccentG", accentColor.g )
				viewModel:SetMaterialParameter( "modelColorAccentB", accentColor.b )
				
				viewModel:SetMaterialParameter( "modelColorTrimR", trimColor.r )
				viewModel:SetMaterialParameter( "modelColorTrimG", trimColor.g )
				viewModel:SetMaterialParameter( "modelColorTrimB", trimColor.b )
				
			end
			
		end
		
	end
	
	//That's it (for now). Simple eh?
	
end

