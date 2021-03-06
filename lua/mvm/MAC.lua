
Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/SelectableMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/DamageMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/WeldableMixin.lua")
Script.Load("lua/mvm/DissolveMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")
Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/NanoshieldMixin.lua")
Script.Load("lua/mvm/SupplyUserMixin.lua")
Script.Load("lua/mvm/RagdollMixin.lua")
Script.Load("lua/mvm/OrdersMixin.lua")

if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
	//TODO Add IFFMixin
end


Script.Load("lua/ResearchMixin.lua")	//To allow recycle
Script.Load("lua/RecycleMixin.lua")

Script.Load("lua/mvm/CommAbilities/Marine/EMPBlast.lua")


local kJetsCinematic = PrecacheAsset("cinematics/marine/mac/jet.cinematic")
local kJetsSound = PrecacheAsset("sound/NS2.fev/marine/structures/mac/thrusters")

local kTeam1LightCinematic = PrecacheAsset("cinematics/marine/mac/mac_light_team1.cinematic")
local kTeam2LightCinematic = PrecacheAsset("cinematics/marine/mac/mac_light_team2.cinematic")

local kRightJetNode = "fxnode_jet1"
local kLeftJetNode = "fxnode_jet2"

// Balance
local kConstructRate = 0.4
local kWeldRate = 0.5
local kOrderScanRadius = 10

local kEmpChatterSoundDelay = 0.75

MAC.kRepairHealthPerSecond = 50
MAC.kHealth = kMACHealth
MAC.kArmor = kMACArmor
MAC.kMoveSpeed = 6
MAC.kHoverHeight = .5
MAC.kStartDistance = 3
MAC.kWeldDistance = 2.25
MAC.kBuildDistance = 2.25     // Distance at which bot can start building a structure. 
MAC.kSpeedUpgradePercent = ( 1 + kMACSpeedAmount )

MAC.kCapsuleHeight = .2
MAC.kCapsuleRadius = .5

// Greetings
MAC.kGreetingUpdateInterval = 1
MAC.kGreetingInterval = 10
MAC.kGreetingDistance = 5
MAC.kUseTime = 2.0

MAC.kTurnSpeed = 3 * math.pi // a mac is nimble

local kMAC_ChatterSoundAsset = PrecacheAsset("sound/NS2.fev/marine/structures/mac/chatter")

local newNetworkVars = {
	headlightActive = "boolean"
}

AddMixinNetworkVars(ResearchMixin, newNetworkVars)
AddMixinNetworkVars(RecycleMixin, newNetworkVars)
AddMixinNetworkVars(DissolveMixin, newNetworkVars)
AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)
AddMixinNetworkVars(ElectroMagneticMixin, newNetworkVars)


//-----------------------------------------------------------------------------


local function MvM_GetCanConstructTarget(self, target)
    return 
		target ~= nil 
		and HasMixin(target, "Construct") 
		and ( 
			GetAreFriends(self, target) or target:isa("PowerPoint") 
		)
end


local function GetIsWeldedByOtherMAC(self, target)

    if target then
        
        //????: Wouldn't a short-ranged check by Ent class be more efficient?
        for _, mac in ipairs(GetEntitiesForTeam("MAC", self:GetTeamNumber())) do

            if self ~= mac then
            
                if mac.secondaryTargetId ~= nil and Shared.GetEntity(mac.secondaryTargetId) == target then
                    return true
                end
            
                local currentOrder = mac:GetCurrentOrder()
                local orderTarget = nil
                if currentOrder and currentOrder:GetParam() ~= nil then
                    orderTarget = Shared.GetEntity(currentOrder:GetParam())
                end 
                
                if currentOrder and orderTarget == target 
					and (currentOrder:GetType() == kTechId.FollowAndWeld 
					or currentOrder:GetType() == kTechId.Weld 
					or currentOrder:GetType() == kTechId.AutoWeld) then
					
                    return true
                    
                end
            
            end
        
        end
        
    end
    
    return false

end


