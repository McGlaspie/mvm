

Script.Load("lua/mvm/FireMixin.lua")


local newNetworkVars = {
    scoutedForTeam1 = "boolean",
    scoutedForTeam2 = "boolean"
}


AddMixinNetworkVars(FireMixin, newNetworkVars)


if Client then
	PowerPoint.kDisabledColor = Color(0.013, 0.013, 0.013)		//Move to globals.lua? Balance?
	PowerPoint.kDisabledCommanderColor = Color(0.15, 0.15, 0.15)
end


local kUnsocketedSocketModelName = PrecacheAsset("models/system/editor/power_node_socket.model")
local kUnsocketedAnimationGraph = nil

local kSocketedModelName = PrecacheAsset("models/system/editor/power_node.model")
local kSocketedAnimationGraph = PrecacheAsset("models/system/editor/power_node.animation_graph")

local kDamagedEffect = PrecacheAsset("cinematics/common/powerpoint_damaged.cinematic")
local kOfflineEffect = PrecacheAsset("cinematics/common/powerpoint_offline.cinematic")

local kTakeDamageSound = PrecacheAsset("sound/NS2.fev/marine/power_node/take_damage")
local kDamagedSound = PrecacheAsset("sound/NS2.fev/marine/power_node/damaged")
local kDestroyedSound = PrecacheAsset("sound/NS2.fev/marine/power_node/destroyed")
local kDestroyedPowerDownSound = PrecacheAsset("sound/NS2.fev/marine/power_node/destroyed_powerdown")
local kAuxPowerBackupSound = PrecacheAsset("sound/NS2.fev/marine/power_node/backup")

local kDamagedPercentage = 0.4

// Re-build only possible when X seconds have passed after destruction (when aux power kicks in)
local kDestructionBuildDelay = 15

// The amount of time that must pass since the last time a PP was attacked until
// the team will be notified. This makes sure the team isn't spammed.
local kUnderAttackTeamMessageLimit = 4

// max amount of "attack" the powerpoint has suffered (?)
local kMaxAttackTime = 10

local kSightedUpdateRate = 2	//seconds
//PowerPoint.kPowerState = enum( { "unsocketed", "socketed", "destroyed" } )


//-----------------------------------------------------------------------------


local orgPowerPointCreate = PowerPoint.OnCreate
function PowerPoint:OnCreate()
	
	orgPowerPointCreate(self)
	
	if Server then
		
		self.scoutedForTeam1 = false
		self.scoutedForTeam2 = false
		
		self:SetUpdates(true)
		self:SetPropagate(Entity.Propagate_Mask)
		self:UpdateRelevancy()
		
	end
	
end


local oldPowerPointInit = PowerPoint.OnInitialized
function PowerPoint:OnInitialized()
	
	oldPowerPointInit(self)

	if Server then
		self:SetTeamNumber(kTeamReadyRoom)
	end

end

function PowerPoint:GetIsFlameAble()
	return false
end

function PowerPoint:GetCanBeNanoShieldedOverride(resultTable)
    resultTable.shieldedAllowed = (
		resultTable.shieldedAllowed 
		and self:GetPowerState() == PowerPoint.kPowerState.socketed
		and self:GetIsBuilt()
	)
end

function PowerPoint:GetReceivesStructuralDamage()
    return true	//false? To slow-down friendly fire? Eh...not a very good idea. Needs true capturing...
    //If above set to false, MASSIVE change needed to HP/AR
end

function PowerPoint:GetCanConstructOverride(player)
    return not self:GetIsBuilt() and self:GetPowerState() ~= PowerPoint.kPowerState.unsocketed --and GetAreFriends(player,self)
end


function PowerPoint:GetTechAllowed(techId, techNode, player)
	
	if player:isa("MarineCommander") and techId == kTechId.SocketPowerNode then
		
		local location = GetLocationForPoint( self:GetOrigin() )
		
		if location then
			
			local playerTeam = player:GetTeamNumber()
			local locationCommUnits = GetEntitiesForTeamByLocation( location, playerTeam )
			
			for _, entity in ipairs(locationCommUnits) do
			    
				if entity:GetTeamNumber() == playerTeam then
					//MAC still not being detected by this...
					if entity:isa("Marine") or entity:isa("MAC") or entity:isa("Exo") then
						return true, true
					end
					
				end
				
			end
		
		end
		
	end
	
	return false, false	//Default to "NAY! I think, not"
	
end

function PowerPoint:OverrideVisionRadius()
	return 2
end


