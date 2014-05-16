// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIMarineBuyMenu.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// Manages the marine buy/purchase menu.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")
Script.Load("lua/mvm/GUIColorGlobals.lua")


class 'GUIMarineBuyMenu' (GUIAnimatedScript)

GUIMarineBuyMenu.kBuyMenuTexture = "ui/marine_buy_textures.dds"
GUIMarineBuyMenu.kBuyHUDTexture = "ui/marine_buy_icons.dds"
GUIMarineBuyMenu.kRepeatingBackground = "ui/menu/grid.dds"
GUIMarineBuyMenu.kContentBgTexture = "ui/menu/repeating_bg.dds"
GUIMarineBuyMenu.kContentBgBackTexture = "ui/menu/repeating_bg_black.dds"
GUIMarineBuyMenu.kResourceIconTexture = "ui/pres_icon_big.dds"
GUIMarineBuyMenu.kBigIconTexture = "ui/marine_buy_bigicons.dds"
GUIMarineBuyMenu.kButtonTexture = "ui/marine_buymenu_button.dds"
GUIMarineBuyMenu.kMenuSelectionTexture = "ui/marine_buymenu_selector.dds"
GUIMarineBuyMenu.kScanLineTexture = "ui/menu/scanLine_big.dds"
GUIMarineBuyMenu.kArrowTexture = "ui/menu/arrow_horiz.dds"

GUIMarineBuyMenu.kFont = "fonts/AgencyFB_small.fnt"
GUIMarineBuyMenu.kFont2 = "fonts/AgencyFB_small.fnt"

GUIMarineBuyMenu.kDescriptionFontName = "fonts/AgencyFB_medium.fnt"	//small
GUIMarineBuyMenu.kDescriptionFontSize = GUIScale(10)	//20

GUIMarineBuyMenu.kScanLineHeight = GUIScale(256)
GUIMarineBuyMenu.kScanLineAnimDuration = 5

GUIMarineBuyMenu.kArrowWidth = GUIScale(32)
GUIMarineBuyMenu.kArrowHeight = GUIScale(32)
GUIMarineBuyMenu.kArrowTexCoords = { 1, 1, 0, 0 }

// Big Item Icons
GUIMarineBuyMenu.kBigIconSize = GUIScale( Vector(320, 256, 0) )
GUIMarineBuyMenu.kBigIconOffset = GUIScale(20)

local kEquippedMouseoverColor = Color(1, 1, 1, 1)
local kEquippedColor = Color(0.5, 0.5, 0.5, 0.5)

local gBigIconIndex = nil
local bigIconWidth = 400
local bigIconHeight = 300
local function GetBigIconPixelCoords(techId, researched)

    if not gBigIconIndex then
    
        gBigIconIndex = {}
        gBigIconIndex[kTechId.Axe] = 0
        gBigIconIndex[kTechId.Pistol] = 1
        gBigIconIndex[kTechId.Rifle] = 2
        gBigIconIndex[kTechId.Shotgun] = 3
        gBigIconIndex[kTechId.GrenadeLauncher] = 4
        gBigIconIndex[kTechId.Flamethrower] = 5
        gBigIconIndex[kTechId.Jetpack] = 6
        gBigIconIndex[kTechId.Exosuit] = 7
        gBigIconIndex[kTechId.Welder] = 8
        gBigIconIndex[kTechId.DemoMines] = 9
        gBigIconIndex[kTechId.DualMinigunExosuit] = 10
        gBigIconIndex[kTechId.UpgradeToDualMinigun] = 10
        gBigIconIndex[kTechId.ClawRailgunExosuit] = 11
        gBigIconIndex[kTechId.DualRailgunExosuit] = 11
        gBigIconIndex[kTechId.UpgradeToDualRailgun] = 11
        
        gBigIconIndex[kTechId.ClusterGrenade] = 12
        gBigIconIndex[kTechId.GasGrenade] = 13
        gBigIconIndex[kTechId.PulseGrenade] = 14
        
    
    end
    
    local index = gBigIconIndex[techId]
    if not index then
        index = 0
    end
    
    local x1 = 0
    local x2 = bigIconWidth
    
    if not researched then
    
        x1 = bigIconWidth
        x2 = bigIconWidth * 2
        
    end
    
    local y1 = index * bigIconHeight
    local y2 = (index + 1) * bigIconHeight
    
    return x1, y1, x2, y2

end

// Small Item Icons
local kSmallIconScale = 0.9
GUIMarineBuyMenu.kSmallIconSize = GUIScale( Vector(100, 50, 0) )
GUIMarineBuyMenu.kMenuIconSize = GUIScale( Vector(190, 80, 0) ) * kSmallIconScale
GUIMarineBuyMenu.kSelectorSize = GUIScale( Vector(215, 110, 0) ) * kSmallIconScale
GUIMarineBuyMenu.kIconTopOffset = 10
GUIMarineBuyMenu.kItemIconYOffset = {}

GUIMarineBuyMenu.kEquippedIconTopOffset = 58

