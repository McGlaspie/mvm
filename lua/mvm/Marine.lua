

Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
//Script.Load("lua/mvm/SprintMixin.lua")	Future use
Script.Load("lua/PostLoadMod.lua")


if Client then
    Script.Load("lua/mvm/TeamMessageMixin.lua")
end


//Is below even needed now?
Script.Load("lua/Alien_Upgrade.lua")		//FIXME Refactor out the required functions into separate files

Shared.PrecacheSurfaceShader("models/marine/marine_noemissive.surface_shader")

Marine.kMaxSprintFov = 95
// Player phase delay - players can only teleport this often
Marine.kPlayerPhaseDelay = 1.5	//2		Move to BalanceMisc?

//Move below to BalanceMisc?
Marine.kWalkMaxSpeed = 5                // Four miles an hour = 6,437 meters/hour = 1.8 meters/second (increase for FPS tastes)
Marine.kRunMaxSpeed = 6               // 10 miles an hour = 16,093 meters/hour = 4.4 meters/second (increase for FPS tastes)
Marine.kRunInfestationMaxSpeed = 5.2    // 10 miles an hour = 16,093 meters/hour = 4.4 meters/second (increase for FPS tastes)

// How fast does our armor get repaired by welders
Marine.kArmorWeldRate = 25		//Move to BalanceHealth?
Marine.kWeldedEffectsInterval = .5

//Marine.kSpitSlowDuration = 3
Marine.kWalkBackwardSpeedScalar = 0.85
Marine.kAcceleration = 90	//100
Marine.kSprintAcceleration = 190 // 70
Marine.kGroundFrictionForce = 16
Marine.kAirStrafeWeight = 0		//May need to add back in for JP - Can stop on a dime with JP...


local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

//-----------------------------------------------------------------------------


function Marine:OnCreate()	//OVERRIDE

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, LadderMoveMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kDefaultFov })
    InitMixin(self, MarineActionFinderMixin)
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, SelectableMixin)
    
    Player.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, WebableMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, TunnelUserMixin)
    InitMixin(self, PhaseGateUserMixin)
    InitMixin(self, PredictedProjectileShooterMixin)
    InitMixin(self, MarineVariantMixin)
    
    if Server then
    
        self.timePoisoned = 0
        self.poisoned = false
        
        // stores welder / builder progress
        self.unitStatusPercentage = 0
        self.timeLastUnitPercentageUpdate = 0
        
    elseif Client then
		
		InitMixin(self, TeamMessageMixin, { kGUIScriptName = "mvm/Hud/Marine/GUIMarineTeamMessage" })
        InitMixin(self, DisorientableMixin)
		InitMixin(self, ColoredSkinsMixin)
		
		if self.flashlight ~= nil then
			Client.DestroyRenderLight(self.flashlight)
		end
		
        self.flashlight = Client.CreateRenderLight()
        
        self.flashlight:SetType( RenderLight.Type_Spot )
        if self:GetTeamNumber() == kTeam2Index then
			self.flashlight:SetColor( Color(1, 0.5, 0.5) )
		else
			self.flashlight:SetColor( Color(0.5, 0.5, 1) )
		end
        self.flashlight:SetInnerCone( math.rad(12) )
        self.flashlight:SetOuterCone( math.rad(32) )
        self.flashlight:SetIntensity( 10 )
        self.flashlight:SetRadius( 16 ) 	//15
        self.flashlight:SetGoboTexture("models/marine/male/flashlight.dds")
        self.flashlight:SetIsVisible(false)
        self.flashlight:SetAtmosphericDensity( 0.015 )
        
    end

end


