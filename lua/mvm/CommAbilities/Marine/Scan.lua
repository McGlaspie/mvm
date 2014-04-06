//
//
//
//

Script.Load("lua/mvm/CommAbilities/CommanderAbility.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")


local newNetworkVars = {}


Scan.kScanEffectTeam2 = PrecacheAsset("cinematics/marine/observatory/scan_team2.cinematic")

Scan.kEmpResistanceHealth = 5

AddMixinNetworkVars(ElectroMagneticMixin, newNetworkVars)
AddMixinNetworkVars(LiveMixin, newNetworkVars)
AddMixinNetworkVars(LOSMixin, newNetworkVars)


//-----------------------------------------------------------------------------


function Scan:OnCreate()	//OVERRIDES

	CommanderAbility.OnCreate(self)
    
    InitMixin(self, LiveMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    
    InitMixin(self, ElectroMagneticMixin)
    
    if Server then
		
        self:SetMaxHealth( Scan.kEmpResistanceHealth )
        
        StartSoundEffectOnEntity(Scan.kScanSound, self)		//FIXME Should only play for Unit and not Comm-auto
        
    end
	
end


function Scan:OnInitialized()	//OVERRIDES

    CommanderAbility.OnInitialized(self)
    
    if Server then
		
		DestroyEntitiesWithinRangeByTeam( "Scan", self:GetOrigin(), Scan.kScanDistance + 8 , self:GetTeamNumber(), EntityFilterOne(self) )
		
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    end
    
end


function Scan:GetSendDeathMessageOverride()
	return false	//TODO Add Kill message for EMP death?
end


function Scan:GetIsVulnerableToEMP()
	return true
end


function Scan:GetIsHealableOverride()
	return false
end


function Scan:GetCanBeHealed()
	return false
end


function Scan:CreateRepeatEffectOverride()
	
	// Glowing rotating particles
    if Client then
    
		local player = Client.GetLocalPlayer()
        local cinematic = self:GetRepeatCinematic()
    
        if cinematic ~= nil and not self.repeatingEffect then
    
            self.repeatingEffect = Client.CreateCinematic(RenderScene.Zone_Default)    
            self.repeatingEffect:SetCinematic(cinematic)    
            self.repeatingEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
			self.repeatingEffect:SetIsVisible( self:GetTeamNumber() == player:GetTeamNumber() )
			//Default to only visible by friendlies
			
            local coords = Coords.GetIdentity()
            coords.origin = self:GetOrigin()
            self.repeatingEffect:SetCoords(coords)
        
        end
        
    end

end


function Scan:DestroyRepeatEffectOverride()

	if Client then
    
        if self.repeatingEffect then
        
            Client.DestroyCinematic(self.repeatingEffect)
            self.repeatingEffect = nil
            
        end
        
    end

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


//Returning false will stop timedcallback
function Scan:OverrideCallbackUpdateFunction()
//TEMP - Copied from CommanderAbilityUpdate
	
	self:CreateRepeatEffect()
    
    // Instant types have already been performed in OnInitialized.
    if abilityType ~= CommanderAbility.kType.Instant then
		
        self:Perform()
        
        if Client and self:GetIsSighted() then
			self.repeatingEffect:SetIsVisible( self:GetIsVisible() )	//piggy back off of enemy scanned sighting scan
        end
        
    end
    
    local lifeSpanEnded = not self:GetLifeSpan() or (self:GetLifeSpan() + self.timeCreated) <= Shared.GetTime()
    
    if Server and ( 
			lifeSpanEnded or self:GetAbilityEndConditionsMet() 
			or abilityType == CommanderAbility.kType.OverTime 
			or abilityType == CommanderAbility.kType.Instant
		) then
		
        DestroyEntity( self )
        
    end
    
    return true

end


if Server then
	
	function Scan:OnEmpDamaged()
		Scan:OnDestroy()
	end

	
	function Scan:GetVisionRadius()
		return Scan.kScanDistance
	end
	
	function Scan:OnKill( attacker, doer, point, direction )
		Scan:OnDestroy()
	end
	
    function Scan:Perform(deltaTime)
    
        PROFILE("Scan:Perform")
        
		local scannedEnts = Shared.GetEntitiesWithTagInRange( "LOS", self:GetOrigin(), Scan.kScanDistance )
		local scanTeam = self:GetTeamNumber()
		
		for _, entity in ipairs( scannedEnts ) do
			
			if HasMixin( entity, "Team" ) and ( GetAreEnemies(self, entity) or entity:isa("PowerPoint") ) then
				
				entity:SetIsSighted( true, self )
				
				// Allow entities to respond
				if entity.OnScan then
				   entity:OnScan()
				end
				
				if HasMixin(entity, "Detectable") then
					entity:SetDetected( true )
					self:SetIsSighted( true, entity )	//This might be really weird...
					self.updateLOS = true
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


Class_Reload( "Scan", newNetworkVars )

