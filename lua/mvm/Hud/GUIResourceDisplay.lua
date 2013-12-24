
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIResourceDisplay.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages displaying resources and number of resource towers.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/mvm/GUIColorGlobals.lua")

Script.Load("lua/GUIScript.lua")

class 'GUIResourceDisplay' (GUIScript)

//GUIResourceDisplay.kBackgroundTextureMarine = "ui/marine_commander_textures.dds"
GUIResourceDisplay.kBackgroundTextureMarine = "ui/marine_commander_resources_icons.dds"

GUIResourceDisplay.kBackgroundTextureCoords = { X1 = 0, Y1 = 0, X2 = 256, Y2 = 64 }
GUIResourceDisplay.kBackgroundWidth = GUIScale(128)
GUIResourceDisplay.kBackgroundHeight = GUIScale(64)
GUIResourceDisplay.kBackgroundYOffset = 0

GUIResourceDisplay.kPersonalResourceIcon = { Width = 0, Height = 0, X = 0, Y = 0, Coords = { X1 = 0, Y1 = 0, X2 = 64, Y2 = 64} }
GUIResourceDisplay.kPersonalResourceIcon.Width = GUIScale(48)
GUIResourceDisplay.kPersonalResourceIcon.Height = GUIScale(48)

GUIResourceDisplay.kTeamResourceIcon = { Width = 0, Height = 0, X = 0, Y = 0, Coords = { X1 = 64, Y1 = 0, X2 = 128, Y2 = 64} }
GUIResourceDisplay.kTeamResourceIcon.Width = GUIScale(48)
GUIResourceDisplay.kTeamResourceIcon.Height = GUIScale(48)

GUIResourceDisplay.kResourceTowerIcon = { Width = 0, Height = 0, X = 0, Y = 0, Coords = { X1 = 128, Y1 = 0, X2 = 192, Y2 = 64} }
GUIResourceDisplay.kResourceTowerIcon.Width = GUIScale(48)
GUIResourceDisplay.kResourceTowerIcon.Height = GUIScale(48)

GUIResourceDisplay.kWorkerIcon = { Width = 0, Height = 0, X = 0, Y = 0, Coords = { X1 = 192, Y1 = 0, X2 = 256, Y2 = 64} }
GUIResourceDisplay.kWorkerIcon.Width = GUIScale(48)
GUIResourceDisplay.kWorkerIcon.Height = GUIScale(48)

GUIResourceDisplay.kIconTextXOffset = 5
GUIResourceDisplay.kIconXOffset = 30

local kFontName = "fonts/AgencyFB_small.fnt"
local kFontScale = GUIScale(Vector(1,1,1))

local kColorWhite = Color(1, 1, 1, 1)
local kColorRed = Color(1, 0, 0, 1)


