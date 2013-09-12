//
//
//
//

Script.Load("lua/PostLoadMod.lua")

Scan.kScanEffectTeam2 = PrecacheAsset("cinematics/marine/observatory/scan_team2.cinematic")

//-----------------------------------------------------------------------------

function Scan:GetRepeatCinematic()
	return ConditionalValue( self:GetTeamNumber() == kTeam2Index, Scan.kScanEffectTeam2, Scan.kScanEffect )
end

//-----------------------------------------------------------------------------

Class_Reload("Scan", {})