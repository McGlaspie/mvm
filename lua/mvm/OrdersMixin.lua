

Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/mvm/TechTreeConstants.lua")


//-----------------------------------------------------------------------------


local function UpdateOrderIndizes(self)

    for i = 1, #self.orders do
    
        local order = Shared.GetEntity(self.orders[i])
        if order then
            order:SetIndex(i)
        end
    
    end

end


local function OrderChanged(self)

    if self:GetHasOrder() then
    
        self.currentOrderId = self.orders[1]
        local order = Shared.GetEntity(self.currentOrderId)
        if order then
            order:SetOrigin(self:GetOrigin())
        end
    
    else
        self.currentOrderId = Entity.invalidId
    end
    
    UpdateOrderIndizes(self)
    
    if self.OnOrderChanged then
        self:OnOrderChanged()
    end
    
end

function OrdersMixin:TransferOrders(dest)
    
    table.copy(self.orders, dest.orders)
    OrderChanged(dest)
    
    table.clear(self.orders)
    OrderChanged(self)
    
end


local function SetOrder(self, order, clearExisting, insertFirst, giver)

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

/**
 * Children can provide a OnOverrideOrder function to issue build, construct, etc. orders on right-click.
 */
local function OverrideOrder(self, order)

    if self.OnOverrideOrder then
        self:OnOverrideOrder(order)
    elseif order:GetType() == kTechId.Default then
        order:SetType(kTechId.Move)
    end
    
end

local function OrderTargetInvalid(self, targetId)

    local invalid = false
    
    if targetId and targetId ~= Entity.invalidId  then
    
        local target = Shared.GetEntity(targetId)
        
        invalid = not target or
                  (target:isa("PowerPoint") and target:GetPowerState() == PowerPoint.kPowerState.unsocketed) or
                  target:isa("ResourcePoint") or target:isa("TechPoint")
    
    end

    return invalid

end

function OrdersMixin:GiveOrder(orderType, targetId, targetOrigin, orientation, clearExisting, insertFirst, giver)

    ASSERT(type(orderType) == "number")
    
    if GetIsVortexed(self) or self.ignoreOrders or OrderTargetInvalid(self, targetId) or ( #self.orders > OrdersMixin.kMaxOrdersPerUnit or (self.timeLastOrder and self.timeLastOrder + OrdersMixin.kOrderDelay > Shared.GetTime()) )  then
        return kTechId.None
    end
    
    // prevent AI units from attack friendly players
    if orderType == kTechId.Attack then
    
        local target = Shared.GetEntity(targetId)
        if target and target:isa("Player") and target:GetTeamNumber() == self:GetTeamNumber() and not GetGamerules():GetFriendlyFire() then
            return
        end
        
    end
    
    if clearExisting == nil then
        clearExisting = true
    end
    
    if insertFirst == nil then
        insertFirst = true
    end
    
    local order = nil
    order = CreateOrder(orderType, targetId, targetOrigin, orientation)
    order:SetOrigin(self:GetOrigin())
    
    OverrideOrder(self, order)
    
    local success = SetOrder(self, order, clearExisting, insertFirst, giver)
    
    if success and self.OnOrderGiven then
        self:OnOrderGiven(order)
    end
    
    return ConditionalValue(success, order:GetType(), kTechId.None)
    
end


