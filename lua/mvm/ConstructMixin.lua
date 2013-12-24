

Script.Load("lua/ConstructMixin.lua")


if Client then
	Shared.PrecacheSurfaceShader("cinematics/vfx_materials/build_team2.surface_shader")
end


local kBuildEffectsInterval = 1
local kDrifterBuildRate = 1

//-----------------------------------------------------------------------------

//FIXME Ideally, this should be based on params, not hard coded in shader(s)
local function CreateBuildEffect_MvM(self)
	
    local model = self:GetRenderModel()
    if not self.buildMaterial and model then
    
        local material = Client.CreateRenderMaterial()
        
        if HasMixin(self, "Team") then
			
			if self:GetTeamNumber() == kTeam2Index then
				material:SetMaterial("cinematics/vfx_materials/build_team2.material")
			else
				material:SetMaterial("cinematics/vfx_materials/build.material")
			end
			
		end
		
        model:AddMaterial(material)
        self.buildMaterial = material
        
    end    
    
end

local function RemoveBuildEffect_MvM(self)	//Pure duplicate, needed for scope limitation(s)

    local model = self:GetRenderModel()
    if self.buildMaterial and model then
    
        local material = self.buildMaterial
        model:RemoveMaterial(material)
        Client.DestroyRenderMaterial(material)
        self.buildMaterial = nil
        
    end            

end


/**
 * Add health to structure as it builds.
 */
local function AddBuildHealth(self, scalar)

    // Add health according to build time.
    if scalar > 0 then
    
        local maxHealth = self:GetMaxHealth()
        self:AddHealth(scalar * (1 - kStartHealthScalar) * maxHealth, false, false, true)
        
    end
    
end

/**
 * Add health to structure as it builds.
 */
local function AddBuildArmor(self, scalar)

    // Add health according to build time.
    if scalar > 0 then
    
        local maxArmor = self:GetMaxArmor()
        self:SetArmor(self:GetArmor() + scalar * (1 - kStartHealthScalar) * maxArmor, true)
        
    end
    
end


/**
 * Build structure by elapsedTime amount and play construction sounds. Pass custom construction sound if desired, 
 * otherwise use Gorge build sound or Marine sparking build sounds. Returns two values - whether the construct
 * action was successful and if enough time has elapsed so a construction AV effect should be played.
 */
function ConstructMixin:Construct(elapsedTime, builder)

    local success = false
    local playAV = false
    
    if not self.constructionComplete and (not HasMixin(self, "Live") or self:GetIsAlive()) then
        
        if builder and builder.OnConstructTarget then
            builder:OnConstructTarget(self)
        end
        
        if Server then

            if not self.lastBuildFractionTechUpdate then
                self.lastBuildFractionTechUpdate = self.buildFraction
            end
            
            local techNode = nil
            local techTree = nil
            //Temp hack
            if not self:isa("PowerPoint") then
				local techTree = self:GetTeam():GetTechTree()
				local techNode = techTree:GetTechNode(self:GetTechId())
			end
			
            //local modifier = (self:GetTeamType() == kMarineTeamType and GetIsPointOnInfestation(self:GetOrigin())) and kInfestationBuildModifier or 1
            local modifier = 1
            local startBuildFraction = self.buildFraction
            local newBuildTime = self.buildTime + elapsedTime * modifier
            local timeToComplete = self:GetTotalConstructionTime()           
            
            if newBuildTime >= timeToComplete then
            
                self:SetConstructionComplete(builder)
                
                if techNode then
                    techNode:SetResearchProgress(1.0)
                    techTree:SetTechNodeChanged(techNode, "researchProgress = 1.0f")
                end    
                
            else
            
                if self.buildTime <= self.timeOfNextBuildWeldEffects and newBuildTime >= self.timeOfNextBuildWeldEffects then
                
                    playAV = true
                    self.timeOfNextBuildWeldEffects = newBuildTime + kBuildEffectsInterval
                    
                end
                
                self.timeLastConstruct = Shared.GetTime()
                self.underConstruction = true
                
                self.buildTime = newBuildTime
                self.oldBuildFraction = self.buildFraction
                self.buildFraction = math.max(math.min((self.buildTime / timeToComplete), 1), 0)
                
                if techNode and (self.buildFraction - self.lastBuildFractionTechUpdate) >= 0.05 then
                
                    techNode:SetResearchProgress(self.buildFraction)
                    techTree:SetTechNodeChanged(techNode, string.format("researchProgress = %.2f", self.buildFraction))
                    self.lastBuildFractionTechUpdate = self.buildFraction
                    
                end
                
                if not self.GetAddConstructHealth or self:GetAddConstructHealth() then
                
                    local scalar = self.buildFraction - startBuildFraction
                    AddBuildHealth(self, scalar)
                    AddBuildArmor(self, scalar)
                
                end
                
                if self.oldBuildFraction ~= self.buildFraction then
                
                    if self.OnConstruct then
                        self:OnConstruct(builder, self.buildFraction, self.oldBuildFraction)
                    end
                    
                end
                
            end
        
        end
        
        success = true
        
    end
    
    if playAV then

        local builderClassName = builder and builder:GetClassName()    
        self:TriggerEffects("construct", {classname = self:GetClassName(), doer = builderClassName, isalien = GetIsAlienUnit(self)})
        
    end 
    
    return success, playAV
    
end




local function SharedUpdate_MvM(self, deltaTime)

    if Server then
        
        local effectTimeout = Shared.GetTime() - self.timeLastConstruct > 0.3
        self.underConstruction = not self:GetIsBuilt() and not effectTimeout
        
        if GetGamerules():GetAutobuild() then
            self:SetConstructionComplete()
        end
        
    elseif Client then
    
        if GetIsMarineUnit(self) then
            if self.underConstruction then
                CreateBuildEffect_MvM(self)
            else
                RemoveBuildEffect_MvM(self)
            end
        end
    
    end
    
end


function ConstructMixin:OnUpdate(deltaTime)
    SharedUpdate_MvM(self, deltaTime)
end

function ConstructMixin:OnProcessMove(input)
    SharedUpdate_MvM(self, input.time)
end


function ConstructMixin:OnUse(player, elapsedTime, useSuccessTable)

    local used = false
	
    if self:GetCanConstruct(player) then

        // Always build by set amount of time, for AV reasons
        // Calling code will put weapon away we return true

        local success, playAV = self:Construct(kUseInterval, player)
        
        if success then

            used = true
        
        end
                
    end
    
    useSuccessTable.useSuccess = useSuccessTable.useSuccess or used
    
end



//-----------------------------------------------------------------------------

//ReplaceLocals( ConstructMixin.Construct, { kBuildEffectsInterval = 1 } )