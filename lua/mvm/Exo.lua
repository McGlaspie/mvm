

Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/PostLoadMod.lua")


local newNetworkVars = {}

//-----------------------------------------------------------------------------

if Client then
	Shared.PrecacheSurfaceShader("cinematics/vfx_materials/heal_exo_team2_view.surface_shader")
end

local kExoHealViewMaterialNameTeam2 = "cinematics/vfx_materials/heal_exo_team2_view.material"


AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

//-----------------------------------------------------------------------------


local oldExoCreate = Exo.OnCreate
function Exo:OnCreate()
	
	oldExoCreate(self)
	
	InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
	
end


local oldExoInit = Exo.OnInitialized
function Exo:OnInitialized()
	
	oldExoInit(self)
	
	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end
	
end


if Client then

	function Exo:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function Exo:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function Exo:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


function Exo:GetIsFlameAble()
	return false
end


function Exo:OnWeldOverride(doer, elapsedTime)

	if self:GetArmor() < self:GetMaxArmor() then
    
        local weldRate = kArmorWeldRatePlayer
        if doer and doer:isa("MAC") then
            weldRate = kArmorWeldRateMAC
        end
      
        local addArmor = weldRate * elapsedTime
        
        if self:GetIsOnFire() then
			addArmor = addArmor * kWhileBurningWeldEffectReduction
        end
        
        self:SetArmor(self:GetArmor() + addArmor)
        
        if Server then
            UpdateHealthWarningTriggered(self)
        end
        
    end

end

//-----------------------------------------------------------------------------

Class_Reload("Exo", newNetworkVars)

