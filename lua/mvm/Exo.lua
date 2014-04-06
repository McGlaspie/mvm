

Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/WeldableMixin.lua")
Script.Load("lua/mvm/SelectableMixin.lua")
Script.Load("lua/mvm/NanoshieldMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")

if Client then
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
	//TODO Add IFFMixin
end


local newNetworkVars = {}

AddMixinNetworkVars( FireMixin, newNetworkVars )
AddMixinNetworkVars( LOSMixin, newNetworkVars )
AddMixinNetworkVars( DetectableMixin, newNetworkVars )
AddMixinNetworkVars( ElectroMagneticMixin, newNetworkVars )


//-----------------------------------------------------------------------------


if Client then
	Shared.PrecacheSurfaceShader("cinematics/vfx_materials/heal_exo_team2_view.surface_shader")
end

local kExoHealViewMaterialNameTeam2 = "cinematics/vfx_materials/heal_exo_team2_view.material"

local kExoFirstPersonHitEffectName = PrecacheAsset("cinematics/marine/exo/hit_view.cinematic")
local kExoViewDamaged = PrecacheAsset("cinematics/marine/exo/hurt_view.cinematic")
local kExoViewHeavilyDamaged = PrecacheAsset("cinematics/marine/exo/hurt_severe_view.cinematic")

local kHealthWarning = PrecacheAsset("sound/NS2.fev/marine/heavy/warning")
local kHealthWarningTrigger = 0.4

local kHealthCritical = PrecacheAsset("sound/NS2.fev/marine/heavy/critical")
local kHealthCriticalTrigger = 0.2

local kWalkMaxSpeed = 3.6       //3.7
local kMaxSpeed = 5.35           //6
local kViewOffsetHeight = 2.3
local kAcceleration = 35        //20

local kIdle2D = PrecacheAsset("sound/NS2.fev/marine/heavy/idle_2D")

local kFlareCinematicTeam1 = PrecacheAsset("cinematics/marine/exo/lens_flares_team1.cinematic")
local kFlareCinematicTeam2 = PrecacheAsset("cinematics/marine/exo/lens_flares_team2.cinematic")

local kThrusterCinematic = PrecacheAsset("cinematics/marine/exo/thruster.cinematic")
local kThrusterLeftAttachpoint = "Exosuit_LFoot"
local kThrusterRightAttachpoint = "Exosuit_RFoot"
local kFlaresAttachpoint = "Exosuit_UpprTorso"

local kDeploy2DSound = PrecacheAsset("sound/NS2.fev/marine/heavy/deploy_2D")


local kThrusterUpwardsAcceleration = 2
local kThrusterHorizontalAcceleration = 23
// added to max speed when using thrusters
local kHorizontalThrusterAddSpeed = 2.5

local kExoEjectDuration = 3

local gHurtCinematic = nil


//-----------------------------------------------------------------------------


function Exo:OnCreate()	//OVERRIDES

    Player.OnCreate(self)
    
    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kExoFov })
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    InitMixin(self, WeldableMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, TunnelUserMixin)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, MarineActionFinderMixin)
    InitMixin(self, WebableMixin)
    InitMixin(self, MarineVariantMixin)
    
    InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, ElectroMagneticMixin)
    
    self:SetIgnoreHealth(true)
    
    self.deployed = false
    
    self.flashlightOn = false
    self.flashlightLastFrame = false
    self.idleSound2DId = Entity.invalidId
    self.timeThrustersEnded = 0
    self.timeThrustersStarted = 0
    self.inventoryWeight = 0
    self.thrusterMode = kExoThrusterMode.Vertical
    self.catpackboost = false
    self.timeCatpackboost = 0
    self.ejecting = false
    
    self.creationTime = Shared.GetTime()
    
    if Server then
    
        self.idleSound2D = Server.CreateEntity(SoundEffect.kMapName)
        self.idleSound2D:SetAsset( kIdle2D )
        self.idleSound2D:SetParent(self)
        self.idleSound2D:Start()
        
        // Only sync 2D sound with this Exo player.
        self.idleSound2D:SetPropagate(Entity.Propagate_Callback)
        function self.idleSound2D.OnGetIsRelevant(_, player)
            return player == self
        end
        
        self.idleSound2DId = self.idleSound2D:GetId()
        
    elseif Client then
    
        InitMixin(self, ColoredSkinsMixin)
        InitMixin(self, CommanderGlowMixin)
		
		self.flashlight = Client.CreateRenderLight()
        
        self.flashlight:SetType(RenderLight.Type_Spot)
        if self:GetTeamNumber() == kTeam2Index then
			self.flashlight:SetColor( Color(1, 0.5, 0.5) )
		else
			self.flashlight:SetColor( Color(0.5, 0.5, 1) )
		end
        self.flashlight:SetInnerCone(math.rad(32))
        self.flashlight:SetOuterCone(math.rad(48))
        self.flashlight:SetIntensity(18)
        self.flashlight:SetRadius(26)
        self.flashlight:SetGoboTexture("models/marine/male/flashlight.dds")
        self.flashlight:SetAtmosphericDensity( 0.25 )
        
        self.flashlight:SetIsVisible(false)
        
        self.idleSound2DId = Entity.invalidId

    end
	
