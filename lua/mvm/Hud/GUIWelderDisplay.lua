// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIWelderDisplay.lua
//
// Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Displays weld percentage of the current structure.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// Global state that can be externally set to adjust the display.
weldPercentage = 0
teamNumber = 0
welderDisplay  = nil

Script.Load("lua/GUIScript.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/GUIDial.lua")
Script.Load("lua/mvm/GUIColorGlobals.lua")

local kHealthCircleWidth = 512
local kHealthCircleHeight = 512
local kArmorCircleSize = Vector(kHealthCircleWidth, kHealthCircleHeight, 0)
local kHealthCircleSize = Vector(kHealthCircleWidth, kHealthCircleHeight, 0)
local kHealthTextureName = "ui/health_circle.dds"

class 'GUIWelderDisplay' (GUIScript)

function GUIWelderDisplay:Initialize()

    self.weldPercentage = 0
    self.time = 0
    self.teamNumber = 0

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize( Vector(512, 512, 0) )
    self.background:SetPosition( Vector(0, 0, 0))  
    //self.background:SetColor( Color(0, 0, 1, 1)) 
    self.background:SetTexture("ui/ShotgunDisplay.dds")
    self.background:SetShader("shaders/GUI_TeamThemed.surface_shader")
    
    self.squares = GUIManager:CreateGraphicItem()
    self.squares:SetSize( Vector(512, 2560, 0) )
    self.squares:SetTexture("ui/WelderSquares.dds")
    self.squares:SetShader("shaders/GUI_TeamThemed.surface_shader")
    
    local healthCircleSettings = { }
    healthCircleSettings.BackgroundWidth = kHealthCircleSize.x
    healthCircleSettings.BackgroundHeight = kHealthCircleSize.y
    healthCircleSettings.BackgroundAnchorX = GUIItem.Left
    healthCircleSettings.BackgroundAnchorY = GUIItem.Bottom
    healthCircleSettings.BackgroundOffset = Vector(0, 0, 0)
    healthCircleSettings.BackgroundTextureName = kHealthTextureName
    healthCircleSettings.BackgroundTextureX1 = 0
    healthCircleSettings.BackgroundTextureY1 = 0
    healthCircleSettings.BackgroundTextureX2 = kHealthCircleWidth
    healthCircleSettings.BackgroundTextureY2 = kHealthCircleHeight
    healthCircleSettings.ForegroundTextureName = kHealthTextureName
    healthCircleSettings.ForegroundTextureWidth = kHealthCircleWidth
    healthCircleSettings.ForegroundTextureHeight = kHealthCircleHeight
    healthCircleSettings.ForegroundTextureX1 = kHealthCircleWidth
    healthCircleSettings.ForegroundTextureY1 = 0
    healthCircleSettings.ForegroundTextureX2 = kHealthCircleWidth * 2
    healthCircleSettings.ForegroundTextureY2 = kHealthCircleHeight
    healthCircleSettings.InheritParentAlpha = true
    self.circle = GUIDial()
    self.circle:Initialize( healthCircleSettings )
    //self.circle.GetBackground():SetShader("shaders/GUI_TeamThemed.surface_shader")   //FIXME Dial not affected
    self.circle:GetBackground():SetIsVisible(true)
    
    // Slightly larger copy of the text for a glow effect
    self.percentageText = GUIManager:CreateTextItem()
    self.percentageText:SetFontName("fonts/AgencyFB_large_bold.fnt")
    self.percentageText:SetScale(Vector(1,1,1) * 3)
    self.percentageText:SetFontIsBold(true)
    self.percentageText:SetTextAlignmentX(GUIItem.Align_Center)
    self.percentageText:SetTextAlignmentY(GUIItem.Align_Center)
    self.percentageText:SetPosition(Vector(256, 256, 0))
    self.percentageText:SetIsVisible(true)
    self.percentageText:SetColor( Color(1, 1, 1, 1) )
    
    // Force an update so our initial state is correct.
    self:Update(0)

end

function GUIWelderDisplay:Uninitialize()

	self.percentageText:SetColor( kGUI_Trans )
	self.percentageText:SetIsVisible(false)

    if self.circle then
        self.circle:Uninitialize()
        self.circle = nil
    end

end

function GUIWelderDisplay:SetTeamNumber(team)
	self.teamNumber = team
end

function GUIWelderDisplay:UpdateTeamColors()
	
	local ui_color = kGUI_Team1_BaseColor
	
	if self.teamNumber == 2 then
		ui_color = kGUI_Team2_BaseColor
	end
	
	self.background:SetFloatParameter( "teamBaseColorR", ui_color.r )
	self.background:SetFloatParameter( "teamBaseColorG", ui_color.g )
	self.background:SetFloatParameter( "teamBaseColorB", ui_color.b )
	
	self.squares:SetFloatParameter( "teamBaseColorR", ui_color.r )
	self.squares:SetFloatParameter( "teamBaseColorG", ui_color.g )
	self.squares:SetFloatParameter( "teamBaseColorB", ui_color.b )
	
	//FIXME Below is not effecting Dial
	//self.circle:GetBackground():SetFloatParameter( "teamBaseColorR", kGUI_HealthBarColors[self.teamNumber].r )
	//self.circle:GetBackground():SetFloatParameter( "teamBaseColorG", kGUI_HealthBarColors[self.teamNumber].g )
	//self.circle:GetBackground():SetFloatParameter( "teamBaseColorB", kGUI_HealthBarColors[self.teamNumber].b )
	
	//self.percentageText:SetColor( kGUI_NameTagFontColors[ self.teamNumber ] )

end

function GUIWelderDisplay:Update(deltaTime)

    PROFILE("GUIWelderDisplay:Update")
    
    self:UpdateTeamColors()
    
    self.time = self.time + deltaTime
    
    // Update percentage display.    
    local isVisible = self.weldPercentage > 0
    self.circle:GetBackground():SetIsVisible(isVisible)    
    self.circle:SetPercentage( self.weldPercentage / 100 )
    self.circle:Update( deltaTime )
    
    local yPos = 512 - ((self.time % 2) / 2) * (2560 + 256)
    
    self.squares:SetPosition(Vector(0, yPos, 0))
    
    local percentageFormat = string.format("%d%%", math.ceil(self.weldPercentage)) 
    self.percentageText:SetText( percentageFormat )
    
    self.percentageText:SetIsVisible( isVisible )

end

// pass 0-1
function GUIWelderDisplay:SetWeldPercentage(percentage)
    self.weldPercentage = percentage
end

/**
 * Called by the player to update the components.
 */
function Update( deltaTime )

    welderDisplay:SetWeldPercentage(weldPercentage)
    welderDisplay:SetTeamNumber(teamNumber)
    welderDisplay:Update( deltaTime )
    
end

/**
 * Initializes the player components.
 */
function Initialize()

    GUI.SetSize( 512, 512 )

    welderDisplay = GUIWelderDisplay()
    welderDisplay:Initialize()

end

Initialize()