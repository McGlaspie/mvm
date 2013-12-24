

Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/PostLoadMod.lua")


// Balance
local kConstructRate = 0.4
local kWeldRate = 0.5
local kOrderScanRadius = 10

MAC.kRepairHealthPerSecond = 50
MAC.kHealth = kMACHealth
MAC.kArmor = kMACArmor
MAC.kMoveSpeed = 4.5
MAC.kHoverHeight = .5
MAC.kStartDistance = 3
MAC.kWeldDistance = 2
MAC.kBuildDistance = 2     // Distance at which bot can start building a structure. 
MAC.kSpeedUpgradePercent = ( 1 + kMACSpeedAmount )

MAC.kCapsuleHeight = .2
MAC.kCapsuleRadius = .5

// Greetings
MAC.kGreetingUpdateInterval = 1
MAC.kGreetingInterval = 10
MAC.kGreetingDistance = 5
MAC.kUseTime = 2.0

MAC.kTurnSpeed = 3 * math.pi // a mac is nimble


local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

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
                if constructable:GetCanConstruct(self) then
                
                    target = constructable
                    orderType = kTechId.Construct
                    break
                    
                end
                
            end
            
            //TODO Ensure PNs are not auto-repaired, but only constructed
            if not target then
			//Auto-Build Powernodes for a given location (not just nearby the MAC)
				local locationName = GetLocationForPoint( self:GetOrigin() ):GetName()
				
				local locationPowerNode = GetPowerPointForLocation( locationName )
				
				if locationPowerNode then
					
					if locationPowerNode:GetCanConstruct( self ) then
						
						target = locationPowerNode
						orderType = kTechId.Construct
					
					end
					
				end
				
			end
            
            //FIXME Below will not repair power nodes. This ight be a good thing, would prevent accidental repairs
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
    InitMixin(self, ModelMixin)
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
    InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    
    if Server then
        InitMixin(self, RepositioningMixin)
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
        InitMixin(self, ColoredSkinsMixin)
    end
    
    self:SetUpdates(true)
    self:SetLagCompensated(true)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.WhipGroup)	//FIXME Still not triggering Location trigger updates
    
end


local orgMacInit = MAC.OnInitialized
function MAC:OnInitialized()

	orgMacInit(self)
	
	if Client then
	
	/*
		//TODO Colorize jet effects?
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
	*/
	
		self:InitializeSkin()
	end
	
	if Server then
	    
	    InitMixin(self, ControllerMixin)
		//self:CreateController(PhysicsGroup.SmallStructuresGroup)
		self:CreateController(PhysicsGroup.WhipGroup)	//FIXME Still not triggering Location trigger updates
	    
	end

end


local function MvM_MAC_GetOrderTargetIsWeldTarget(order, doerTeamNumber)

    if(order ~= nil) then
		
        local entityId = order:GetParam()
        
        if(entityId > 0) then
			
            local entity = Shared.GetEntity(entityId)
            
            if entity ~= nil and HasMixin(entity, "Weldable") 
					and ( entity:GetTeamNumber() == doerTeamNumber or entity:GetTeamNumber() == kTeamReadyRoom ) then
				
                return entity
                
            end
            
        end
        
    end
    
    return nil

end


function MAC:OnOverrideOrder(order)		//OVERRIDE

    local orderTarget = nil
    if (order:GetParam() ~= nil) then
        orderTarget = Shared.GetEntity(order:GetParam())
    end
    
    local isSelfOrder = orderTarget == self
    
    // Default orders to unbuilt friendly structures should be construct orders
    if order:GetType() == kTechId.Default 
		and GetOrderTargetIsConstructTarget(order, self:GetTeamNumber()) 
		and not isSelfOrder 
		then
    
        order:SetType(kTechId.Construct)
		
    elseif order:GetType() == kTechId.Default 
		and MvM_MAC_GetOrderTargetIsWeldTarget( order, self:GetTeamNumber() ) 
		and not isSelfOrder 
		and not GetIsWeldedByOtherMAC(self, orderTarget) 
		then
    
        order:SetType(kTechId.FollowAndWeld)

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


if Server then

	// Required by ControllerMixin.
	function MAC:GetControllerSize()
		return GetTraceCapsuleFromExtents( self:GetExtents() )    
	end
    
	// Required by ControllerMixin.
	function MAC:GetMovePhysicsMask()
		return PhysicsMask.Movement
	end

end


//-----------------------------------------------------------------------------


ReplaceLocals( MAC.OnUpdate, { FindSomethingToDo = MvM_FindSomethingToDo } )
ReplaceLocals( MAC.ProcessConstruct, { GetCanConstructTarget = MvM_GetCanConstructTarget } )

Class_Reload("MAC", newNetworkVars)

