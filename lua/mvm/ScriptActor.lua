
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/mvm/EffectsMixin.lua")


// Called right after an entity is created on the client or server. This happens through Server.CreateEntity, 
// or when a server-created object is propagated to client. 
function ScriptActor:OnCreate()     //OVERRIDES - Required to use MvM EffectsMixin

    Entity.OnCreate(self)
    
    // This field is not synchronized over the network.
    self.creationTime = Shared.GetTime()
    
    InitMixin(self, EffectsMixin)
    InitMixin(self, TechMixin)
    
    self.attachedId = Entity.invalidId
    
    self.locationId = 0
    
    self.pathingFlags = 0
    
    if Server then
    
        self.locationEntId = Entity.invalidId
        
        InitMixin(self, InvalidOriginMixin)
        InitMixin(self, RelevancyMixin)
        
        // Ownership only exists on the Server.
        InitMixin(self, OwnerMixin)
        
        self.selectedCount = 0
        self.hotgroupedCount = 0
        
    end
    
    InitMixin(self, ExtentsMixin)
    InitMixin(self, TargetMixin)
    InitMixin(self, UsableMixin)
    
    self:SetUpdates(true)
    self:SetPropagate(Entity.Propagate_Mask)
    self:SetRelevancyDistance(kMaxRelevancyDistance)
    
end



//Must override utility functions in order for supply to be calculated correctly
//across the board. Otherwise, supply is tracked correctly, but doesn't restrict
//anything.
function ScriptActor:GetTechAllowed( techId, techNode, player )

    local allowed =  GetIsUnitActive(self)
    local canAfford = true
    local requiredSupply = LookupTechData(techId, kTechDataSupply, 0)
    
    if not player:GetGameStarted() or techNode == nil or ( LookupTechData(techId, kTechDataRequiresMature, false) and (not HasMixin(self, "Maturity") or not self:GetIsMature()) ) then
    
        allowed = false
        canAfford = false
        
    elseif requiredSupply > 0 and MvM_GetSupplyUsedByTeam(self:GetTeamNumber()) + requiredSupply > MvM_GetMaxSupplyForTeam( self:GetTeamNumber() ) then
    //???? Why does this not catch armory upgrade?
        allowed = false
        canAfford = false
        
    elseif techId == kTechId.Recycle and HasMixin(self, "Recycle") then

        allowed = not HasMixin(self, "Live") or self:GetIsAlive()
        canAfford = allowed
        
    elseif techId == kTechId.Cancel then

        allowed = true
        canAfford = true
        
    elseif techNode:GetIsUpgrade() then
        
        canAfford = techNode:GetCost() <= player:GetTeamResources()
        allowed = HasMixin(self, "Research") and not self:GetIsResearching() and allowed
        
    elseif techNode:GetIsEnergyManufacture() or techNode:GetIsEnergyBuild() then
        
        local energy = 0
        if HasMixin(self, "Energy") then
            energy = self:GetEnergy()
        end
        
        local canManufacture = not techNode:GetIsEnergyManufacture() or (HasMixin(self, "Research") and not self:GetIsResearching())
        
        canAfford = techNode:GetCost() <= energy
        allowed = canManufacture and canAfford and allowed
    
    // If tech is research
    elseif techNode:GetIsResearch() then
    
        canAfford = techNode:GetCost() <= player:GetTeamResources()
        allowed = HasMixin(self, "Research") and self:GetResearchTechAllowed(techNode) and not self:GetIsResearching() and allowed

    // If tech is action or buy action
    elseif techNode:GetIsAction() or techNode:GetIsBuy() then
    
        canAfford = player:GetResources() >= techNode:GetCost()
        
    // If tech is activation
    elseif techNode:GetIsActivation() then
        
        canAfford = techNode:GetCost() <= player:GetTeamResources()
        allowed = self:GetActivationTechAllowed(techId) and allowed
        
    // If tech is build
    elseif techNode:GetIsBuild() then
    
        canAfford = player:GetTeamResources() >= techNode:GetCost()
        
    elseif techNode:GetIsManufacture() then
    
        canAfford = player:GetTeamResources() >= techNode:GetCost()
        allowed = HasMixin(self, "Research") and not self:GetIsResearching() and allowed
    
    end
    
    return allowed, canAfford

end


//-----------------------------------------------------------------------------


Class_Reload( "ScriptActor", {} )

