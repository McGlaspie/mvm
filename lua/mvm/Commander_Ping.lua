


local function MvM_CheckMouseIsInMinimapFrame(x, y)
	
    local minimapScript = ClientUI.GetScript("mvm/GUIMinimapFrame")
    local containsPoint, withinX, withinY = GUIItemContainsPoint(minimapScript:GetMinimapItem(), x, y)
    return containsPoint, withinX, withinY, minimapScript:GetMinimapSize()
    
end


ReplaceLocals( 
	CheckKeyEventForCommanderPing, 
	{ CheckMouseIsInMinimapFrame = MvM_CheckMouseIsInMinimapFrame } 
)