end


function Exo:OnInitialized()	//OVERRIDES

    // Only set the model on the Server, the Client
    // will already have the correct model at this point.
    if Server then    
        self:InitExoModel()
    end
    
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kPlayerMoveOrderCompleteDistance })
    InitMixin(self, NanoShieldMixin)
    
    Player.OnInitialized(self)
    
    if Server then
    
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        self.armor = self:GetArmorAmount()
        self.maxArmor = self.armor
        
        self.thrustersActive = false
        
    elseif Client then
    
        InitMixin(self, HiveVisionMixin)
        InitMixin(self, MarineOutlineMixin)	//??
        
        self:InitializeSkin()
        
        self.clientThrustersActive = self.thrustersActive

        self.thrusterLeftCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        self.thrusterLeftCinematic:SetCinematic(kThrusterCinematic)
        self.thrusterLeftCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.thrusterLeftCinematic:SetParent(self)
        self.thrusterLeftCinematic:SetCoords(Coords.GetIdentity())
        self.thrusterLeftCinematic:SetAttachPoint(self:GetAttachPointIndex(kThrusterLeftAttachpoint))
        self.thrusterLeftCinematic:SetIsVisible(false)
        
        self.thrusterRightCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        self.thrusterRightCinematic:SetCinematic(kThrusterCinematic)
        self.thrusterRightCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.thrusterRightCinematic:SetParent(self)
        self.thrusterRightCinematic:SetCoords(Coords.GetIdentity())
        self.thrusterRightCinematic:SetAttachPoint(self:GetAttachPointIndex(kThrusterRightAttachpoint))
        self.thrusterRightCinematic:SetIsVisible(false)
        
        self.flares = Client.CreateCinematic(RenderScene.Zone_Default)
        self.flares:SetCinematic(
			ConditionalValue(
				self:GetTeamNumber() == kTeam1Index,
				kFlareCinematicTeam1,
				kFlareCinematicTeam2
			)
		)
        self.flares:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.flares:SetParent(self)
        self.flares:SetCoords(Coords.GetIdentity())
        self.flares:SetAttachPoint(self:GetAttachPointIndex(kFlaresAttachpoint))
        self.flares:SetIsVisible(false)
        
        self:AddHelpWidget("GUITunnelEntranceHelp", 1)
        
    end
    
end


local function MvM_ShowHUD(self, show)

    assert(Client)
    
    if ClientUI.GetScript("mvm/Hud/Marine/GUIMarineHUD") then
        ClientUI.GetScript("mvm/Hud/Marine/GUIMarineHUD"):SetIsVisible(show)
    end
    
    if ClientUI.GetScript("mvm/Hud/Exo/GUIExoHUD") then
        ClientUI.GetScript("mvm/Hud/Exo/GUIExoHUD"):SetIsVisible(show)
    end
    
end