local function MvM_GetAutomaticOrder(self)

    local target = nil
    local orderType = nil

    if self.timeOfLastFindSomethingTime == nil or Shared.GetTime() > self.timeOfLastFindSomethingTime + 1 then

        local currentOrder = self:GetCurrentOrder()
        local primaryTarget = nil
        if currentOrder and currentOrder:GetType() == kTechId.FollowAndWeld then
            primaryTarget = Shared.GetEntity(currentOrder:GetParam())
        end

        if primaryTarget and (HasMixin(primaryTarget, "Weldable") and primaryTarget:GetWeldPercentage() < 1) and not primaryTarget:isa("MAC") then
            
            target = primaryTarget
            orderType = kTechId.AutoWeld
                    
        else

            // If there's a friendly entity nearby that needs constructing, constuct it.
            local constructables = GetEntitiesWithMixinForTeamWithinRange("Construct", self:GetTeamNumber(), self:GetOrigin(), kOrderScanRadius)
            for c = 1, #constructables do
				
                local constructable = constructables[c]
                if constructable:GetCanConstruct(self) then	//prevent auto-rebuild of PNs
                
                    target = constructable
                    orderType = kTechId.Construct
                    break
                    
                end
                
            end
            
            /*
            if not target then
			//Auto-Build Powernodes for a given location (not just nearby the MAC)
				local locationName = GetLocationForPoint( self:GetOrigin() ):GetName()
				
				if locationName then
					
					local locationPowerNode = GetPowerPointForLocation( locationName )
					
					if locationPowerNode then
						
						if locationPowerNode:GetCanConstruct( self ) then
							
							target = locationPowerNode
							orderType = kTechId.Construct
						
						end
						
					end
					
				end
				
			end
			*/
            
            //FIXME Below will not repair power nodes. This might be a good thing, would prevent accidental repairs
            //when enemy structures still in a room. Pehapes add a weighted repair command? I.e. only repair when 
            //friendly (ghost)structures and no enemy buildings?
            // - above "fix" is tricky since power nodes are neutral....
            if not target then
            
                // Look for entities to heal with weld.
                local weldables = GetEntitiesWithMixinForTeamWithinRange("Weldable", self:GetTeamNumber(), self:GetOrigin(), kOrderScanRadius)
                for w = 1, #weldables do
                
                    local weldable = weldables[w]
                    // There are cases where the weldable's weld percentage is very close to
                    // 100% but not exactly 100%. This second check prevents the MAC from being so pedantic.
                    if weldable:GetCanBeWelded(self) and weldable:GetWeldPercentage() < 1 and not GetIsWeldedByOtherMAC(self, weldable) and not weldable:isa("MAC") then
                    
                        target = weldable
                        orderType = kTechId.AutoWeld
                        break

                    end
                    
                end
            
            end
        
        end

        self.timeOfLastFindSomethingTime = Shared.GetTime()

    end
    
    return target, orderType

end


local function MvM_FindSomethingToDo(self)

    local target, orderType = MvM_GetAutomaticOrder(self)
    if target and orderType then
        return self:GiveOrder(orderType, target:GetId(), target:GetOrigin(), nil, false, false) ~= kTechId.None    
    end
    
    return false
    
end


//-------------------------------------


function MAC:OnCreate()		//OVERRIDES

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, DoorMixin)
    InitMixin(self, BuildingMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, UpgradableMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, PathingMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, SoftTargetMixin)
    InitMixin(self, WebableMixin)
    InitMixin(self, ParasiteMixin)
    
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, ElectroMagneticMixin)
    
    if Server then
        InitMixin(self, RepositioningMixin)
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
        InitMixin(self, ColoredSkinsMixin)
    end
    
    self.playedEmpEffectedSound = false
    self.empDelayedOrder = nil
    
    self.headlightActive = false
    
    self:SetUpdates(true)
    self:SetLagCompensated(true)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)
    
end


