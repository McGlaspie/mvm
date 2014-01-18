// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIMarineHUDStyle.lua
//
// Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// texture names, coordinates and colors used in the marine hud
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kScanLinesBigTexture = PrecacheAsset("ui/marine_HUD_scanLinesBig.dds")

kScanLinesBigCoords = { 0, 0, 316, 192 }
kScanLinesBigWidth = kScanLinesBigCoords[3] - kScanLinesBigCoords[1]
kScanLinesBigHeight = kScanLinesBigCoords[4] - kScanLinesBigCoords[2]

kBrightestColorTeam1 = Color( kMarineFontColor.r, kMarineFontColor.g, kMarineFontColor.b, 1)
kBrightColorTeam1 = Color(147/255, 206/255, 1, 1)
kBrightColorTeam1Transparent = Color( kBrightColorTeam1.r, kBrightColorTeam1.g, kBrightColorTeam1.b, 0.3)

kBrightestColorTeam2 = Color( kAlienTeamColorFloat.r, kAlienTeamColorFloat.g, kAlienTeamColorFloat.b, 1)
kBrightColorTeam2 = kAlienFontColor
kBrightColorTeam2Transparent = Color( kBrightColorTeam2.r, kBrightColorTeam2.g, kBrightColorTeam2.b, 0.5 )

kDarkColorTeam1 = Color(0.55, 0.55, 0.65, 1)
kDarkColorTeam1Transparent = Color(kDarkColorTeam1.r, kDarkColorTeam1.g, kDarkColorTeam1.b, 0.3)

kDarkColorTeam2 = Color( kBrightestColorTeam2.r * 0.6, kBrightestColorTeam2.g * 0.6, kBrightestColorTeam2.b * 0.6, kBrightColorTeam2.a )
kDarkColorTeam2Transparent = Color(kDarkColorTeam2.r, kDarkColorTeam2.g, kDarkColorTeam2.b, 0.5)

kGreyColor = Color(0.5, 0.5, 0.5, 1)
kGreyColorTransparent = Color(kGreyColor.r, kGreyColor.g, kGreyColor.b, 0.3)