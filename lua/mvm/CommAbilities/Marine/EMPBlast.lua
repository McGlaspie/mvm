

local kSplashEffect = PrecacheAsset("cinematics/marine/mac/empblast.cinematic")
local kRadius = 6
local kType = CommanderAbility.kType.Instant
local kEMPBlastMinEnergy = 10


local orgEmpBlastCreate = EMPBlast.OnCreate
function EMPBlast:OnCreate()

	orgEmpBlastCreate( self )
	
	InitMixin(self, DamageMixin)

end


function EMPBlast:GetDamageType()
	return kDamageType.ElectroMagnetic
end


if Server then
	
	local function SineFalloff(distanceFraction)
		local piFraction = Clamp( distanceFraction, 0, 1 ) * math.pi / 2
		return math.cos(piFraction + math.pi) + 1 
	end
	
    function EMPBlast:Perform()		//OVERRIDES
        
        local hitEntities = GetEntitiesWithMixinForTeamWithinRange(
			"Live", 
			GetEnemyTeamNumber( self:GetTeamNumber() ), 
			self:GetOrigin(), 
			kRadius
		)
        
        RadiusDamage( hitEntities, self:GetOrigin(), kRadius, kMACEMPBlastDamage, self, false, SineFalloff )

    end

end


Class_Reload( "EMPBlast", {} )