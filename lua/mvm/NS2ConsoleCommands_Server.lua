

Script.Load("lua/NS2ConsoleCommands_Server.lua")

//-----------------------------------------------------------------------------


local function MvM_OnCommandSpawn(client, itemName, teamnum, marineVariant, useLastPos)

    local player = client:GetControllingPlayer()
    
    if(Shared.GetCheatsEnabled() and itemName ~= nil) then
    
        // trace along players zAxis and spawn the item there
        local startPoint = player:GetEyePos()
        local endPoint = startPoint + player:GetViewCoords().zAxis * 100
        local usePos = nil
        
        if not teamnum then
            teamnum = player:GetTeamNumber()
        else
            teamnum = tonumber(teamnum)
        end
        
        if useLastPos and gLastPosition then
            usePos = gLastPosition
        else
        
            local trace = Shared.TraceRay(startPoint, endPoint,  CollisionRep.Default, PhysicsMask.Bullets, EntityFilterAll())
            usePos = trace.endPoint
        
        end
		
		local newItem = CreateEntity(itemName, usePos, teamnum)
		
		if newItem:isa("Marine") then
			
			if marineVariant ~= nil then
				
				if string.find( marineVariant, "female" ) then
					newItem.isMale = false
				end
				
				if string.find( marineVariant, "black") or string.find( marineVariant, "special") then
					newItem.variant = kMarineVariant.special
				elseif string.find( marineVariant, "deluxe") then
					newItem.variant = kMarineVariant.deluxe
				elseif string.find( marineVariant, "assault") and newItem.isMale then
					newItem.variant = kMarineVariant.assault
				elseif string.find( marineVariant, "elite") or string.find( marineVariant, "eliteassault") and newItem.isMale then
					newItem.variant = kMarineVariant.eliteassault
				else
					newItem.variant = kMarineVariant.green
				end
				
				newItem:SetModel( newItem:GetVariantModel() , MarineVariantMixin.kMarineAnimationGraph )
				
			end
			
		end

        Print("spawned \""..itemName.."\" at Vector("..usePos.x..", "..usePos.y..", "..usePos.z..")")
        
    end
    
end



Event.Hook("Console_spawnd", MvM_OnCommandSpawn)

