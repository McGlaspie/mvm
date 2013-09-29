
Script.Load("lua/NanoshieldMixin.lua")


if Client then
	Shared.PrecacheSurfaceShader("cinematics/vfx_materials/nanoshield_team2.surface_shader")
	Shared.PrecacheSurfaceShader("cinematics/vfx_materials/nanoshield_view_team2.surface_shader")
	//Shared.PrecacheSurfaceShader("cinematics/vfx_materials/nanoshield_exoview.surface_shader")	TODO - Make team2 version
end


local kNanoShieldStartSound = PrecacheAsset("sound/NS2.fev/marine/commander/nano_shield_3D")
local kNanoLoopSound = PrecacheAsset("sound/NS2.fev/marine/commander/nano_loop")
local kNanoDamageSound = PrecacheAsset("sound/NS2.fev/marine/commander/nano_damage")


//-----------------------------------------------------------------------------

function NanoShieldMixin:__initmixin()

    //if Server then
        self.timeNanoShieldInit = 0		//Used for IP shields
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

function NanoShieldMixin:ActivateNanoShield()

    if self:GetCanBeNanoShielded() then
    
        self.timeNanoShieldInit = Shared.GetTime()
        self.nanoShielded = true
        
        if Server then
        
            assert(self.shieldLoopSound == nil)
            self.shieldLoopSound = Server.CreateEntity(SoundEffect.kMapName)
            self.shieldLoopSound:SetAsset(kNanoLoopSound)
            self.shieldLoopSound:SetParent(self)
            self.shieldLoopSound:Start()
            
            StartSoundEffectOnEntity(kNanoShieldStartSound, self)
            
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

	/** Adds the material effect to the entity and all child entities (hat have a Model mixin) */
    local function AddEffect(entity, material, viewMaterial, entities)
    
        local numChildren = entity:GetNumChildren()
        
        if HasMixin(entity, "Model") then
            local model = entity._renderModel
            if model ~= nil then
                if model:GetZone() == RenderScene.Zone_ViewModel then
                    model:AddMaterial(viewMaterial)
                else
                    model:AddMaterial(material)
                end
                table.insert(entities, entity:GetId())
            end
        end
        
        for i = 1, entity:GetNumChildren() do
            local child = entity:GetChildAtIndex(i - 1)
            AddEffect(child, material, viewMaterial, entities)
        end
    
    end
    
    local function RemoveEffect(entities, material, viewMaterial)
    
        for i =1, #entities do
            local entity = Shared.GetEntity( entities[i] )
            if entity ~= nil and HasMixin(entity, "Model") then
                local model = entity._renderModel
                if model ~= nil then
                    if model:GetZone() == RenderScene.Zone_ViewModel then
                        model:RemoveMaterial(viewMaterial)
                    else
                        model:RemoveMaterial(material)
                    end
                end                    
            end
        end
        
    end
    

	function NanoShieldMixin:_CreateEffect()
   
        if not self.nanoShieldMaterial then
        
            local material = Client.CreateRenderMaterial()
            local viewMaterial = Client.CreateRenderMaterial()
            
            /*	Update for Exos
            if self:isa("Exo") then
                viewMaterial:SetMaterial("cinematics/vfx_materials/nanoshield_exoview.material")
            else
                viewMaterial:SetMaterial("cinematics/vfx_materials/nanoshield_view.material")
            end
            */
            
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