function Marine:OnInitialized()	//OVERRIDE

    // work around to prevent the spin effect at the infantry portal spawned from
    // local player should not see the holo marine model
    if Client and Client.GetIsControllingPlayer() then
    
        local ips = GetEntitiesForTeamWithinRange("InfantryPortal", self:GetTeamNumber(), self:GetOrigin(), 1)
        if #ips > 0 then
            Shared.SortEntitiesByDistance(self:GetOrigin(), ips)
            ips[1]:PreventSpinEffect(0.2)
        end
    
    end

    // These mixins must be called before SetModel because SetModel eventually
    // calls into OnUpdatePoseParameters() which calls into these mixins.
    // Yay for convoluted class hierarchies!!!
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kPlayerMoveOrderCompleteDistance })
    InitMixin(self, OrderSelfMixin, { kPriorityAttackTargets = { "Extractor" } })	//This alone could be a mixin...
    InitMixin(self, StunMixin)
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, SprintMixin)
    InitMixin(self, WeldableMixin)
    
    // SetModel must be called before Player.OnInitialized is called so the attach points in
    // the Marine are valid to attach weapons to. This is far too subtle...
    self:SetModel(Marine.kModelName, Marine.kMarineAnimationGraph)
    
    Player.OnInitialized(self)
    
    // Calculate max and starting armor differently
    self.armor = 0
    
    if Server then
    
        self.armor = self:GetArmorAmount()
        self.maxArmor = self.armor
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
       
    elseif Client then
    
        //InitMixin(self, HiveVisionMixin)
        
        self:AddHelpWidget("GUIMarineHealthRequestHelp", 2)
        self:AddHelpWidget("GUIMarineFlashlightHelp", 2)
        self:AddHelpWidget("GUIBuyShotgunHelp", 2)
        self:AddHelpWidget("GUIMarineWeldHelp", 2)
        self:AddHelpWidget("GUIMapHelp", 1)
        
		self.notifications = { }
		
		self:InitializeSkin()	//Colorized skins system
		
    end
    
    self.weaponDropTime = 0
    self.timeOfLastPhase = 0
    
    local viewAngles = self:GetViewAngles()
    self.lastYaw = viewAngles.yaw
    self.lastPitch = viewAngles.pitch
    
    // -1 = leftmost, +1 = right-most
    self.horizontalSwing = 0
    // -1 = up, +1 = down
    
    self.timeLastSpitHit = 0
    self.lastSpitDirection = Vector(0, 0, 0)
    self.timeOfLastDrop = 0
    self.timeOfLastPickUpWeapon = 0
    self.ruptured = false
    self.interruptAim = false
    
    self.catpackboost = false
    self.timeCatpackboost = 0
    
    self.flashlightLastFrame = false
    
end


if Client then

	function Marine:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = self:GetTeamNumber() - 1
	end
	
	function Marine:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function Marine:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end
	
	function Marine:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


function Marine:GetSlowOnLand()
    return false	--REMOVED
end


function Marine:GetIsFlameAble()
    return false	//causing WAY too much damage
end


function Marine:OnWeldOverride(doer, elapsedTime)

    if self:GetArmor() < self:GetMaxArmor() then
    
        local addArmor = Marine.kArmorWeldRate * elapsedTime
        
        if HasMixin(self, "Fire") and self:GetIsOnFire() then
			addArmor = addArmor * kWhileBurningWeldEffectReduction
        end
        
        self:SetArmor(self:GetArmor() + addArmor)
        
    end
    
end

//OVERRIDES
function Marine:OnProcessMove(input)

    if self.catpackboost then
        self.catpackboost = Shared.GetTime() - self.timeCatpackboost < kCatPackDuration
    end
	
    if Server then
    
		//self.ruptured = Shared.GetTime() - self.timeRuptured < Rupture.kDuration
		//self.interruptAim  = Shared.GetTime() - self.interruptStartTime < Gore.kAimInterruptDuration
        
        if self.unitStatusPercentage ~= 0 and self.timeLastUnitPercentageUpdate + 2 < Shared.GetTime() then
            self.unitStatusPercentage = 0
        end    
        
        /*
        if self.poisoned then
        
            if self:GetIsAlive() and self.timeLastPoisonDamage + 1 < Shared.GetTime() then
            
                local attacker = Shared.GetEntity(self.lastPoisonAttackerId)
            
                local currentHealth = self:GetHealth()
                local poisonDamage = kBitePoisonDamage
                
                // never kill the marine with poison only
                if currentHealth - poisonDamage < kPoisonDamageThreshhold then
                    poisonDamage = math.max(0, currentHealth - kPoisonDamageThreshhold)
                end
                
                self:DeductHealth(poisonDamage, attacker, nil, true)
                self.timeLastPoisonDamage = Shared.GetTime()   
                
            end
            
            if self.timePoisoned + kPoisonBiteDuration < Shared.GetTime() then
            
                self.timePoisoned = 0
                self.poisoned = false
                
            end
            
        end
        */
        
        // check nano armor
        if not self:GetIsInCombat() and self.hasNanoArmor then            
            self:SetArmor(self:GetArmor() + input.time * kNanoArmorHealPerSecond, true)            
        end
        
    end
    
    Player.OnProcessMove(self, input)
    
end





if Server then	
	
	local orgMarineKill = Marine.OnKill
	function Marine:OnKill( attacker, doer, point, direction )
	
		orgMarineKill(self, attacker, doer, point, direction )
		
		if doer then
			
			if doer:isa("Railgun") then
			
				Print("\t Marine:OnKill() - Trigger railgun_death effect")
				GetEffectManager():TriggerEffects(
					"railgun_death", 
					{ 
						effecthostcoords = Coords.GetTranslation( self:GetOrigin()) 
					} 
				)
				
			end
			
		end
		
	end
	

end	//Server


//-------------------------------------


