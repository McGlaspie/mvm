
Script.Load("lua/mvm/bots/BotCommanderBrain.lua")
Script.Load("lua/mvm/bots/BotMarineCommanderBrain_Data.lua")
Script.Load("lua/mvm/bots/BotDebug.lua")

gBotDebug:AddBoolean("mcom")

gMarineCommanderBrains = {}

//----------------------------------------
//  
//----------------------------------------
class 'BotMarineCommanderBrain' (BotCommanderBrain)

function BotMarineCommanderBrain:Initialize()

    CommanderBrain.Initialize(self)
    self.senses = CreateMarineComSenses()
    table.insert( gMarineCommanderBrains, self )

end

function BotMarineCommanderBrain:GetExpectedPlayerClass()
    return "MarineCommander"
end

function BotMarineCommanderBrain:GetExpectedTeamNumber()	//May cause issues
    return kMarineTeamType
end

function BotMarineCommanderBrain:GetActions()
    return kMarineComBrainActions
end

function BotMarineCommanderBrain:GetSenses()
    return self.senses
end
