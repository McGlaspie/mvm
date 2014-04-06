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
Script.Load("lua/mvm/NanoshieldMixin.lua")

if Client then
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
end


local newNetworkVars = {
    scoutedForTeam1 = "boolean",
    scoutedForTeam2 = "boolean",
    isStartingPoint = "boolean"
}


AddMixinNetworkVars( FireMixin, newNetworkVars )
AddMixinNetworkVars( ElectroMagneticMixin, newNetworkVars )


if Client then
	
	PowerPoint.kDisabledColor = Color(0.0075, 0.0075, 0.0075)		//Move to globals.lua? Balance?
	PowerPoint.kDisabledCommanderColor = Color(0.11, 0.11, 0.11)
	
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
	
	PowerPoint.kImpulseEffectFrequency = 25     //Unused, essentially
	
end


local kUnsocketedSocketModelName = PrecacheAsset("models/system/editor/power_node_socket.model")
local kUnsocketedAnimationGraph = nil

local kSocketedModelName = PrecacheAsset("models/system/editor/power_node.model")
local kSocketedAnimationGraph = PrecacheAsset("models/system/editor/power_node.animation_graph")

local kDamagedEffect = PrecacheAsset("cinematics/common/powerpoint_damaged.cinematic")  //TODO add to damage event
local kOfflineEffect = PrecacheAsset("cinematics/common/powerpoint_offline.cinematic")  //TODO add to destroyed event


local kTakeDamageFlagUpdateRate = 0.4

local kDamagedPercentage = 0.4	//Move to BalanceMisc?

// Re-build only possible when X seconds have passed after destruction (when aux power kicks in)
local kDestructionBuildDelay = 15

// The amount of time that must pass since the last time a PP was attacked until
// the team will be notified. This makes sure the team isn't spammed.
local kUnderAttackTeamMessageLimit = 10

// max amount of "attack" the powerpoint has suffered (?)
local kMaxAttackTime = 10

local kDefaultUpdateRange = 200

local kSightedUpdateRate = 1.5	//seconds	//2 - NS2
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
				local inRange = (powerPoint:GetOrigin() - playerPos):GetLengthSquared() < kDefaultUpdateRangeSq
				
				local isComm = player:isa("Commander")
				
				// Ignore range check if the player is a commander since they are high above
				// the lights in a lot of cases and see through ceilings and some walls.
				if inRange or isComm then
					powerPoint:UpdatePoweredLights( isComm )
				end
				
			end
			
		end
		
	end
	
	
	function PowerPoint:UpdatePoweredLights( isCommander )	//OVERRIDES
		
		PROFILE("PowerPoint:UpdatePoweredLights") 
		
		if not self.lightHandler then    
			
			self.lightHandler = PowerPointLightHandler():Init( self )	//isCommander
	   
		end
		
		local time = Shared.GetTime()
		
		local updateRate = ConditionalValue(
			isCommander,
			0.05,	//50+ too much?
			0.05	//50 per second
		)
		
		if self.lastUpdatedTime == nil or time - self.lastUpdatedTime > updateRate then   
			
			self.lastUpdatedTime = time
			self.lightHandler:Run( self:GetLightMode(), isCommander )
			
		end

	end
	
	
end


//-----------------------------------------------------------------------------

//Below is a shitfest hack...this creates an average of 98 total entites per map (assuming 14 nodes)

local kPowerNodeSoundsDistance = 30	//??? Ideally always limited to prevent always propagating out


local kTakeDamageSound = PrecacheAsset("sound/NS2.fev/marine/power_node/take_damage")
local kDamagedSound = PrecacheAsset("sound/NS2.fev/marine/power_node/damaged")
local kDestroyedPowerDownSound = PrecacheAsset("sound/NS2.fev/marine/power_node/destroyed_powerdown")
local kAuxPowerBackupSound = PrecacheAsset("sound/NS2.fev/marine/power_node/backup")
local kPowerRestoredSound = PrecacheAsset("sound/NS2.fev/marine/power_node/fixed_powerup")


