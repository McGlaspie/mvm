//
//
//
//
//=============================================================================

Script.Load("lua/GUIScript.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/mvm/GUIColorGlobals.lua")


weaponClip = 0		//ClipSize, Mines remaining to be deployed
teamNumber = 0		//Player's team
demoMinesDisplay = nil

local kBackgroundColor = Color(0.302, 0.859, 1, 0.2)

//-----------------------------------------------------------------------------


class 'GUIDemoMines' (GUIScript)
	

//TODO Add Mine Icon
//TODO Small Square to show "Mines in Clip"
//TODO Show each "ammo clip" square as TeamColor for in-inventory
//and Red for ARMED-STATE.
function GUIDemoMines:Initialize()

    self.weaponClip = 0
    self.teamNumber = 0
    
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize( Vector(256, 512, 0) )
    self.background:SetPosition( Vector(0, 0, 0) )
    self.background:SetIsVisible(true)
    
    // Slightly larger copy of the text for a glow effect
    self.ammoTextBg = GUIManager:CreateTextItem()
    self.ammoTextBg:SetFontName("fonts/MicrogrammaDMedExt_large.fnt")
    self.ammoTextBg:SetScale( Vector( 1.9, 2.35, 1.9 ) )
    self.ammoTextBg:SetTextAlignmentX(GUIItem.Align_Center)
    self.ammoTextBg:SetTextAlignmentY(GUIItem.Align_Center)
    self.ammoTextBg:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.ammoTextBg:SetColor( kGUI_Grey )
    
    // Text displaying the amount of ammo in the clip
    self.ammoText = GUIManager:CreateTextItem()
    self.ammoText:SetFontName("fonts/MicrogrammaDMedExt_large.fnt")
    self.ammoText:SetScale(Vector(1.75, 2.2, 1.75))
    self.ammoText:SetTextAlignmentX(GUIItem.Align_Center)
    self.ammoText:SetTextAlignmentY(GUIItem.Align_Center)
    self.ammoText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.ammoText:SetColor( kGUI_White )
    
    self:Update(0)
    
end


function GUIDemoMines:SetTeamNumber(team)
    self.teamNumber = team
end

function GUIDemoMines:SetClip(clip)
    self.weaponClip = clip
end


function GUIDemoMines:UpdateTeamColors()
	
	self.background:SetColor( kGUI_TeamThemes_BaseColor[self.teamNumber] )
	self.ammoText:SetColor( kGUI_White )

end



function GUIDemoMines:Update(deltaTime)

    PROFILE("GUIMineDisplay:Update")
    
    self:UpdateTeamColors()
    
    local ammoFormat = string.format("%d", self.weaponClip) 
    self.ammoText:SetText(ammoFormat)
    self.ammoTextBg:SetText(ammoFormat)
    
end


//-------------------------------------


function Update(deltaTime)

    PROFILE("GUIMineDisplay Update")
	
    mineDisplay:SetClip( weaponClip )
    mineDisplay:SetTeamNumber( teamNumber )
    mineDisplay:Update( deltaTime )
    
end


function Initialize()

    GUI.SetSize(256, 417)
    
    mineDisplay = GUIDemoMines()
    mineDisplay:Initialize()
    
end


Initialize()

