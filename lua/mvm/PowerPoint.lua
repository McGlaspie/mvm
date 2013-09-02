

Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/PostLoadMod.lua")


local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)


if Client then	//????
	PowerPoint.kDisabledColor = Color(0.013, 0.013, 0.013)		//Move to globals.lua?
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
local kUnderAttackTeamMessageLimit = 5

// max amount of "attack" the powerpoint has suffered (?)
local kMaxAttackTime = 10


//-----------------------------------------------------------------------------

function PowerPoint:OnCreate()
	
	ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, PowerSourceMixin)
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, WeldableMixin)
    InitMixin(self, FireMixin)
    //InitMixin(self, PointGiverMixin)	// No points given for a neutral structure
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
    self.lightMode = kLightMode.Normal
    self.powerState = PowerPoint.kPowerState.unsocketed

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

function PowerPoint:GetReceivesStructuralDamage()
    return true	//false? To slow-down friendly fire? Eh...
end

function PowerPoint:GetCanConstructOverride(player)
    return not self:GetIsBuilt() and self:GetPowerState() ~= PowerPoint.kPowerState.unsocketed --and GetAreFriends(player,self)
end


if Server then

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
    local function MvM_CheckSendDamageTeamMessage(self)

        if not self.timePowerNodeAttackAlertSent or self.timePowerNodeAttackAlertSent + kUnderAttackTeamMessageLimit < Shared.GetTime() then

            // Check if there is a built Command Station in the same location as this PowerPoint.
            local foundStation = false
            //**********************
            //FIXME - Change to use self:GetLocation() and send message to that Station's team
            //**********************
            local stations = GetEntitiesForTeam("CommandStation", self:GetTeamNumber())
            for s = 1, #stations do
            
                local station = stations[s]
                if station:GetIsBuilt() and station:GetLocationName() == self:GetLocationName() then
                    foundStation = true
                end
                
            end
            
            // Only send the message if there was a CommandStation found at this same location.
            if foundStation then
                SendTeamMessage(self:GetTeam(), kTeamMessageTypes.PowerPointUnderAttack, self:GetLocationId())
                self:GetTeam():TriggerAlert(kTechId.MarineAlertStructureUnderAttack, self, true)
            end
            
            self.timePowerNodeAttackAlertSent = Shared.GetTime()
        end
        
    end
    
    
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
            
            MvM_CheckSendDamageTeamMessage(self)
        end
        
        self:AddAttackTime(0.9)
    end
    
    
    

end //Server


//-----------------------------------------------------------------------------

Class_Reload("PowerPoint", newNetworkVars)