local orgPowerPointReset = PowerPoint.Reset
function PowerPoint:Reset()
	
	orgPowerPointReset(self)
	
	if Server then
		
		self.scoutedForTeam1 = false
		self.scoutedForTeam2 = false
		self:UpdateRelevancy()
		
	end

end


if Server then	
	
	
	function PowerPoint:UpdateRelevancy()
		
		//FIXME below fixes switching teams not updating PN visibility, but Location powered effect not correct now...
		local mask = bit.bor(kRelevantToTeam1, kRelevantToTeam2, kRelevantToReadyRoom)
		
		if self:GetIsSighted() then
		
			if self.scoutedForTeam1 then
				mask = bit.bor(mask, kRelevantToTeam1Commander)
			end
			
			if self.scoutedForTeam2 then
				mask = bit.bor(mask, kRelevantToTeam2Commander)
			end
		
		end
		
		self:SetExcludeRelevancyMask(mask)
	
	end
	
	
	local function PowerUp(self)
    
        self:SetInternalPowerState(PowerPoint.kPowerState.socketed)
        self:SetLightMode(kLightMode.Normal)
        self:StopSound(kAuxPowerBackupSound)
        self:TriggerEffects("fixed_power_up")
        self:SetPoweringState(true)
        
    end


	// Repaired by marine with welder or MAC 
    function PowerPoint:OnWeldOverride(entity, elapsedTime)
    
        local welded = false
        local weldAmount = 0
        
        // Marines can repair power points
        if entity:isa("Welder") then
            weldAmount = kWelderPowerRepairRate * elapsedTime
        elseif entity:isa("MAC") then
            weldAmount = MAC.kRepairHealthPerSecond * elapsedTime
        else
            weldAmount = kBuilderPowerRepairRate * elapsedTime
        end
        
        if HasMixin(self, "Fire") and self:GetIsOnFire() then
			weldAmount = weldAmount * kWhileBurningWeldEffectReduction
        end
        
        welded = (self:AddHealth(weldAmount) > 0)
        
        if self:GetHealthScalar() > kDamagedPercentage then
        
            self:StopDamagedSound()
            
            if self:GetLightMode() == kLightMode.LowPower and self:GetIsPowering() then
                self:SetLightMode(kLightMode.Normal)
            end
            
        end
        
        if self:GetHealthScalar() == 1 and self:GetPowerState() == PowerPoint.kPowerState.destroyed then
        
            self:StopDamagedSound()
            
            self.health = kPowerPointHealth
            self.armor = kPowerPointArmor
            
            self.maxHealth = kPowerPointHealth
            self.maxArmor = kPowerPointArmor
            
            self.alive = true
            
            PowerUp(self)
            
        end
        
        if welded then
            self:AddAttackTime(-0.1)
        end
        
    end
    
    
    // send a message every kUnderAttackTeamMessageLimit seconds when a base power node is under attack
    //TODO Examine adding in delay to these messages. Currently happens anytime PN takes ANY damage
    // - May need a 'Only when HP below X AND timeInterval > Y'
    local function MvM_CheckSendDamageTeamMessage(self)
		
        if not self.timePowerNodeAttackAlertSent or self.timePowerNodeAttackAlertSent + kUnderAttackTeamMessageLimit < Shared.GetTime() then

            // Check if there is a built Command Station in the same location as this PowerPoint.
            local foundStation = false
            local targetCommandStation = nil
            
			for _, commStation in ientitylist( Shared.GetEntitiesWithClassname("CommandStation") ) do
				
				if commStation:GetIsBuilt() and commStation:GetLocationName() == self:GetLocationName() then
					foundStation = true
					targetCommandStation = commStation
				end
			
			end
            
            // Only send the message if there was a CommandStation found at this same location.
            if foundStation and targetCommandStation ~= nil then
                SendTeamMessage( targetCommandStation:GetTeam(), kTeamMessageTypes.PowerPointUnderAttack, self:GetLocationId() )
                targetCommandStation:GetTeam():TriggerAlert( kTechId.MarineAlertStructureUnderAttack, self, true )
            end
            
            self.timePowerNodeAttackAlertSent = Shared.GetTime()
        end
        
    end
    
    
    //FIXME Need anti-spam limiter to team messages
    function PowerPoint:OnTakeDamage(damage, attacker, doer, point)
		
        if self:GetIsPowering() then
			
            self:PlaySound(kTakeDamageSound)
            
            local healthScalar = self:GetHealthScalar()
            
            if healthScalar < kDamagedPercentage then
				
                self:SetLightMode(kLightMode.LowPower)
                
                if not self.playingLoopedDamaged then
                    self:PlaySound(kDamagedSound)
                    self.playingLoopedDamaged = true
                end
                
            else
                self:SetLightMode(kLightMode.Damaged)
            end
            
            if not preventAlert then
				MvM_CheckSendDamageTeamMessage(self)
			end
            
        end
        
        self:AddAttackTime(0.9)
        
    end
    
    
    
    local function PlayAuxSound(self)
    
        if not self:GetIsDisabled() then
            self:PlaySound(kAuxPowerBackupSound)
        end
        
    end
    
    
    function PowerPoint:OnKill(attacker, doer, point, direction)	//OVERRIDES
    
        ScriptActor.OnKill(self, attacker, doer, point, direction)
        
        self:StopDamagedSound()
        
        self:MarkBlipDirty()
        
        self:PlaySound(kDestroyedSound)
        self:PlaySound(kDestroyedPowerDownSound)
        
        self:SetInternalPowerState(PowerPoint.kPowerState.destroyed)
        
        self:SetLightMode(kLightMode.NoPower)
        
        // Remove effects such as parasite when destroyed.
        self:ClearGameEffects()
        
        if attacker and attacker:isa("Player") and GetEnemyTeamNumber(self:GetTeamNumber()) == attacker:GetTeamNumber() then
            attacker:AddScore(self:GetPointValue())
        end
        
        // Let the team know the power is down.
        //SendTeamMessage(self:GetTeam(), kTeamMessageTypes.PowerLost, self:GetLocationId())	//Removed - no pointing sending msg to RR "team"
        
        // A few seconds later, switch on aux power.
        self:AddTimedCallback(PlayAuxSound, 4)
        self.timeOfDestruction = Shared.GetTime()
        
    end
    
    

