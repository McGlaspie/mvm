//=============================================================================
//
// lua\bots\BotCommander.lua
//
// Created by Steven An (steve@unknownworlds.com)
// Copyright (c) 2013, Unknown Worlds Entertainment, Inc.
//
//  Tries to log in to a command structure, then creates the appropriate brain for the team.
//
//=============================================================================

Script.Load("lua/mvm/bots/BotPlayer.lua")
Script.Load("lua/mvm/bots/BotMarineCommanderBrain.lua")
//Script.Load("lua/bots/AlienCommanderBrain.lua")


gBotCommanders = {}

local kCommander2BrainClass =
{
    ["MarineCommander"] = MarineCommanderBrain,
    ["MarineCommander"] = MarineCommanderBrain
}

/*
local kTeam2StationClassName =
{
    "CommandStation",
    "CommandStation"	//Need two? Reverse usage...
}
*/

class 'BotCommander' (BotPlayer)

//----------------------------------------
//  Override
//----------------------------------------
function BotCommander:GetNamePrefix()
    return "[BOT] "
end

//----------------------------------------
//  Override
//----------------------------------------
function BotCommander:_LazilyInitBrain()
	
	PROFILE("BotCommander:_LazilyInitBrain")

    if self.brain == nil then

        //local brainClass = kCommander2BrainClass[ self:GetPlayer():GetClassName() ]
        local brainClass = MarineCommanderBrain

        if brainClass ~= nil then
            self.brain = brainClass()
        else
            // must be spectator - wait until we have joined a team
        end

        if self.brain ~= nil then
            self.brain:Initialize()
            self:GetPlayer().botBrain = self.brain
        end

    end
	
end

function BotCommander:GetIsPlayerCommanding()

	PROFILE("BotCommander:GetIsPlayerCommanding")

    return self:GetPlayer():isa("Commander")

end

//----------------------------------------
//  Override
//----------------------------------------
function BotCommander:GenerateMove()

	PROFILE("BotCommander:GenerateMove")
	
    if gBotDebug:Get("spam") then
        Print("BotCommander:GenerateMove")
    end

    local player = self:GetPlayer()
    local playerClass = player:GetClassName()
    local stationClass = "CommandStation"		//kTeam2StationClassName[ player:GetTeamNumber() ]
	
    local move = Move()
	
    //----------------------------------------
    //  Take commander chair/hive if we are not
    //----------------------------------------
    if not self:GetIsPlayerCommanding() and stationClass ~= nil then

        //Print("trying to log %s into %s", player:GetName(), stationClass)
		
		for _, station in ipairs( GetEntitiesForTeam( "CommandStation", player:GetTeamNumber() ) ) do
		//just hit the first we find (for now)
			station:LoginPlayer(player)
			break
		end
		
    else

        // Brain will modify move.commands
        self:_LazilyInitBrain()
        if self.brain ~= nil then
            self.brain:Update(self,  move)
        else
            // must be waiting to join a team
        end

    end

    return move

end
