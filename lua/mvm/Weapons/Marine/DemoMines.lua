//
//	Demo-Mines Weapon
//		Author Brock 'McGlaspie' Gillespie - mcglaspie@gmail.com
//
//	This is a Two-State weapon. Using the Secondary fire to toggle between
//	the two states. States: Deploy Mines and Trigger Mines.
//
//	This is effectively a combination of the builder tool and NS2 Mines. All of
//	the deployed mines work just like the used to (proximity detonation), but a
//	new mode is provided via the "Trigger" (Builder-Tool). This allows players
//	to detonate their mines manually.
//
//=============================================================================


Script.Load("lua/mvm/Weapons/Weapon.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")


local kTriggerModelName = PrecacheAsset("models/marine/welder/builder.model")
local kTriggerViewModels = GenerateMarineViewModelPaths("welder")
local kTriggerAnimationGraph = PrecacheAsset("models/marine/welder/welder_view.animation_graph")

local kDemoMinesViewModels = GenerateMarineViewModelPaths("mine")
local kHeldDemoMinesModelName = PrecacheAsset("models/marine/mine/mine_3p.model")
local kDeployMinesAnimationGraph = PrecacheAsset("models/marine/mine/mine_view.animation_graph")

local kDropModelName = PrecacheAsset("models/marine/mine/mine_pile.model")

local kMineTriggerDetonationDelay = 0.3
local kMineTriggerDetonationRange = 40	//balance?
local kPlacementDistance = 2

kDemoMineStates = enum({ 'Deploy', 'Trigger', 'Empty' })	//Empty needed?

local kNumMinesPerPurchase = kNumMines	
//Refill at Armory? Too strong?
// - refill via additional purchase? Eh...same as buying
//BUT! If more Mines are acquired, then how are ALL of them
//handled via detonation standpoint?
//Prevent player from buying while kNumMinesPerPurchase deployed?

local networkVars = {
    weaponState = "private enum kDemoMineStates",
    previousWeaponState = "private enum kDemoMineStates",	//safe to remove?
    minesLeft = string.format("private integer (0 to %d)", kNumMinesPerPurchase),
    deployedMines = string.format("private integer (0 to %d)", kNumMinesPerPurchase),
    droppingMine = "private boolean",
    timeLastModeSwitch = "private time",
    timeLastMineTriggered = "private time"
}

AddMixinNetworkVars( LOSMixin, networkVars )


//-----------------------------------------------------------------------------


local function DropStructure( self, player )

    if Server then
    
        local showGhost, coords, valid = self:GetPositionForStructure( player )
        
		if valid then
			
            local mine = CreateEntity( Mine.kMapName, coords.origin, player:GetTeamNumber() )
            
            if mine then
            
                mine:SetOwner( player )
                
                // Check for space
                if mine:SpaceClearForEntity( coords.origin ) then
					
                    local angles = Angles()
                    angles:BuildFromCoords(coords)
                    mine:SetAngles(angles)
                    
                    player:TriggerEffects( "create_" .. self:GetSuffixName() )
                    
                    return true	// Jackpot.
                    
                else
                    player:TriggerInvalidSound()
                    DestroyEntity(mine)
                end
                
            else
                player:TriggerInvalidSound()
            end
            
        else
            if not valid then
                player:TriggerInvalidSound()
            end
        end
        
    elseif Client then
        return true
    end
    
    return false
    
end


//-----------------------------------------------------------------------------


/*
TODO
Find appropriate sound for "Trigger mine detonation" event
Update TriggerEffects according, etc.
Different kill message icon for a Triggered kill, versus mine auto-trigger

????:
How are deployed mines handled after a player dies and respawns?
 - Should that player just be "given" the Trigger portion of this only?
 - Should the mines just be reverted to "normal" mines?
*/
class 'DemoMines' (Weapon)

DemoMines.kMapName = "demomines"


function DemoMines:OnCreate()

	Weapon.OnCreate(self)
    
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, PickupableWeaponMixin)
    
    self.minesLeft = kNumMinesPerPurchase
    self.deployedMines = 0
    self.droppingMine = false
    self.minesInRange = 0
    self.weaponState = kDemoMineStates.Deploy
    self.previousWeaponState = kDemoMineStates.Empty
    self.timeLastModeSwitch = 0
    self.timeLastMineTriggered = 0
    
    if Client then
		InitMixin( self, ColoredSkinsMixin)
    end
    
    self:SetUpdates(true)

