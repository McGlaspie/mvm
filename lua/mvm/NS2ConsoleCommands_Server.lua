


Script.Load("lua/NS2ConsoleCommands_Server.lua")




//MvM: FIXME - Force UI refresh (somwhow)
// Switch player from one team to the other, while staying in the same place
local function OnCommandSwitch(client)

    local player = client:GetControllingPlayer()
    local teamNumber = player:GetTeamNumber()
    if(Shared.GetCheatsEnabled() and (teamNumber == kTeam1Index or teamNumber == kTeam2Index)) and not player:GetIsCommander() then
    
        // Remember position and team for calling player for debugging
        local playerOrigin = player:GetOrigin()
        local playerViewAngles = player:GetViewAngles()
        
        local newTeamNumber = kTeam1Index
        if(teamNumber == kTeam1Index) then
            newTeamNumber = kTeam2Index
        end
        
        //TODO Trigger UI Reset event somehow...
        
        local success, newPlayer = GetGamerules():JoinTeam(player, kTeamReadyRoom)
        success, newPlayer = GetGamerules():JoinTeam(newPlayer, newTeamNumber)
        
        newPlayer:SetOrigin(playerOrigin)
        newPlayer:SetViewAngles(playerViewAngles)
        
    end
    
end



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
			
			if marineVariant ~= nil and HasMixin(newItem, "MarineVariant") then
				
				if marineVariant == "female" then
					newItem:SetVariant("green", "female")
				elseif marineVariant == "female_black" then
					newItem:SetVariant("special", "female")
				elseif marineVariant == "female_deluxe" then
					newItem:SetVariant("deluxe", "female")
				elseif marineVariant == "male_black" then
					newItem:SetVariant("special", "male")
				elseif marineVariant == "male_deluxe" then
					newItem:SetVariant("deluxe", "male")
				end
				
			end
			
			end
			
		end

        Print("spawned \""..itemName.."\" at Vector("..usePos.x..", "..usePos.y..", "..usePos.z..")")
        
    end
    
end



Event.Hook("Console_spawn", MvM_OnCommandSpawn)

