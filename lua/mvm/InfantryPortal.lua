

Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/mvm/PowerConsumerMixin.lua")
Script.Load("lua/PostLoadMod.lua")
Script.Load("lua/mvm/SupplyUserMixin.lua")

local newNetworkVars = {}

local kSpinEffect = PrecacheAsset("cinematics/marine/infantryportal/spin.cinematic")
local kSpinEffectTeam2 = PrecacheAsset("cinematics/marine/infantryportal/spin_team2.cinematic")
local kAnimationGraph = PrecacheAsset("models/marine/infantry_portal/infantry_portal.animation_graph")
local kHoloMarineModel = PrecacheAsset("models/marine/male/male_spawn.model")

local kHoloMarineMaterialname = "cinematics/vfx_materials/marine_ip_spawn.material"

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)


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
    self.fakeMarineMaterial:SetParameter("spawnProgress", spawnProgress+0.2)    // Add a little so it always fills up

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


local oldIPcreate = InfantryPortal.OnCreate
function InfantryPortal:OnCreate()

	oldIPcreate(self)
	
	InitMixin(self, FireMixin)
	InitMixin(self, DetectableMixin)

	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end

end


local function InfantryPortalUpdate(self)

    self:FillQueueIfFree()
    
    if GetIsUnitActive(self) then
    
        if self:SpawnTimeElapsed() then
            self:FinishSpawn()
        end
        
        // Stop spinning if player left server, switched teams, etc.
        if self.timeSpinUpStarted and self.queuedPlayerId == Entity.invalidId then
            MvMStopSpinning(self)
        end
        
    end
    
    return true
    
end


local orgInfantryPortalInit = InfantryPortal.OnInitialized
function InfantryPortal:OnInitialized()

	orgInfantryPortalInit(self)
	
	if Client then
		self:InitializeSkin()
	end

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

        local shouldSpin = GetIsUnitActive(self) and self.queuedPlayerId ~= Entity.invalidId and (self.preventSpinDuration == nil or self.preventSpinDuration == 0)
        
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