end


function DemoMines:OnInitialized()
	
	Weapon.OnInitialized(self)
    
    self:SetModel( kDropModelName )
	
	if Client then
		self:InitializeSkin()
	end

end


//Overrides and takes place of Weapon.OnDestroy
function DemoMines:OnDestroy()	

    ScriptActor.OnDestroy(self)
    
    // Force end events just in case the weapon goes out of relevancy on the client for example.
    self:TriggerEffects( self:GetPrimaryAttackPrefix() .. "_attack_end" )
    self:TriggerEffects( self:GetSecondaryAttackPrefix() .. "_alt_attack_end" )
    
    if self.mineDisplayUI then
        Client.DestroyGUIView(self.mineDisplayUI)
        self.mineDisplayUI = nil
    end
    
    if self.triggerDisplayUI then
		Client.DestroyGUIView(self.triggerDisplayUI)
        self.triggerDisplayUI = nil
    end

end


if Client then

	function DemoMines:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = 0	//Static
	end
	
	function DemoMines:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_BaseColor, kTeam2_BaseColor )
	end

	function DemoMines:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_AccentColor, kTeam2_AccentColor )
	end

	function DemoMines:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam1Index, kTeam1_TrimColor, kTeam2_TrimColor )
	end

end


function DemoMines:Refill( amount )
    self.minesLeft = amount
end


function DemoMines:GetIsDroppable()
    return true
end

function DemoMines:Dropped( prevOwner )	//fixme leaves hanging in air (not actual drop)
    
	Weapon.Dropped( self, prevOwner )
    
    self:SetModel( kDropModelName )
    
end

function DemoMines:GetDropClassName()
    return "Mine"
end


function DemoMines:SetWeaponState( state )
	
	assert(state)
	
	if state == kDemoMineStates.Deploy and self.minesLeft == 0 then
		state = kDemoMineStates.Trigger
	elseif state == kDemoMineStates.Trigger and ( self.minesLeft == 0 and self.deployedLeft == 0 ) then
		state = kDemoMineStates.Empty
	end
	
	self.previousWeaponState = self.weaponState
	self.weaponState = state

end

function DemoMines:GetSprintAllowed()
    return true
end

function DemoMines:OnUpdate( deltaTime )
	Weapon.OnUpdate(self, deltaTime)
end


local function setupTriggerDisplay( self, parent, settings )
	
	if parent and parent:GetIsLocalPlayer() and settings then
        local triggerDisplayUI = self.triggerDisplayUI
        if not triggerDisplayUI then
            triggerDisplayUI = Client.CreateGUIView(settings.xSize, settings.ySize)
            triggerDisplayUI:Load(settings.script)
            triggerDisplayUI:SetTargetTexture("*ammo_displaytrigger")
            self.triggerDisplayUI = triggerDisplayUI
        end
        
        triggerDisplayUI:SetGlobal( "deployedMines", self.deployedMines )
        
		if settings.variant then
			triggerDisplayUI:SetGlobal( "weaponVariant", settings.variant )
		end
    elseif self.triggerDisplayUI then
        Client.DestroyGUIView( self.triggerDisplayUI )
        self.triggerDisplayUI = nil
    end
    
end

function DemoMines:OnDrawClient()
	
    Weapon.OnDrawClient(self)

	local triggerSettings = self:GetUIDisplaySettings( kDemoMineStates.Trigger )
	setupTriggerDisplay( self, parent, triggerSettings )
	
	if self.triggerDisplayUI then
		self.triggerDisplayUI:SetGlobal( "deployedMines", self.deployedMines )
		self.triggerDisplayUI:SetGlobal( "teamNumber", self:GetTeamNumber() )
		self.triggerDisplayUI:SetGlobal( "minesInRange", self.minesInRange )
	end
  
end

function DemoMines:OnHolsterClient()
	
    Weapon.OnHolsterClient(self)
	
	if self.triggerDisplayUI then
		Client.DestroyGUIView(self.triggerDisplayUI)
        self.triggerDisplayUI = nil
    end
   
end