function GUIResourceDisplay:Initialize(settingsTable)

    self.textureName = GUIResourceDisplay.kBackgroundTextureMarine
    
    local playerTeam = PlayerUI_GetTeamNumber()
    local ui_baseColor = ConditionalValue(
		playerTeam == kTeam1Index,
		kGUI_Team1_BaseColor,
		kGUI_Team2_BaseColor
    )
    
    // Background, only used for positioning
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(GUIResourceDisplay.kBackgroundWidth, GUIResourceDisplay.kBackgroundHeight, 0))
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.background:SetPosition(Vector(-GUIResourceDisplay.kBackgroundWidth / 2, GUIResourceDisplay.kBackgroundYOffset, 0))
    self.background:SetColor(Color(1, 1, 1, 0))
    
    
    // Team display.
    self.teamIcon = GUIManager:CreateGraphicItem()
    self.teamIcon:SetSize(Vector(GUIResourceDisplay.kTeamResourceIcon.Width, GUIResourceDisplay.kTeamResourceIcon.Height, 0))
    self.teamIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
    local teamIconX = GUIResourceDisplay.kTeamResourceIcon.X + -GUIResourceDisplay.kTeamResourceIcon.Width - GUIResourceDisplay.kIconXOffset
    local teamIconY = GUIResourceDisplay.kTeamResourceIcon.Y + -GUIResourceDisplay.kPersonalResourceIcon.Height / 2
    self.teamIcon:SetPosition(Vector(teamIconX, teamIconY, 0))
    self.teamIcon:SetTexture(self.textureName)
    self.teamIcon:SetShader( "shaders/GUI_TeamThemed.surface_shader" )
    self.teamIcon:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.teamIcon:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.teamIcon:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
    GUISetTextureCoordinatesTable(self.teamIcon, GUIResourceDisplay.kTeamResourceIcon.Coords)
    self.background:AddChild(self.teamIcon)

    self.teamText = GUIManager:CreateTextItem()
    self.teamText:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.teamText:SetTextAlignmentX(GUIItem.Align_Min)
    self.teamText:SetTextAlignmentY(GUIItem.Align_Center)
    self.teamText:SetPosition(Vector(GUIResourceDisplay.kIconTextXOffset, 0, 0))
    self.teamText:SetColor( Color(1, 1, 1, 1) )	//?????
    self.teamText:SetFontName(kFontName)
    self.teamText:SetScale(kFontScale)
    self.teamIcon:AddChild(self.teamText)
    
    // Tower display.
    self.towerIcon = GUIManager:CreateGraphicItem()
    self.towerIcon:SetSize(Vector(GUIResourceDisplay.kResourceTowerIcon.Width, GUIResourceDisplay.kResourceTowerIcon.Height, 0))
    self.towerIcon:SetAnchor(GUIItem.Middle, GUIItem.Center)
    local towerIconX = GUIResourceDisplay.kResourceTowerIcon.X + -GUIResourceDisplay.kResourceTowerIcon.Width
    local towerIconY = GUIResourceDisplay.kResourceTowerIcon.Y + -GUIResourceDisplay.kResourceTowerIcon.Height / 2
    self.towerIcon:SetPosition(Vector(towerIconX, towerIconY, 0))
    self.towerIcon:SetTexture(self.textureName)
    self.towerIcon:SetShader( "shaders/GUI_TeamThemed.surface_shader" )
    self.towerIcon:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.towerIcon:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.towerIcon:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
    GUISetTextureCoordinatesTable(self.towerIcon, GUIResourceDisplay.kResourceTowerIcon.Coords)
    self.background:AddChild(self.towerIcon)

    self.towerText = GUIManager:CreateTextItem()
    self.towerText:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.towerText:SetTextAlignmentX(GUIItem.Align_Min)
    self.towerText:SetTextAlignmentY(GUIItem.Align_Center)
    self.towerText:SetPosition(Vector(GUIResourceDisplay.kIconTextXOffset, 0, 0))
    self.towerText:SetColor(Color(1, 1, 1, 1))	//??????
    self.towerText:SetFontName(kFontName)
    self.towerText:SetScale(kFontScale)
    self.towerIcon:AddChild(self.towerText)
    
    // worker display.
    self.workerIcon = GUIManager:CreateGraphicItem()
    self.workerIcon:SetSize(Vector(GUIResourceDisplay.kResourceTowerIcon.Width, GUIResourceDisplay.kResourceTowerIcon.Height, 0))
    self.workerIcon:SetAnchor(GUIItem.Right, GUIItem.Center)
    local workerIconX = GUIResourceDisplay.kWorkerIcon.X + -GUIResourceDisplay.kWorkerIcon.Width + GUIResourceDisplay.kIconXOffset
    local workerIconY = GUIResourceDisplay.kWorkerIcon.Y + -GUIResourceDisplay.kWorkerIcon.Height / 2
    self.workerIcon:SetPosition(Vector(workerIconX, workerIconY, 0))
    self.workerIcon:SetTexture(self.textureName)
    self.workerIcon:SetShader( "shaders/GUI_TeamThemed.surface_shader" )
    self.workerIcon:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.workerIcon:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.workerIcon:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
    GUISetTextureCoordinatesTable(self.workerIcon, GUIResourceDisplay.kWorkerIcon.Coords)
    self.background:AddChild(self.workerIcon)

    self.workerText = GUIManager:CreateTextItem()
    self.workerText:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.workerText:SetTextAlignmentX(GUIItem.Align_Min)
    self.workerText:SetTextAlignmentY(GUIItem.Align_Center)
    self.workerText:SetPosition(Vector(GUIResourceDisplay.kIconTextXOffset, 0, 0))
    self.workerText:SetColor(Color(1, 1, 1, 1))		//?????
    self.workerText:SetFontName(kFontName)
    self.workerText:SetScale(kFontScale)
    self.workerIcon:AddChild(self.workerText)
    
end

function GUIResourceDisplay:Uninitialize()
    
    if self.background then
        GUI.DestroyItem(self.background)
    end
    self.background = nil
    
end

local kWhite = Color(1,1,1,1)
local kRed = Color(1,0,0,1)


function GUIResourceDisplay:UpdateTeamColors()

	local playerTeam = PlayerUI_GetTeamNumber()
    local ui_baseColor = ConditionalValue(
		playerTeam == kTeam1Index,
		kGUI_Team1_BaseColor,
		kGUI_Team2_BaseColor
    )
    
    self.teamIcon:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.teamIcon:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.teamIcon:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
    
    self.towerIcon:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.towerIcon:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.towerIcon:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
    
    self.workerIcon:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.workerIcon:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.workerIcon:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )

end


function GUIResourceDisplay:Update(deltaTime)

    PROFILE("GUIResourceDisplay:Update")
    
    self:UpdateTeamColors()
    
    local currentTeamRes = PlayerUI_GetTeamResources()
    if not self.displayedTeamRes then
        self.displayedTeamRes = currentTeamRes
    else

        if self.displayedTeamRes > currentTeamRes then
            self.displayedTeamRes = currentTeamRes
        else
            self.displayedTeamRes = Slerp(self.displayedTeamRes, currentTeamRes, deltaTime * 40)
        end    
            
    end

    self.teamText:SetText(ToString(math.round(self.displayedTeamRes)))
    
    local numHarvesters = CommanderUI_GetTeamHarvesterCount()
    self.towerText:SetText(ToString(numHarvesters))
    
    local supplyUsed = MvM_GetSupplyUsedByTeam(Client.GetLocalPlayer():GetTeamNumber())
    local maxSupply = MvM_GetMaxSupplyForTeam(Client.GetLocalPlayer():GetTeamNumber())
    
    local useColor = ConditionalValue( supplyUsed < maxSupply, kWhite, kRed)
    
    self.workerText:SetText(string.format("%d / %d", supplyUsed, maxSupply))
    self.workerText:SetColor(useColor)
    self.workerIcon:SetColor(useColor)
    
end