function MAC:OnInitialized()	//OVERRIDES
    
    ScriptActor.OnInitialized(self)

    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)

    if Server then
    
        self:UpdateIncludeRelevancyMask()
        
        InitMixin(self, SleeperMixin)
        InitMixin(self, MobileTargetMixin)
        InitMixin(self, SupplyUserMixin)
        InitMixin(self, InfestationTrackerMixin)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        self.jetsSound = Server.CreateEntity(SoundEffect.kMapName)
        self.jetsSound:SetAsset(kJetsSound)
        self.jetsSound:SetParent(self)

		//InitMixin(self, ControllerMixin)
		//self:CreateController(PhysicsGroup.WhipGroup)

    elseif Client then
    
        InitMixin(self, UnitStatusMixin)     
        //InitMixin(self, HiveVisionMixin)
        
        self:InitializeSkin()

        // Setup movement effects
        self.jetsCinematics = {}
        for index,attachPoint in ipairs({ kLeftJetNode, kRightJetNode }) do
            self.jetsCinematics[index] = Client.CreateCinematic(RenderScene.Zone_Default)
            self.jetsCinematics[index]:SetCinematic(kJetsCinematic)
            self.jetsCinematics[index]:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.jetsCinematics[index]:SetParent(self)
            self.jetsCinematics[index]:SetCoords(Coords.GetIdentity())
            self.jetsCinematics[index]:SetAttachPoint(self:GetAttachPointIndex(attachPoint))
            self.jetsCinematics[index]:SetIsActive(false)
        end
        //Colorize above?
        
        self.headlightCinematic = nil
        self.headlightCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        if self:GetTeamNumber() == kTeam2Index then
			self.headlightCinematic:SetCinematic( kTeam2LightCinematic )
		else
			self.headlightCinematic:SetCinematic( kTeam1LightCinematic )
		end
		self.headlightCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
		self.headlightCinematic:SetParent(self)
		self.headlightCinematic:SetCoords(Coords.GetIdentity())
		self.headlightCinematic:SetAttachPoint( self:GetAttachPointIndex( MAC.kLightNode ) )
		self.headlightCinematic:SetIsActive(false)
		
    end
    
    self.timeOfLastGreeting = 0
    self.timeOfLastGreetingCheck = 0
    self.timeOfLastChatterSound = 0
    self.timeOfLastWeld = 0
    self.timeOfLastConstruct = 0
    self.moving = false
    self.headlightActive = false
    self:SetModel(MAC.kModelName, MAC.kAnimationGraph)
    
    InitMixin(self, IdleMixin)
    
end


local orgMacDestroy = MAC.OnDestroy
function MAC:OnDestroy()
	
	orgMacDestroy( self )
	
	if Client then
		Client.DestroyCinematic( self.headlightCinematic )
	end

end


function MAC:GetTechButtons(techId)	//OVERRIDES

    return { kTechId.Move, kTechId.Stop, kTechId.Welding, kTechId.None,
             kTechId.None, kTechId.None, kTechId.None, kTechId.None }	//MACEMP
    
end


//function MAC:GetDamageType()
//	return kDamageType.ElectroMagnetic
//end
/*
function MAC:PerformActivation(techId, position, normal, commander)	//OVERRIDES

    if techId == kTechId.MACEMP then
		
        local empBlast = CreateEntity( EMPBlast.kMapName, self:GetOrigin(), self:GetTeamNumber() )
        self:DoDamage( kMACEMPBlastDamage * 2.5, self, self:GetOrigin(), GetNormalizedVector(self:GetOrigin()), "none")
        
        return empBlast ~= nil, false
		
    end
    
    return ScriptActor.PerformActivation(self, techId, position, normal, commander)
    
end
*/

local function MvM_MAC_GetOrderTargetIsConstructTarget(order, doerTeamNumber)

    if(order ~= nil) then
    
        local entity = Shared.GetEntity(order:GetParam())
		
        if entity and ( HasMixin(entity, "Construct") and (
					( entity:GetTeamNumber() == doerTeamNumber ) or ( entity:GetTeamNumber() == kTeamReadyRoom )
				) and not entity:GetIsBuilt() 
			) 
		then
			
			//Print("\t MAC Construct Order target is a " .. entity:GetClassName() )
            return entity
            
        end
        
    end
    
    return nil

end

local function MvM_MAC_GetOrderTargetIsWeldTarget(order, doerTeamNumber)

    if(order ~= nil) then
		
        local entityId = order:GetParam()
        
        if(entityId > 0) then
			
            local entity = Shared.GetEntity(entityId)
            
            if entity ~= nil and HasMixin(entity, "Weldable") 
					and ( entity:GetTeamNumber() == doerTeamNumber or entity:GetTeamNumber() == kTeamReadyRoom ) then
				
				//Print("\t MAC Weld Order target is a " .. entity:GetClassName() )
				
                return entity
                
            end
            
        end
        
    end
    
    return nil

