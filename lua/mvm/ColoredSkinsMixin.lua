//=============================================================================
//
// Colored Skins Mixin
// 		Author: Brock 'McGlaspie' Gillespie
//		@McGlaspie  -  mcglaspie@gmail.com		
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
// Keep in mind this is a Client focused Mixin. So, any changes to the colorization
// or skin toggle should be based on game rules/data that get propogated over
// the network. Otherwise, skin-state or color values won't be synchronized for
// all players. It is strongly advised that the skin state and color values NOT
// be set as network variables. This would significantly increase network traffic
// and slow down rendering, and introduce server side lag.
//
//=============================================================================

if Client then
	Shared.PrecacheSurfaceShader("shaders/colored_skins.surface_shader")
	Shared.PrecacheSurfaceShader("shaders/colored_skins_noemissive.surface_shader")
	//TODO Add additional shaders needed for all models
end

//TODO Move below and create additional utility functions
//Debugging and/or for when "complex" material parameter values allowed
local function ColorAsParam( color )
	return string.format("(%0.3f, %0.3f, %0.3f)", color.r, color.g, color.b )
end


local gColoredSkinsToggle = true	//global to specify if colored skins are Active


//-----------------------------------------------------------------------------


ColoredSkinsMixin = CreateMixin( ColoredSkinsMixin )
ColoredSkinsMixin.type = "ColoredSkin"


ColoredSkinsMixin.expectedMixins = {
	Model = "Needed for setting material parameters"
}

ColoredSkinsMixin.expectedCallbacks = {
	GetBaseSkinColor = "Should return a Color object. This is applied to albedo textures",
	GetAccentSkinColor = "Should return a Color object. This is applied to emissive textures",
	GetTrimSkinColor = "Should return Color object",
	InitializeSkin = "Setup routine for any customization of skin colors applied to material"
}

ColoredSkinsMixin.optionalCallbacks = {}

//-----------------------------------------------------------------------------

//Initial color values are defined when implementing Entity is initialized.
//This does not prevent these colors from being updated according to a
//specific case or game condition. Generally, you do NOT want to be getting
//a "fresh" (I.e. calling Get****SkinColor() every time OnUpdateRender() is
//run. This causes an FPS drop and will increase the more skinned entities 
//are on screen.
function ColoredSkinsMixin:__initmixin()
	
	self._activeBaseColor = Color(0, 0, 0, 0)
	self._activeAccentColor = Color(0, 0, 0, 0)
	self._activeTrimColor = Color(0, 0, 0, 0)
	
	self._coloredSkinEnabled = true	//Allows for colored skins to be toggled on per-entity basis
	
end
//IntializeSkin() should ALWAYS be called in an Entity's OnInitialize() method within a "is Client" check
//This is required in order for the color values to correctly propogate to the shader(s). If not, the entity
//will appear black due to the default Colors variables being initialized that way.


