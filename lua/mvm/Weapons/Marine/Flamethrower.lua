
Script.Load("lua/mvm/Weapons/Marine/Flame.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")
Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/PointGiverMixin.lua")


Flamethrower.kModelName = PrecacheAsset("models/marine/flamethrower/flamethrower.model")
local kViewModels = GenerateMarineViewModelPaths("flamethrower")
local kAnimationGraph = PrecacheAsset("models/marine/flamethrower/flamethrower_view.animation_graph")

local kFireLoopingSound = PrecacheAsset("sound/NS2.fev/marine/flamethrower/attack_loop")

local kRange = kFlamethrowerRange
local kUpgradedRange = kFlamethrowerUpgradedRange

local kConeWidth = 0.17


local newNetworkVars = {}


//-----------------------------------------------------------------------------


function Flamethrower:OnCreate()	//OVERRIDES

    ClipWeapon.OnCreate(self)
    
    self.loopingSoundEntId = Entity.invalidId
    
    if Server then
    
        self.createParticleEffects = false
        self.animationDoneTime = 0
        
        self.loopingFireSound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingFireSound:SetAsset(kFireLoopingSound)
        self.loopingFireSound:SetParent(self)
        self.loopingSoundEntId = self.loopingFireSound:GetId()
        
    elseif Client then
    
        self:SetUpdates(true)
        self.lastAttackEffectTime = 0.0
        
    end
    
    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, PointGiverMixin)

end



local function BurnSporesAndUmbra(self, startPoint, endPoint)	//change to burn nervegasclouds
end


local function MvM_CreateFlame(self, player, position, normal, direction)

    // create flame entity, but prevent spamming:
    local nearbyFlames = GetEntitiesForTeamWithinRange("Flame", self:GetTeamNumber(), position, 1.5)    

    if table.count(nearbyFlames) == 0 then
    
        local flame = CreateEntity(Flame.kMapName, position, player:GetTeamNumber())
        flame:SetOwner(player)
        
        local coords = Coords.GetTranslation(position)
        coords.yAxis = normal
        coords.zAxis = direction
        
        coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
        coords.xAxis:Normalize()
        
        coords.zAxis = coords.xAxis:CrossProduct(coords.yAxis)
        coords.zAxis:Normalize()
        
        flame:SetCoords(coords)
        
    end

end


//MvM:Removed check to burn spores/umbra and added exo reduce, same otherwise
local function MvM_ApplyConeDamage(self, player)
    
    local barrelPoint = self:GetBarrelPoint() - Vector(0, 0.4, 0)
    local ents = {}
    
    local fireDirection = GetNormalizedVector((player:GetEyePos() - Vector(0, 0.3, 0) + player:GetViewCoords().zAxis * kRange) - barrelPoint)
    local extents = Vector(kConeWidth, kConeWidth, kConeWidth)
    local remainingRange = kRange
    local startPoint = barrelPoint
    
    for i = 1, 4 do
    
        if remainingRange <= 0 then
            break
        end
        
        local trace = TraceMeleeBox(self, startPoint, fireDirection, extents, remainingRange, PhysicsMask.Melee, EntityFilterOne(player))
        
        if trace.fraction ~= 1 then
        
            if trace.entity then
            
                if HasMixin(trace.entity, "Live") then
                    table.insertunique(ents, trace.entity)
                end
                
            else
            
                // Make another trace to see if the shot should get deflected.
                local lineTrace = Shared.TraceRay(
					startPoint, 
					startPoint + remainingRange * fireDirection, 
					CollisionRep.LOS, 
					PhysicsMask.Melee, 
					EntityFilterOne(player)
				)
                
                if lineTrace.fraction < 0.8 then
                
                    fireDirection = fireDirection + trace.normal * 0.55
                    fireDirection:Normalize()
                    
                    if Server then
                        MvM_CreateFlame(self, player, lineTrace.endPoint, lineTrace.normal, fireDirection)
                    end
                    
                end
                
            end
            
            remainingRange = remainingRange - (trace.endPoint - startPoint):GetLength() - kConeWidth * 2
            startPoint = trace.endPoint + fireDirection * kConeWidth * 2
        
        else
            break
        end

    end
    
    for index, ent in ipairs(ents) do
    
        if ent ~= player then
        
            local toEnemy = GetNormalizedVector(ent:GetModelOrigin() - barrelPoint)
            local health = ent:GetHealth()
            
            local flameThrowerDamage = kFlamethrowerDamage
            
            if ent:isa("Exo") or ent:isa("Exosuit") then	//undeployed arc?
				
				flameThrowerDamage = flameThrowerDamage * kBurnDamageExoReduction
				
				//Print("Flamethrower.MvM_ApplyConeDamage() - Have Exo")
				//Print("\t ent HP = " .. tostring(health))
				//Print("\t ent has FireMixin: " .. tostring( HasMixin( ent, "Fire") ) )
				
            end
            
            self:DoDamage(flameThrowerDamage, ent, ent:GetModelOrigin(), toEnemy)
            
            // Only light on fire if we successfully damaged them
            if ( ent:GetHealth() ~= health or ( ent:isa("Exo") or ent:isa("Exosuit") ) ) and HasMixin(ent, "Fire") then
                ent:SetOnFire(player, self)
            end
            
        end
    
    end

end


local function MvM_ShootFlame(self, player)
	
	local viewAngles = player:GetViewAngles()
	local viewCoords = viewAngles:GetCoords()
	
	viewCoords.origin = self:GetBarrelPoint(player) + viewCoords.zAxis * (-0.4) + viewCoords.xAxis * (-0.2)
	local endPoint = self:GetBarrelPoint(player) + viewCoords.xAxis * (-0.2) + viewCoords.yAxis * (-0.3) + viewCoords.zAxis * self:GetRange()
	
	local trace = Shared.TraceRay(viewCoords.origin, endPoint, CollisionRep.Damage, PhysicsMask.Flame, EntityFilterAll())
	
	local range = (trace.endPoint - viewCoords.origin):GetLength()
	if range < 0 then
		range = range * (-1)
	end
	
	if trace.endPoint ~= endPoint and trace.entity == nil then
	
		local angles = Angles(0,0,0)
		angles.yaw = GetYawFromVector(trace.normal)
		angles.pitch = GetPitchFromVector(trace.normal) + (math.pi/2)
		
		local normalCoords = angles:GetCoords()
		normalCoords.origin = trace.endPoint
		range = range - 3
		
	end
	
	MvM_ApplyConeDamage(self, player)
	
	TEST_EVENT("Flamethrower primary attack")
	
end  


function Flamethrower:FirePrimary(player, bullets, range, penetration)
    MvM_ShootFlame(self, player)
end


if Client then
	
    function Flamethrower:GetUIDisplaySettings()
        return { xSize = 128, ySize = 256, script = "lua/mvm/Hud/GUIFlamethrowerDisplay.lua" }
    end

end


//-----------------------------------------------------------------------------


//ReplaceLocals( Flamethrower.FirePrimary , { ShootFlame = MvM_ShootFlame } )

Class_Reload( "Flamethrower", newNetworkVars )

