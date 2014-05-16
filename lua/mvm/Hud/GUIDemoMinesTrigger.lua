//
//	Demo-Mines Trigger Display
//		Author: Brock 'McGlaspie' Gillespie - mcglaspie@gmail.com
//
//	This is a separate variant of the Builer/Welder GUI display (on weapon).
//	It shows the number of mines deployed and undeployed. It will remove them
//	as they are consumed.
//	
//=============================================================================


Script.Load("lua/GUIScript.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/mvm/GUIColorGlobals.lua")


deployedMines = 0
teamNumber = 0
minesInRange = 0
demoMinesTriggerDisplay = nil


//-----------------------------------------------------------------------------


class 'GUIDemoMinesTrigger' (GUIScript)


function GUIDemoMinesTrigger:Initialize()

    self.deployedMines = 0
    self.teamNumber = 0
    self.minesInRange = 0

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize( Vector(512, 512, 0) )
    self.background:SetPosition( Vector(0, 0, 0) )  
    self.background:SetTexture("ui/ShotgunDisplay.dds")
    self.background:SetShader("shaders/GUI_TeamThemed.surface_shader")
    
    self.mineIcon = GUIManager:CreateGraphicItem()
    self.mineIcon:SetSize( Vector(512, 512, 0) )
    self.mineIcon:SetPosition( Vector(0, 0, 0) )
    self.mineIcon:SetTexture( "ui/MineIcon.dds" )
    self.mineIcon:SetIsVisible(true)
    //self.mineIcon:SetShader("shaders/GUI_TeamThemed.surface_shader")
    
    self.deployedMinesText = GUIManager:CreateTextItem()
    self.deployedMinesText:SetFontName("fonts/AgencyFB_large_bold.fnt")
    self.deployedMinesText:SetScale( Vector(1,1,1) * 8 )
    self.deployedMinesText:SetFontIsBold(true)
    self.deployedMinesText:SetTextAlignmentX(GUIItem.Align_Center)
    self.deployedMinesText:SetTextAlignmentY(GUIItem.Align_Center)
    self.deployedMinesText:SetPosition( Vector(256, 256, 0) )	//this will need a lot of tests
    self.deployedMinesText:SetIsVisible(true)
    self.deployedMinesText:SetColor( kGUI_NameTagFontColors[self.teamNumber] )
    
    // Force an update so our initial state is correct.
    self:Update(0)

end

function GUIDemoMinesTrigger:Uninitialize()
	self.mineIcon:SetColor( kGUI_Trans )	
	self.deployedMinesText:SetColor( kGUI_Trans )
	self.deployedMinesText:SetIsVisible(false)
	self.mineIcon:SetIsVisible(false)
end

function GUIDemoMinesTrigger:SetTeamNumber(team)
	self.teamNumber = team
end

function GUIDemoMinesTrigger:UpdateTeamColors()
	
	local uiColor = kGUI_Team1_BaseColor
	if self.teamNumber == 2 then
		uiColor = kGUI_Team2_BaseColor
	end
	
	self.background:SetFloatParameter( "teamBaseColorR", uiColor.r )
	self.background:SetFloatParameter( "teamBaseColorG", uiColor.g )
	self.background:SetFloatParameter( "teamBaseColorB", uiColor.b )
	
	self.mineIcon:SetColor( kGUI_HealthBarColors[self.teamNumber] )
	self.deployedMinesText:SetColor( kGUI_White )
	
end

function GUIDemoMinesTrigger:Update(deltaTime)

    PROFILE("GUIDemoMinesTrigger:Update")
	
	self:UpdateTeamColors()
	
	self.deployedMinesText:SetText( string.format("%d", self.deployedMines )  )
	//self.mineIcon:SetIsVisible( self.minesInRange ~= 0 )
	//self.deployedMinesText:SetIsVisible( self.minesInRange ~= 0 )
	
end

function GUIDemoMinesTrigger:SetDeployedMines( numMines )
    self.deployedMines = numMines
end

function GUIDemoMinesTrigger:SetMinesInRange( minesInRange )	//pass 0 or 1
    self.minesInRange = minesInRange
end

function Update( deltaTime )
	
	demoMinesTriggerDisplay:SetTeamNumber( teamNumber )
    demoMinesTriggerDisplay:SetDeployedMines( deployedMines )
    demoMinesTriggerDisplay:SetMinesInRange( minesInRange )
    demoMinesTriggerDisplay:Update( deltaTime )
    
end


/**
 * Initializes the player components.
 */
function Initialize()

    GUI.SetSize( 512, 512 )

    demoMinesTriggerDisplay = GUIDemoMinesTrigger()
    demoMinesTriggerDisplay:Initialize()

end


Initialize()