local smallIconHeight = 64
local smallIconWidth = 128
local gSmallIconIndex = nil
local function GetSmallIconPixelCoordinates(itemTechId)

    if not gSmallIconIndex then
    
        gSmallIconIndex = {}
        gSmallIconIndex[kTechId.Axe] = 4
        gSmallIconIndex[kTechId.Pistol] = 3
        gSmallIconIndex[kTechId.Rifle] = 1
        gSmallIconIndex[kTechId.Shotgun] = 5
        gSmallIconIndex[kTechId.GrenadeLauncher] = 8
        gSmallIconIndex[kTechId.Flamethrower] = 6
        gSmallIconIndex[kTechId.Jetpack] = 24
        gSmallIconIndex[kTechId.Exosuit] = 26
        gSmallIconIndex[kTechId.Welder] = 10
        gSmallIconIndex[kTechId.DemoMines] = 21
        gSmallIconIndex[kTechId.DualMinigunExosuit] = 26
        gSmallIconIndex[kTechId.UpgradeToDualMinigun] = 26
        gSmallIconIndex[kTechId.ClawRailgunExosuit] = 38
        gSmallIconIndex[kTechId.DualRailgunExosuit] = 38
        gSmallIconIndex[kTechId.UpgradeToDualRailgun] = 38
        
        gSmallIconIndex[kTechId.ClusterGrenade] = 42
        gSmallIconIndex[kTechId.GasGrenade] = 43
        gSmallIconIndex[kTechId.PulseGrenade] = 44
    
    end
    
    local index = gSmallIconIndex[itemTechId]
    if not index then
        index = 0
    end
    
    local y1 = index * smallIconHeight
    local y2 = (index + 1) * smallIconHeight
    
    return 0, y1, smallIconWidth, y2

end
                            
GUIMarineBuyMenu.kTextColor = Color(kMarineFontColor)

GUIMarineBuyMenu.kMenuWidth = GUIScale(190)
GUIMarineBuyMenu.kPadding = GUIScale(8)

GUIMarineBuyMenu.kEquippedWidth = GUIScale(128)

GUIMarineBuyMenu.kBackgroundWidth = GUIScale(600)
GUIMarineBuyMenu.kBackgroundHeight = GUIScale(710)
// We want the background graphic to look centered around the circle even though there is the part coming off to the right.
GUIMarineBuyMenu.kBackgroundXOffset = GUIScale(0)

GUIMarineBuyMenu.kPlayersTextSize = GUIScale(24)
GUIMarineBuyMenu.kResearchTextSize = GUIScale(24)

GUIMarineBuyMenu.kResourceDisplayHeight = GUIScale(64)

GUIMarineBuyMenu.kResourceIconWidth = GUIScale(32)
GUIMarineBuyMenu.kResourceIconHeight = GUIScale(32)

GUIMarineBuyMenu.kMouseOverInfoTextSize = GUIScale(20)
GUIMarineBuyMenu.kMouseOverInfoOffset = Vector(GUIScale(-30), GUIScale(-20), 0)
GUIMarineBuyMenu.kMouseOverInfoResIconOffset = Vector(GUIScale(-40), GUIScale(-60), 0)

GUIMarineBuyMenu.kDisabledColor = Color(0.5, 0.5, 0.5, 0.5)
GUIMarineBuyMenu.kCannotBuyColor = Color(1, 0, 0, 0.5)
GUIMarineBuyMenu.kEnabledColor = Color(1, 1, 1, 1)

GUIMarineBuyMenu.kCloseButtonColor = Color(1, 1, 0, 1)

GUIMarineBuyMenu.kButtonWidth = GUIScale(160)
GUIMarineBuyMenu.kButtonHeight = GUIScale(64)

GUIMarineBuyMenu.kItemNameOffsetX = GUIScale(28)
GUIMarineBuyMenu.kItemNameOffsetY = GUIScale(256)

GUIMarineBuyMenu.kItemDescriptionOffsetY = GUIScale(300)
GUIMarineBuyMenu.kItemDescriptionSize = GUIScale( Vector(450, 180, 0) )

function GUIMarineBuyMenu:SetHostStructure(hostStructure)

    self.hostStructure = hostStructure
    self:_InitializeItemButtons()
    
end

function GUIMarineBuyMenu:OnClose()

    // Check if GUIMarineBuyMenu is what is causing itself to close.
    if not self.closingMenu then
        // Play the close sound since we didn't trigger the close.
        MarineBuy_OnClose()
    end

end

function GUIMarineBuyMenu:Initialize()

    GUIAnimatedScript.Initialize(self)

    self.mouseOverStates = { }
    self.equipped = { }
    
    self.selectedItem = kTechId.None
    
    self.teamNumber = 0
    
    self:_InitializeBackground()
    self:_InitializeContent()
    self:_InitializeResourceDisplay()
    self:_InitializeCloseButton()
    self:_InitializeEquipped()

	//self:UpdateTeamColors()
	
    // note: items buttons get initialized through SetHostStructure()
    MarineBuy_OnOpen()
    
end

/**
 * Checks if the mouse is over the passed in GUIItem and plays a sound if it has just moved over.
 */
local function GetIsMouseOver(self, overItem)

    local mouseOver = GUIItemContainsPoint(overItem, Client.GetCursorPosScreen())
    if mouseOver and not self.mouseOverStates[overItem] then
        MarineBuy_OnMouseOver()
    end
    self.mouseOverStates[overItem] = mouseOver
    return mouseOver
    
