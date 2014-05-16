//=============================================================================
//
//	NanoBot - Marine vs Marine AI Player
//		Author: Brock 'McGlaspie' Gillespie
//
//=============================================================================

assert( Client or Server )


gNanoBotsDebugHandler = {}

gNanoBotsDebugHandler.enabled = false

gNanoBotsDebugHandler.debugFlags = {}
gNanoBotsDebugHandler.debugFlags["ShowViewAngles"] = false
gNanoBotsDebugHandler.debugFlags["ShowHeading"] = false
gNanoBotsDebugHandler.debugFlags["ShowStates"] = false
gNanoBotsDebugHandler.debugFlags["EnableChatInfo"] = false
gNanoBotsDebugHandler.debugFlags["FreezeAll"] = false
gNanoBotsDebugHandler.debugFlags["ShowGoal"] = false
gNanoBotsDebugHandler.debugFlags["ShowGoalPath"] = false
gNanoBotsDebugHandler.debugFlags["ShowBehaviors"] = false


//-----------------------------------------------------------------------------


gNanoBotsDebugHandler.SetDebugFlag = function( self, flagName, state )

	assert( type(self.debugFlags) == "table" )
	
	

end


gNanoBotsDebugHandler.SetMode = function( self, enabled )
	assert( type(enabled) == "boolean")
	self.enabled = enabled or false
end


//-----------------------------------------------------------------------------


local function OnCommandDebugNanoBots(  )


end


local function OnCommandDebugNanoBots_ShowViewAngles(  )
	//TODO toggle flag after cast
	// - use debugdraw to create Viewer attachment point like 3-axis vector showing
	//	 where bots are looking
end


local function OnCommandDebugNanoBots_ShowHeading(  )
	//TODO toggle flag in handler
	// - this should draw a debugline in which direction the bot wants to move
	// - show debugline in which direction bot IS moving
end


local function OnCommandDebugNanoBots_ShowGoalPath(  )
	//TODO toggle flag in handler
	// - use pathing utils to draw debug line of current navpath to self goal
end


local function OnCommandDebugNanoBots_ShowGoal(  )
	//TODO toggle flag in handler
	// - use world text, draw bot's Goal on it's origin, or offset to side
end

local function OnCommandDebugNanoBots_ShowBehaviors(  )
	//TODO toggle flag in handler
	// - use world text, draw bot's current Behavior
end


local function OnCommandDebugNanoBots_ShowStates(  )
	//TODO toggle flag in handler
	// - this should use WorldText to draw the State a bot is in on it's origin
end


local function OnCommandDebugNanoBots_OverrideState(  )
	//TODO toggle specific bot's FSM State (runs current State exit())
	// - find bot, override it's state, let FSM exit current state
end


local function OnCommandDebugNanoBots_EnableChatInfo(  )
	//TODO toggle flag in handler
	// - this should make the bot a player is looking at toggle its sayall debug chat
end


local function OnCommandDebugNanoBots_FreezeAll(  )
	//TODO Toggle debug handler flag
	// - use in Bots update routine and prevent any changes from occuring
end






