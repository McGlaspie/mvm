

Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/SelectableMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/ConstructMixin.lua")
Script.Load("lua/mvm/GhostStructureMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/WeldableMixin.lua")
Script.Load("lua/mvm/DissolveMixin.lua")
Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/PowerConsumerMixin.lua")
Script.Load("lua/mvm/SupplyUserMixin.lua")
Script.Load("lua/mvm/NanoshieldMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/mvm/RagdollMixin.lua")

if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
end


local newNetworkVars = {}

local kSpinEffect = PrecacheAsset("cinematics/marine/infantryportal/spin.cinematic")
local kSpinEffectTeam2 = PrecacheAsset("cinematics/marine/infantryportal/spin_team2.cinematic")
local kAnimationGraph = PrecacheAsset("models/marine/infantry_portal/infantry_portal.animation_graph")
local kHoloMarineModel = PrecacheAsset("models/marine/male/male_spawn.model")

local kHoloMarineMaterialname = "cinematics/vfx_materials/marine_ip_spawn_mvm.material"

if Client then
    Shared.PrecacheSurfaceShader("cinematics/vfx_materials/marine_ip_spawn_mvm.surface_shader")	//FIXME this needs some work, ugly atm
end

AddMixinNetworkVars( FireMixin, newNetworkVars )
AddMixinNetworkVars( DetectableMixin, newNetworkVars )
AddMixinNetworkVars( DissolveMixin, newNetworkVars )
AddMixinNetworkVars( ElectroMagneticMixin, newNetworkVars )


local kUpdateRate = 0.25
local kPushRange = 3
local kPushImpulseStrength = 40


//-----------------------------------------------------------------------------


local function MvMCreateSpinEffect(self)

    if not self.spinCinematic then
    
        self.spinCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        
        if self:GetTeamNumber() == kTeam2Index then
			self.spinCinematic:SetCinematic(kSpinEffectTeam2)
		else
			self.spinCinematic:SetCinematic(kSpinEffect)
		end
        
        self.spinCinematic:SetCoords(self:GetCoords())
        self.spinCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
    
    end
    
    //FIXME change to pull from what a player is (variant)
    if not self.fakeMarineModel and not self.fakeMarineMaterial then
    
        self.fakeMarineModel = Client.CreateRenderModel(RenderScene.Zone_Default)
        self.fakeMarineModel:SetModel( Shared.GetModelIndex( kHoloMarineModel ) )
        
        local coords = self:GetCoords()
        coords.origin = coords.origin + Vector(0, 0.5, 0)
        
        self.fakeMarineModel:SetCoords(coords)
        self.fakeMarineModel:InstanceMaterials()
        self.fakeMarineModel:SetMaterialParameter("hiddenAmount", 1.0)
        
        self.fakeMarineMaterial = AddMaterial(self.fakeMarineModel, kHoloMarineMaterialname)
    
    end
    
    if self.clientQueuedPlayerId ~= self.queuedPlayerId then
        self.timeSpinStarted = Shared.GetTime()
        self.clientQueuedPlayerId = self.queuedPlayerId
    end
    
    local spawnProgress = Clamp((Shared.GetTime() - self.timeSpinStarted) / kMarineRespawnTime, 0, 1)
    
    self.fakeMarineModel:SetIsVisible(true)
    self.fakeMarineMaterial:SetParameter("spawnProgress", spawnProgress + 0.2)    // Add a little so it always fills up
    
    local teamAccentColor = self:GetAccentSkinColor()
    self.fakeMarineMaterial:SetParameter("teamAccentR", teamAccentColor.r )
    self.fakeMarineMaterial:SetParameter("teamAccentG", teamAccentColor.g )
	self.fakeMarineMaterial:SetParameter("teamAccentB", teamAccentColor.b )

end

local function DestroySpinEffect(self)

    if self.spinCinematic then
    
        Client.DestroyCinematic(self.spinCinematic)    
        self.spinCinematic = nil
    
    end
    
    if self.fakeMarineModel then    
        self.fakeMarineModel:SetIsVisible(false)
    end

end

local function MvMStopSpinning(self)
	
	if self:GetTeamNumber() == kTeam2Index then
		self:TriggerEffects("infantry_portal_stop_spin_team2")
	else
		self:TriggerEffects("infantry_portal_stop_spin")
	end
	
    self.timeSpinUpStarted = nil
    
end



function InfantryPortal:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
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
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)
    
    InitMixin(self, FireMixin)
	InitMixin(self, DetectableMixin)
	InitMixin(self, ElectroMagneticMixin)
	
	
    if Client then
        InitMixin(self, CommanderGlowMixin)
        InitMixin(self, ColoredSkinsMixin)
    end
    
    if Server then
        self.timeLastPush = 0
    end
    
    self.queuedPlayerId = Entity.invalidId
    
    self:SetLagCompensated(true)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    