function DemoMines:OnDraw( player, previousWeaponMapName )
	
    Weapon.OnDraw( self, player, previousWeaponMapName )    
    
    self.droppingMine = false
    self:SetAttachPoint( Weapon.kHumanAttachPoint )
    
    self.deployedMines = self:GetAllDeployedMines(true)
    
    if self.weaponState == kDemoMineStates.Deploy and self.minesLeft > 0 then
		self:SetModel( kHeldModelName, self:GetAnimationGraphName()  )
	elseif self.weaponState == kDemoMineStates.Trigger and self.deployedMines > 0 then
		self:SetModel( kTriggerModelName, self:GetAnimationGraphName() )
	end
	
	if Client then
		self:InitializeSkin()	//Needed?
	end
    
end


function DemoMines:GetViewModelName( sex, variant )
	
	if self.weaponState == kDemoMineStates.Deploy then
		return kDemoMinesViewModels[sex][variant]
	elseif self.weaponState == kDemoMineStates.Trigger then
		return kTriggerViewModels[sex][variant]
	else	
		return nil	//?? certainly to cause error
	end
	
end

function DemoMines:GetAnimationGraphName()
	
	if self.weaponState == kDemoMineStates.Deploy then
		return kDeployMinesAnimationGraph
	elseif self.weaponState == kDemoMineStates.Trigger then
		return kTriggerAnimationGraph
	else
		return nil	//?? certainly to cause error
	end
	
end

function DemoMines:GetResetViewModelOnDraw()
    return true
end

function DemoMines:UpdateViewModelPoseParameters( viewModel )
	viewModel:SetPoseParam("welder", 0)
end

function DemoMines:OnUpdatePoseParameters( viewModel )
    self:SetPoseParam("welder", 0)    
end

function DemoMines:OnUpdateAnimationInput(modelMixin)

    PROFILE("DemoMines:OnUpdateAnimationInput")

    local activity = "none"
    if self.primaryAttacking and not self.secondaryAttacking then
        activity = "primary"
    end
    
    modelMixin:SetAnimationInput("activity", activity)
    modelMixin:SetAnimationInput("welder", false)
    self:SetPoseParam("welder", 0)
    
    if self.weaponState == kDemoMineStates.Deploy then
		modelMixin:SetAnimationInput("activity", ConditionalValue( self.droppingMine, "primary", "none" ) )
	end
    
end


function DemoMines:PerformPrimaryAttack( player )
	
    local success = false
    
    if self.weaponState == kDemoMineStates.Deploy then
		
		if self.minesLeft > 0 then
		
			player:TriggerEffects("start_create_" .. self:GetSuffixName())
			
			local viewAngles = player:GetViewAngles()
			local viewCoords = viewAngles:GetCoords()
			
			success = DropStructure( self, player )
			
			if success then
				self.minesLeft = Clamp( self.minesLeft - 1, 0, kNumMinesPerPurchase )
				self.deployedMines = self.deployedMines - 1
			end
			
		end
		
	elseif self.weaponState == kDemoMineStates.Trigger and self.deployedMines > 0 then
		success = true
		self.droppingMine = false
	end
    
    return success
    
end


