//=============================================================================
//  MvM - GUI Graphics Colors
// 
// Any additions to this file need to be sure they don't overwrite existing
// game globals.
//=============================================================================

//Need team number for lookups
kGUI_Team1Index = 1
kGUI_Team2Index = 2

kGUI_Trans = Color( 1, 1, 1, 0 )
kGUI_White = Color( 1, 1, 1, 1 )
kGUI_Grey = Color( 0.6, 0.6, 0.6, 0.6 )
kGUI_Red = Color( 1, 0.1, 0.1, 1 )
kGUI_RedGrey = Color( 0.4, 0.185, 0.185, 0.56 )

kGUI_Team1_BaseColor = Color(0.085, 0.72, 0.96, 0.15)
kGUI_Team1_AccentColor = Color(0.756, 0.982, 1, 1)
kGUI_Team1_TrimColor = Color(0.725, 0.921, 0.949, 1)

kGUI_Team2_BaseColor = Color(0.61, 0.43, 0.16, 0.85)
kGUI_Team2_AccentColor = Color(1.0, 0.0, 0.0, 1)
kGUI_Team2_TrimColor = Color(0.576, 0.194, 0.011, 1)


kGUI_TeamThemes_BaseColor = {
    [0] = kGUI_Grey,
    [kGUI_Team1Index] = kGUI_Team1_BaseColor,
    [kGUI_Team2Index] = kGUI_Team2_BaseColor
}

kGUI_TeamThemes_AccentColor = {
    [0] = Color( 1,1,1,1 ),
    [kGUI_Team1Index] = kGUI_Team1_AccentColor,
    [kGUI_Team2Index] = kGUI_Team2_AccentColor
}


kGUI_HealthBarColors = { 
	[0] = Color( 0.6, 0.6, 0.6, 1),
	[kGUI_Team1Index] = Color(0.725, 0.921, 0.949, 1),
	[kGUI_Team2Index] = Color(0.776, 0.364, 0.031, 1)
}

kGUI_NameTagFontColors = { 
	[0] = Color( 0.6, 0.6, 0.6, 1),
	[kGUI_Team1Index] = Color(0.756, 0.952, 0.988, 1),
	[kGUI_Team2Index] = Color(0.901, 0.623, 0.215, 1)
}



//compares color2 equivilent to color1 within byMargin
function CompareColors( color1, color2, byMargin )

	return (
		color2.r - color1.r <= byMargin and
		color2.g - color1.g <= byMargin and
		color2.b - color1.b <= byMargin and
		color2.a - color1.a <= byMargin
	)
    
end


