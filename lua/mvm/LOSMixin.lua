

Script.Load("lua/LOSMixin.lua")


local kUnitMaxLOSDistance = kPlayerLOSDistance
local kUnitMinLOSDistance = kStructureLOSDistance

// How often to look for nearby enemies.
local kLookForEnemiesRate = 0.5

local kLOSTimeout = 1


//-----------------------------------------------------------------------------


local function MvM_UpdateLOS(self)

    local mask = bit.bor(kRelevantToTeam1Unit, kRelevantToTeam2Unit, kRelevantToReadyRoom)
    
	if self.sighted then
		mask = bit.bor(mask, kRelevantToTeam1Commander, kRelevantToTeam2Commander)		
	elseif self:GetTeamNumber() == kTeam1Index then
		mask = bit.bor(mask, kRelevantToTeam1Commander)
	elseif self:GetTeamNumber() == kTeam2Index then
		mask = bit.bor(mask, kRelevantToTeam2Commander)
	end
    
    self:SetExcludeRelevancyMask(mask)
    self.visibleClient = self.sighted
    
    if self.lastSightedState ~= self.sighted then
		
        if self.OnSighted then
            self:OnSighted(self.sighted)
        end
        
        self.lastSightedState = self.sighted
        
    end
    
end


function LOSMixin:__initmixin()

    if Server then
    
        self.sighted = false
        self.lastTimeLookedForEnemies = 0
        self.updateLOS = true
        self.timeLastLOSUpdate = 0
        self.dirtyLOS = true
        self.timeLastLOSDirty = 0
        self.prevLOSorigin = Vector(0,0,0)
    
        self:SetIsSighted(false)
        
        MvM_UpdateLOS(self)
        
        self.oldSighted = true
        self.lastViewerId = Entity.invalidId
        
    end
    
end


if Server then

	
	local function GetCanSee(viewer, entity)
		
		if viewer:isa("Commander") and entity:isa("PowerPoint") then
			local viewerTeam = viewer:GetTeamNumber()
			if not entity:IsScouted( viewerTeam ) then
				return false
			end
        end
			
		if viewer:isa("PowerPoint") and entity:isa("Commander") then
			return false
		end
		
		// SA: We now allow marines to build ghosts anywhere - so make sure they're blind. Otherwise they can sorta scout.
        if HasMixin(viewer, "GhostStructure") then
            return false
        end
		
        // If the other entity is not visible then we cannot see it.
        if not entity:GetIsVisible() then
            return false
        end
        
        // We don't care to sight dead things.
        local dead = HasMixin(entity, "Live") and not entity:GetIsAlive() and not entity:isa("PowerPoint")
        if dead then
            return false
        end
        
        local viewerDead = HasMixin(viewer, "Live") and not viewer:GetIsAlive()
        if viewerDead then
            return false
        end
        
        // Anything cloaked or camoflaged is invisible to us.
        if (HasMixin(entity, "Cloakable") and entity:GetIsCloaked()) or
           (entity.GetIsCamouflaged and entity:GetIsCamouflaged()) then
            return false
        end
        
        // Check if this entity is beyond our vision radius.
        local maxDist = viewer:GetVisionRadius()
        local dist = (entity:GetOrigin() - viewer:GetOrigin()):GetLengthSquared()
        if dist > (maxDist * maxDist) then
            return false
        end
        
        // If close enough to the entity, we see it no matter what.
        if dist < (kUnitMinLOSDistance * kUnitMinLOSDistance) then
            return true
        end
        
        return GetCanSeeEntity(viewer, entity)
        
    end
	
	
	local function CheckIsAbleToSee(viewer)
    
        if viewer:isa("Structure") and not viewer:GetIsBuilt() then
            return false
        end
        
        if HasMixin(viewer, "Live") and not viewer:GetIsAlive() then
            return false
        end
        
        if viewer.OverrideCheckVision then
            return viewer:OverrideCheckVision()
        end
        
        return true
        
    end

	
	local function LookForEnemies(self)
    
        PROFILE("LOSMixin:LookForEnemies")
        
        if not CheckIsAbleToSee(self) then
            return
        end
        
        local entities = Shared.GetEntitiesWithTagInRange("LOS", self:GetOrigin(), self:GetVisionRadius())
        
        for e = 1, #entities do
        
            local otherEntity = entities[e]
            
            if not otherEntity.sighted or otherEntity:isa("PowerPoint") then	//Hacky, so hacky...
				
                // Only check sight for enemy entities.
                local areEnemies = otherEntity:GetTeamNumber() == GetEnemyTeamNumber( self:GetTeamNumber() )
                
                if otherEntity:isa("PowerPoint") and GetCanSee(self, otherEntity) then
					
					otherEntity:SetIsSighted(true, self)
					
                elseif areEnemies and GetCanSee(self, otherEntity) then
					
                    otherEntity:SetIsSighted(true, self)
                    
                end
                
            end
            
        end
        
    end

	
	local function UpdateSelfSighted(self)
    
        // Marines are seen if parasited or on infestation.
        // Soon make this something other Mixins can hook into instead of hardcoding GameEffects here.
        local seen = false
        
        if HasMixin(self, "GameEffects") then
            seen = GetIsParasited(self)
        end
        
        local lastViewer = self:GetLastViewer()
        //and not ( lastViewer:isa("Commander") and self:isa("PowerPoint") )
        if not seen and lastViewer then
        
            // prevents flickering, ARCs for example would lose their target
            seen = GetCanSee(lastViewer, self)
            
        end
        
        if self.SetIsSightedOverride then
			self:SetIsSightedOverride( seen, lastViewer )
		else
			self:SetIsSighted( seen, lastViewer )
		end
        
    end
	
	
	local function MarkNearbyDirty(self)
    
        self.updateLOS = true
        
        for _, entity in ipairs( 
							GetEntitiesWithMixinForTeamWithinRange(
								"LOS", 
								GetEnemyTeamNumber(self:GetTeamNumber()), 
								self:GetOrigin(), 
								kUnitMaxLOSDistance
							)
						) do
						
            entity.updateLOS = true
            
        end
        
    end
    