//Should below just be ref to Mine.lua - kTimeArmed?
local kDemoMineTriggerDelay = 0.2	//3 mine dets a second
function DemoMines:OnPrimaryAttack( player )
	
    // Ensure the current location is valid for placement.
    if not player:GetPrimaryAttackLastFrame() then
		if self.weaponState == kDemoMineStates.Deploy then
			local showGhost, coords, valid = self:GetPositionForStructure(player)
			if valid then
				if self.minesLeft > 0 then
					self.droppingMine = true
				else
					self.droppingMine = false
					
					if Client then
						player:TriggerInvalidSound()
					end
				end
			else
				self.droppingMine = false
				
				if Client then
					player:TriggerInvalidSound()
				end
				
			end
		elseif self.weaponState == kDemoMineStates.Trigger then
			self.droppingMine = false
			
			if self.timeLastMineTriggered + kDemoMineTriggerDelay < Shared.GetTime() then
				local mineCount, allMines = self:GetAllDeployedMines()
				
				if mineCount > 0 and allMines then
					self.deployedMines = mineCount
					self.minesInRange = 1
					local targetMine = nil
					
					for i, mine in ipairs(allMines) do
						if mine:GetOrigin():GetDistance( player:GetOrigin() ) <= kMineTriggerDetonationRange then
							if targetMine == nil then
								targetMine = mine
								break
							end
						end
					end
					
					if mineCount > 0 and targetMine == nil then
						self.minesInRange = 0
					end
					
					if targetMine then
						if targetMine:TriggerDetonation() then
							self.timeLastMineTriggered = Shared.GetTime()
							self.deployedMines = self.deployedMines - 1
							self.primaryAttacking = true
						end
					end
					
				end
				
				if self.deployedMines < 1 and self.minesLeft == 0 then
					self:OnHolster(player)
					
					player:RemoveWeapon( self )
					player:SwitchWeapon( kPrimaryWeaponSlot )
					
					if Server then                
						DestroyEntity(self)
					end
				elseif self.deployedMines < 1 and self.minesLeft > 0 then
				//switch modes back to mine deploy
					self:SetWeaponState( kDemoMineStates.Deploy )
					
					player:SetViewModel(nil, nil)
					
					self:OnDraw( player, nil )
					
					self.timeLastModeSwitch = Shared.GetTime()
					self.secondaryAttacking = false
					self.primaryAttacking = false
					self.minesInRange = 0
				end
			else
				if Client then
					player:TriggerInvalidSound()
				end
			end
			
		end
        
    end
    
end

function DemoMines:OnPrimaryAttackEnd( player )
	self.droppingMine = false
end

function DemoMines:GetHasSecondary( player )
    return true
end

function DemoMines:GetSecondaryAttackPrefix()
	if self.weaponState == kDemoMineStates.Trigger then
		return "builder"	//spoof builder primary
	end
	
	return ""
end

local kDemoMinesModeSwitchDelay = 0.4	//minesLeft==0 act as reducer?
function DemoMines:OnSecondaryAttack( player )
//Fixme causing invalid sound to place twice, rapidly	
	if not player:GetSecondaryAttackLastFrame() and player then
		local now = Shared.GetTime()
		if self.timeLastModeSwitch + kDemoMinesModeSwitchDelay < now then
			
			local switched = false
			local deployedMines = self:GetAllDeployedMines(true)
			
			if deployedMines > 0 and self.weaponState == kDemoMineStates.Deploy then
				self:SetWeaponState( kDemoMineStates.Trigger )
			elseif self.minesLeft > 0 and self.weaponState == kDemoMineStates.Trigger then
				self:SetWeaponState( kDemoMineStates.Deploy )
			end
			
			switched = (
				self.weaponState ~= self.previousWeaponState
				and self.previousWeaponState ~= kDemoMineStates.Empty
			)
			if self.weaponState == kDemoMineStates.Trigger and switched then
				switched = switched and self.minesLeft > 0	//prvent redrawing over and over
			end
			
			if switched then
				player:SetViewModel(nil, nil)
				
				self:OnDraw( player, nil )
				
				self.timeLastModeSwitch = now
				self.secondaryAttacking = true
				self.primaryAttacking = false
			else
				player:TriggerInvalidSound()
			end
		else
			player:TriggerInvalidSound()
		end
	end
	
end

function DemoMines:OnSecondaryAttackEnd( player )
	self.droppingMine = false
	self.primaryAttacking = false
end

function DemoMines:GetIsValidRecipient( recipient )
    if self:GetParent() == nil and recipient and recipient:isa("Marine") and recipient:GetTeamNumber() == self:GetTeamNumber() then
        local demoMines = recipient:GetWeapon( DemoMines.kMapName )
        return demoMines == nil
    end
    
    return false
end

function DemoMines:GetAllDeployedMines(countOnly)
	local mineCount = 0
	local allMines = {}
	local player = self:GetParent()
	
	if player then
		if player.ownedEntities then
			for _, ent in ipairs( player.ownedEntities ) do
				if ent:isa("Mine") then
					mineCount = mineCount + 1
					allMines[mineCount] = ent
				end
			end
		end
	end
	
	if countOnly then
		return mineCount
	end
	
	return mineCount, allMines
end

function DemoMines:GetDropStructureId()	//???
    return kTechId.DemoMines
end

function DemoMines:GetMinesLeft()
    return self.minesLeft
end

function DemoMines:GetMinesDeployed()
    return self:GetAllDeployedMines(true)