end


function MAC:OnLocationChange( locationName )
	


end


function MAC:OnOverrideOrder(order)		//OVERRIDE

    local orderTarget = nil
    if (order:GetParam() ~= nil) then
        orderTarget = Shared.GetEntity(order:GetParam())
    end
    
    local isSelfOrder = orderTarget == self
    
    // Default orders to unbuilt friendly structures should be construct orders
    if order:GetType() == kTechId.Default 
		and MvM_MAC_GetOrderTargetIsConstructTarget( order, self:GetTeamNumber() ) 
		and not isSelfOrder 
		then
		
        order:SetType(kTechId.Construct)
		
    elseif order:GetType() == kTechId.Default 
		and MvM_MAC_GetOrderTargetIsWeldTarget( order, self:GetTeamNumber() ) 
		and not isSelfOrder 
		and not GetIsWeldedByOtherMAC(self, orderTarget) 
		then
		
		if orderTarget:isa("PowerPoint") then
			order:SetType(kTechId.Weld)
		else
			order:SetType(kTechId.FollowAndWeld)
		end

    elseif (order:GetType() == kTechId.Default or order:GetType() == kTechId.Move) then
        
        // Convert default order (right-click) to move order
        order:SetType(kTechId.Move)
        
    end
    
    if GetAreEnemies(self, orderTarget) then
        order.orderParam = -1
    end
    
end



if Client then
	
	function MAC:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		//self.skinAtlasIndex = self:GetTeamNumber() - 1
		self.skinAtlasIndex = 0	//TEMP
	end

	function MAC:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function MAC:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end
	
	function MAC:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


function MAC:GetIsFlameAble()
    return false
end



function MAC:ProcessConstruct(deltaTime, orderTarget, orderLocation)	//OVERRIDES

    local time = Shared.GetTime()
    
    local toTarget = (orderLocation - self:GetOrigin())
    local distToTarget = toTarget:GetLengthXZ()
    local orderStatus = kOrderStatus.InProgress
    local canConstructTarget = MvM_GetCanConstructTarget(self, orderTarget)   
    
    if self.timeOfLastConstruct == 0 or (time > (self.timeOfLastConstruct + kConstructRate)) then

        if canConstructTarget then
        
            local engagementDist = GetEngagementDistance(orderTarget:GetId()) 
            if distToTarget < engagementDist then
        
                if orderTarget:GetIsBuilt() then   
                    orderStatus = kOrderStatus.Completed
                else
            
                    // Otherwise, add build time to structure
                    if not self:GetIsVortexed() and not GetIsVortexed(orderTarget) then
                        orderTarget:Construct(kConstructRate * kMACConstructEfficacy, self)
                        self.timeOfLastConstruct = time
                    end
                
                end
                
            else
				
                local hoverAdjustedLocation = GetHoverAt(self, orderLocation)
                local doneMoving = self:MoveToTarget( PhysicsMask.AIMovement, hoverAdjustedLocation, self:GetMoveSpeed(), deltaTime )
                self.moving = not doneMoving

            end    
        
        
        else
            orderStatus = kOrderStatus.Cancelled
        end

        
    end
    
    // Continuously turn towards the target. But don't mess with path finding movement if it was done.
    if not self.moving and toTarget then
        self:SmoothTurn(deltaTime, GetNormalizedVector(toTarget), 0)
    end
    
    return orderStatus
    
end


