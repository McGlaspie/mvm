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



if Server then

	
	function Scan:GetVisionRadius()
		return Scan.kScanDistance
	end

	
    function Scan:Perform(deltaTime)
    
        PROFILE("Scan:Perform")
        
        //if not InkCloudNearby(self) then	//Use Inkcould for "jamming" later
        
		/*
		local enemies = GetEntitiesWithMixinForTeamWithinRange(
			"LOS", 
			GetEnemyTeamNumber(self:GetTeamNumber()), 
			self:GetOrigin(), 
			Scan.kScanDistance
		)
		*/
		//hacky change to include PowerPoints in scanned (for scouting flag they hold)
		local scannedEnts = Shared.GetEntitiesWithTagInRange( "LOS", self:GetOrigin(), Scan.kScanDistance )
		local scanTeam = self:GetTeamNumber()
		
		for _, entity in ipairs(scannedEnts) do
			
			if HasMixin( entity, "Team" ) and ( GetAreEnemies(self, entity) or entity:isa("PowerPoint") ) then
				
				entity:SetIsSighted(true, self)
				
				// Allow entities to respond
				if entity.OnScan then
				   entity:OnScan()
				end
				
				if HasMixin(entity, "Detectable") then
					entity:SetDetected(true)
				end
			
			end
			
		end
            
        //end    
        
    end
    
    
    function Scan:OnDestroy()
    
        for _, entity in ipairs( GetEntitiesWithMixinForTeamWithinRange("LOS", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), Scan.kScanDistance)) do
            entity.updateLOS = true
        end
        
        CommanderAbility.OnDestroy(self)
    
    end
    
    
end	//End Server


//-----------------------------------------------------------------------------

Class_Reload("Scan", {})