end

function DemoMines:GetSuffixName()
    return "mine"
end

function DemoMines:GetDropClassName()
    return "DemoMines"
end

function DemoMines:OverrideWeaponName()	//Ensure 3P shows correctly
    return ConditionalValue(
		self.weaponState == kDemoMineStates.Trigger,
		"builder",
		"mine"
    )
end

function DemoMines:GetWeight()	//weight per mines carried?
    return kDemoMinesWeight
end

function DemoMines:GetDropMapName()
    return DemoMines.kMapName
end

function DemoMines:GetHUDSlot()
    return 4
end

function DemoMines:GetShowDamageIndicator()	//????
    return true
end

function DemoMines:ModifyDamageTaken( damageTable, attacker, doer, damageType )
    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
end


function DemoMines:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end


if Server then

	function DemoMines:GetSendDeathMessageOverride()
		return false
	end
	
	function DemoMines:OnKill()
        DestroyEntity(self)
    end

end


// Given a gorge player's position and view angles, return a position and orientation
// for structure. Used to preview placement via a ghost structure and then to create it.
// Also returns bool if it's a valid position or not.
function DemoMines:GetPositionForStructure( player )
	
    local isPositionValid = false
    local foundPositionInRange = false
    local structPosition = nil
    local origin = player:GetEyePos() + player:GetViewAngles():GetCoords().zAxis * kPlacementDistance
    
    // Trace short distance in front
    local trace = Shared.TraceRay(
		player:GetEyePos(), 
		origin, 
		CollisionRep.Default, 
		PhysicsMask.AllButPCsAndRagdolls, 
		EntityFilterTwo( player, self )
	)
    
    local displayOrigin = trace.endPoint
    
    // If we hit nothing, trace down to place on ground
    if trace.fraction == 1 then
        origin = player:GetEyePos() + player:GetViewAngles():GetCoords().zAxis * kPlacementDistance
        trace = Shared.TraceRay(
			origin, 
			origin - Vector(0, kPlacementDistance, 0), 
			CollisionRep.Default, 
			PhysicsMask.AllButPCsAndRagdolls, 
			EntityFilterTwo(player, self)
		)
    end

    
    // If it hits something, position on this surface (must be the world or another structure)
    if trace.fraction < 1 then
        
        foundPositionInRange = true
		local traceEnt = trace.entity
		
        if traceEnt == nil then
            isPositionValid = true
        elseif traceEnt:isa("Strucutre") then
        //not trace.entity:isa("ScriptActor") and and not trace.entity:isa("Clog") and not trace.entity:isa("Web")
            isPositionValid = true
        end
        
        displayOrigin = trace.endPoint
        
        // Can not be built on infestation
        if GetIsPointOnInfestation(displayOrigin) then
            isPositionValid = false
        end
    
        // Don't allow dropped structures to go too close to techpoints and resource nozzles
        if GetPointBlocksAttachEntities(displayOrigin) then
            isPositionValid = false
        end
    
		if trace.surface == "nocling" then
            isPositionValid = false
        end
		
        // Don't allow placing above or below us and don't draw either
        local structureFacing = player:GetViewAngles():GetCoords().zAxis
    
        if math.abs(Math.DotProduct(trace.normal, structureFacing)) > 0.9 then
            structureFacing = trace.normal:GetPerpendicular()
        end
    
        // Coords.GetLookIn will prioritize the direction when constructing the coords,
        // so make sure the facing direction is perpendicular to the normal so we get
        // the correct y-axis.
        local perp = Math.CrossProduct(trace.normal, structureFacing)
        structureFacing = Math.CrossProduct(perp, trace.normal)
        structPosition = Coords.GetLookIn(displayOrigin, structureFacing, trace.normal)
        
    end
    
    return foundPositionInRange, structPosition, isPositionValid
    
end

function DemoMines:GetGhostModelName()
    return LookupTechData( self:GetDropStructureId(), kTechDataModel )
end