local function SetupSoundEntities( self )	
// *facepalm* god this is horribly hacky and wasteful...6 ents per node, ffs...
//BUT...normal Effects manager doesn't handle relevancy and entity trigger sound well...
	
	if Server then
		
		local defaultMask = bit.bor( kRelevantToTeam1Unit, kRelevantToTeam2Unit )
		
		self.takeDamageSound = Server.CreateEntity( SoundEffect.kMapName )	//this one especially is horrible...results is LOTS of messages...just horrid.
		self.takeDamageSound:SetAsset( kTakeDamageSound )
		self.takeDamageSound:SetRelevancyDistance( kPowerNodeSoundsDistance )
		self.takeDamageSound:SetExcludeRelevancyMask( defaultMask )
		self.takeDamageSound:SetKeepAlive( true )
		self.takeDamageSound:SetVolume(1)
		
		//Must be SetRelevancyDistance( Math.infinity ) from here on, or Comm view gets cut-off
		//and repeating sounds
		self.damagedSound = Server.CreateEntity( SoundEffect.kMapName )
		self.damagedSound:SetAsset( kDamagedSound )
		self.damagedSound:SetRelevancyDistance( Math.infinity )
		self.damagedSound:SetExcludeRelevancyMask( defaultMask )
		self.damagedSound:SetKeepAlive( true )
		self.damagedSound:SetVolume(0.7)
		
		self.destroyedPowerDownSound = Server.CreateEntity( SoundEffect.kMapName )
		self.destroyedPowerDownSound:SetAsset( kDestroyedPowerDownSound )
		self.destroyedPowerDownSound:SetRelevancyDistance( Math.infinity )
		self.destroyedPowerDownSound:SetExcludeRelevancyMask( defaultMask )
		self.destroyedPowerDownSound:SetKeepAlive( true )
		self.destroyedPowerDownSound:SetVolume(0.75)
		
		self.auxBackupSound = Server.CreateEntity( SoundEffect.kMapName )
		self.auxBackupSound:SetAsset( kAuxPowerBackupSound )
		self.auxBackupSound:SetRelevancyDistance( Math.infinity )
		self.auxBackupSound:SetExcludeRelevancyMask( defaultMask )
		self.auxBackupSound:SetKeepAlive( true )
		self.auxBackupSound:SetVolume(0.6)
		
		self.powerRestoredSound = Server.CreateEntity( SoundEffect.kMapName )
		self.powerRestoredSound:SetAsset( kPowerRestoredSound )
		self.powerRestoredSound:SetRelevancyDistance( kPowerNodeSoundsDistance )
		self.powerRestoredSound:SetExcludeRelevancyMask( Math.infinity )
		self.powerRestoredSound:SetKeepAlive( true )
		self.powerRestoredSound:SetVolume(0.7)
		
	end
	
end

/*
local function UpdateInitialSoundParams( self )
//Holy shit this is nasty...
	
	if self:GetNumChildren() > 0 then
	
		for i = 1, self:GetNumChildren() do
			
            local child = self:GetChildAtIndex(i - 1)
            
            if child and child:isa("SoundEffect") then
				
				if child.soundEffectInstance then
					child.soundEffectInstance:SetRolloff( SoundSystem.Rolloff_Linear )
				end
				
				//child:SetOrigin( self:GetOrigin() )
				
            else
				Print("ERROR: Failed to initialize PowerPoint SoundEffect for client at index: " .. tostring(i) )
            end
            
        end
	
	end		
	
	return false
	
end
*/

