//
//	Marine vs Marine - NS2 Mod
//	Copyright 2013 - Brock 'McGlaspie' Gillespie
//

decoda_name = "Server"


Script.Load("lua/Server.lua")

Script.Load("lua/mvm_Shared.lua")
Script.Load("lua/mvm/TechData.lua")
Script.Load("lua/mvm/TargetCache.lua")
Script.Load("lua/mvm/MarineTeam.lua")

Script.Load("lua/mvm/bots/Bot.lua")

Script.Load("lua/mvm/VoteManager.lua")
Script.Load("lua/mvm/Voting.lua")
Script.Load("lua/mvm/VotingKickPlayer.lua")
Script.Load("lua/mvm/VotingChangeMap.lua")
Script.Load("lua/mvm/VotingResetGame.lua")
Script.Load("lua/mvm/VotingRandomizeRR.lua")
Script.Load("lua/mvm/VotingForceEvenTeams.lua")


//-----------------------------------------------------------------------------



/**
 * The reserved slot system allows players marked as reserved players to join while
 * all non-reserved slots are taken and the server is not full.
 */
local function MvM_OnCheckConnectionAllowed(userId)

    local reservedSlots = Server.GetConfigSetting("reserved_slots")
    
    if not reservedSlots or not reservedSlots.amount or not reservedSlots.ids then
        return true
    end
    
    local newPlayerIsReserved = false
    for name, id in pairs(reservedSlots.ids) do
    
        if id == userId then
        
            newPlayerIsReserved = true
            break
            
        end
        
    end
    
    local numPlayers = Server.GetNumPlayers()
    local maxPlayers = Server.GetMaxPlayers()
    
    //TODO Add support for Bots not reporting as Players in conn sequence
    // - How does the Server return number of players when queried through SteamAPI?
    // see Client.GetServerMaxPlayers() if you can find the def. Not in docs/Client.json
    
    if ( numPlayers < ( maxPlayers - reservedSlots.amount ) ) or ( newPlayerIsReserved and ( numPlayers < maxPlayers ) ) then
        return true
    end
    
    return false
    
end

Event.Hook( "CheckConnectionAllowed", MvM_OnCheckConnectionAllowed )