function DemoMines:OnTag( tagName )
    PROFILE("DemoMines:OnTag")
    
    if tagName == "mine" then
        local player = self:GetParent()
        if player then
			
            if self:PerformPrimaryAttack( player ) then
				local deployedMines = self:GetAllDeployedMines(true)
				
				if self.minesLeft == 0 and deployedMines == 0 then	
					self:OnHolster(player)
					
					player:RemoveWeapon( self )
					player:SwitchWeapon( kPrimaryWeaponSlot )
					
					if Server then
						DestroyEntity(self)
					end
				elseif self.minesLeft == 0 and deployedMines > 0 then
					self:SetWeaponState( kDemoMineStates.Trigger )
					
					player:SetViewModel( nil, nil )
					
					self:OnDraw( player, nil )
					self.droppingMine = false
					self.primaryAttacking = false
				end
			end
        end
        
        self.droppingMine = false
	//welder doesn't have any tags for the "fire" nodes
	//What about "builder" tag?
    end
end

function DemoMines:ProcessMoveOnWeapon( player, input )
    Weapon.ProcessMoveOnWeapon( self, player, input )
end

function DemoMines:GetShowGhostModel()
	if self.weaponState == kDemoMineStates.Deploy then
		return self.showGhost
	else
		return false
	end
end

function DemoMines:GetGhostModelCoords()
    return self.ghostCoords
end   

function DemoMines:GetIsPlacementValid()
    return self.placementValid
end


local function setupMinesDisplay( self, parent, settings )
	if parent and parent:GetIsLocalPlayer() and settings then
        local mineDisplayUI = self.mineDisplayUI
        if not mineDisplayUI then
            mineDisplayUI = Client.CreateGUIView(settings.xSize, settings.ySize)
            mineDisplayUI:Load(settings.script)
            mineDisplayUI:SetTargetTexture("*ammo_displaymine")
            self.mineDisplayUI = mineDisplayUI
        end
        
        mineDisplayUI:SetGlobal( "weaponClip", self.minesLeft )
        
		if settings.variant then
			mineDisplayUI:SetGlobal( "weaponVariant", settings.variant )
		end
    elseif self.mineDisplayUI then
        Client.DestroyGUIView( self.mineDisplayUI )
        self.mineDisplayUI = nil
    end
end

//Note: setupTriggerDisplay delared just before OnDrawClient

//Overrides and takes behavior of Weapon.OnUpdateRender
function DemoMines:OnUpdateRender()
	
	local parent = self:GetParent()
	
	if parent and not self.isHolstered then
		local viewModel = parent:GetViewModelEntity():GetRenderModel()	//hackish
		if viewModel then
			viewModel:SetMaterialParameter( "screenMapIdx", 1.0 )
		end
	end
	
	local mineSettings = self:GetUIDisplaySettings( kDemoMineStates.Deploy )	
	setupMinesDisplay( self, parent, mineSettings )	
	if self.mineDisplayUI then
		self.mineDisplayUI:SetGlobal( "weaponClip", self.minesLeft )
		self.mineDisplayUI:SetGlobal( "teamNumber", self:GetTeamNumber() )
	end
	
	local triggerSettings = self:GetUIDisplaySettings( kDemoMineStates.Trigger )
	setupTriggerDisplay( self, parent, triggerSettings )
	if self.triggerDisplayUI then
		self.triggerDisplayUI:SetGlobal( "deployedMines", self.deployedMines )
		self.triggerDisplayUI:SetGlobal( "teamNumber", self:GetTeamNumber() )
		self.triggerDisplayUI:SetGlobal( "minesInRange", self.minesInRange )
	end
	
end


//-----------------------------------------------------------------------------


if Client then
	
	function DemoMines:GetUIDisplaySettings( forState )
		if forState == kDemoMineStates.Deploy then
			return { xSize = 256, ySize = 417, script = "lua/mvm/Hud/GUIDemoMines.lua" }
		elseif forState == kDemoMineStates.Trigger then
			return { xSize = 512, ySize = 512, script = "lua/mvm/Hud/GUIDemoMinesTrigger.lua" }
		else
			return nil
		end
	end
    
    function DemoMines:OnProcessIntermediate( input )
		if self.weaponState == kDemoMineStates.Deploy then
			local player = self:GetParent()
			
			if player then
				self.showGhost, self.ghostCoords, self.placementValid = self:GetPositionForStructure(player)
				self.showGhost = self.showGhost and self.minesLeft > 0
			end
		end
    end
    
end	//End Client


Shared.LinkClassToMap( "DemoMines", DemoMines.kMapName, networkVars )