//-------------------------------------


	local function MvM_SharedUpdate(self, deltaTime)
		
        PROFILE("LOS:MvM_SharedUpdate")
        
        //Print("MvM_SharedUpdate()")
        
        // Prevent entities from being sighted before the game starts.
        if not GetGamerules():GetGameStarted() then
            return
        end
        
        local now = Shared.GetTime()
        if self.dirtyLOS and self.timeLastLOSDirty + 0.2 < now then
        
            MarkNearbyDirty(self)
            self.dirtyLOS = false
            self.timeLastLOSDirty = now
            
        end
        
        if self.updateLOS and self.timeLastLOSUpdate + 0.2 < now then
        
            UpdateSelfSighted(self)
            LookForEnemies(self)
            
            self.updateLOS = false
            self.timeLastLOSUpdate = now
            
        end
        
        if self.oldSighted ~= self.sighted then
        
            if self.sighted then
				
                MvM_UpdateLOS(self)
                self.timeUpdateLOS = nil
                
            else
                self.timeUpdateLOS = Shared.GetTime() + kLOSTimeout
            end
            
            self.oldSighted = self.sighted
            
        end
        
        if self.timeUpdateLOS and self.timeUpdateLOS < Shared.GetTime() then
        
            MvM_UpdateLOS(self)
            self.timeUpdateLOS = nil
            
        end
        
    end
	
	
	function LOSMixin:OnTeamChange()
    
        MvM_UpdateLOS(self)
        self:SetIsSighted(false)
        
    end
	
	
	function LOSMixin:OnUpdate(deltaTime)
        MvM_SharedUpdate(self, deltaTime)
    end
    
    function LOSMixin:OnProcessMove(input)
        MvM_SharedUpdate(self, input.time)
    end


	
	function LOSMixin:SetIsSighted(sighted, viewer)
    
        PROFILE("LOSMixin:SetIsSighted")
        
        if self.SetIsSightedOverride then
			self.sighted = self:SetIsSightedOverride( sighted, viewer )
		else
			self.sighted = sighted
		end
        
        if viewer then
			
            if not HasMixin(viewer, "LOS") and not viewer:isa("CommanderAbility") then	//hackish
                error(string.format("%s: %s added as a viewer without having LOS mixin", ToString(self), ToString(viewer)))
            end
            
            self.lastViewerId = viewer:GetId()
            
        end
        
    end
    
    
    function LOSMixin:GetLastViewer()

        if self.lastViewerId and self.lastViewerId ~= Entity.invalidId then
        
            local viewer = Shared.GetEntity(self.lastViewerId)
            
            if viewer and not HasMixin(viewer, "LOS") and not viewer:isa("CommanderAbility") then	//more hackies
                error(string.format("%s: %s added as a viewer without having LOS mixin", ToString(self), ToString(viewer)))
            end
            
            return viewer
            
        end
        
    end


end	//Server

