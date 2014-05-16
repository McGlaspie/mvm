//=============================================================================
//	NanoBot - AI Player
//		Author: Brock 'McGlaspie' Gillespie
//
//	These bots are an attempt to bypass the need for using the VirtualClient
//  aspect of Spark. This is mainly so bots can leverage more of the existing
//  NS2 codebase, and prevent them from atificially inflating a server's player
//  count.
//
//  NanoBots (NBs) are a server-side entity that does not use the VirtualClient
//  component of Spark. They are all based from the core Entity class. Their
//	AI is a composite of Pseudo-FiniteStateMachine and a BehaviorTree.
//
//	The State a bot is in will dictate what behaviors are scoped for execution.
//	All of the core concepts of a BTree are allowed. So, some behaviors can run
//	multiple times until compelted, some can require a specific state, and others
//	can be called in sequence for conditionally.
//
//	Each Behavior conforms to a specific format, and has a very specific set of
//	optional functions ( PreCondition, on_enter, on_exit ). All Behvaiors must
//	define a Behavior function, which is the core routine of a single behavior
//	in a BTree.
//
//=============================================================================

/*
TODO - Update Following for Bot Support:
NS2Gamerules:ResetGame()
NS2Gamerules:JoinTeam()
Gamerules:OnClientDisconnect(client)
Gamerules:OnClientConnect(client)
lua\PlayerInfoEntity.lua (make new? BotInfoEnt?)
ScoreBoard.lua - UpdatePlayerRecords()
Shared.lua
Server.lua - OnCheckConnectionAllowed()
Client.lua

Future Options:
Weight Bot skill based on averaged player skill on server?
Allow read/write of Btree definition in JSON (file on server)
Btree web-based editor
*/


Script.Load("lua/Globals.lua")
Script.Load("lua/mvm/TechTreeConstants.lua")
Script.Load("lua/mvm/TechData.lua")
Script.Load("lua/mvm/MvMUtility.lua")


if Server then

	Script.Load("lua/mvm/nb/NanoBotBehaviorTree.lua")
	Script.Load("lua/mvm/nb/NanoBotBehaviors.lua")
	Script.Load("lua/mvm/nb/NanoBotUtility.lua")
	Script.Load("lua/mvm/nb/NanoBotMemory.lua")
	Script.Load("lua/mvm/nb/NanoBotProfile.lua")
	
	//Global ref to all bots
	//Useful in cases where they all need XYZ to be performed
	gNanoBots = {}

	//Global to track the minimum level of NanoBot "skill" level
	gNanoBotSkillLevel = 0	//0 - 5
	
	kNanoBotDefaultProfileType = kNanoBotProfiles.Balanced

end


gNanoBotDebug = false


/*
--todo describe purpose & usage
*/
kNanoBotStates = enum({ 
	'Idle', 'Traveling', 'Escorting', 'Combat', 
	'Waiting', 'Roaming', 'Retreating', 'Spawning'
})


//how often a bot will see if it should be in a different state
//this interval is not related to combat
kNanoBotStateUpdateInterval = 0.3
kNanoBotMaxStateUpdateInterval = 0.5

kNanoBotBehaviorRunLimit = 10		//Maximum amount of time a behvaior can run
kNanoBotBehaviorRunLongWarnging = 8	//Amount of time until a warning is generated


local nanoBotNetworkVars = {
	clientId = "integer (-1 to 4000)",
}


//-----------------------------------------------------------------------------


/*
TODO:
Base movement
Base Looking
DTree init
Unit Tests
 - FSM Tests
 - DTree Tests
 - Base bot tests
 - Core functionality Tests
Debug visualizers (See debugger)
Debug console commands
Console Commands
Game Hooks
Bot Config(s)
Bot Dynamic Join/Kick
*/


/*
The NanoBot extends ScriptActor because of the limitations of Spark's VirtualClient.
While this does create a lot more processing for the Server, it does not impact player's
ability to join a server. VirtualClient's do not show as filling a player slot from
the Server Browser, but DO count towards a server's player limit.
*/
class 'NanoBot' (ScriptActor)	//TODO Review Entity & ScriptActor, ensure these are what's needed

	
	
	function NanoBot:OnCreate()

		PROFILE("NanoBot:OnCreate")

		ScriptActor.OnCreate( self )
		
		self.debugHandler = nil
		
		if Server then
			
			self.clientId = -1	//Mock value for Scoreboard, kicks, etc
			
			self.behaviorTree = nil
			
			self.currentState = kNanoBotState.Spawning
			self.previousState = nil
			self.lastStateChangeTime = 0
			
			self.stateUpdateInterval = math.max( 
											kNanoBotMaxStateUpdateInterval, 
											math.random() + math.random(),
											kNanoBotStateUpdateInterval
									   )
			
			self.lastUpdateTime = 0	//Actually needed?
			
			self.currentBehavior = nil
			self.previousBehavior = nil
			
			self.lastBehaviorUpdateTime = 0
			
		end
		
		Shared.AddTagToEntity( self, "NanoBot" )
		
		self:SetUpdates(true)

	end
	

	function NanoBot:OnInitialized()

		PROFILE("NanoBot:OnInitialized")

		if Server then
		
			
		
		end

	end
	
	
if Server then


	function NanoBot:OnThink()
	
		
	
	end

	
	function NanoBot:InitializeBehaviors( bTreeData, profileType )
	
		assert( bTreeData )
		assert( type( bTreeData ) == "table" )
		
		if profileType == nil then
			profileType = kNanoBotDefaultProfileType
		end
		
		
	
	end

	
end	//End Server

	
	--todo add all the common crap needed


	function NanoBot:OnUpdate( deltaTime )
		
		PROFILE("NanoBot:OnUpdate")
		
		assert( self.behaviorTree )
		assert( type( self.behaviorTree ) == "" )
		
		self.lastUpdateTime = deltaTime + self.lastUpdateTime
		
		self:OnUpdateState( deltaTime )
		
		if self.currentBehavior.status ~= kBehaviorStatus.Running then
			--todo run behavior tree, here or (X)Player?
			self.behaviorTree:Process( self, deltaTime )
			
		end

	end
	
	
	function NanoBot:OnUpdateState( deltaTime )
	
		if self.lastUpdateStateTime + self.updateStateInterval > Shared.GetTime() then
		
			
		
		end
	
	end





//=============================================================================
//Core Console Commands


local function OnCommandNanoBotAdd( client, numBots, team, profile )


end


local function OnCommandNanoBotRemove( client, numBots, team )


end


local function OnCommandNanoBotSetSkill( client, skill )


end


//TODO Handle loading / parsing / executing server settings



