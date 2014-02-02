//
//
//
//

Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/mvm/LiveMixin.lua")


local newNetworkVars = {}


Scan.kScanEffectTeam2 = PrecacheAsset("cinematics/marine/observatory/scan_team2.cinematic")

Scan.kEmpResistanceHealth = 3

AddMixinNetworkVars(ElectroMagneticMixin, newNetworkVars)
AddMixinNetworkVars(LiveMixin, newNetworkVars)

//-----------------------------------------------------------------------------


//local orgScanCreate = Scan.OnCreate
function Scan:OnCreate()	//OVERRIDES

	CommanderAbility.OnCreate(self)
    
    InitMixin(self, LiveMixin)
    
    if Server then
		
        StartSoundEffectOnEntity(Scan.kScanSound, self)
        
        self:SetMaxHealth( Scan.kEmpResistanceHealth )
        
    end
	
end

function Scan:GetSendDeathMessageOverride()
	return false
end

function Scan:GetIsHealableOverride()
	return false
end

function Scan:GetCanBeHealed()
	return false
end

function Scan:AttemptToKill( damage, attacker, doer, point )
	
	if doer and doer:GetDamageType() == kDamageType.ElectroMagnetic then
		return true
	end
	
	return false
	
end


function Scan:GetLifeSpan()
    return kScanDuration
end

function Scan:GetRepeatCinematic()
	return ConditionalValue( self:GetTeamNumber() == kTeam2Index, Scan.kScanEffectTeam2, Scan.kScanEffect )
end



if Server then
	
	//function Scan:OnEmpDamaged()
	//	Scan:OnDestroy()
	//end

	
	function Scan:GetVisionRadius()
		return Scan.kScanDistance
	end
	
	function Scan:OnKill( attacker, doer, point, direction )
		Scan:OnDestroy()
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

Class_Reload("Scan", newNetworkVars)