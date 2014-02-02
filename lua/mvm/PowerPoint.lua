//
// To put it simplely...if any other mod tries to modify this class, explosions will happen.
//

Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/WeldableMixin.lua")
Script.Load("lua/mvm/ConstructMixin.lua")
Script.Load("lua/mvm/SelectableMixin.lua")
Script.Load("lua/mvm/GhostStructureMixin.lua")

Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
if Client then
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
end


local newNetworkVars = {
    scoutedForTeam1 = "boolean",
    scoutedForTeam2 = "boolean",
    isStartingPoint = "boolean"
}


AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars( ElectroMagneticMixin, newNetworkVars )


if Client then
	
	PowerPoint.kDisabledColor = Color(0.005, 0.005, 0.005)		//Move to globals.lua? Balance?
	PowerPoint.kDisabledCommanderColor = Color(0.1, 0.1, 0.1)
	
	// chance of a aux light flickering when powering up
	PowerPoint.kAuxFlickerChance = 0
	// chance of a full light flickering when powering up
	PowerPoint.kFullFlickerChance = 0.3
	
	// determines if aux lights will randomly fail after they have come on for a certain amount of time
	PowerPoint.kAuxLightsFail = false
	
	// max varying delay to turn on full lights
	PowerPoint.kMaxFullLightDelay = 2	//4
	// min 2 seconds from repairing the node till the light goes on
	PowerPoint.kMinFullLightDelay = 1	//2
	// how long time for the light to reach full power (PowerOnTime was a bit brutal and give no chance for the flicker to work)
	PowerPoint.kFullPowerOnTime = 5	//4

	// max varying delay to turn on aux lights
	PowerPoint.kMaxAuxLightDelay = 0
	
	// minimum time that aux lights are on before they start going out
	PowerPoint.kAuxLightSafeTime = 20 // short for testing, should be like 300 (5 minutes)
	// maximum time for a power point to stay on after the safe time
	PowerPoint.kAuxLightFailTime = 20 // short .. should be like 600 (10 minues)
	// how long time a light takes to go from full aux power to dead (last 1/3 of that time is spent flickering)
	PowerPoint.kAuxLightDyingTime = 20
	
	PowerPoint.kImpulseEffectFrequency = 25
	
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

local kDefaultUpdateRange = 200

local kSightedUpdateRate = 1.5	//seconds	//2
//PowerPoint.kPowerState = enum( { "unsocketed", "socketed", "destroyed" } )


//-----------------------------------------------------------------------------


if Client then

	Script.Load("lua/mvm/PowerPointLightHandler.lua")
	

	// The default update range; if the local player is inside this range from the powerpoint, the
	// lights will update. As the lights controlled by a powerpoint can be located quite far from the powerpoint,
	// and the area lit by the light even further, this needs to be set quite high.
	// The powerpoint cycling is also very efficient, so there is no need to keep it low from a performance POV.
	local kDefaultUpdateRangeSq = kDefaultUpdateRange * kDefaultUpdateRange
	
	
	function UpdatePowerPointLights()	//OVERRIDES - Called in Client.lua
	
		PROFILE("PowerPoint:UpdatePowerPointLights")
		
		// Now update the lights every frame
		local player = Client.GetLocalPlayer()
		if player then
		
			local playerPos = player:GetOrigin()
			local powerPoints = Shared.GetEntitiesWithClassname("PowerPoint")
			
			for index, powerPoint in ientitylist(powerPoints) do
				
				// PowerPoints are always loaded but in order to avoid running the light modification stuff
				// for all of them at all times, we restrict it to powerpoints inside the updateRange. The
				// updateRange should be long enough that players can't see the lights being updated by the
				// powerpoint when outside this range, and short enough not to waste too much cpu.
				//local inRange = (powerPoint:GetOrigin() - playerPos):GetLengthSquared() < kDefaultUpdateRangeSq
				
				local isComm = player:isa("Commander")
				
				// Ignore range check if the player is a commander since they are high above
				// the lights in a lot of cases and see through ceilings and some walls.
				//if inRange or isComm then
					powerPoint:UpdatePoweredLights( isComm )
				//end
				
			end
			
		end
		
	end
	
	
	function PowerPoint:UpdatePoweredLights( isCommander )	//OVERRIDES
		
		PROFILE("PowerPoint:UpdatePoweredLights") 
		
		if not self.lightHandler then    
			
			self.lightHandler = PowerPointLightHandler():Init( self )
	   
		end
		
		local time = Shared.GetTime()
		
		local updateRate = ConditionalValue(
			isCommander,
			0.05,	//40 per second, too much?
			0.05	//20 per second
		)
		
		if self.lastUpdatedTime == nil or time - self.lastUpdatedTime > updateRate then   
			
			self.lastUpdatedTime = time
			self.lightHandler:Run( self:GetLightMode(), isCommander )
			
		end

	end
	
	