local function InitializeSoundEntities( self )

	if Server then
		
		local powerNodeOrigin = self:GetOrigin()	//Never moves, safe to use now
		
		self.takeDamageSound:SetOrigin( powerNodeOrigin )
		self.damagedSound:SetOrigin( powerNodeOrigin )
		self.destroyedPowerDownSound:SetOrigin( powerNodeOrigin )
		self.powerRestoredSound:SetOrigin( powerNodeOrigin )
		self.auxBackupSound:SetOrigin( powerNodeOrigin )
		
		self.takeDamageSound:SetPositional( true )
		self.damagedSound:SetPositional( true )
		self.destroyedPowerDownSound:SetPositional( true )
		self.powerRestoredSound:SetPositional( true )
		self.auxBackupSound:SetPositional( true )
	
	end
	
	if Client then
		//self:AddTimedCallback( UpdateInitialSoundParams, 0.5 )
		//FIXME Should NOT be a timed callback
	end

end


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
		self.canTakeDamageFlag = false
		self.timeLastDamageFlagUpdate = 0
	end
	
	SetupSoundEntities( self )
	
end


local function PlayAuxSound(self)
		
	if self:GetIsDisabled() and not self.auxBackupSound:GetIsPlaying() then
		self.auxBackupSound:Start()
	end
	
	if self.auxBackupSound:GetIsPlaying() and self:GetIsDisabled() then
		return true
	end
	
	if not self:GetIsDisabled() then
		self.auxBackupSound:Stop()
	end
	
	return false
	
end


local function SetupWithInitialSettings(self)	//Called in Reset()

    if self.startSocketed then
		
        self:SetInternalPowerState( PowerPoint.kPowerState.socketed )
        self:SetConstructionComplete()
        self:SetLightMode( kLightMode.Normal )
        self:SetPoweringState(true)
    
    else
		
        self:SetModel(kUnsocketedSocketModelName, kUnsocketedAnimationGraph)	//Hacky, but it works
        
        self:SetLightMode( kLightMode.NoPower )
        self.powerState = PowerPoint.kPowerState.unsocketed
        self.timeOfDestruction = 0
        
        if Server then
        
            self.startsBuilt = false
            self.attackTime = 0.0
            self:AddTimedCallback( PlayAuxSound, 4 )
            
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
    
    InitializeSoundEntities( self )
    
end


local orgPowernodeDestroy = PowerPoint.OnDestroy
function PowerPoint:OnDestroy()

	orgPowernodeDestroy( self )
	
	if Server then
	//This is stupid...just fucking stupid...
		DestroyEntity( self.takeDamageSound )
		self.takeDamageSound = nil
		
		DestroyEntity( self.destroyedPowerDownSound )
		self.destroyedPowerDownSound = nil
		
		DestroyEntity( self.damagedSound )
		self.damagedSound = nil
		
		DestroyEntity( self.auxBackupSound )
		self.auxBackupSound = nil
		
		DestroyEntity( self.powerRestoredSound )
		self.powerRestoredSound = nil
	
	end

end


function PowerPoint:GetIsDisabled()
    return (
		self:GetPowerState() == PowerPoint.kPowerState.destroyed or
		self:GetPowerState() == PowerPoint.kPowerState.unsocketed
	)
end


function PowerPoint:OnResetComplete()
end


function PowerPoint:GetDestroyMapBlipOnKill()
	return false
end


local function GetSoundRelevancyMask( self )
	
	local mask = bit.bor( kRelevantToTeam1Unit, kRelevantToTeam2Unit )
	if self.scoutedForTeam1 ~= false then
		mask = bit.bor( mask, kRelevantToTeam1Commander )
	end
	if self.scoutedForTeam2 ~= false then
		mask = bit.bor( mask, kRelevantToTeam2Commander )
	end
	
	return mask

end


local function UpdateAllSoundRelevancies( self )

	local mask = GetSoundRelevancyMask( self )
	
	self.takeDamageSound:SetExcludeRelevancyMask( mask )
	self.damagedSound:SetExcludeRelevancyMask( mask )
	self.destroyedPowerDownSound:SetExcludeRelevancyMask( mask )
	self.auxBackupSound:SetExcludeRelevancyMask( mask )
	self.powerRestoredSound:SetExcludeRelevancyMask( mask )

