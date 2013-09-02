

Shared.PrecacheSurfaceShader("cinematics/vfx_materials/nanoshield_team2.surface_shader")
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/nanoshield_view_team2.surface_shader")

//-----------------------------------------------------------------------------

function NanoShieldMixin:__initmixin()

    //if Server then
        self.timeNanoShieldInit = 0
        self.tempShieldLifeTime = 0
        self.nanoShielded = false
    //end
    
end

local function ClearNanoShield(self, destroySound)

    self.nanoShielded = false
    self.timeNanoShieldInit = 0
    self.tempShieldLifeTime = 0
    
    if Client then
        self:_RemoveEffect()
    end
    
    if Server and self.shieldLoopSound and destroySound then
        DestroyEntity(self.shieldLoopSound)
    end
    
    self.shieldLoopSound = nil
    
end

function NanoShieldMixin:OnDestroy()

    if self:GetIsNanoShielded() then
        ClearNanoShield(self, false)
    end
    
end

function NanoShieldMixin:ActivateNanoShield(shieldLifeTime)
	
    if self:GetCanBeNanoShielded() then
    
        self.timeNanoShieldInit = Shared.GetTime()
        self.nanoShielded = true
        
        if shieldLifeTime ~= nil and shieldLifeTime > 0 then
			self.tempShieldLifeTime = shieldLifeTime
		else
			self.tempShieldLifeTime = 0
		end
        
        if Server then
			
            assert(self.shieldLoopSound == nil)
            self.shieldLoopSound = Server.CreateEntity(SoundEffect.kMapName)
            self.shieldLoopSound:SetAsset(kNanoLoopSound)
            self.shieldLoopSound:SetParent(self)
            self.shieldLoopSound:Start()
            
        end
        
    end
    
end


local function UpdateClientNanoShieldEffects(self)

    assert(Client)
    
    if self:GetIsNanoShielded() and self:GetIsAlive() then
        self:_CreateEffect()
    else
        self:_RemoveEffect() 
    end
    
end


local function SharedUpdate(self)

    if Server then
    
        if not self:GetIsNanoShielded() then
            return
        end
        
        // See if nano shield time is over
        if self.tempShieldLifeTime > 0 and ( self.tempShieldLifeTime + self.timeNanoShieldInit < Shared.GetTime() ) then
			ClearNanoShield(self, true)
			self.tempShieldLifeTime = 0
        elseif self.timeNanoShieldInit + kNanoShieldDuration < Shared.GetTime() then
            ClearNanoShield(self, true)
        end
       
    elseif Client and not Shared.GetIsRunningPrediction() then
        UpdateClientNanoShieldEffects(self)
    end
    
end

function NanoShieldMixin:OnUpdate(deltaTime)   
    SharedUpdate(self)
end

function NanoShieldMixin:OnProcessMove(input)   
    SharedUpdate(self)
end


if Client then

	function NanoShieldMixin:_CreateEffect()
   
        if not self.nanoShieldMaterial then
        
            local material = Client.CreateRenderMaterial()
            local viewMaterial = Client.CreateRenderMaterial()
            
            //TODO Try using material param
            if self:GetTeamNumber() == kTeam2Index then
				material:SetMaterial("cinematics/vfx_materials/nanoshield_team2.material")
				viewMaterial:SetMaterial("cinematics/vfx_materials/nanoshield_view_team2.material")
			else
				material:SetMaterial("cinematics/vfx_materials/nanoshield.material")
				viewMaterial:SetMaterial("cinematics/vfx_materials/nanoshield_view.material")
			end
            
            self.nanoShieldEntities = {}
            self.nanoShieldMaterial = material
            self.nanoShieldViewMaterial = viewMaterial
            AddEffect(self, material, viewMaterial, self.nanoShieldEntities)
            
        end
        
    end
    
end //Client

//-----------------------------------------------------------------------------