function ColoredSkinsMixin:OnUpdateRender()
	
	PROFILE("ColoredSkinsMixin:OnUpdateRender()")
	
	local model = self:GetRenderModel()
	local enabled = ConditionalValue( gColoredSkinsToggle and self._coloredSkinEnabled, 1, 0 )
	
	if model then
		
		/*
		//Example of how color layers can be set via code
		// - This could easily be done in an entity's update routine(s)
		//Just be sure and wrap any changes in a HasMixin(entity, "ColoredSkin") condition
		
		local ts = math.floor( Shared.GetTime() )
		if math.fmod( ts , 5 ) == 0 and ts < 90 then
			
			local rc = {
				[1] = Color(1, 1, 0),
				[2] = Color(0, 1, 0),
				[3] = Color(1, 0, 0),
				[4] = Color(0, 0, 1),
				[5] = Color(1, 1, 1),
				[6] = Color(0, 0, 0)
			}
			
			self._activeBaseColor = LerpColor( self._activeBaseColor, rc[ math.random(1,6) ] , 0.025 )
			self._activeAccentColor = LerpColor( self._activeAccentColor, rc[ math.random(6,1) ] , 0.5 )
			self._activeTrimColor = LerpColor( self._activeTrimColor, rc[ math.random(6,1) ] , 0.01 )
			
		else
			
			self._activeBaseColor = LerpColor( self._activeBaseColor, kTeam2_BaseColor, 0.001 )
			self._activeAccentColor = LerpColor( self._activeAccentColor, kTeam2_AccentColor , 0.01 )
			self._activeTrimColor = LerpColor( self._activeTrimColor, kTeam2_TrimColor , 0.005 )
			
		end
		*/
		
		//Note: This will apply to all child materials
		//		That means for players (I.e. A marine) the male_face.material 
		//		and male_visor.material need the colored_skins.surface_shader)
		//		set as the shader file in said materials. Each entity needs to
		//		be setup accordingly. Setting the color once will propogate to
		//		"child" materials.
		
		//The RGB values MUST be added to materials due to lack of Vector/Float3/Color parameter support.
		//This appears to be a limitation of current material system.
		//The Alpha value of the Color object is not used, nor supported by the shader(s).
		
		//If these values do NOT have a distinct color. The implementing Entity WILL appear black
		//Because no color specified will amount to setting Color(0,0,0) as the material parameter
		
		model:SetMaterialParameter( "modelColorBaseR", self._activeBaseColor.r )
		model:SetMaterialParameter( "modelColorBaseG", self._activeBaseColor.g )
		model:SetMaterialParameter( "modelColorBaseB", self._activeBaseColor.b )
		
		model:SetMaterialParameter( "modelColorAccentR", self._activeAccentColor.r )
		model:SetMaterialParameter( "modelColorAccentG", self._activeAccentColor.g )
		model:SetMaterialParameter( "modelColorAccentB", self._activeAccentColor.b )
		
		model:SetMaterialParameter( "modelColorTrimR", self._activeTrimColor.r )
		model:SetMaterialParameter( "modelColorTrimG", self._activeTrimColor.g )
		model:SetMaterialParameter( "modelColorTrimB", self._activeTrimColor.b )
		
		//Set enabled state
		model:SetMaterialParameter( "colorizeModel", enabled )
		
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
					
					jpModel:SetMaterialParameter( "modelColorBaseR", self._activeBaseColor.r )
					jpModel:SetMaterialParameter( "modelColorBaseG", self._activeBaseColor.g )
					jpModel:SetMaterialParameter( "modelColorBaseB", self._activeBaseColor.b )
					
					jpModel:SetMaterialParameter( "modelColorAccentR", self._activeAccentColor.r )
					jpModel:SetMaterialParameter( "modelColorAccentG", self._activeAccentColor.g )
					jpModel:SetMaterialParameter( "modelColorAccentB", self._activeAccentColor.b )
					
					jpModel:SetMaterialParameter( "modelColorTrimR", self._activeTrimColor.r )
					jpModel:SetMaterialParameter( "modelColorTrimG", self._activeTrimColor.g )
					jpModel:SetMaterialParameter( "modelColorTrimB", self._activeTrimColor.b )
					
					//Set enabled state
					jpModel:SetMaterialParameter( "colorizeModel", enabled )
					
				end
				
			end
		
		end
		
	end
	
	if ( self:isa("Marine") or self:isa("Exo") ) and self == Client.GetLocalPlayer() then	//Don't run on World objects
	
		local viewEnt = self:GetViewModelEntity()
	
		if viewEnt then
		
			local viewModel = viewEnt:GetRenderModel()
			
			if viewModel then
				
				viewModel:SetMaterialParameter( "modelColorBaseR", self._activeBaseColor.r )
				viewModel:SetMaterialParameter( "modelColorBaseG", self._activeBaseColor.g )
				viewModel:SetMaterialParameter( "modelColorBaseB", self._activeBaseColor.b )
				
				viewModel:SetMaterialParameter( "modelColorAccentR", self._activeAccentColor.r )
				viewModel:SetMaterialParameter( "modelColorAccentG", self._activeAccentColor.g )
				viewModel:SetMaterialParameter( "modelColorAccentB", self._activeAccentColor.b )
				
				viewModel:SetMaterialParameter( "modelColorTrimR", self._activeTrimColor.r )
				viewModel:SetMaterialParameter( "modelColorTrimG", self._activeTrimColor.g )
				viewModel:SetMaterialParameter( "modelColorTrimB", self._activeTrimColor.b )
				
				//Set enabled state
				jpModel:SetMaterialParameter( "colorizeModel", enabled )
				
			end
			
		end
		
	end
	
	//That's it (for now). Simple eh? The heavy lifting is done in the shader(s).
	
end



//-----------------------------------------------------------------------------


local function OnCommandToggleColoredSkins()
	
	if Shared.GetCheatsEnabled() then
		
		gColoredSkinsToggle = ConditionalValue(
			gColoredSkinsToggle == true,
			false,
			true
		)
		
	end

end


Event.Hook("Console_coloredskins", OnCommandToggleColoredSkins)

