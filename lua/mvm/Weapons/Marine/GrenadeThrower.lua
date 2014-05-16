

Script.Load("lua/Weapons/Marine/GrenadeThrower.lua")


local kGrenadeVelocity = 18	//TODO move to balance

kTeam1ArmedLight = PrecacheAsset("models/marine/grenades/armed_light_blue.cinematic")
kTeam2ArmedLight = PrecacheAsset("models/marine/grenades/armed_light_red.cinematic")

kArmedLightFx = {
	[kTeam1Index] = kTeam1ArmedLight,
	[kTeam2Index] = kTeam2ArmedLight
}


local kDefaultVariantData = kMarineVariantData[ kDefaultMarineVariant ]
function GenerateMarineGrenadeViewModelPaths(grenadeType)

    local viewModels = { male = { }, female = { } }
    
    local function MakePath(prefix, suffix)
        return "models/marine/grenades/" .. prefix .. grenadeType .. "_view" .. suffix .. ".model"
    end
    
    for variant, data in pairs(kMarineVariantData) do
        viewModels.male[variant] = PrecacheAssetSafe(MakePath("", data.viewModelFilePart), MakePath("", kDefaultVariantData.viewModelFilePart))
    end
    
    for variant, data in pairs(kMarineVariantData) do
        viewModels.female[variant] = PrecacheAssetSafe(MakePath("female_", data.viewModelFilePart), MakePath("female_", kDefaultVariantData.viewModelFilePart))
    end
    
    return viewModels
    
end



local function MvM_ThrowGrenade( self, player )
	
	if Server or (Client and Client.GetIsControllingPlayer()) then

        local viewCoords = player:GetViewCoords()
        local eyePos = player:GetEyePos()

        local startPointTrace = Shared.TraceCapsule(eyePos, eyePos + viewCoords.zAxis, 0.2, 0, CollisionRep.Move, PhysicsMask.PredictedProjectileGroup, EntityFilterTwo(self, player))
        local startPoint = startPointTrace.endPoint

        local direction = viewCoords.zAxis
        
        if startPointTrace.fraction ~= 1 then
            direction = GetNormalizedVector(direction:GetProjection(startPointTrace.normal))
        end
        
        local grenadeClassName = self:GetGrenadeClassName()
        local grenade = player:CreatePredictedProjectile(grenadeClassName, startPoint, direction * kGrenadeVelocity, 0.7, 0.45)
		
		//local isMarine = self:GetTeamNumber() == kTeam1Index
		//local isAlien = self:GetTeamNumber() == kTeam2Index
		//self:TriggerEffects("grenade_armed_light", { world_space = true, ismarine = isMarine, isalien = isAlien } )
		
		if grenade then
			grenade:SetOwner( player )	//nerve-gas fix hack
		elseif Server then
			Print("MvM_ThrowGrenade() - Server VM and no grenade returned")
		end
		
    end

end



ReplaceLocals( GrenadeThrower.OnTag, { ThrowGrenade = MvM_ThrowGrenade } )

Class_Reload( "GrenadeThrower", {} )