if Client then
	
	
	function Marine:OnCountDown()
		Player.OnCountDown(self)
		ClientUI.GetScript("mvm/GUIMarineHUD"):SetIsVisible(false)	
	end

	function Marine:OnCountDownEnd()
		Player.OnCountDownEnd(self)
		ClientUI.GetScript("mvm/GUIMarineHUD"):SetIsVisible(true)
		ClientUI.GetScript("mvm/GUIMarineHUD"):TriggerInitAnimations()
	end
	
	
	function Marine:UpdateClientEffects(deltaTime, isLocal)
		
		Player.UpdateClientEffects(self, deltaTime, isLocal)
		
		if isLocal then
			Client.SetMouseSensitivityScalar(ConditionalValue(self:GetIsStunned(), 0, 1))
			
			self:UpdateGhostModel()
			
			local marineHUD = ClientUI.GetScript("mvm/GUIMarineHUD")
			if marineHUD then
				marineHUD:SetIsVisible(self:GetIsAlive())
			end
			
			if self.buyMenu then
				if not self:GetIsAlive() or not GetIsCloseToMenuStructure(self) then
					self:CloseMenu()
				end
			end    
			
			if Player.screenEffects.disorient then
				Player.screenEffects.disorient:SetParameter("time", Client.GetTime())
			end
			
			local stunned = HasMixin(self, "Stun") and self:GetIsStunned()
			local blurEnabled = self.buyMenu ~= nil or stunned or self:GetIsMinimapVisible()
			self:SetBlurEnabled(blurEnabled)
			
			// update spit hit effect
			//if not Shared.GetIsRunningPrediction() then
			//end
			
		end
		
		//if self._renderModel then
		//end
		
	end

	
	//lowered flashlight haze
	function Marine:OnUpdateRender()
	
		PROFILE("Marine:OnUpdateRender")
		
		Player.OnUpdateRender(self)
		
		local isLocal = self:GetIsLocalPlayer()
		
		// Synchronize the state of the light representing the flash light.
		self.flashlight:SetIsVisible(self.flashlightOn and (isLocal or self:GetIsVisible()) )
		
		if self.flashlightOn then
		
			local coords = Coords(self:GetViewCoords())
			coords.origin = coords.origin + coords.zAxis * 0.75
			
			self.flashlight:SetCoords(coords)
			
			// Only display atmospherics for third person players.
			local density = 0.0185
			/*
			if isLocal and not self:GetIsThirdPerson() then
				density = 0.025
			end
			*/
			self.flashlight:SetAtmosphericDensity(density)
			
		end
		
	end
	
	
	function Marine:TriggerFootstep()
		Player.TriggerFootstep(self)
	end
	

//-------------------------------------
	
	
	local kSensorBlipSize = 25
	function PlayerUI_GetSensorBlipInfo()

		PROFILE("PlayerUI_GetSensorBlipInfo")
		
		local player = Client.GetLocalPlayer()
		local blips = {}
		
		if player then
		
			local eyePos = player:GetEyePos()
			for index, blip in ientitylist(Shared.GetEntitiesWithClassname("SensorBlip")) do
			
				local blipOrigin = blip:GetOrigin()
				local blipEntId = blip.entId
				local blipName = ""
				
				// Lookup more recent position of blip
				local blipEntity = Shared.GetEntity(blipEntId)
				
				// Do not display a blip for the local player.
				if blipEntity ~= player then

					local obstructed = true

					if blipEntity then
					
						if blipEntity:isa("Player") then
							blipName = Scoreboard_GetPlayerData(blipEntity:GetClientIndex(), kScoreboardDataIndexName)
						elseif blipEntity.GetTechId then
							blipName = GetDisplayNameForTechId(blipEntity:GetTechId())
						end
						
						if not player:isa("Commander") then
							obstructed = not GetCanSeeEntity( player, blipEntity, true )
						end
						
					end
					
					if not blipName then
						blipName = ""
					end
					
					//local obstructed = ( (trace.fraction ~= 1) and ( (trace.entity == nil) or trace.entity:isa("Door") ) )
					//local trace = Shared.TraceRay(eyePos, blipOrigin, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterTwo(player, blipEntity))
					//blipEntity and not 
					
					
					// Get direction to blip. If off-screen, don't render. Bad values are generated if 
					// Client.WorldToScreen is called on a point behind the camera.
					local normToEntityVec = GetNormalizedVector(blipOrigin - eyePos)
					local normViewVec = player:GetViewAngles():GetCoords().zAxis
				   
					local dotProduct = normToEntityVec:DotProduct(normViewVec)
					if dotProduct > 0 then
					
						// Get distance to blip and determine radius
						local distance = (eyePos - blipOrigin):GetLength()
						local drawRadius = kSensorBlipSize/distance
						
						// Compute screen xy to draw blip
						local screenPos = Client.WorldToScreen(blipOrigin)
						
						// Add to array (update numElementsPerBlip in GUISensorBlips:UpdateBlipList)
						table.insert(blips, screenPos.x)
						table.insert(blips, screenPos.y)
						table.insert(blips, drawRadius)
						table.insert(blips, obstructed)
						table.insert(blips, blipName)

					end
					
				end
				
			end
		
		end
		
		return blips
		
	end	
	

end	//Client


//-----------------------------------------------------------------------------


Class_Reload("Marine", newNetworkVars)

