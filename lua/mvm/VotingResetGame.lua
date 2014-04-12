// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//    
// lua\VotingResetGame.lua
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================


local kExecuteVoteDelay = 5

RegisterVoteType("MvM_VoteResetGame", { })

if Client then

    local function SetupResetGameVote(voteMenu)
    
        local function StartResetGameVote(data)
            AttemptToStartVote("MvM_VoteResetGame", { })
        end
        
        voteMenu:AddMainMenuOption(Locale.ResolveString("VOTE_RESET_GAME"), nil, StartResetGameVote)
        
        -- This function translates the networked data into a question to display to the player for voting.
        local function GetVoteResetGameQuery(data)
            return Locale.ResolveString("VOTE_RESET_GAME_QUERY")
        end
        AddVoteStartListener("MvM_VoteResetGame", GetVoteResetGameQuery)
        
    end
    
    AddVoteSetupCallback(SetupResetGameVote)
    
end

if Server then

    local function OnResetGameVoteSuccessful(data)
        GetGamerules():ResetGame()
    end
    SetVoteSuccessfulCallback("MvM_VoteResetGame", kExecuteVoteDelay, OnResetGameVoteSuccessful)
    
end