end


//-----------------------------------------------------------------------------


function PowerPoint:OnCreate()	//OVERRIDES
	
	ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, PowerSourceMixin)
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, WeldableMixin)
    InitMixin(self, ParasiteMixin)
    
    InitMixin(self, FireMixin)
    InitMixin(self, ElectroMagneticMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
    self.lightMode = kLightMode.Normal
    self.powerState = PowerPoint.kPowerState.unsocketed
	
	self.scoutedForTeam1 = false
	self.scoutedForTeam2 = false
	self.isStartingPoint = false
	
	
	if Server then
		
		self:SetUpdates(true)
		self:SetPropagate(Entity.Propagate_Mask)
		
	end
	
end


local function SetupWithInitialSettings(self)	//Called in Reset()

    if self.startSocketed then
		
        self:SetInternalPowerState( PowerPoint.kPowerState.socketed )
        self:SetConstructionComplete()
        self:SetLightMode( kLightMode.Normal )
        self:SetPoweringState(true)
    
    else
		
        self:SetModel(kUnsocketedSocketModelName, kUnsocketedAnimationGraph)
        
        self:SetLightMode( kLightMode.NoPower )
        self.powerState = PowerPoint.kPowerState.unsocketed
        self.timeOfDestruction = 0
        
        if Server then
        
            self.startsBuilt = false
            self.attackTime = 0.0
            
        elseif Client then 
        
            self.unchangingLights = { }
            self.lightFlickers = { }
            
        end
    
    end
    
end


function PowerPoint:OnInitialized()		//OVERRIDES
	
    ScriptActor.OnInitialized(self)
    
    SetupWithInitialSettings(self)
    
    if Server then
		
		self:SetTeamNumber( kTeamReadyRoom )
        
        self:SetRelevancyDistance( kDefaultUpdateRange )
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    elseif Client then
		
        InitMixin(self, UnitStatusMixin)
        
    end
    
    InitMixin(self, IdleMixin)
    
    self:UpdateRelevancy()
    
end

function PowerPoint:OnResetComplete()
end

function PowerPoint:Reset()		//OVERRIDES

	self.scoutedForTeam1 = false
	self.scoutedForTeam2 = false
	self.isStartingPoint = false

	if Server then
	
		Print("PowerPoint:Reset()")
		ScriptActor.Reset(self)
		
		SetupWithInitialSettings(self)
		self:MarkBlipDirty()
		
		self:UpdateRelevancy()
		
	end
	
	if Client then
		self.lightHandler:Run( self:GetLightMode() )
	end

end


function PowerPoint:SetLightMode(lightMode)		//OVERRIDES
    
    if self:GetIsDisabled() then
        lightMode = kLightMode.NoPower
    end

    // Don't change light mode too often or lights will change too much
    if self.lightMode ~= lightMode or (not self.timeOfLightModeChange or (Shared.GetTime() > (self.timeOfLightModeChange + 1.0))) then
            
        self.lightMode = lightMode
        self.timeOfLightModeChange = Shared.GetTime()
        
    end
    
end


function PowerPoint:GetIsFlameAble()
	return false
end

function PowerPoint:GetIsVulnerableToEMP()
	return true
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
    return not self:GetIsBuilt() and self:GetPowerState() ~= PowerPoint.kPowerState.unsocketed
end


function PowerPoint:GetTechAllowed(techId, techNode, player)
	
	if player:isa("MarineCommander") and techId == kTechId.SocketPowerNode then
		
		local location = GetLocationForPoint( self:GetOrigin() )
		
		if location then
			
			local playerTeam = player:GetTeamNumber()
			local locationCommUnits = GetEntitiesForTeamByLocation( location, playerTeam )
			
			for _, entity in ipairs(locationCommUnits) do
			    
				if entity:GetTeamNumber() == playerTeam then
					if not entity:isa("Structure") and not entity:isa("ARC") then	//won't this allow scans?
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



if Client then
	
	function PowerPoint:GetIsVisible()	//This makes the dark magic happen
		
		local player = Client.GetLocalPlayer()
		
		if player and HasMixin( player, "Team" ) and player:isa("Commander") then
			
			local playerTeam = player:GetTeamNumber()
			if not self:IsScouted( playerTeam ) then
				return false
			end
			
		end
		
		return ScriptActor.GetIsVisible(self)
		
	end
	
end


function PowerPoint:UpdateRelevancy()
	
	local mask = 0
	mask = bit.bor( mask, kRelevantToTeam1, kRelevantToTeam2 )
	//Must make relevant to both teams to propogate lighting info to commanders
	self:SetExcludeRelevancyMask( mask )

end


function PowerPoint:IsScouted( byTeamNumber )

	return ConditionalValue(
		byTeamNumber == kTeam2Index,
		self.scoutedForTeam2,
		self.scoutedForTeam1
	)

end


if Server then	
	
	
	function PowerPoint:SetIsSightedOverride( seen, viewer )
		
		if seen and viewer and HasMixin( viewer, "Team") then
		
			if not viewer:isa("ARC") and not viewer:isa("Structure") and not viewer:isa("Commander") then
			//Only players, scans, and MACs can scout things
				
				local viewerTeam = viewer:GetTeamNumber()
				
				if viewerTeam == kTeam1Index then
					self.scoutedForTeam1 = true
				elseif viewerTeam == kTeam2Index then
					self.scoutedForTeam2 = true
				end
				
			end
			
			//Force LOS checks to be run again
			//Required so BOTH teams have LOS checks performed on sighted event(s)
			self.lastSightedState = false
			self.updateLOS = true
			self.dirtyLOS = true
			
		end
		
		return seen
	
	end
	
	local function PowerUp(self)
		
        self:SetInternalPowerState( PowerPoint.kPowerState.socketed )
        self:SetLightMode( kLightMode.Normal )
        self:StopSound( kAuxPowerBackupSound )
		self:TriggerEffects( "fixed_power_up", { ismarine = self.scoutedFormTeam1, isalien = self.scoutedForTeam2 } )
        self:SetPoweringState( true )
        
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
            
            // Only send the message if there is a CommandStation found at this same location.
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
	//FIXME Need way to prevent this from being played if not scouted
        if not self:GetIsDisabled() then
			self:PlaySound(kAuxPowerBackupSound)
        end
        
    end
    
    
    function PowerPoint:OnKill( attacker, doer, point, direction )	//OVERRIDES
    
        ScriptActor.OnKill( self, attacker, doer, point, direction )
        
        self:StopDamagedSound()
        
        self:MarkBlipDirty()
        
        self:PlaySound( kDestroyedSound )
        self:PlaySound( kDestroyedPowerDownSound )
        
        self:SetInternalPowerState(PowerPoint.kPowerState.destroyed)
        //self.constructionComplete = false
        self:SetLightMode( kLightMode.NoPower )
        
        // Remove effects such as parasite when destroyed.
        self:ClearGameEffects()
        
        //No scoring from neutral PNs
        //if attacker and attacker:isa("Player") and GetEnemyTeamNumber(self:GetTeamNumber()) == attacker:GetTeamNumber() then
        //    attacker:AddScore(self:GetPointValue())
        //end
        
        // Let the team know the power is down.
        //FIXME Do lookup for CSs and notify accordingly
        //SendTeamMessage(self:GetTeam(), kTeamMessageTypes.PowerLost, self:GetLocationId())
        
        // A few seconds later, switch on aux power.
        self:AddTimedCallback(PlayAuxSound, 4)
        self.timeOfDestruction = Shared.GetTime()
        
    end

end //Server




local function CreateEffects(self)

    // Create looping cinematics if we're low power or no power
    local lightMode = self:GetLightMode() 
    
    if lightMode == kLightMode.LowPower and not self.lowPowerEffect then
    
        self.lowPowerEffect = Client.CreateCinematic(RenderScene.Zone_Default)
        self.lowPowerEffect:SetCinematic(kDamagedEffect)        
        self.lowPowerEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.lowPowerEffect:SetCoords(self:GetCoords())
        self.timeCreatedLowPower = Shared.GetTime()
        
    elseif lightMode == kLightMode.NoPower and not self.noPowerEffect then
    
        self.noPowerEffect = Client.CreateCinematic(RenderScene.Zone_Default)
        self.noPowerEffect:SetCinematic(kOfflineEffect)
        self.noPowerEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.noPowerEffect:SetCoords(self:GetCoords())
        self.timeCreatedNoPower = Shared.GetTime()
        
    end
    
    if self:GetPowerState() == PowerPoint.kPowerState.socketed and self:GetIsBuilt() and self:GetIsVisible() then
    
        if self.lastImpulseEffect == nil then
            self.lastImpulseEffect = Shared.GetTime() - PowerPoint.kImpulseEffectFrequency
        end
        
        if self.lastImpulseEffect + PowerPoint.kImpulseEffectFrequency < Shared.GetTime() then
        
            self:CreateImpulseEffect()
            self.createStructureImpulse = true
            
        end
        
        if self.lastImpulseEffect + 1 < Shared.GetTime() and self.createStructureImpulse == true then
        
            self:CreateImpulseStructureEffect()
            self.createStructureImpulse = false
            
        end
        
    end
    
end

local function DeleteEffects(self)

    local lightMode = self:GetLightMode() 
    
    // Delete old effects when they shouldn't be played any more, and also every three seconds
    local kReplayInterval = 3
    
    if (lightMode ~= kLightMode.LowPower and self.lowPowerEffect) or (self.timeCreatedLowPower and (Shared.GetTime() > self.timeCreatedLowPower + kReplayInterval)) then
    
        Client.DestroyCinematic(self.lowPowerEffect)
        self.lowPowerEffect = nil
        self.timeCreatedLowPower = nil
        
    end
    
    if (lightMode ~= kLightMode.NoPower and self.noPowerEffect) or (self.timeCreatedNoPower and (Shared.GetTime() > self.timeCreatedNoPower + kReplayInterval)) then
    
        Client.DestroyCinematic(self.noPowerEffect)
        self.noPowerEffect = nil
        self.timeCreatedNoPower = nil
        
    end
    
end


function PowerPoint:OnUpdate(deltaTime)	//OVERRIDES
	
	ScriptActor.OnUpdate(self, deltaTime)
    
	if Client then
		
		local player = Client.GetLocalPlayer()
		
		if HasMixin( player, "Team") then
			local playerTeam = player:GetTeamNumber()
			if playerTeam == kTeam1Index or playerTeam == kTeam2Index then
				if self:IsScouted( playerTeam ) then
					CreateEffects(self)
				end
			else
				CreateEffects(self)	//For spectators, etc
			end
		end
	    
	    DeleteEffects(self)
	    
	else
	
	    self:AddAttackTime(-0.1)
	    
	    if self:GetLightMode() == kLightMode.Damaged and self:GetAttackTime() == 0 then
	        self:SetLightMode( kLightMode.Normal )
	    end
	    
	end
	
	if Server then
		
		if self.mapBlipId and self.mapBlipId ~= Entity.invalidId and GetGamerules():GetGameStarted() then
			
			local mapBlip = Shared.GetEntity( self.mapBlipId )
			
			if mapBlip then
				
				//Required to ensure scouted relevancy is propogated to mapblip, per team
				mapBlip:Update()	//this "should" reflect destroyed state back into blip via mixin
				
			end
			
		end
	
		self:UpdateRelevancy()
		
	end

end



if Client then	
	
	function PowerPoint:OnUpdateRender()	//OVERRIDES

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

end	//End Client


//-----------------------------------------------------------------------------


Class_Reload( "PowerPoint", newNetworkVars )