if Client then

	function Exo:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = self:GetTeamNumber() - 1
	end

	function Exo:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_BaseColor, kTeam2_BaseColor )
	end

	function Exo:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_AccentColor, kTeam2_AccentColor )
	end

	function Exo:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_TrimColor, kTeam2_TrimColor )
	end

end


function Exo:GetIsVulnerableToEMP()
	return true
end

function Exo:OnOverrideCanSetFire()
	return true
end

local function UpdateHealthWarningTriggered(self)

    local healthPercent = self:GetArmorScalar()
    
    if healthPercent > kHealthWarningTrigger then
        self.healthWarningTriggered = false
    end
    
    if healthPercent > kHealthCriticalTrigger then
        self.healthCriticalTriggered = false
    end
    
end


function Exo:OnWeldOverride(doer, elapsedTime)

	if self:GetArmor() < self:GetMaxArmor() then
    
        local weldRate = kPlayerWeldRate
        if doer and doer:isa("MAC") then
            weldRate = MAC.kRepairHealthPerSecond
        end
      
        local addArmor = weldRate * elapsedTime
        
        if self:GetIsOnFire() then
			addArmor = addArmor * kWhileBurningWeldEffectReduction
        end
        
        self:SetArmor(self:GetArmor() + addArmor)
        
        if Server then
            UpdateHealthWarningTriggered(self)
        end
        
    end

end


if Client then	//Required to override Armor display

	
    function Exo:OnUpdateRender()
    
        PROFILE("Exo:OnUpdateRender")
        
        Player.OnUpdateRender(self)
        
        local isLocal = self:GetIsLocalPlayer()
        local flashLightVisible = self.flashlightOn and (isLocal or self:GetIsVisible()) and self:GetIsAlive()
        local flaresVisible = flashLightVisible and (not isLocal or self:GetIsThirdPerson())
        
        // Synchronize the state of the light representing the flash light.
        self.flashlight:SetIsVisible(flashLightVisible)
        self.flares:SetIsVisible(flaresVisible)
        
        if self.flashlightOn then
        
            local coords = Coords(self:GetViewCoords())
            coords.origin = coords.origin + coords.zAxis * 0.75
            
            self.flashlight:SetCoords(coords)
            
            // Only display atmospherics for third person players.
            local density = 0.025
            if isLocal and not self:GetIsThirdPerson() then
                density = 0.025
            end
            
            self.flashlight:SetAtmosphericDensity(density)
            
        end
        
        if self:GetIsLocalPlayer() then
        
            local armorDisplay = self.armorDisplay
            if not armorDisplay then
				
                armorDisplay = Client.CreateGUIView(256, 256, true)
                armorDisplay:Load("lua/mvm/Hud/Exo/GUIExoArmorDisplay.lua")
                armorDisplay:SetTargetTexture("*exo_armor")
                self.armorDisplay = armorDisplay
				
            end
            
            local armorAmount = self:GetIsAlive() and math.ceil(math.max(1, self:GetArmor())) or 0
            
            armorDisplay:SetGlobal("armorAmount", armorAmount)
            armorDisplay:SetGlobal("teamNumber", self:GetTeamNumber())
            
            // damaged effects for view model. triggers when under 60% and a stronger effect under 30%. every 3 seconds and non looping, so the effects fade out when healed up
            if not self.timeLastDamagedEffect or self.timeLastDamagedEffect + 3 < Shared.GetTime() then
            
                local healthScalar = self:GetHealthScalar()
                
                if healthScalar < .7 then
                
                    local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
                    local cinematicName = kExoViewDamaged
                    
                    if healthScalar < .4 then
                        cinematicName = kExoViewHeavilyDamaged
                    end
                    
                    cinematic:SetCinematic(cinematicName)
                
                end
                
                self.timeLastDamagedEffect = Shared.GetTime()
                
            end
            
        elseif self.armorDisplay then
        
            Client.DestroyGUIView(self.armorDisplay)
            self.armorDisplay = nil
            
        end
        
    end
    
    
    ReplaceLocals( Exo.UpdateClientEffects, { ShowHUD = MvM_ShowHUD } )
    

end


//-----------------------------------------------------------------------------


Class_Reload( "Exo", newNetworkVars )