end


function PowerPoint:Reset()		//OVERRIDES

	self.scoutedForTeam1 = false
	self.scoutedForTeam2 = false
	self.isStartingPoint = false

	if Server then
		
		ScriptActor.Reset(self)
		
		SetupWithInitialSettings(self)
		self:MarkBlipDirty()
		self:UpdateRelevancy()
		
		UpdateAllSoundRelevancies( self )
		//???? Stop sounds?
		
		self.canTakeDamageFlag = false
		self.timeLastDamageFlagUpdate = 0
		
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
    return true	
	//false? To slow-down friendly fire? Eh...not a very good idea. Needs true capturing...
    //If above set to false, MASSIVE change needed to HP/AR
end


function PowerPoint:GetCanConstructOverride(player)
    return not self:GetIsBuilt() and self:GetPowerState() ~= PowerPoint.kPowerState.unsocketed
end


//Change to bool flag and run at X interval in OnUpdate?
function PowerPoint:GetCanTakeDamageOverride()
	return false
end


//FIXME Revise function, not having intended behavior
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
	
	return false, false
	
end


function PowerPoint:OverrideVisionRadius()
	return 2
end



if Client then
	
	function PowerPoint:GetIsVisible()	//This makes the dark/scouting magic happen
		
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
//Must always propogate to teams because difference in 1P and Comm light handling
	
	local mask = 0
	mask = bit.bor( mask, kRelevantToTeam1, kRelevantToTeam2 )
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
				//Deployed ARCs?
				local viewerTeam = viewer:GetTeamNumber()
				
				if viewerTeam == kTeam1Index then
					self.scoutedForTeam1 = true
				elseif viewerTeam == kTeam2Index then
					self.scoutedForTeam2 = true
				end
				
				UpdateAllSoundRelevancies( self )
				
			end
			
			//Force LOS checks to be run again
			//Required so BOTH teams have LOS checks performed on sighted event(s)
			self.lastSightedState = false
			self.updateLOS = true
			self.dirtyLOS = true
			
		end
		
		return seen
	
	end
	
	
	local function PowerUp( self )
		
        self:SetInternalPowerState( PowerPoint.kPowerState.socketed )
        self:SetLightMode( kLightMode.Normal )
		
		self.powerRestoredSound:Start()
		
        self:SetPoweringState( true )
        
    end
	
	
	function PowerPoint:OnConstructionComplete()	//OVERRIDES

        self:StopDamagedSound()
        
        self.health = kPowerPointHealth
        self.armor = kPowerPointArmor
        
        self:SetMaxHealth(kPowerPointHealth)
        self:SetMaxArmor(kPowerPointArmor)
        
        self.alive = true
        
        PowerUp(self)
        
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
        
        local powerState = self:GetPowerState()
        if self:GetHealthScalar() == 1 and ( powerState == PowerPoint.kPowerState.destroyed or powerState == PowerPoint.kPowerState.unsocketed ) then
        
            self:StopDamagedSound()
            
            self.health = kPowerPointHealth
            self.armor = kPowerPointArmor
            
            self.maxHealth = kPowerPointHealth
            self.maxArmor = kPowerPointArmor
            
            self.alive = true
            
            PowerUp( self )
            
        end
        
        if welded then
            self:AddAttackTime(-0.1)
        end
        
    end
    
    
    // send a message every kUnderAttackTeamMessageLimit seconds when a base power node is under attack
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
    
    
    function PowerPoint:StopDamagedSound()		//OVERRIDES
    
        if self.playingLoopedDamaged then
			
            self.damagedSound:Stop()
            self.playingLoopedDamaged = false
            
        end
        
    end
    
    
    function PowerPoint:StartDamagedSound()	//ADDED
    
		self.damagedSound:Start()
		self.playingLoopedDamaged = true
    
    end
    
    
    function PowerPoint:OnTakeDamage(damage, attacker, doer, point)		//OVERRIDES
		
        if self:GetIsPowering() then
			
			if self.attackTime == 0.0 or math.fmod( math.floor(self.attackTime), 2 ) == 0 then
			//FIXME This is a craptastic condition
				self.takeDamageSound:Start()
			end
            
            local healthScalar = self:GetHealthScalar()
            
            if healthScalar < kDamagedPercentage then
				
                self:SetLightMode( kLightMode.LowPower )
                
                if not self.playingLoopedDamaged then
					
                    self:StartDamagedSound()
                    
                end
                
            else
                self:SetLightMode( kLightMode.Damaged )
            end
            
			MvM_CheckSendDamageTeamMessage(self)
            
        end
        
        self:AddAttackTime(0.9)
        
    end
    
    
    local function MvM_CheckSendPowerDestroyedTeamMessage( self )
		
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
            SendTeamMessage( targetCommandStation:GetTeam(), kTeamMessageTypes.PowerLost, self:GetLocationId() )
        end
        
    end
    
    
    function PowerPoint:OnKill( attacker, doer, point, direction )	//OVERRIDES
    
        ScriptActor.OnKill( self, attacker, doer, point, direction )
        
        self:StopDamagedSound()
        
        self:MarkBlipDirty()
        
        self.destroyedPowerDownSound:Start()
        
        self:SetInternalPowerState( PowerPoint.kPowerState.destroyed )
        //self.constructionComplete = false
        self:SetLightMode( kLightMode.NoPower )
        
        // Remove effects such as parasite when destroyed.
        self:ClearGameEffects()
        
        //No scoring from neutral PNs - This will change once ownership added (PowerGrids)
        //if attacker and attacker:isa("Player") and GetEnemyTeamNumber(self:GetTeamNumber()) == attacker:GetTeamNumber() then
        //    attacker:AddScore(self:GetPointValue())
        //end
        
        // Let the team know the power is down.
        //SendTeamMessage(self:GetTeam(), kTeamMessageTypes.PowerLost, self:GetLocationId())
        MvM_CheckSendPowerDestroyedTeamMessage( self )
        
        // A few seconds later, switch on aux power.
        self:AddTimedCallback( PlayAuxSound, 4 )
        self.timeOfDestruction = Shared.GetTime()
        
    end

	
	function PowerPoint:UpdateTakeDamageState()	//this is slow and wasteful...just bad...
		
		local canBeDamaged = false
		local nodeLocation = GetLocationForPoint( self:GetOrigin() )
		local teamStructures = GetEntitiesWithinRange( "Structure", self:GetOrigin(), 850 )
		self.timeLastDamageFlagUpdate = Shared.GetTime()
		
		if teamStructures and #teamStructures > 0 then
			
			local teamNumPrev = 0
			local canBeDamaged = false
			local multiTeams = false
			
			for _, ent in ipairs(teamStructures) do
				
				if ent:GetLocationName() == nodeLocation:GetName() and HasMixin( ent, "Team") then
					
					if not ent:isa("Mine") then	//remove if can
						
						if teamNumPrev == 0 then
							teamNumPrev = ent:GetTeamNumber()
						else
							multiTeams = ent:GetTeamNumber() ~= teamNumPrev and MvM_GetIsUnitActive(ent)
						end
						
						if multiTeams then
							canBeDamaged = self.powerState ~= PowerPoint.kPowerState.unsocketed and self:GetIsBuilt() and self:GetHealth() > 0
						end
					
					end
					
				end
				
			end
			
		end
		
		self.canTakeDamageFlag = canBeDamaged

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
		
		//if self.timeLastDamageFlagUpdate + kTakeDamageFlagUpdateRate < Shared.GetTime() or self.timeLastDamageFlagUpdate == 0 then
			//self:UpdateTakeDamageState()
		//end
		
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