/*
function MAC:ProcessWeldOrder(deltaTime, orderTarget, orderLocation, autoWeld)	//OVERRIDES

    local time = Shared.GetTime()
    local canBeWeldedNow = false
    local orderStatus = kOrderStatus.InProgress

    if self.timeOfLastWeld == 0 or time > self.timeOfLastWeld + kWeldRate then
    
        // Not allowed to weld after taking damage recently.
        if Shared.GetTime() - self:GetTimeLastDamageTaken() <= 1.0 then
        
            TEST_EVENT("MAC cannot weld after taking damage")
            return kOrderStatus.InProgress
            
        end
    
        // It is possible for the target to not be weldable at this point.
        // This can happen if a damaged Marine becomes Commander for example.
        // The Commander is not Weldable but the Order correctly updated to the
        // new entity Id of the Commander. In this case, the order will simply be completed.
        if orderTarget and HasMixin(orderTarget, "Weldable") then
        
            local toTarget = (orderLocation - self:GetOrigin())
            local distanceToTarget = toTarget:GetLength()
            canBeWeldedNow = orderTarget:GetCanBeWelded(self)
            
            local obstacleSize = 0
            if HasMixin(orderTarget, "Extents") then
                obstacleSize = orderTarget:GetExtents():GetLengthXZ()
            end
            
            if autoWeld and distanceToTarget > 15 then
                orderStatus = kOrderStatus.Cancelled
            elseif not canBeWeldedNow then
                orderStatus = kOrderStatus.Completed
            else
            
                // If we're close enough to weld, weld
                if distanceToTarget - obstacleSize < MAC.kWeldDistance and not GetIsVortexed(self) then
 
                    orderTarget:OnWeld(self, kWeldRate)
                    self.timeOfLastWeld = time
                    self.moving = false
                    
                else
                
                    // otherwise move towards it
                    local hoverAdjustedLocation = GetHoverAt(self, orderTarget:GetOrigin())
                    local doneMoving = self:MoveToTarget(PhysicsMask.AIMovement, hoverAdjustedLocation, self:GetMoveSpeed(), deltaTime)
                    self.moving = not doneMoving
                    
                end
                
            end    
            
        else
            orderStatus = kOrderStatus.Cancelled
        end
        
    end
    
    // Continuously turn towards the target. But don't mess with path finding movement if it was done.
    if not self.moving and orderLocation then
    
        local toOrder = (orderLocation - self:GetOrigin())
        self:SmoothTurn(deltaTime, GetNormalizedVector(toOrder), 0)
        
    end
    
    return orderStatus
    
end
*/


function MAC:ProcessFollowAndWeldOrder(deltaTime, orderTarget, targetPosition)	//OVERRIDES

    local currentOrder = self:GetCurrentOrder()
    local orderStatus = kOrderStatus.InProgress
    //or ( orderTarget:isa("PowerPoint") and not orderTarget:GetIsBuilt() )
    if ( orderTarget and orderTarget:GetIsAlive() )  then
        
        local distance = (self:GetOrigin() - targetPosition):GetLengthXZ()
        local target, orderType = MvM_GetAutomaticOrder(self)
        
        if target and orderType then
        
            self.secondaryOrderType = orderType
            self.secondaryTargetId = target:GetId()
            
        end
        
        target = target ~= nil and target or ( self.secondaryTargetId ~= nil and Shared.GetEntity(self.secondaryTargetId) )
        orderType = orderType ~= nil and orderType or self.secondaryOrderType
        
        local triggerMoveDistance = (self.welding or self.constructing or orderType) and 15 or 6	//15 or 6? wtf?
        
        if distance > triggerMoveDistance or self.moveToPrimary then
        
            if self:ProcessMove(deltaTime, target, targetPosition) == kOrderStatus.InProgress and (self:GetOrigin() - targetPosition):GetLengthXZ() > 3 then
                self.moveToPrimary = true
                self.secondaryTargetId = nil
                self.secondaryOrderType = nil
            else
                self.moveToPrimary = false
            end
            
        else
            self.moving = false
        end
        
        // when we attempt to follow the primary target, dont interrupt with auto orders
        if not self.moveToPrimary then
        
            if target and orderType then
            
                local secondaryOrderStatus = nil
            
                if orderType == kTechId.AutoWeld then            
                    secondaryOrderStatus = self:ProcessWeldOrder(deltaTime, target, target:GetOrigin(), true)        
                elseif orderType == kTechId.Construct then
                    secondaryOrderStatus = self:ProcessConstruct(deltaTime, target, target:GetOrigin())
                end
                
                if secondaryOrderStatus == kOrderStatus.Completed or secondaryOrderStatus == kOrderStatus.Cancelled then
                
                    self.secondaryTargetId = nil
                    self.secondaryOrderType = nil
                    
                end
            
            end
        
        end
        
    else
        self.moveToPrimary = false
        orderStatus = kOrderStatus.Cancelled
    end
    
    return orderStatus

