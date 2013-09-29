// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUICommanderLogout.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages displaying and animating the commander logout button in addition to logging the
// commander out when pressed.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUICommanderLogout' (GUIScript)

GUICommanderLogout.kBackgroundWidth = 208 * kCommanderGUIsGlobalScale
GUICommanderLogout.kBackgroundHeight = 107 * kCommanderGUIsGlobalScale
GUICommanderLogout.kBackgroundScaleDefault = Vector(1, 1, 1)
GUICommanderLogout.kBackgroundScalePressed = Vector(0.9, 0.9, 0.9)

GUICommanderLogout.kMouseOverColor = Color(0.8, 0.8, 1, 1)
GUICommanderLogout.kDefaultColor = Color(1, 1, 1, 1)

GUICommanderLogout.kFrameHeight = 107
GUICommanderLogout.kLogoutOffset = 2
GUICommanderLogout.kLogoutMarineTextureName = "ui/marine_commander_logout.dds"

GUICommanderLogout.kArrowWidth = 37 * kCommanderGUIsGlobalScale
GUICommanderLogout.kArrowHeight = 45 * kCommanderGUIsGlobalScale

GUICommanderLogout.kFontName = "fonts/AgencyFB_large.fnt"
GUICommanderLogout.kFontScale = Vector(1, 1, 0) * kCommanderGUIsGlobalScale
GUICommanderLogout.kTooltipPos = Vector(56, -4, 0) * kCommanderGUIsGlobalScale

GUICommanderLogout.kTooltipFontSize = 16

local kArrowAnimationDuration = 0.75
local kNumFrames = 7

local function GetLogoutFontColor()
	
    if PlayerUI_GetTeamNumber() == kTeam2Index then
        return kAlienFontColor
    else
        return kMarineFontColor
    end
    
end

function GUICommanderLogout:Initialize()

	local playerTeam = PlayerUI_GetTeamNumber()
	local ui_baseColor = ConditionalValue(
		playerTeam == kTeam1Index,
		kTeam1_BaseColor,
		kTeam2_BaseColor
	)

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(GUICommanderLogout.kBackgroundWidth, GUICommanderLogout.kBackgroundHeight, 0))
    self.background:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.background:SetPosition(Vector(-GUICommanderLogout.kBackgroundWidth - GUICommanderLogout.kLogoutOffset, GUICommanderLogout.kLogoutOffset, 0))
    self.background:SetLayer(kGUILayerPlayerHUD)
    self.background:SetTexture( GUICommanderLogout.kLogoutMarineTextureName )
    self.background:SetShader("shaders/GUI_TeamThemed.surface_shader")
    self.background:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.background:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.background:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
    
    self.tooltip = GUIManager:CreateTextItem()
    self.tooltip:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.tooltip:SetTextAlignmentX(GUIItem.Align_Min)
    self.tooltip:SetTextAlignmentY(GUIItem.Align_Center)
    self.tooltip:SetPosition(GUICommanderLogout.kTooltipPos)
    self.tooltip:SetFontName(GUICommanderLogout.kFontName)
    self.tooltip:SetScale(GUICommanderLogout.kFontScale)
    self.tooltip:SetText(Locale.ResolveString("LOGOUT"))
    self.tooltip:SetColor( GetLogoutFontColor() )
    self.background:AddChild(self.tooltip)
    
    self:Update(0)
    
end

function GUICommanderLogout:Uninitialize()

    if self.background then
    
        GUI.DestroyItem(self.background)
        self.background = nil
        
    end
    
end
    
function GUICommanderLogout:SendKeyEvent(key, down)

    if key == InputKey.MouseButton0 then

        local mouseX, mouseY = Client.GetCursorPosScreen()
        local containsPoint, withinX, withinY = GUIItemContainsPoint(self.background, mouseX, mouseY)
        
        if containsPoint and GetCommanderLogoutAllowed() then
            // Check if the button was pressed.
            if not down then
                CommanderUI_Logout()
            end
            return true
        end
        
    end
    
    return false
    
end

local function GetCoordsForFrame(frame)

    local x1 = 0
    local x2 = 208
    local y1 = frame * GUICommanderLogout.kFrameHeight
    local y2 = (frame + 1) * GUICommanderLogout.kFrameHeight
    
    return x1, y1, x2, y2
    
end


function GUICommanderLogout:UpdateTeamColors()
	
	local ui_baseColor = ConditionalValue(
		PlayerUI_GetTeamNumber() == kTeam1Index,
		kTeam1_BaseColor,
		kTeam2_BaseColor
	)
	
	self.tooltip:SetColor( GetLogoutFontColor() )

	self.background:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.background:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.background:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )

end


function GUICommanderLogout:Update(deltaTime)

    PROFILE("GUICommanderLogout:Update")
    
    local mouseX, mouseY = Client.GetCursorPosScreen()    
    local animateArrows = false
    
    self:UpdateTeamColors()
    
    self.tooltip:SetColor( LerpColor( GetLogoutFontColor(), Color(0, 0, 0), 0.25) )
    
    // Animate arrows when the mouse is hovering over.
    local containsPoint, withinX, withinY = GUIItemContainsPoint(self.background, mouseX, mouseY)
    if containsPoint then
    
        animateArrows = true
        self.tooltip:SetColor( GetLogoutFontColor() )
        
    end
    
    if not self.animatingArrows and animateArrows then
        self.arrowAnimationStartTime = Shared.GetTime()
    end
    
    self.animatingArrows = animateArrows
    
    // Update background pixel coords.
    if self.animatingArrows then
    
        local frame = math.floor(kNumFrames * (((Shared.GetTime() - self.arrowAnimationStartTime) % kArrowAnimationDuration) / kArrowAnimationDuration))
        self.background:SetTexturePixelCoordinates(GetCoordsForFrame(frame))
        
    else
        self.background:SetTexturePixelCoordinates(GetCoordsForFrame(0))
    end
    
    local logoutAllowed = GetCommanderLogoutAllowed()
    self.background:SetIsVisible( logoutAllowed )
    
end

function GUICommanderLogout:ContainsPoint(pointX, pointY)
    return GUIItemContainsPoint(self.background, pointX, pointY)
end