end


local function PushPlayers(self)

    for _, player in ipairs(GetEntitiesWithinRange("Player", self:GetOrigin(), 0.5)) do

        if player:GetIsAlive() and HasMixin(player, "Controller") then

            player:DisableGroundMove(0.1)
            player:SetVelocity(Vector(GetSign(math.random() - 0.5) * 2, 3, GetSign(math.random() - 0.5) * 2))

        end
        
    end

end


local function InfantryPortalUpdate(self)

    self:FillQueueIfFree()
    
    if MvM_GetIsUnitActive(self) then
        
        local remainingSpawnTime = self:GetSpawnTime()
        if self.queuedPlayerId ~= Entity.invalidId then
        
            local queuedPlayer = Shared.GetEntity(self.queuedPlayerId)
            if queuedPlayer then
            
                remainingSpawnTime = math.max(0, self.queuedPlayerStartTime + self:GetSpawnTime() - Shared.GetTime())
            
                if remainingSpawnTime < 0.3 and self.timeLastPush + 0.5 < Shared.GetTime() then
                
                    //PushPlayers(self)
                    self.timeLastPush = Shared.GetTime()
                    
                end
                
            else
            
                self.queuedPlayerId = nil
                self.queuedPlayerStartTime = nil
                
            end

        end
    
        if remainingSpawnTime == 0 then
            self:FinishSpawn()
        end
        
        // Stop spinning if player left server, switched teams, etc.
        if self.timeSpinUpStarted and self.queuedPlayerId == Entity.invalidId then
            MvMStopSpinning(self)
        end
        
    end
    
    return true
    
end



function InfantryPortal:OnInitialized()		//OVERRIDES

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    self:SetModel(InfantryPortal.kModelName, kAnimationGraph)
    
    if Server then
		
        self:AddTimedCallback( InfantryPortalUpdate, kUpdateRate )
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        //InitMixin(self, InfestationTrackerMixin)
        InitMixin(self, SupplyUserMixin)
        
    elseif Client then
		
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
        self:InitializeSkin()
        
    end
    
    InitMixin(self, IdleMixin)
    
end


function InfantryPortal:OverrideVisionRadius()
	return 3
end

function InfantryPortal:GetIsVulnerableToEMP()
	return false
end


// Spawn player on top of IP. Returns true if it was able to, false if way was blocked.
local function MvMSpawnPlayer(self)

    if self.queuedPlayerId ~= Entity.invalidId then
    
        local queuedPlayer = Shared.GetEntity(self.queuedPlayerId)
        local team = queuedPlayer:GetTeam()
        
        // Spawn player on top of IP
        local spawnOrigin = self:GetAttachPointOrigin("spawn_point")
        
        local success, player = team:ReplaceRespawnPlayer(queuedPlayer, spawnOrigin, queuedPlayer:GetAngles())
        if success then
        
            player:SetCameraDistance(0)
			if GetHasTech( player, kTechId.NanoShieldTech ) and HasMixin(player, "NanoShieldAble") then
				player:ActivateNanoShield( kNanoShieldOnSpawnLength )
			end
			
            self.queuedPlayerId = Entity.invalidId
            self.queuedPlayerStartTime = nil
            
            player:ProcessRallyOrder(self)
            
            self:TriggerEffects("infantry_portal_spawn")            
            
            return true
            
        else
            Print("Warning: Infantry Portal failed to spawn the player")
        end
        
    end
    
    return false

end




if Client then

	function InfantryPortal:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
	end

	function InfantryPortal:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end
	
	function InfantryPortal:GetAccentSkinColor()
		if self:GetIsBuilt() then
			return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
		else
			return Color( 0,0,0 )
		end
	end

	function InfantryPortal:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

	
	function InfantryPortal:OnUpdate(deltaTime)

        PROFILE("InfantryPortal:OnUpdate")
        
        ScriptActor.OnUpdate(self, deltaTime)
        
        if self.preventSpinDuration then            
            self.preventSpinDuration = math.max(0, self.preventSpinDuration - deltaTime)         
        end

        local shouldSpin = MvM_GetIsUnitActive(self) and self.queuedPlayerId ~= Entity.invalidId and (self.preventSpinDuration == nil or self.preventSpinDuration == 0)
        
        if shouldSpin then
            MvMCreateSpinEffect(self)
        else
            DestroySpinEffect(self)
        end
        
    end
	

end


//-----------------------------------------------------------------------------


if Server then
	ReplaceLocals( InfantryPortal.FinishSpawn, { SpawnPlayer = MvMSpawnPlayer } )
end

Class_Reload("InfantryPortal", newNetworkVars)

