//
//
//
//

Script.Load("lua/PostLoadMod.lua")

Scan.kScanEffectTeam2 = PrecacheAsset("cinematics/marine/observatory/scan_team2.cinematic")

//-----------------------------------------------------------------------------

function Scan:GetRepeatCinematic()
	
	if self:GetTeamNumber() == kTeam2Index then
		return Scan.kScanEffectTeam2
	end
	
	return Scan.kScanEffect
	
end

//-----------------------------------------------------------------------------

Class_Reload("Scan", {})