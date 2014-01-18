// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUITechMap.lua
//
// Created by: Andreas Urwalek (and@unknownworlds.com)
//
// 
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")
Script.Load("lua/MarineTechMap.lua")
Script.Load("lua/AlienTechMap.lua")
Script.Load("lua/mvm/GuIColorGlobals.lua")

local kTechStatus = enum({'Available', 'Allowed', 'NotAvailable'})

local kTechMaps =
{
    [kTeam1Index] = kMarineTechMap,
    [kTeam2Index] = kMarineTechMap
}
local kLines =
{
    [kTeam1Index] = kMarineLines,
    [kTeam2Index] = kAlienLines
}
local kLineColors =
{
    [kTeam1Index] = Color(0, 0.8, 1, 0.5),
    [kTeam2Index] = Color(1, 0.4, 0, 0.5),
}

local kGrey = Color(0.2, 0.2, 0.2, 1)
local kAllowedColor = Color(0.5, 0.5, 0.5, 1)

local kTechMapIconColors =
{
    [kTeam1Index] = { 
		[kTechStatus.Available] = Color(0.8, 1, 1, 1), 
		[kTechStatus.Allowed] = kAllowedColor,  
		[kTechStatus.NotAvailable] = kGrey 
	},
	
    [kTeam2Index] =  { 
		[kTechStatus.Available] = Color(1, 0.9, 0.4, 1),  
		[kTechStatus.Allowed] = kAllowedColor,  
		[kTechStatus.NotAvailable] = kGrey 
	}

}

local kStartOffset =
{
    [kTeam1Index] = kMarineTechMapYStart,
    [kTeam2Index] = kMarineTechMapYStart
}

local kIconSize = GUIScale(Vector(56, 56, 0))
local kHalfIconSize = kIconSize * 0.5
local kBackgroundSize = Vector(15 * kIconSize.x, 15 * kIconSize.y, 0)
local kIconTexture = "ui/buildmenu.dds"

local kProgressMeterSize = Vector(kIconSize.x, GUIScale(10), 0)

class 'GUITechMap' (GUIScript)


local function CreateTechIcon(self, techId, position, teamNumber, modFunction, text)

    local icon = GetGUIManager():CreateGraphicItem()
    icon:SetSize(kIconSize)
    icon:SetTexture(kIconTexture)    
    icon:SetPosition(Vector(position.x * kIconSize.x, position.y * kIconSize.y, 0))
    icon:SetColor( kIconColors[teamNumber] )
    icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(techId)))
    icon:SetLayer(1)
    
    self.background:AddChild(icon)
    
    local textItem
    
    if text then
    
        textItem = GetGUIManager():CreateTextItem()
        textItem:SetFontSize(GUIScale(15))
        textItem:SetText(text)    
        textItem:SetAnchor(GUIItem.Right, GUIItem.Bottom)
        textItem:SetTextAlignmentX(GUIItem.Align_Max)
        textItem:SetTextAlignmentY(GUIItem.Align_Max)
        textItem:SetLayer(2)
        
        icon:AddChild(textItem)
    
    end
    
    return { Icon = icon, TechId = techId, ModFunction = modFunction, Text = textItem }

end

local function CreateLine(self, startPoint, endPoint, teamNumber)

    local lineStartPoint = Vector(startPoint.x * kIconSize.x, startPoint.y * kIconSize.y, 0) + kHalfIconSize
    local lineEndPoint = Vector(endPoint.x * kIconSize.x, endPoint.y * kIconSize.y, 0) + kHalfIconSize
    
    local delta = lineStartPoint - lineEndPoint
    local direction = GetNormalizedVector(delta)
    local length = math.sqrt(delta.x ^ 2 + delta.y ^ 2)    
    local rotation = math.atan2(direction.x, direction.y)
    
    if rotation < 0 then
        rotation = rotation + math.pi * 2
    end

    rotation = rotation + math.pi * 0.5
    local rotationVec = Vector(0, 0, rotation)
    
    local line = GetGUIManager():CreateGraphicItem()
    line:SetSize(Vector(length, 2, 0))
    line:SetPosition(lineStartPoint)
    line:SetRotationOffset(Vector(-length, 0, 0))
    line:SetRotation(rotationVec)
    line:SetColor(kLineColors[teamNumber])
    line:SetLayer(0) 
    
    self.background:AddChild(line)
    
    return line

end

local function CreateProgressMeter(icon)

    local progressMeterBackGround = GetGUIManager():CreateGraphicItem()
    progressMeterBackGround:SetSize(kProgressMeterSize)
    progressMeterBackGround:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    progressMeterBackGround:SetPosition(Vector(0, -kProgressMeterSize.y, 0))
    progressMeterBackGround:SetColor(Color(0, 0, 0, 1))

    local progressMeter = GetGUIManager():CreateGraphicItem()
    progressMeter:SetPosition( Vector(1, 1, 0))
    
    icon:AddChild(progressMeterBackGround)
    progressMeterBackGround:AddChild(progressMeter)
    
    return progressMeter, progressMeterBackGround

end