end

local function UpdateEquipped(self, deltaTime)

    self.hoverItem = nil
    for i = 1, #self.equipped do
    
        local equipped = self.equipped[i]
        if GetIsMouseOver(self, equipped.Graphic) then
			
            self.hoverItem = equipped.TechId
            equipped.Graphic:SetColor( kGUI_NameTagFontColors[ self.teamNumber ] )
            
        else
			
            equipped.Graphic:SetColor( kGUI_HealthBarColors[ self.teamNumber ] )
            
        end
        
    end
    
end


function GUIMarineBuyMenu:Update(deltaTime)

    GUIAnimatedScript.Update(self, deltaTime)

	self.teamNumber = PlayerUI_GetTeamNumber()
	
	self:UpdateTeamColors()
	
    UpdateEquipped(self, deltaTime)
    self:_UpdateItemButtons(deltaTime)
    self:_UpdateContent(deltaTime)
    self:_UpdateResourceDisplay(deltaTime)
    self:_UpdateCloseButton(deltaTime)
    
end


function GUIMarineBuyMenu:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)

    self:_UninitializeItemButtons()
    self:_UninitializeBackground()
    self:_UninitializeContent()
    self:_UninitializeResourceDisplay()
    self:_UninitializeCloseButton()

end


local function MoveDownAnim(script, item)

    item:SetPosition( Vector(0, -GUIMarineBuyMenu.kScanLineHeight, 0) )
    item:SetPosition( 
		Vector(0, Client.GetScreenHeight() + GUIMarineBuyMenu.kScanLineHeight, 0), 
		GUIMarineBuyMenu.kScanLineAnimDuration, 
		"MARINEBUY_SCANLINE", 
		AnimateLinear, MoveDownAnim
	)

end


function GUIMarineBuyMenu:_InitializeBackground()

    // This invisible background is used for centering only.
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.background:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.background:SetColor( Color(0.05, 0.05, 0.1, 0.7) )
    self.background:SetShader("shaders/GUI_TeamThemed.surface_shader")
    self.background:SetLayer(kGUILayerPlayerHUDForeground4)
    
    self.repeatingBGTexture = GUIManager:CreateGraphicItem()
    self.repeatingBGTexture:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.repeatingBGTexture:SetTexture(GUIMarineBuyMenu.kRepeatingBackground)
    self.repeatingBGTexture:SetTexturePixelCoordinates(0, 0, Client.GetScreenWidth(), Client.GetScreenHeight())
    self.repeatingBGTexture:SetShader("shaders/GUI_TeamThemed.surface_shader")
    self.background:AddChild(self.repeatingBGTexture)
    
    self.content = GUIManager:CreateGraphicItem()
    self.content:SetSize(Vector(GUIMarineBuyMenu.kBackgroundWidth, GUIMarineBuyMenu.kBackgroundHeight, 0))
    self.content:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.content:SetPosition(Vector((-GUIMarineBuyMenu.kBackgroundWidth / 2) + GUIMarineBuyMenu.kBackgroundXOffset, -GUIMarineBuyMenu.kBackgroundHeight / 2, 0))
    self.content:SetTexture( GUIMarineBuyMenu.kContentBgTexture )
    self.content:SetTexturePixelCoordinates(0, 0, GUIMarineBuyMenu.kBackgroundWidth, GUIMarineBuyMenu.kBackgroundHeight)
    self.content:SetColor( kGUI_NameTagFontColors[self.teamNumber] )
    self.background:AddChild(self.content)
    
    self.scanLine = self:CreateAnimatedGraphicItem()
    self.scanLine:SetSize( Vector( Client.GetScreenWidth(), GUIMarineBuyMenu.kScanLineHeight, 0) )
    self.scanLine:SetTexture(GUIMarineBuyMenu.kScanLineTexture)
    self.scanLine:SetShader("shaders/GUI_TeamThemed.surface_shader")
    self.scanLine:SetLayer(kGUILayerPlayerHUDForeground4)
    self.scanLine:SetIsScaling(false)
    
    self.scanLine:SetPosition( Vector(0, -GUIMarineBuyMenu.kScanLineHeight, 0) )
    self.scanLine:SetPosition( 
		Vector(0, Client.GetScreenHeight() + GUIMarineBuyMenu.kScanLineHeight, 0), 
		GUIMarineBuyMenu.kScanLineAnimDuration, 
		"MARINEBUY_SCANLINE", 
		AnimateLinear, MoveDownAnim
	)

end

function GUIMarineBuyMenu:_UninitializeBackground()

    GUI.DestroyItem(self.background)
    self.background = nil
    
    self.content = nil
    
end

