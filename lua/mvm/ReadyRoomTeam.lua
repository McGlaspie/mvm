
Script.Load("lua/mvm/ReadyRoomPlayer.lua")


//-----------------------------------------------------------------------------


function ReadyRoomTeam:GetRespawnMapName(player)

	local mapName = player.kMapName    
    
    if mapName == nil then
        mapName = ReadyRoomPlayer.kMapName
    end
    
    // Use previous life form if dead or in commander chair
    if mapName == MarineCommander.kMapName or mapName == Spectator.kMapName or mapName == MarineSpectator.kMapName then 
        mapName = player:GetPreviousMapName()
    end
    
    // Default to the basic ReadyRoomPlayer type for certain player types.
    // We cannot currently allow the JetpackMarine in the Ready Room because
    // his Jetpack is destroyed when the game is reset and JetpackMarine
    // expects that the Jetpack always exists.
    if mapName == JetpackMarine.kMapName then
		mapName = ReadyRoomPlayer.kMapName
    end
    
    return mapName

end


function ReadyRoomTeam:ReplaceRespawnPlayer(player, origin, angles)
	
	local mapName = self:GetRespawnMapName(player)
    
    // We do not support Commanders in the ready room. The ready room is chaos!
    if mapName == MarineCommander.kMapName then	//or mapName == AlienCommander.kMapName 
        mapName = ReadyRoomPlayer.kMapName
    end
    
    //Print("ReadyRoomTeam:ReplaceRespawnPlayer() - player.previousTeamNumber=" .. player.previousTeamNumber)
    
    local newPlayer = player:Replace(mapName, self:GetTeamNumber(), false, origin)
    
    //Print("\t newPlayer.previousTeamNumber=" .. newPlayer.previousTeamNumber )
    
    self:RespawnPlayer(newPlayer, origin, angles)
    
    newPlayer:ClearGameEffects()
    newPlayer:SetUpdates(true)
    
    return (newPlayer ~= nil), newPlayer

end



function ReadyRoomTeam:RespawnPlayer(player, origin, angles)
	
	//Print("ReadyRoomTeam:RespawnPlayer() - player.previousTeamNumber = " .. tostring(player.previousTeamNumber) )
	
	Team.RespawnPlayer( self, player, origin, angles )
    
end


function ReadyRoomTeam:OnConstructionComplete(structure)
end


function ReadyRoomTeam:AddPlayer( player )

	//Print("ReadyRoomTeam:AddPlayer()")
	//Print("\t player.previousTeamNumber = " .. tostring( player.previousTeamNumber ) )
	
	Team.AddPlayer( self, player )

end


//-----------------------------------------------------------------------------


Class_Reload("ReadyRoomTeam", {})

