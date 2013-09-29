
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIMinimapButtons.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// Buttons for minimap action (commander ping).
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")

class 'GUIMinimapButtons' (GUIScript)

local kButtonBackgroundTexture =
{
    [kMarineTeamType] = "ui/marine_buildmenu_buttonbg.dds",
    [kAlienTeamType] = "ui/alien_buildmenu_buttonbg.dds",
}

local kBackgroundPos = GUIScale(Vector(16, -6, 0))
local kButtonSize = GUIScale(Vector(60, 60, 0))

local kIconTexture = "ui/buildmenu.dds"

local function CreateButtonBackground(self, position, child)
	
	local ui_baseColor = ConditionalValue(
		PlayerUI_GetTeamNumber() == kTeam1Index,
		kMarineFontColor,
		kAlienFontColor
	)
	
    local buttonBackground = GetGUIManager():CreateGraphicItem()
    buttonBackground:SetTexture( kButtonBackgroundTexture[ PlayerUI_GetTeamType() ] )
    
	buttonBackground:SetShader("shaders/GUI_TeamThemed.surface_shader")
    buttonBackground:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    buttonBackground:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    buttonBackground:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
    
    buttonBackground:SetPosition(position)
    buttonBackground:SetSize(kButtonSize)
    buttonBackground:AddChild(child)
    
    self.background:AddChild(buttonBackground)

end

function GUIMinimapButtons:Initialize()

    self.pingButtonActive = false
    
    local playerTeam = PlayerUI_GetTeamNumber()
	local ui_baseColor = ConditionalValue(
		playerTeam == kTeam1Index,
		kMarineFontColor,
		kAlienFontColor
	)
    
    self.teamType = PlayerUI_GetTeamType()
    self.teamNumber = PlayerUI_GetTeamNumber()
    
    self.background = GetGUIManager():CreateGraphicItem()
    self.background:SetPosition(kBackgroundPos)
    self.background:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.background:SetColor(Color(1,1,1,0))
  
    self.pingButton = GetGUIManager():CreateGraphicItem()
    self.pingButton:SetSize(kButtonSize)
    self.pingButton:SetTexture( kIconTexture )
    self.pingButton:SetShader("shaders/GUI_TeamThemed.surface_shader")
    self.pingButton:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.pingButton:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.pingButton:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
    
    self.pingButton:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.PingLocation)))   
    CreateButtonBackground(self, Vector(0,0,0), self.pingButton)
	
    self.techMapButton = GetGUIManager():CreateGraphicItem()
    self.techMapButton:SetSize(kButtonSize)
    self.techMapButton:SetTexture(kIconTexture)
    self.techMapButton:SetShader("shaders/GUI_TeamThemed.surface_shader")
    self.techMapButton:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.techMapButton:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.techMapButton:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
    
    self.techMapButton:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.Research)))  
    CreateButtonBackground(self, Vector(0, kButtonSize.y, 0), self.techMapButton)
    
    //TODO Add Directives button here
    
end

function GUIMinimapButtons:GetBackground()
    return self.background
end

function GUIMinimapButtons:Uninitialize()

    if self.background then
    
        GUI.DestroyItem(self.background)
        self.background = nil
        
    end
    
end

function GUIMinimapButtons:Update(deltaTime)

	self.teamNumber = PlayerUI_GetTeamNumber()
	
    local teamColor = kIconColors[self.teamNumber]    
    local useColor = Color(
        teamColor.r,
        teamColor.g,
        teamColor.b,
        GetCommanderPingEnabled() and 1 or 0.7
    )
    
	local ui_baseColor = ConditionalValue(
		self.teamNumber == kTeam1Index,
		kMarineFontColor,
		kAlienFontColor
	)
    
    self.pingButton:SetColor(useColor)
    
    self.pingButton:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.pingButton:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.pingButton:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
    
    local techMapScript = ClientUI.GetScript("mvm/GUITechMap")
    if techMapScript then
   
        local mapActive = techMapScript.background:GetIsVisible() 
        useColor.a = mapActive and 1 or 0.7
        self.techMapButton:SetColor(useColor)
        
    end    
    
end

function GUIMinimapButtons:ContainsPoint(pointX, pointY)
    return GUIItemContainsPoint(self.pingButton, pointX, pointY) or GUIItemContainsPoint(self.techMapButton, pointX, pointY)
end

function GUIMinimapButtons:SendKeyEvent(key, down)

    local mouseX, mouseY = Client.GetCursorPosScreen()
    
    if key == InputKey.MouseButton0 and CommanderUI_GetUIClickable() then
    
        if GUIItemContainsPoint(self.pingButton, mouseX, mouseY) then
        
            SetCommanderPingEnabled(true)
            return true
            
        elseif GUIItemContainsPoint(self.techMapButton, mouseX, mouseY) then
        
            local techMapScript = ClientUI.GetScript("mvm/GUITechMap")
            if techMapScript and not down then
                
                local showMap = not techMapScript.background:GetIsVisible()
                techMapScript:ShowTechMap(showMap)
                
            end
            
            return true
            
        end
        
    elseif key == InputKey.Escape or (GetIsBinding(key, "ShowTechMap") and not down) then
    
        local showingMap = false 
        local techMapScript = ClientUI.GetScript("mvm/GUITechMap")
        if techMapScript and techMapScript.background:GetIsVisible() then
        
            techMapScript:ShowTechMap(false)
            return true
            
        elseif GetCommanderPingEnabled() then
        
            SetCommanderPingEnabled(false)
            return true
            
        end
    
    end
    
end