

Script.Load("lua/Weapons/Marine/GrenadeThrower.lua")


local kGrenadeVelocity = 18	//TODO move to balance


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
		
		if grenade then
			grenade:SetOwner( player )	//nervegas fix hack
		elseif Server then
			Print("MvM_ThrowGrenade() - Server VM and no grenade returned")
		end
		
    end

end



ReplaceLocals( GrenadeThrower.OnTag, { ThrowGrenade = MvM_ThrowGrenade } )

Class_Reload( "GrenadeThrower", {} )