end


function MAC:GetIsVulnerableToEMP()
	return true
end

function MAC:OnEmpDamaged()

	//TODO Start cinematic via mixin
	// - Reference FireMixin for handling this

end


local function SetOrderFromPrevious(self, order, clearExisting, insertFirst, giver)

    if self.ignoreOrders or order:GetType() == kTechId.Default then
        return false
    end
    
    if clearExisting then
        self:ClearOrders()
    end
    
    // Always snap the location of the order to the ground.
    local location = order:GetLocation()
    if location then
    
        location = GetGroundAt(self, location, PhysicsMask.AIMovement)
        order:SetLocation(location)
        
    end
    
    order:SetOwner(self)
    
    if insertFirst then
        table.insert(self.orders, 1, order:GetId())
    else
        table.insert(self.orders, order:GetId())
    end
    
    self.timeLastOrder = Shared.GetTime()
    OrderChanged(self)
    
    return true
    
end


local function UpdateOrders(self, deltaTime)

    local currentOrder = self:GetCurrentOrder()
    
    if currentOrder ~= nil then
    
        local orderStatus = kOrderStatus.None        
        local orderTarget = Shared.GetEntity( currentOrder:GetParam() )
        local orderLocation = currentOrder:GetLocation()
    
        if currentOrder:GetType() == kTechId.FollowAndWeld then
            orderStatus = self:ProcessFollowAndWeldOrder(deltaTime, orderTarget, orderLocation)    
        elseif currentOrder:GetType() == kTechId.Move then
        
            orderStatus = self:ProcessMove(deltaTime, orderTarget, orderLocation)
            self:UpdateGreetings()

        elseif currentOrder:GetType() == kTechId.Weld or currentOrder:GetType() == kTechId.AutoWeld then
            orderStatus = self:ProcessWeldOrder(deltaTime, orderTarget, orderLocation, currentOrder:GetType() == kTechId.AutoWeld)
        elseif currentOrder:GetType() == kTechId.Build or currentOrder:GetType() == kTechId.Construct then
            orderStatus = self:ProcessConstruct(deltaTime, orderTarget, orderLocation)
        end
        
        if orderStatus == kOrderStatus.Cancelled then
            self:ClearCurrentOrder()
        elseif orderStatus == kOrderStatus.Completed then
            self:CompletedCurrentOrder()
        end
        
    end
    
end


function MAC:OnUpdate( deltaTime )	//OVERRIDES
	
	if self:GetIsUnderEmpEffect() and self:GetIsAlive() then
		
		if Client then
			if Shared.GetTime() > self.timeOfLastEmpEffect + kEmpChatterSoundDelay and not self.playedEmpEffectedSound then
				self:PlaySound( kMAC_ChatterSoundAsset )
				self.playedEmpEffectedSound = true
			end
		end
		
		if Server then
			
			if self:GetHasOrder() and self.empDelayedOrder == nil then
				
				self.empDelayedOrder = self:GetCurrentOrder():GetId()
				self:ClearOrders()
				self.ignoreOrders = true
				
			end
			
		end
		
	else
		
		if Server then
			
			if self.empDelayedOrder ~= nil and self.empDelayedOrder ~= Entity.InvalidId then
				
				local previousOrder = Shared.GetEntity( self.empDelayedOrder )
				
				if previousOrder and previousOrder:isa("Order") then
					SetOrderFromPrevious(self, previousOrder, true, true)
				end
				
				self.empDelayedOrder = nil
				
			end
			
			self.ignoreOrders = false
			
		end
		
		self.playedEmpEffectedSound = false
		
	end
	
	/*
	if Server then
		
		local location = GetLocationForPoint( self:GetOrigin() ) or nil
		
		if location and location:isa("Location") then
			
			local locationPower = GetPowerPointForLocation( location:GetName() )
			if locationPower and locationPower:isa("PowerPoint") then
				self.headlightActive = locationPower:GetIsDisabled()
			else
				self.headlightActive = false
			end
			
		end
		
	end
	
	if Client and self.headlightCinematic then
		self.headlightCinematic:SetIsActive( self.headlightActive )
	end
	*/
	
