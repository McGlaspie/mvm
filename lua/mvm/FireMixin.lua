
Script.Load("lua/FireMixin.lua")



local kBurnBigCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_big.cinematic")
local kBurnHugeCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_huge.cinematic")
local kBurnMedCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_med.cinematic")
local kBurnSmallCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_small.cinematic")
local kBurn1PCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_1p.cinematic")

local kBurnUpdateRate = 0.5

local kFireCinematicTable = { }
kFireCinematicTable["CommandStation"] = kBurnHugeCinematic
kFireCinematicTable["InfantryPortal"] = kBurnMedCinematic
kFireCinematicTable["Extractor"] = kBurnBigCinematic
kFireCinematicTable["Armory"] = kBurnBigCinematic
kFireCinematicTable["Observatory"] = kBurnSmallCinematic
kFireCinematicTable["PhaseGate"] = kBurnMedCinematic
kFireCinematicTable["ArmsLab"] = kBurnSmallCinematic
kFireCinematicTable["RoboticsFactory"] = kBurnHugeCinematic
kFireCinematicTable["PrototypeLab"] = kBurnBigCinematic
kFireCinematicTable["SentryBattery"] = kBurnSmallCinematic
kFireCinematicTable["Sentry"] = kBurnSmallCinematic

kFireCinematicTable["MAC"] = kBurnSmallCinematic
kFireCinematicTable["Mine"] = kBurnSmallCinematic
kFireCinematicTable["ARC"] = kBurnMedCinematic
kFireCinematicTable["Exo"] = kBurnBigCinematic
kFireCinematicTable["Marine"] = kBurnSmallCinematic

kFireCinematicTable["PowerPoint"] = kBurnMedCinematic


local function MvMGetOnFireCinematic(ent, firstPerson)

    if firstPerson then
        return kBurn1PCinematic
    end
    
    return kFireCinematicTable[ent:GetClassName()] or kBurnMedCinematic
    
end


function FireMixin:SetOnFire( attacker, doer )

	if ( self:isa("Exo") or self:isa("Exosuit") ) then
		//Print("Exo - FireMixin:SetOnFire()")
	end

	if Server and not self:GetIsDestroyed() then
    
		if ( self:isa("Exo") or self:isa("Exosuit") ) then
			//Print("[Server] Exo - FireMixin:SetOnFire()")
		end
    
        if not self:GetCanBeSetOnFire() then
            return
        end
        
        self:SetGameEffectMask(kGameEffect.OnFire, true)
        
        if attacker then
            self.fireAttackerId = attacker:GetId()
        end
        
        if doer then
            self.fireDoerId = doer:GetId()
        end
        
        self.timeBurnInit = Shared.GetTime()
        self.isOnFire = true
        
        if ( self:isa("Exo") or self:isa("Exosuit") ) and not self.isOnFire then
			//Print("[Server]\t Failed to set Exo on fire!")
		end
        
    end	

end


function UpdateFireMaterial(self)
	
    if self._renderModel then
    
        if self.isOnFire and not self.fireMaterial then
			
            self.fireMaterial = Client.CreateRenderMaterial()
            self.fireMaterial:SetMaterial("cinematics/vfx_materials/burning.material")
            self._renderModel:AddMaterial(self.fireMaterial)
            
        elseif not self.isOnFire and self.fireMaterial then
        
            self._renderModel:RemoveMaterial(self.fireMaterial)
            Client.DestroyRenderMaterial(self.fireMaterial)
            self.fireMaterial = nil
            
        end
        
    end
    
    if self:isa("Player") and self:GetIsLocalPlayer() then
    
        local viewModelEntity = self:GetViewModelEntity()
        if viewModelEntity then
        
            local viewModel = self:GetViewModelEntity():GetRenderModel()
            if viewModel and (self.isOnFire and not self.viewFireMaterial) then
            
                self.viewFireMaterial = Client.CreateRenderMaterial()
                self.viewFireMaterial:SetMaterial("cinematics/vfx_materials/burning_view.material")
                
                if self:isa("Exo") then
					self.viewFireMaterial:SetParameter( "opacityOverride", 0.025 )
                end
                
                viewModel:AddMaterial(self.viewFireMaterial)
                
            elseif viewModel and (not self.isOnFire and self.viewFireMaterial) then
            
                viewModel:RemoveMaterial(self.viewFireMaterial)
                Client.DestroyRenderMaterial(self.viewFireMaterial)
                self.viewFireMaterial = nil
                
            end
            
        end
        
    end
    
end



local function MvM_SharedUpdate(self, deltaTime)

    if Client then
        UpdateFireMaterial(self)
        self:_UpdateClientFireEffects()
    end

    if not self:GetIsOnFire() then
        return
    end
    
    if Server then
		
		//Add burn delay (visually) for Exos to denote damage reduction?
        if self:GetIsAlive() and (not self.timeLastFireDamageUpdate or self.timeLastFireDamageUpdate + kBurnUpdateRate <= Shared.GetTime()) then
    
            local damageOverTime = kBurnUpdateRate * kBurnDamagePerSecond
            
            if self.GetIsFlameAble and self:GetIsFlameAble() then	//Muh? Is this not handled in DamageTypes.lua?
                damageOverTime = damageOverTime * kFlameableMultiplier
            end
            
            //if self:isa("Exo") or self:isa("Exosuit") then
				//Print("FireMixin:MvM_SharedUpdate() - Reduced fire DOT to Exo")
				//damageOverTime = damageOverTime * kBurnDamageExoReduction
            //end
            
            local attacker = nil
            if self.fireAttackerId ~= Entity.invalidId then
                attacker = Shared.GetEntity(self.fireAttackerId)
            end

            local doer = nil
            if self.fireDoerId ~= Entity.invalidId then
                doer = Shared.GetEntity(self.fireDoerId)
            end
            
            self:DeductHealth(damageOverTime, attacker, doer)

            if attacker then
            
                local msg = BuildDamageMessage(self, damageOverTime, self:GetOrigin())
                
                Server.SendNetworkMessage(attacker, "Damage", msg, false)
                
                for _, spectator in ientitylist(Shared.GetEntitiesWithClassname("Spectator")) do
                
                    if attacker == Server.GetOwner(spectator):GetSpectatingPlayer() then
						
                        Server.SendNetworkMessage(spectator, "Damage", msg, false)
                        
                    end
                    
                end
            
            end
            
            self.timeLastFireDamageUpdate = Shared.GetTime()
            
        end
        
        // See if we put ourselves out
        if Shared.GetTime() - self.timeBurnInit > kFlamethrowerBurnDuration then
            self:SetGameEffectMask(kGameEffect.OnFire, false)
        end
        
    end
    
end


function FireMixin:OnUpdate(deltaTime)   
    MvM_SharedUpdate(self, deltaTime)
end

function FireMixin:OnProcessMove(input)   
    MvM_SharedUpdate(self, input.time)
end


//-----------------------------------------------------------------------------


if Client then
	ReplaceLocals( FireMixin._UpdateClientFireEffects, { GetOnFireCinematic = MvMGetOnFireCinematic } )
end

