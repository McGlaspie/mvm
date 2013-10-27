

Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/PostLoadMod.lua")	//this really needed for all scripts that call override stuffs?


local newNetworkVars = {}

//-----------------------------------------------------------------------------

if Client then
	Shared.PrecacheSurfaceShader("cinematics/vfx_materials/heal_exo_team2_view.surface_shader")
end

local kExoHealViewMaterialNameTeam2 = "cinematics/vfx_materials/heal_exo_team2_view.material"

local kExoFirstPersonHitEffectName = PrecacheAsset("cinematics/marine/exo/hit_view.cinematic")
local kExoViewDamaged = PrecacheAsset("cinematics/marine/exo/hurt_view.cinematic")
local kExoViewHeavilyDamaged = PrecacheAsset("cinematics/marine/exo/hurt_severe_view.cinematic")


AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

//-----------------------------------------------------------------------------


local oldExoCreate = Exo.OnCreate
function Exo:OnCreate()
	
	oldExoCreate(self)
	
	InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
	
	if Client then
		
		if self.flashlight ~= nil then
			Client.DestroyRenderLight(self.flashlight)
		end
		
		self.flashlight = Client.CreateRenderLight()
        
        self.flashlight:SetType(RenderLight.Type_Spot)
        self.flashlight:SetColor(Color(.8, .8, 1))
        self.flashlight:SetInnerCone(math.rad(30))
        self.flashlight:SetOuterCone(math.rad(45))
        self.flashlight:SetIntensity(10)
        self.flashlight:SetRadius(25)
        //self.flashlight:SetGoboTexture("models/marine/male/flashlight.dds")
        
        self.flashlight:SetIsVisible(false)
	
		InitMixin(self, ColoredSkinsMixin)
		
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