function GUITechMap:Initialize()

    self.showtechMap = false
    self.techMapButton = false

    self.techIcons = {}
    self.lines = {}
    
    self.background = GetGUIManager():CreateGraphicItem()
    self.background:SetSize(kBackgroundSize)
    self.background:SetPosition(-kBackgroundSize * 0.5)
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:SetIsVisible(true)
    self.background:SetColor( Color( 0, 0, 0, 0.5 ) )
    self.background:SetLayer( kGUILayerScoreboard )
    
    self.teamType = PlayerUI_GetTeamType()
    self.teamNumber = PlayerUI_GetTeamNumber()
    
    local techMap = kTechMaps[self.teamNumber]
    local offset = kStartOffset[self.teamNumber]
    for i = 1, #techMap do

        local entry = techMap[i]
    
        if entry[1] and entry[1] ~= kTechId.None then

            local position = Vector(entry[2], entry[3] + offset, 0)
            table.insert(self.techIcons, CreateTechIcon(self, entry[1], position, self.teamNumber, entry[4], entry[5]))
        
        end
    
    end
    local lines = kLines[self.teamType]
    for i = 1, #lines do
    
        local line = lines[i]
        local startPoint = Vector(line[1], line[2] + offset, 0)
        local endPoint = Vector(line[3], line[4] + offset, 0)
        table.insert(self.lines, CreateLine(self, startPoint, endPoint, self.teamNumber))
    
    end

end

function GUITechMap:Uninitialize()

    if self.background then
        GUI.DestroyItem(self.background)
        self.background = nil
    end
    
    self.techIcons = {}
    self.lines = {}

end

function GUITechMap:SendKeyEvent(key, down)

    if GetIsBinding(key, "ShowTechMap") then
    
        self.techMapButton = down
        
    end

end

function GUITechMap:ShowTechMap(show)
    self.showtechMap = show
end

function GUITechMap:GetIsVisible()
    return self.background ~= nil and self.background:GetIsVisible()
end

function GUITechMap:Update(deltaTime)

    local teamNumber = PlayerUI_GetTeamNumber()
    // reload the tech map. its possible that the script is not destroyed when changing player class in some cases and would use therefor the incorrect tech map
    if teamNumber ~= self.teamNumber then
		
        self:Uninitialize()
        self:Initialize()
        
    end

    self.hoverTechId = nil
    
    local commanderClicked = false
    local player = Client.GetLocalPlayer()
    if player and not player:isa("Commander") then
        self.showtechMap = false
    end
    
    if player:isa("Commander") and not self.registered then
        
        local script = GetGUIManager():GetGUIScriptSingle("GUICommanderTooltip")
        if script then
            script:Register(self)
            self.registered = true
        end
        
    end
    
    local showMap = self.techMapButton or self.showtechMap
    
    self.background:SetIsVisible(showMap)

    if showMap then
    
        local animation = 0.65 + 0.35 * (1 + math.sin(Shared.GetTime() * 5)) * 0.5
    
        local baseColor = kIconColors[self.teamNumber]
        self.researchingColor = Color(
            baseColor.r * animation,
            baseColor.g * animation,
            baseColor.b * animation, 1)
		
        local techTree = GetTechTree()
        local useColors = kTechMapIconColors[self.teamNumber]
        local mouseX, mouseY = Client.GetCursorPosScreen()
        
        if techTree then
    
            for i = 1, #self.techIcons do
            
                local techIcon = self.techIcons[i]
                local techId = techIcon.TechId
                local techNode = techTree:GetTechNode(techId)
                local status = kTechStatus.NotAvailable
                local researchProgress = 0

                if techNode then
                
                    researchProgress = techNode:GetResearchProgress()
                
                    if techNode:GetHasTech() then                
                        status = kTechStatus.Available                    
                    elseif techNode:GetAvailable() then
                        status = kTechStatus.Allowed
                    end
                    
                    if techNode:GetIsPassive() or techNode:GetIsMenu() then
                        status = kTechStatus.Available
                    elseif techNode:GetIsUpgrade() and techNode:GetAvailable() then    
                        status = kTechStatus.Available
                    elseif techNode:GetIsResearch() then

                        if techNode:GetResearched() and techTree:GetHasTech(techId) then
                            status = kTechStatus.Available
                        elseif techNode:GetAvailable() then
                        
                            status = kTechStatus.Allowed
                            
                        elseif techNode:GetResearching() then
                        
                            status = kTechStatus.Allowed
                            
                        end

                    elseif (techNode:GetIsBuy() or techNode:GetIsActivation()) and techNode:GetAvailable() then
                        status = kTechStatus.Available
                    end
                    
                end
                
                local progressing = false                
                if researchProgress ~= 0 and researchProgress ~= 1 then                
                    progressing = true
                    status = kTechStatus.Available                
                end
                
                local useColor = useColors[status]
                
                if progressing then
                    
                    if not techIcon.ProgressMeter then
                        techIcon.ProgressMeter, techIcon.ProgressMeterBackground = CreateProgressMeter(techIcon.Icon)
                    end
                    
                    techIcon.ProgressMeterBackground:SetIsVisible(true)
                    techIcon.ProgressMeter:SetSize(Vector((kProgressMeterSize.x - 2) * researchProgress, kProgressMeterSize.y - 2, 0))
                    
                    useColor = self.researchingColor
                    
                elseif techIcon.ProgressMeterBackground then
                    techIcon.ProgressMeterBackground:SetIsVisible(false)
                end
                
                if techIcon.ModFunction then
                    techIcon.ModFunction(techIcon.Icon, techIcon.TechId, techIcon.Text)
                end
                
                techIcon.Icon:SetColor(useColor)
                
                if not self.hoveTechId and GUIItemContainsPoint(techIcon.Icon, mouseX, mouseY) then
                    self.hoverTechId = techIcon.TechId
                end
            
            end
        
        end
    
    end

end

function GUITechMap:GetTooltipData()

    if self.hoverTechId then
        return PlayerUI_GetTooltipDataFromTechId(self.hoverTechId)
    end    

    return nil

end