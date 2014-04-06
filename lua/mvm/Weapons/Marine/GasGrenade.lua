
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")
Script.Load("lua/mvm/DamageMixin.lua")


//Gas cloud
local kCloudUpdateRate = 0.25
local kSpreadDelay = 0.5
local kNerveGasCloudRadius = 6
local kNerveGasCloudLifetime = 6
local kCloudMoveSpeed = 1

//Gas grenade
local kLifeTime = 9	//Must have additional second to account for ownership hack-fix
local kGasReleaseDelay = 1


local newNetworkVars = {}

AddMixinNetworkVars(LOSMixin, newNetworkVars )


//-----------------------------------------------------------------------------


local function TimeUp(self)
    DestroyEntity(self)
end


function GasGrenade:OnCreate()	//OVERRIDES

    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    
    if Server then  
  
        //self:AddTimedCallback(TimeUp, kLifeTime)
        self:AddTimedCallback(GasGrenade.ReleaseGas, kGasReleaseDelay)
        self:AddTimedCallback(GasGrenade.UpdateNerveGas, 1)
        self.releaseGasTime = 0
        
    end
    
    self.releaseGas = false
    self.clientGasReleased = false
    
end


//function GasGrenade:OverrideCheckVision()
//	return false
//end

function GasGrenade:OverrideVisionRadius()
	return 0
end


if Server then
	
	function GasGrenade:ReleaseGas()	//OVERRIDES
		self.releaseGas = true
		self.releaseGasTime = Shared.GetTime()
	end
	
	
    function GasGrenade:UpdateNerveGas()	//OVERRIDES
		
        if self.releaseGas then
        
			if (self.releaseGasTime + kLifeTime) - 1 < Shared.GetTime() then
				TimeUp(self)
				return false
			end
        
            local direction = Vector(math.random() - 0.5, 0.5, math.random() - 0.5)
            direction:Normalize()
            
            local trace = Shared.TraceRay(self:GetOrigin() + Vector(0, 0.2, 0), self:GetOrigin() + direction * 7, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAll())
            local nervegascloud = CreateEntity(NerveGasCloud.kMapName, self:GetOrigin(), self:GetTeamNumber())
            nervegascloud:SetEndPos(trace.endPoint)
            
            //FIXME cloud lifespan exceed the grenade
            local owner = self:GetOwner()
            if owner then
				nervegascloud:SetOwner( owner )
			else
				Print("GasGrenade:UpdateNerveGas() - Failed to set owner for NerveGasCloud")
            end
        
        end
        
        return true
    
    end

end


if Client then
	
    function GasGrenade:OnUpdateRender()
    
        PredictedProjectile.OnUpdateRender(self)
    
        if self.releaseGas and not self.clientGasReleased then
			
			if self:GetTeamNumber() == kTeam2Index then
				self:TriggerEffects("release_nervegas_team2", { effethostcoords = Coords.GetTranslation(self:GetOrigin())} )        
			else
				self:TriggerEffects("release_nervegas", { effethostcoords = Coords.GetTranslation(self:GetOrigin())} )        
			end
			
            self.clientGasReleased = true
        
        end
    
    end
    
end


//-----------------------------------------------------------------------------


Class_Reload( "GasGrenade", {} )





//=============================================================================
//Nerve Gas Cloud

local gNerveGasDamageTakers = {}


local newGasNetworkVars = {
	ownerId = "entityid",
}

NerveGasCloud.kEffectTeam2Name = PrecacheAsset("cinematics/marine/nervegascloud_team2.cinematic")


function NerveGasCloud:OnCreate()	//OVERRIDES

    Entity.OnCreate(self)

    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)

    if Server then
    
        self.creationTime = Shared.GetTime()
    
        self:AddTimedCallback(TimeUp, kNerveGasCloudLifetime)
        self:AddTimedCallback(NerveGasCloud.DoNerveGasDamage, kCloudUpdateRate)
        
        InitMixin(self, OwnerMixin)
        
    end
    
    self:SetUpdates(true)

end



local function GetRecentlyDamaged(entityId, time)

    for index, pair in ipairs(gNerveGasDamageTakers) do
        if pair[1] == entityId and pair[2] > time then
            return true
        end
    end
    
    return false

end

local function SetRecentlyDamaged(entityId)

    for index, pair in ipairs(gNerveGasDamageTakers) do
        if pair[1] == entityId then
            table.remove(gNerveGasDamageTakers, index)
        end
    end
    
    table.insert(gNerveGasDamageTakers, {entityId, Shared.GetTime()})
    
end

local function GetIsInCloud(self, entity, radius)

    local targetPos = entity.GetEyePos and entity:GetEyePos() or entity:GetOrigin()    
    return (self:GetOrigin() - targetPos):GetLength() <= radius

end


function NerveGasCloud:DoNerveGasDamage()

    local radius = math.min(1, (Shared.GetTime() - self.creationTime) / kSpreadDelay) * kNerveGasCloudRadius
	
    for _, entity in ipairs( GetEntitiesWithMixinForTeamWithinRange("Live", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), 2 * kNerveGasCloudRadius)) do

        if not GetRecentlyDamaged(entity:GetId(), (Shared.GetTime() - kCloudUpdateRate)) and GetIsInCloud(self, entity, radius) then
            
            self:DoDamage(
				kNerveGasDamagePerSecond * kCloudUpdateRate, 
				entity, 
				entity:GetOrigin(), 
				GetNormalizedVector(self:GetOrigin() - entity:GetOrigin()), 
				"none"
			)
			
            SetRecentlyDamaged(entity:GetId())
            
        end
    
    end

    return true

end


function NerveGasCloud:OverrideVisionRadius()
	return 0
end

function NerveGasCloud:GetDeathIconIndex()	//Useful one burn away function added
	return kDeathMessageIcon.GasGrenade
end


if Client then

    function NerveGasCloud:OnInitialized()

        local cinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        
        if self:GetTeamNumber() == kTeam2Index then
			cinematic:SetCinematic( NerveGasCloud.kEffectTeam2Name )
		else
			cinematic:SetCinematic( NerveGasCloud.kEffectName )
		end
		
        cinematic:SetParent(self)
        cinematic:SetCoords(Coords.GetIdentity())
        
    end
    
end


//-----------------------------------------------------------------------------


Class_Reload( "NerveGasCloud", newGasNetworkVars )