function GUIMarineBuyMenu:_InitializeEquipped()

    self.equippedBg = GetGUIManager():CreateGraphicItem()
    self.equippedBg:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.equippedBg:SetPosition(Vector( GUIMarineBuyMenu.kPadding, -GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.equippedBg:SetSize(Vector(GUIMarineBuyMenu.kEquippedWidth, GUIMarineBuyMenu.kBackgroundHeight + GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.equippedBg:SetColor(Color(0,0,0,0))
    self.content:AddChild(self.equippedBg)
    
    self.equippedTitle = GetGUIManager():CreateTextItem()
    self.equippedTitle:SetFontName(GUIMarineBuyMenu.kFont)
    self.equippedTitle:SetFontIsBold(true)
    self.equippedTitle:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.equippedTitle:SetTextAlignmentX(GUIItem.Align_Center)
    self.equippedTitle:SetTextAlignmentY(GUIItem.Align_Center)
    self.equippedTitle:SetColor( kGUI_NameTagFontColors[self.teamNumber] )
    self.equippedTitle:SetPosition(Vector(0, GUIMarineBuyMenu.kResourceDisplayHeight / 2, 0))
    self.equippedTitle:SetText( Locale.ResolveString("EQUIPPED") )
    self.equippedBg:AddChild(self.equippedTitle)
    
    self.equipped = { }
    
    local equippedTechIds = MarineBuy_GetEquipped()
    local selectorPosX = -GUIMarineBuyMenu.kSelectorSize.x + GUIMarineBuyMenu.kPadding
    
    for k, itemTechId in ipairs(equippedTechIds) do
    
        local graphicItem = GUIManager:CreateGraphicItem()
        graphicItem:SetSize(GUIMarineBuyMenu.kSmallIconSize)
        graphicItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
        graphicItem:SetPosition(
			Vector(-GUIMarineBuyMenu.kSmallIconSize.x / 2, 
				GUIMarineBuyMenu.kEquippedIconTopOffset + (GUIMarineBuyMenu.kSmallIconSize.y) * k - GUIMarineBuyMenu.kSmallIconSize.y, 
				0
			)
		)
        graphicItem:SetTexture(kInventoryIconsTexture)
        graphicItem:SetShader("shaders/GUI_TeamThemed.surface_shader")
        graphicItem:SetTexturePixelCoordinates(GetSmallIconPixelCoordinates(itemTechId))
        
        self.equippedBg:AddChild(graphicItem)
        table.insert(self.equipped, { Graphic = graphicItem, TechId = itemTechId } )
    
    end
    
end

function GUIMarineBuyMenu:_InitializeItemButtons()
    
    self.menu = GetGUIManager():CreateGraphicItem()
    self.menu:SetPosition(Vector( -GUIMarineBuyMenu.kMenuWidth - GUIMarineBuyMenu.kPadding, 0, 0))
    self.menu:SetTexture(GUIMarineBuyMenu.kContentBgTexture)
    self.menu:SetShader("shaders/GUI_TeamThemed.surface_shader")
    self.menu:SetSize(Vector(GUIMarineBuyMenu.kMenuWidth, GUIMarineBuyMenu.kBackgroundHeight, 0))
    self.menu:SetTexturePixelCoordinates(0, 0, GUIMarineBuyMenu.kMenuWidth, GUIMarineBuyMenu.kBackgroundHeight)
    self.content:AddChild(self.menu)
    
    self.menuHeader = GetGUIManager():CreateGraphicItem()
    self.menuHeader:SetSize(Vector(GUIMarineBuyMenu.kMenuWidth, GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.menuHeader:SetPosition(Vector(0, -GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.menuHeader:SetTexture(GUIMarineBuyMenu.kContentBgBackTexture)
    self.menuHeader:SetShader("shaders/GUI_TeamThemed.surface_shader")
    self.menuHeader:SetTexturePixelCoordinates(0, 0, GUIMarineBuyMenu.kMenuWidth, GUIMarineBuyMenu.kResourceDisplayHeight)
    self.menu:AddChild(self.menuHeader) 
    
    self.menuHeaderTitle = GetGUIManager():CreateTextItem()
    self.menuHeaderTitle:SetFontName(GUIMarineBuyMenu.kFont)
    self.menuHeaderTitle:SetFontIsBold(true)
    self.menuHeaderTitle:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.menuHeaderTitle:SetTextAlignmentX(GUIItem.Align_Center)
    self.menuHeaderTitle:SetTextAlignmentY(GUIItem.Align_Center)
    self.menuHeaderTitle:SetColor( kGUI_HealthBarColors[self.teamNumber] )
    self.menuHeaderTitle:SetText(Locale.ResolveString("BUY"))
    self.menuHeader:AddChild(self.menuHeaderTitle)
    
    self.itemButtons = { }
    
    local itemTechIdList = self.hostStructure:GetItemList(Client.GetLocalPlayer())
    local selectorPosX = -GUIMarineBuyMenu.kSelectorSize.x + GUIMarineBuyMenu.kPadding
    local fontScaleVector = Vector(0.8, 0.8, 0)
    
    for k, itemTechId in ipairs(itemTechIdList) do
    
        local graphicItem = GUIManager:CreateGraphicItem()
        graphicItem:SetSize(GUIMarineBuyMenu.kMenuIconSize)
        graphicItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
        graphicItem:SetPosition(
			Vector(
				-GUIMarineBuyMenu.kMenuIconSize.x / 2, 
				GUIMarineBuyMenu.kIconTopOffset + (GUIMarineBuyMenu.kMenuIconSize.y) * k - GUIMarineBuyMenu.kMenuIconSize.y, 
				0
			)
		)
        graphicItem:SetTexture(kInventoryIconsTexture)
        graphicItem:SetShader("shaders/GUI_TeamThemed.surface_shader")
        graphicItem:SetTexturePixelCoordinates(GetSmallIconPixelCoordinates(itemTechId))
        
        local graphicItemActive = GUIManager:CreateGraphicItem()
        graphicItemActive:SetSize(GUIMarineBuyMenu.kSelectorSize)
        
        graphicItemActive:SetPosition(Vector(selectorPosX, -GUIMarineBuyMenu.kSelectorSize.y / 2, 0))
        graphicItemActive:SetAnchor(GUIItem.Right, GUIItem.Center)
        graphicItemActive:SetTexture( GUIMarineBuyMenu.kMenuSelectionTexture )
        graphicItemActive:SetShader("shaders/GUI_TeamThemed.surface_shader")
        graphicItemActive:SetIsVisible(false)
        
        graphicItem:AddChild(graphicItemActive)
        
        local costIcon = GUIManager:CreateGraphicItem()
        costIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
        costIcon:SetAnchor(GUIItem.Right, GUIItem.Bottom)
        costIcon:SetPosition(Vector(-32, -GUIMarineBuyMenu.kResourceIconHeight * 0.5, 0))
        costIcon:SetTexture( GUIMarineBuyMenu.kResourceIconTexture )
        costIcon:SetColor( kGUI_HealthBarColors[self.teamNumber] )
        
        local selectedArrow = GUIManager:CreateGraphicItem()
        selectedArrow:SetSize(Vector(GUIMarineBuyMenu.kArrowWidth, GUIMarineBuyMenu.kArrowHeight, 0))
        selectedArrow:SetAnchor(GUIItem.Left, GUIItem.Center)
        selectedArrow:SetPosition(Vector(-GUIMarineBuyMenu.kArrowWidth - GUIMarineBuyMenu.kPadding, -GUIMarineBuyMenu.kArrowHeight * 0.5, 0))
        selectedArrow:SetTexture(GUIMarineBuyMenu.kArrowTexture)
        selectedArrow:SetColor( kGUI_NameTagFontColors[self.teamNumber] )
        selectedArrow:SetTextureCoordinates(unpack(GUIMarineBuyMenu.kArrowTexCoords))
        selectedArrow:SetIsVisible(false)
        
        graphicItem:AddChild(selectedArrow) 
        
        local itemCost = GUIManager:CreateTextItem()
        itemCost:SetFontName(GUIMarineBuyMenu.kFont)
        itemCost:SetFontIsBold(true)
        itemCost:SetAnchor(GUIItem.Right, GUIItem.Center)
        itemCost:SetPosition(Vector(0, 0, 0))
        itemCost:SetTextAlignmentX(GUIItem.Align_Min)
        itemCost:SetTextAlignmentY(GUIItem.Align_Center)
        itemCost:SetScale( fontScaleVector )
        itemCost:SetColor( kGUI_NameTagFontColors[self.teamNumber] )
        itemCost:SetText(ToString(LookupTechData(itemTechId, kTechDataCostKey, 0)))
        
        costIcon:AddChild(itemCost)  
        
        graphicItem:AddChild(costIcon)  
        
        self.menu:AddChild(graphicItem)
        table.insert(
			self.itemButtons, { 
				Button = graphicItem, 
				Highlight = graphicItemActive, 
				TechId = itemTechId, 
				Cost = itemCost, 
				ResourceIcon = costIcon, 
				Arrow = selectedArrow 
			} 
		)
		
    end
    
    // to prevent wrong display before the first update
    self:_UpdateItemButtons(0)

end


local gResearchToWeaponIds = nil

local function GetItemTechId(researchTechId)

    if not gResearchToWeaponIds then
		
        gResearchToWeaponIds = { }
        gResearchToWeaponIds[kTechId.ShotgunTech] = kTechId.Shotgun
        gResearchToWeaponIds[kTechId.FlamethrowerTech] = kTechId.Flamethrower	//AdvancedWeaponry
        gResearchToWeaponIds[kTechId.GrenadeLauncherTech] = kTechId.GrenadeLauncher
        gResearchToWeaponIds[kTechId.WelderTech] = kTechId.Welder
        gResearchToWeaponIds[kTechId.MinesTech] = kTechId.DemoMines
        gResearchToWeaponIds[kTechId.JetpackTech] = kTechId.Jetpack
        gResearchToWeaponIds[kTechId.ExosuitTech] = kTechId.Exosuit
        gResearchToWeaponIds[kTechId.DualMinigunTech] = kTechId.DualMinigunExosuit
        gResearchToWeaponIds[kTechId.ClawRailgunTech] = kTechId.ClawRailgunExosuit
        gResearchToWeaponIds[kTechId.DualRailgunTech] = kTechId.DualRailgunExosuit
        
    end
    
    return gResearchToWeaponIds[researchTechId]
    
end

function GUIMarineBuyMenu:_UpdateItemButtons(deltaTime)
	
	local equippedTechIds = MarineBuy_GetEquipment()
	
    for i, item in ipairs(self.itemButtons) do
		
		local playerHasEquipment = equippedTechIds[item.TechId]
		
        if GetIsMouseOver(self, item.Button) then
        
            item.Highlight:SetIsVisible(true)
            self.hoverItem = item.TechId
            
        else
            item.Highlight:SetIsVisible(false)
        end
        
        local useColor = kGUI_NameTagFontColors[self.teamNumber]
        
        if playerHasEquipment then
			useColor = kGUI_Grey
		elseif not MarineBuy_IsResearched(item.TechId) then
			useColor = kGUI_RedGrey
        elseif PlayerUI_GetPlayerResources() < MarineBuy_GetCosts(item.TechId) then
           useColor = kGUI_Red
        // set normal visible
        else

            local newResearchedId = GetItemTechId( PlayerUI_GetRecentPurchaseable() )
            local newlyResearched = false 
            if type(newResearchedId) == "table" then
                newlyResearched = table.contains(newResearchedId, item.TechId)
            else
                newlyResearched = newResearchedId == item.TechId
            end
            
            if newlyResearched then
				
                local anim = math.cos(Shared.GetTime() * 9) * 0.4 + 0.6
                useColor = Color(anim, anim, anim, 1)
                
            end
           
        end
        
        item.Button:SetColor(useColor)
        item.Highlight:SetColor( Color(1,1,1,1) )
        item.Cost:SetColor(useColor)
        item.ResourceIcon:SetColor(useColor)
        item.Arrow:SetIsVisible(self.selectedItem == item.TechId)
        
    end

end

function GUIMarineBuyMenu:_UninitializeItemButtons()

    for i, item in ipairs(self.itemButtons) do
        GUI.DestroyItem(item.Button)
    end
    self.itemButtons = nil

end

function GUIMarineBuyMenu:_InitializeContent()

    self.itemName = GUIManager:CreateTextItem()
    self.itemName:SetFontName(GUIMarineBuyMenu.kFont)
    self.itemName:SetFontIsBold(true)
    self.itemName:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.itemName:SetPosition(Vector(GUIMarineBuyMenu.kItemNameOffsetX , GUIMarineBuyMenu.kItemNameOffsetY , 0))
    self.itemName:SetTextAlignmentX(GUIItem.Align_Min)
    self.itemName:SetTextAlignmentY(GUIItem.Align_Min)
    self.itemName:SetColor( kGUI_NameTagFontColors[self.teamNumber] )
    self.itemName:SetText("No Selection")
    
    self.content:AddChild(self.itemName)
    
    self.portrait = GetGUIManager():CreateGraphicItem()
    self.portrait:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.portrait:SetPosition(Vector(-GUIMarineBuyMenu.kBigIconSize.x/2, GUIMarineBuyMenu.kBigIconOffset, 0))
    self.portrait:SetSize(GUIMarineBuyMenu.kBigIconSize)
    self.portrait:SetTexture(GUIMarineBuyMenu.kBigIconTexture)	//Don't colorize weapon/item image
    self.portrait:SetTexturePixelCoordinates(GetBigIconPixelCoords(kTechId.Axe))
    self.portrait:SetIsVisible(false)
    self.content:AddChild(self.portrait)
    
    self.itemDescription = GetGUIManager():CreateTextItem()
    self.itemDescription:SetFontName(GUIMarineBuyMenu.kDescriptionFontName)
    self.itemDescription:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.itemDescription:SetPosition(Vector(-GUIMarineBuyMenu.kItemDescriptionSize.x / 2, GUIMarineBuyMenu.kItemDescriptionOffsetY, 0))
    self.itemDescription:SetTextAlignmentX(GUIItem.Align_Min)
    self.itemDescription:SetTextAlignmentY(GUIItem.Align_Min)
    self.itemDescription:SetColor( kGUI_NameTagFontColors[self.teamNumber] )
    self.itemDescription:SetTextClipped(true, GUIMarineBuyMenu.kItemDescriptionSize.x - 2* GUIMarineBuyMenu.kPadding, GUIMarineBuyMenu.kItemDescriptionSize.y - GUIMarineBuyMenu.kPadding)
    
    self.content:AddChild(self.itemDescription)
    
end


function GUIMarineBuyMenu:UpdateTeamColors()

	local ui_baseColor = ConditionalValue(
		PlayerUI_GetTeamNumber() == kTeam1Index,
		kTeam1_BaseColor,
		kTeam2_BaseColor
	)
	
	self.background:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.background:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.background:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
    
    self.repeatingBGTexture:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.repeatingBGTexture:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.repeatingBGTexture:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
    
    self.scanLine:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.scanLine:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.scanLine:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
	
	self.menu:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.menu:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.menu:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
	
	self.menuHeader:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.menuHeader:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.menuHeader:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
	
	self.resourceDisplayBackground:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.resourceDisplayBackground:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.resourceDisplayBackground:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
	
	self.closeButton:SetFloatParameter( "teamBaseColorR", ui_baseColor.r )
    self.closeButton:SetFloatParameter( "teamBaseColorG", ui_baseColor.g )
    self.closeButton:SetFloatParameter( "teamBaseColorB", ui_baseColor.b )
	
	self.menuHeaderTitle:SetColor( kGUI_HealthBarColors[self.teamNumber] )
	self.itemName:SetColor( kGUI_NameTagFontColors[self.teamNumber] )
	self.closeButtonText:SetColor( kGUI_NameTagFontColors[self.teamNumber] )
	self.resourceDisplayIcon:SetColor( kGUI_HealthBarColors[self.teamNumber] )
	self.resourceDisplay:SetColor( kGUI_NameTagFontColors[self.teamNumber] )
	self.currentDescription:SetColor( kGUI_NameTagFontColors[self.teamNumber] )

end


function GUIMarineBuyMenu:_UpdateContent(deltaTime)

    local techId = self.hoverItem
    if not self.hoverItem then
        techId = self.selectedItem
    end
    
    if techId then
    
        local researched, researchProgress, researching = self:_GetResearchInfo(techId)
        
        local itemCost = MarineBuy_GetCosts(techId)
        local canAfford = PlayerUI_GetPlayerResources() >= itemCost
		
        local color = kGUI_NameTagFontColors[self.teamNumber]
        if not canAfford and researched then
            color = Color(1, 0, 0, 1)
			self.portrait:SetColor( color )
        elseif not researched then
            // Make it clear that we can't buy this
            color = Color(0.5, 0.5, 0.5, .6)
            self.portrait:SetColor( color )
		else
			self.portrait:SetColor( Color(1,1,1,1) )
        end
    
        self.itemName:SetColor(color)
        self.itemDescription:SetColor(color)

        self.itemName:SetText(MarineBuy_GetDisplayName(techId))
        self.portrait:SetTexturePixelCoordinates(GetBigIconPixelCoords(techId, researched))
        self.itemDescription:SetText(MarineBuy_GetWeaponDescription(techId))
        self.itemDescription:SetTextClipped(
			true, 
			GUIMarineBuyMenu.kItemDescriptionSize.x - 2 * GUIMarineBuyMenu.kPadding, 
			GUIMarineBuyMenu.kItemDescriptionSize.y - GUIMarineBuyMenu.kPadding
		)
		
    end
    
    local contentVisible = techId ~= nil and techId ~= kTechId.None
    
    self.portrait:SetIsVisible(contentVisible)
    self.itemName:SetIsVisible(contentVisible)
    self.itemDescription:SetIsVisible(contentVisible)
    
end

function GUIMarineBuyMenu:_UninitializeContent()

    GUI.DestroyItem(self.itemName)

end

function GUIMarineBuyMenu:_InitializeResourceDisplay()
    
    self.resourceDisplayBackground = GUIManager:CreateGraphicItem()
    self.resourceDisplayBackground:SetSize(Vector(GUIMarineBuyMenu.kBackgroundWidth, GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.resourceDisplayBackground:SetPosition(Vector(0, -GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.resourceDisplayBackground:SetTexture(GUIMarineBuyMenu.kContentBgBackTexture)
    self.resourceDisplayBackground:SetShader("shaders/GUI_TeamThemed.surface_shader")
    self.resourceDisplayBackground:SetTexturePixelCoordinates(0, 0, GUIMarineBuyMenu.kBackgroundWidth, GUIMarineBuyMenu.kResourceDisplayHeight)
    self.content:AddChild(self.resourceDisplayBackground)
    
    self.resourceDisplayIcon = GUIManager:CreateGraphicItem()
    self.resourceDisplayIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth, GUIMarineBuyMenu.kResourceIconHeight, 0))
    self.resourceDisplayIcon:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.resourceDisplayIcon:SetPosition(Vector(-GUIMarineBuyMenu.kResourceIconWidth * 2.2, -GUIMarineBuyMenu.kResourceIconHeight / 2, 0))
    self.resourceDisplayIcon:SetTexture(GUIMarineBuyMenu.kResourceIconTexture)
    self.resourceDisplayIcon:SetColor( kGUI_HealthBarColors[self.teamNumber] )
    self.resourceDisplayBackground:AddChild(self.resourceDisplayIcon)

    self.resourceDisplay = GUIManager:CreateTextItem()
    self.resourceDisplay:SetFontName(GUIMarineBuyMenu.kFont)
    self.resourceDisplay:SetFontIsBold(true)
    self.resourceDisplay:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.resourceDisplay:SetPosition(Vector(-GUIMarineBuyMenu.kResourceIconWidth , 0, 0))
    self.resourceDisplay:SetTextAlignmentX(GUIItem.Align_Min)
    self.resourceDisplay:SetTextAlignmentY(GUIItem.Align_Center)
    
    self.resourceDisplay:SetColor( kGUI_NameTagFontColors[self.teamNumber] )
    
    self.resourceDisplay:SetText("")
    self.resourceDisplayBackground:AddChild(self.resourceDisplay)
    
    self.currentDescription = GUIManager:CreateTextItem()
    self.currentDescription:SetFontName( GUIMarineBuyMenu.kFont )
    self.currentDescription:SetFontIsBold( true )
    self.currentDescription:SetAnchor( GUIItem.Right, GUIItem.Top )
    self.currentDescription:SetPosition( Vector(-GUIMarineBuyMenu.kResourceIconWidth * 3 , GUIMarineBuyMenu.kResourceIconHeight, 0) )
    self.currentDescription:SetTextAlignmentX(GUIItem.Align_Max )
    self.currentDescription:SetTextAlignmentY(GUIItem.Align_Center )
    self.currentDescription:SetColor( kGUI_NameTagFontColors[self.teamNumber] )
    self.currentDescription:SetText( Locale.ResolveString("CURRENT") )
    
    self.resourceDisplayBackground:AddChild( self.currentDescription )

end


function GUIMarineBuyMenu:_UpdateResourceDisplay(deltaTime)

    self.resourceDisplay:SetText( ToString( PlayerUI_GetPlayerResources() ) )
    
end


function GUIMarineBuyMenu:_UninitializeResourceDisplay()

    GUI.DestroyItem(self.resourceDisplay)
    self.resourceDisplay = nil
    
    GUI.DestroyItem(self.resourceDisplayIcon)
    self.resourceDisplayIcon = nil
    
    GUI.DestroyItem(self.resourceDisplayBackground)
    self.resourceDisplayBackground = nil
    
end

function GUIMarineBuyMenu:_InitializeCloseButton()

    self.closeButton = GUIManager:CreateGraphicItem()
    self.closeButton:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    self.closeButton:SetSize(Vector(GUIMarineBuyMenu.kButtonWidth, GUIMarineBuyMenu.kButtonHeight, 0))
    self.closeButton:SetPosition(Vector(-GUIMarineBuyMenu.kButtonWidth, GUIMarineBuyMenu.kPadding, 0))
    self.closeButton:SetTexture(GUIMarineBuyMenu.kButtonTexture)
    self.closeButton:SetShader("shaders/GUI_TeamThemed.surface_shader")
    self.closeButton:SetLayer(kGUILayerPlayerHUDForeground4)
    self.content:AddChild(self.closeButton)
    
    self.closeButtonText = GUIManager:CreateTextItem()
    self.closeButtonText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.closeButtonText:SetFontName(GUIMarineBuyMenu.kFont)
    self.closeButtonText:SetTextAlignmentX(GUIItem.Align_Center)
    self.closeButtonText:SetTextAlignmentY(GUIItem.Align_Center)
    self.closeButtonText:SetText(Locale.ResolveString("EXIT"))
    self.closeButtonText:SetFontIsBold(true)
    self.closeButtonText:SetColor( kGUI_NameTagFontColors[self.teamNumber] )
    self.closeButton:AddChild(self.closeButtonText)
    
end

function GUIMarineBuyMenu:_UpdateCloseButton(deltaTime)

    if GetIsMouseOver(self, self.closeButton) then
        self.closeButton:SetColor(Color(1, 1, 1, 1))
    else
        self.closeButton:SetColor(Color(0.5, 0.5, 0.5, 1))
    end
    
end

function GUIMarineBuyMenu:_UninitializeCloseButton()
    
    GUI.DestroyItem(self.closeButton)
    self.closeButton = nil

end

function GUIMarineBuyMenu:_GetResearchInfo(techId)

    local researched = MarineBuy_IsResearched(techId)
    local researchProgress = 0
    local researching = false
    
    if not researched then    
        researchProgress = MarineBuy_GetResearchProgress(techId)        
    end
    
    if not (researchProgress == 0) then
        researching = true
    end
    
    return researched, researchProgress, researching
end

local function HandleItemClicked(self, mouseX, mouseY)

    for i = 1, #self.itemButtons do
    
        local item = self.itemButtons[i]
        if GetIsMouseOver(self, item.Button) then
        
            local researched, researchProgress, researching = self:_GetResearchInfo(item.TechId)
            local itemCost = MarineBuy_GetCosts(item.TechId)
            local canAfford = PlayerUI_GetPlayerResources() >= itemCost
            local hasItem = PlayerUI_GetHasItem(item.TechId)
            
            if researched and canAfford and not hasItem then
            
                MarineBuy_PurchaseItem(item.TechId)
                MarineBuy_OnClose()
                
                return true, true
                
            end
            
        end
        
    end
    
    return false, false
    
end

function GUIMarineBuyMenu:SendKeyEvent(key, down)

    local closeMenu = false
    local inputHandled = false
    
    if key == InputKey.MouseButton0 and self.mousePressed ~= down then
    
        self.mousePressed = down
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        if down then
        
            inputHandled, closeMenu = HandleItemClicked(self, mouseX, mouseY)
            
            if not inputHandled then
            
                // Check if the close button was pressed.
                if GetIsMouseOver(self, self.closeButton) then
                
                    closeMenu = true
                    MarineBuy_OnClose()
                    
                end
                
            end
            
        end
        
    end
    
    // No matter what, this menu consumes MouseButton0/1.
    if key == InputKey.MouseButton0 or key == InputKey.MouseButton1 then
        inputHandled = true
    end
    
    if InputKey.Escape == key and not down then
    
        closeMenu = true
        inputHandled = true
        MarineBuy_OnClose()
        
    end
    
    if closeMenu then
    
        self.closingMenu = true
        MarineBuy_Close()
        
    end
    
    return inputHandled
    
end