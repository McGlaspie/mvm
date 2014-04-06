

Script.Load("lua/NS2ConsoleCommands_Server.lua")

//-----------------------------------------------------------------------------


local function MvM_OnCommandChangeClass(className, teamNumber, extraValues)

    return function(client)
    
        local player = client:GetControllingPlayer()
        local replaceTeam = 0
        
        if teamNumber == nil then
			replaceTeam = player:GetTeamNumber()
		else
			replaceTeam = teamNumber
        end
        
        if Shared.GetCheatsEnabled() then	//and player:GetTeamNumber() == teamNumber
            player:Replace(className, teamNumber, false, nil, extraValues)
        end
        
    end
    
end

//Yes, you can be a skulk in MvM. Need aliens code available for future gametypes
Event.Hook("Console_skulk", MvM_OnCommandChangeClass("skulk", nil))
Event.Hook("Console_gorge", MvM_OnCommandChangeClass("gorge", nil))
Event.Hook("Console_lerk", MvM_OnCommandChangeClass("lerk", nil))
Event.Hook("Console_fade", MvM_OnCommandChangeClass("fade", nil))
Event.Hook("Console_onos", MvM_OnCommandChangeClass("onos", nil))
Event.Hook("Console_marine", MvM_OnCommandChangeClass("marine"))
Event.Hook("Console_exo", MvM_OnCommandChangeClass("exo", nil, { layout = "ClawMinigun" }))
Event.Hook("Console_dualminigun", MvM_OnCommandChangeClass("exo", nil, { layout = "MinigunMinigun" }))
Event.Hook("Console_clawrailgun", MvM_OnCommandChangeClass("exo", nil, { layout = "ClawRailgun" }))
Event.Hook("Console_dualrailgun", MvM_OnCommandChangeClass("exo", nil, { layout = "RailgunRailgun" }))


//This is new function that behaves just like the old spawn, but some extra params are
//available to spawn marine variants. 
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
				elseif string.find( marineVariant, "assault") then
					newItem.variant = kMarineVariant.assault
				elseif string.find( marineVariant, "elite") or string.find( marineVariant, "eliteassault") then
					newItem.variant = kMarineVariant.eliteassault
				else
					newItem.variant = kMarineVariant.green
				end
				
				if not marineVariant then
					newItem.variant = kMarineVariant.green
				end
				
				newItem:SetModel( newItem:GetVariantModel() , MarineVariantMixin.kMarineAnimationGraph )
				
			end
			
		end

        Print("spawned \""..itemName.."\" at Vector("..usePos.x..", "..usePos.y..", "..usePos.z..")")
        
    end
    
end


local function OnCommandShockAll(client)

    if Shared.GetCheatsEnabled() then
    
        local player = client:GetControllingPlayer()
        
        if player then
            
            for _, shockable in ipairs( GetEntitiesWithMixin("EMP") ) do                
                shockable:SetPulsed( player, player )            
            end
    
        end
        
    end  

end



Event.Hook( "Console_spawnd", MvM_OnCommandSpawn )
Event.Hook( "Console_shockall", OnCommandShockAll )
