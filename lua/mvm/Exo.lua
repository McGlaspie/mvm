

Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/WeldableMixin.lua")
Script.Load("lua/mvm/SelectableMixin.lua")
Script.Load("lua/mvm/DissolveMixin.lua")
if Client then
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
end


local newNetworkVars = {}

//-----------------------------------------------------------------------------

if Client then
	Shared.PrecacheSurfaceShader("cinematics/vfx_materials/heal_exo_team2_view.surface_shader")
end

local kExoHealViewMaterialNameTeam2 = "cinematics/vfx_materials/heal_exo_team2_view.material"

local kExoFirstPersonHitEffectName = PrecacheAsset("cinematics/marine/exo/hit_view.cinematic")
local kExoViewDamaged = PrecacheAsset("cinematics/marine/exo/hurt_view.cinematic")
local kExoViewHeavilyDamaged = PrecacheAsset("cinematics/marine/exo/hurt_severe_view.cinematic")

local kIdle2D = PrecacheAsset("sound/NS2.fev/marine/heavy/idle_2D")

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)


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


local oldExoInit = Exo.OnInitialized
function Exo:OnInitialized()
	
	oldExoInit(self)
	
	if Client then
		self:InitializeSkin()
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
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_BaseColor, kTeam1_BaseColor )
	end

	function Exo:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_AccentColor, kTeam1_AccentColor )
	end

	function Exo:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_TrimColor, kTeam1_TrimColor )
	end

end


function Exo:GetIsFlameAble()
	return false
end


function Exo:OnWeldOverride(doer, elapsedTime)

	if self:GetArmor() < self:GetMaxArmor() then
    
        local weldRate = kArmorWeldRatePlayer
        if doer and doer:isa("MAC") then
            weldRate = kArmorWeldRateMAC
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

end


//-----------------------------------------------------------------------------


Class_Reload("Exo", newNetworkVars)

