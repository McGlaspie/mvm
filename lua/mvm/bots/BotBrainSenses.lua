
//
// ????: Should this drive a FSM?
//
//



//----------------------------------------
//  STEVE TODO: Should refactor this so a senses state is different from senses functions.
//  So we can hotload the functions without recreating it each frame.
//----------------------------------------
class "BotBrainSenses"

function BotBrainSenses:Initialize()

    self.name2eval = {}

    // per-frame state
    self.name2value = {}
    self.name2evaling = {}
    self.bot = nil

end

function BotBrainSenses:Add(senseName, evalFunc)
    self.name2eval[ senseName ] = evalFunc
end

function BotBrainSenses:OnBeginFrame(bot)

    self.name2value = {}
    self.name2evaling = {}
    self.bot = bot

end

function BotBrainSenses:GetDebugTrace()
    return self.debugTrace
end

//----------------------------------------
//  Call this before passing in the senses to a new weight evaluator
//----------------------------------------
function BotBrainSenses:ResetDebugTrace()
    self.debugTrace = ""
end

function BotBrainSenses:Get(senseName)

    local oldTrace = self.debugTrace
    self.debugTrace = ""
    
    local value = self.name2value[ senseName ]

    if value == nil then

        // Check for cycles
        assert( self.name2evaling[senseName] == nil )

        local evalFunc = self.name2eval[ senseName ]
        assert( evalFunc ~= nil )

        self.name2evaling[ senseName ] = true
        value = evalFunc( self )
        self.name2evaling[ senseName ] = nil
        self.name2value[ senseName ] = value

    end

    self.debugTrace = string.format( "%s%s = %s%s",
            oldTrace == "" and "" or oldTrace..", ",
            senseName,
            ToString(value),
            self.debugTrace == "" and "" or " ("..self.debugTrace..")" )

    return value
end