//Original OnUpdate -----------------------------
    if Server and self:GetIsAlive() then

        // assume we're not moving initially
        self.moving = false
    
        if not self:GetHasOrder() then
            MvM_FindSomethingToDo(self)
        else
            UpdateOrders(self, deltaTime)
        end
        
        self.constructing = Shared.GetTime() - self.timeOfLastConstruct < 0.5
        self.welding = Shared.GetTime() - self.timeOfLastWeld < 0.5

        if self.moving and not self.jetsSound:GetIsPlaying() then
            self.jetsSound:Start()
        elseif not self.moving and self.jetsSound:GetIsPlaying() then
            self.jetsSound:Stop()
        end
        
    // client side build / weld effects
    elseif Client and self:GetIsAlive() then
		
        if self.constructing then
        
            if not self.timeLastConstructEffect or self.timeLastConstructEffect + kConstructRate < Shared.GetTime()  then
				
				local currentOrder = self:GetCurrentOrder()
				local orderTarget = nil
				if currentOrder then
					orderTarget = Shared.GetEntity( currentOrder:GetParam() )
				end
				
				if orderTarget and orderTarget:isa("PowerPoint") then
					self:TriggerEffects( "mac_construct", {
						ismarine = ( orderTarget.scoutedForTeam1 ~= false ), isalien = ( orderTarget.scoutedForTeam2 ~= false )
					})
				else
					self:TriggerEffects( "mac_construct", {
						ismarine = ( self:GetTeamNumber() == kTeam1Index ), isalien = ( self:GetTeamNumber() == kTeam2Index )
					})
				end
				
				self.timeLastConstructEffect = Shared.GetTime()
                
            end
            
        end
        
        if self.welding then
        
            if not self.timeLastWeldEffect or self.timeLastWeldEffect + kWeldRate < Shared.GetTime()  then
				
				local currentOrder = self:GetCurrentOrder()
				local orderTarget = nil
				if currentOrder then
					orderTarget = Shared.GetEntity( currentOrder:GetParam() )
				end
				
				if orderTarget and orderTarget:isa("PowerPoint") then
					self:TriggerEffects( "mac_weld", {
						ismarine = ( orderTarget.scoutedForTeam1 ~= false ), isalien = ( orderTarget.scoutedForTeam2 ~= false )
					})
				else
					self:TriggerEffects( "mac_weld", {
						ismarine = ( self:GetTeamNumber() == kTeam1Index ), isalien = ( self:GetTeamNumber() == kTeam2Index )
					})
				end
				
                self.timeLastWeldEffect = Shared.GetTime()
                
            end
            
        end
        
        if self:GetHasOrder() ~= self.clientHasOrder then
        
            self.clientHasOrder = self:GetHasOrder()
            
            if self.clientHasOrder then
                self:TriggerEffects("mac_set_order")
            end
            
        end

        if self.jetsCinematics then

            for id,cinematic in ipairs(self.jetsCinematics) do
                self.jetsCinematics[id]:SetIsActive(self.moving and self:GetIsVisible())
            end

        end

    end
	

end


if Server then
	/*
	// Required by ControllerMixin.
	function MAC:GetControllerSize()
		return GetTraceCapsuleFromExtents( self:GetExtents() )    
	end
    
	// Required by ControllerMixin.
	function MAC:GetMovePhysicsMask()
		return PhysicsMask.Movement
	end
	
	function MAC:GetControllerPhysicsGroup()
		return PhysicsGroup.SmallStructuresGroup	//???
	end
	*/
	
	function MAC:GetMoveSpeed()		//OVERRIDES
	
		local maxSpeedTable = {}//{ maxSpeed = MAC.kMoveSpeed }
		
		if self:GetIsUnderEmpEffect() then
			maxSpeedTable = { maxSpeed = MAC.kMoveSpeed * kElectrifiedMovementModifier }
		else
			maxSpeedTable = { maxSpeed = MAC.kMoveSpeed }
		end
		
		self:ModifyMaxSpeed( maxSpeedTable )

		return maxSpeedTable.maxSpeed
		
	end
	

end	//End Server


//-----------------------------------------------------------------------------


Class_Reload( "MAC", newNetworkVars )

