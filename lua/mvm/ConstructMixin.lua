

Script.Load("lua/ConstructMixin.lua")


if Client then
	Shared.PrecacheSurfaceShader("cinematics/vfx_materials/build_team2.surface_shader")
end

//-----------------------------------------------------------------------------


local function CreateBuildEffect_MvM(self)

    local model = self:GetRenderModel()
    if not self.buildMaterial and model then
    
        local material = Client.CreateRenderMaterial()
        
        if HasMixin("Team", self) then
			
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


local function SharedUpdate_MvM(self, deltaTime)

    if Server then
        
        local effectTimeout = Shared.GetTime() - self.timeLastConstruct > 0.3
        self.underConstruction = not self:GetIsBuilt() and not effectTimeout
        
        // Only Alien structures auto build.
        // Update build fraction every tick to be smooth.
        //if not GetIsMarineUnit(self) then
			//if not self:GetIsBuilt() and GetIsAlienUnit(self) then
				//if not self.GetCanAutoBuild or self:GetCanAutoBuild() then
				//	self:Construct(deltaTime)
				//end
			//end
		//end
        
    elseif Client then
    
        if GetIsMarineUnit(self) then
            if self.underConstruction then
                CreateBuildEffect_MvM(self)
            else
                RemoveBuildEffect(self)
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
