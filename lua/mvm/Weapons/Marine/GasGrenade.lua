

//Script.Load("")


//-----------------------------------------------------------------------------


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


if Client then
	Class_Reload("GasGrenade", {})
end




//=============================================================================
//Nerve Gas Cloud

local gNerveGasDamageTakers = {}

local kCloudUpdateRate = 0.3
local kSpreadDelay = 0.6
local kNerveGasCloudRadius = 7
local kNerveGasCloudLifetime = 6

local kCloudMoveSpeed = 2


NerveGasCloud.kEffectTeam2Name = PrecacheAsset("cinematics/marine/nervegascloud_team2.cinematic")


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


Class_Reload("NerveGasCloud", {})