end //Server



/*
FIXME ALL of below "state" crap would be MUCH easier if the "node" was
just an attachment to the base socket...then attachment visiblity could
be toggled, instead of swapping the damn model...need new model for this
however...yay.
	PowerPoint.kPowerState = enum( { "unsocketed", "socketed", "destroyed" } )
*/
function PowerPoint:OnSighted(sighted)
	
	local lastViewer = self:GetLastViewer()
	
	if lastViewer ~= nil and HasMixin(lastViewer, "Team") then
		
		if not lastViewer:isa("ARC") and not lastViewer:isa("Structure") and not lastViewer:isa("Commander") then
		//Only players, scans, and MACs can scout things
			
			if lastViewer:GetTeamNumber() == kTeam1Index then
				self.scoutedForTeam1 = true
			elseif lastViewer:GetTeamNumber() == kTeam2Index then
				self.scoutedForTeam2 = true
			end
			
		end
		
	end
	
end


local orgPowerPointOnUpdate = PowerPoint.OnUpdate
function PowerPoint:OnUpdate(deltaTime)
	
	orgPowerPointOnUpdate(self, deltaTime)
	
	if Server and self.sighted then
		self:UpdateRelevancy()
	end

end



if Client then
	
	
	function PowerPoint:OnUpdateRender()

		PROFILE("PowerPoint:OnUpdateRender")		
		
		if self:GetIsSocketed() then

			local model = self:GetRenderModel()
			self:InstanceMaterials()
			
			if model then
				
				local showGhost = not self:GetIsBuilt() 
					// or (not GetPowerPointRecentlyDestroyed(self) and self:GetHealthScalar() < 0.15 
					//and self.powerState == PowerPoint.kPowerState.destroyed)
				
				if showGhost then
				
					if not self.ghostMaterial then
						//TODO Update with team appropriate color once capturing feature added
						self.ghostMaterial = AddMaterial(model, "cinematics/vfx_materials/ghoststructure.material") 
					end   

					self:SetOpacity(0, "ghostStructure") 
				
				else
				
					if self.ghostMaterial then
						RemoveMaterial(model, self.ghostMaterial)
						self.ghostMaterial = nil
					end
					
					self:SetOpacity(1, "ghostStructure")
				
				end
				
				local amount = 0
				if self:GetIsPowering() then
				
					local animVal = (math.cos(Shared.GetTime()) + 1) / 2
					amount = 1 + (animVal * 5)
					
				end
				model:SetMaterialParameter("emissiveAmount", amount)
				
			end
			
		end
		
	end

end


//-----------------------------------------------------------------------------


Class_Reload("PowerPoint", newNetworkVars)

