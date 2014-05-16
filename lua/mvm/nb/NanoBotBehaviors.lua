//=============================================================================
//
//	NanoBot AI Behaviors
//		Author: Brock 'McGlaspie' Gillespie
//
//	Be very careful about what variables are accessed and created within a
//	Behavior "object". Doing so increases the likelihood the Garbage Collector
//	will have to run mid-frame. This create a lot of overhead that could cause
//	spikes in the Server's tickrate.
//
//=============================================================================

/*
TODO:
Review ALL of below, see where and how much of this
is already available in NS2 code.
*/


assert( Server )


//Be very careful of what files are in scope
Script.Load("lua/Globals.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/mvm/mvm_Globals.lua")
Script.Load("lua/mvm/BehaviorTree.lua")
Script.Load("lua/mvm/nb/NanoBotUtility.lua")
Script.Load("lua/mvm/nb/NanoBotMemory.lua")


--global
gBehaviorsIndex = {}	//Used to store all of the Behavior names for lookups


//-----------------------------------------------------------------------------

/*
All of the Behavior "objects" are stored in this table to allow for String based
key referencing. This makes it significantly easier to create and modify a behavior
tree. Potentially, even opening up the option for some kind of web-based editor.


Definition of an AI Behavior:

gNanoBotBehaviors[ tableIdex ]	-  this is the Name of a Behavior and how it's position
								   in a BehaviorTree is denoted.
								
_type
	This denotes the Type of Behavior Node a specific Behavior definition is. Type checks
	are performed when initializing a Tree, so it is important to ensure this is accurate
	for a given behavior.
	
PreCondition = function( self )
	If this is present, it acts as a conditional check that controls IF the
	Behavior() CAN be called.
	
Behavior = function( self )
	This is the actual logical routine to run for a given behavior. Care should be
	taken to ensure these functions are as fast as they can be and don't create
	a bunch of crap the garbage collect has to clean up


on_enter = function( self )
	This function (if specified) is called BEFORE Behavior() is called. It should
	do any initialization, quick data retrievals, or prep for changes that will
	occur in Behavior()

on_exit = function( self )
	Optional call everytime the Tree finishes running a Behavior()

The 'self' parameter to all the functions is a reference to the AI Agent (Bot)
	
*/
gNanoBotBehaviors = {}


//-----------------------------------------------------------------------------
//	BehaviorTree - Core Behaviors Routines
//
//kBehaviorStatus = enum({ 'Invalid', 'Running', 'Success', 'Failed' })
//kBehaviorTreeNodeType = enum({ 'Invalid', 'Action', 'Selector', 'Sequence' })

gNanoBotBehaviors["Idle"] = {
	
	local isIdle = false,	//is legit Lua?
	
	PreCondition = function( self )
		return 
			self.botState ~= kNanoBotStates.Combat 
			and self:GetOrders() ~= nil
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:Idle")
		
		if self.stateUpdateInterval + self.lastStateUpdateTime > Shared.GetTime() then
			
			isIdle = true
			if GetGameRules():GetGameStarted() and not self:isa("Commander") then
				--todo request order at random+intv
			end
			
		end
		
		return kBehaviorStatus.Success
		
	end,
	
	on_exit = function( self )
		if isIdle then
			self.stateUpdateInterval = kNanoBotStateUpdateInterval + math.random()
		end
	end
	
}


gNanoBotBehaviors["FindRoamingDestination"] = {
	
	PreCondition = function( self )
		return 
			self.botState ~= kNanoBotStates.Combat
			and self.botState ~= kNanoBotStates.Retreating
			and self.botState ~= kNanoBotStates.Spawning
			and self.botState ~= kNanoBotStates.Escorting
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:FindRoamingDestination")
		
	end,
	
	on_enter = function( self )
		
	end,
	
	on_exit = function( self )
		self.botState = kNanoBotStates.Roaming
	end
	
}


gNanoBotBehaviors["WaitForStructurePlacement"] = {
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:WaitForStructurePlacement")
		
		self.stateUpdateInterval = 1 + math.random(1)
		//calc how long until tres? Would need to know what's being placed...
	end,
	
	on_enter = function( self )
		
	end,
	
	on_exit = function( self )
		self.botState = kNanoBotStates.Waiting
	end
	
}


gNanoBotBehaviors["WaitReinforcements"] = {
	
	PreCondition = function( self )
		return self.botState ~= kNanoBotStates.Combat
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:WaitReinforcements")
	
		self.stateUpdateInterval = 1 + math.random()
	end,
	
	on_enter = function( self )
		self.botState = kNanoBotStates.Waiting
	end,
	
}


gNanoBotBehaviors["PrioritizeStructureTargets"] = {
	
	PreCondition = function( self )
		return self.botState == kNanoBotStates.Combat
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:Idle")
	end,
	
	on_enter = function( self )
		
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["AttackTarget"] = {
	
	PreCondition = function( self )
		return self.botState == kNanoBotStates.Combat
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:Idle")
	end,
	
	on_enter = function( self )
		//Use TargetingMixin here?
	end,
	
	on_exit = function( self )
		
	end
	
}


gNanoBotBehaviors["StrafeLeft"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:StrafeLeft")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["StrafeRight"] = {

	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:StrafeRight")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end

}


gNanoBotBehaviors["QuickStepLeft"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:QuickStepLeft")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["QuickStepRight"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:QuickStepRight")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["CheckForStuck"] = {		//FIXME Move to NanoBotMove

	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:CheckForStuck")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end

}


gNanoBotBehaviors["CommitSuicide"] = {

	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:CommitSuicide")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end

}


gNanoBotBehaviors["RequestOrder"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:RequestOrder")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["RequestMedpack"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:RequestMedpack")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["RequestAmmoPack"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:RequestAmmoPack")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["RequestSupport"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:RequestSupport")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["FindEnemiesNearBy"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:FindEnemiesNearBy")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["PriotitizeEnemies"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:PriotitizeEnemies")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["FindWeldPlayerTarget"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:FindWeldPlayerTarget")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["FindWeldStructureTarget"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:FindWeldStructureTarget")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["FindCover"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:FindCover")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["CheckForRetreat"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:CheckForRetreat")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["RunAway"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:RunAway")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["SprintToGoal"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:SprintToGoal")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["DropPrimaryWeapon"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:DropPrimaryWeapon")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["FindUsableEquipment"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:FindUsableEquipment")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}


gNanoBotBehaviors["DropPrimaryWeapon"] = {
	
	PreCondition = function( self )
	
	end,
	
	Behavior = function( self )
		PROFILE("gNanoBotBehaviors:DropPrimaryWeapon")
	end,
	
	on_enter = function( self )
	
	end,
	
	on_exit = function( self )
	
	end
	
}



//-----------------------------------------------------------------------------


local bDefTblSize = GetTableSize( gNanoBotBehaviors )
local bIndxTblSize = GetTableSize( gBehaviorsIndex )

local function GenerateBehaviorIndexes( behaviorDefTable )

	assert( type(behaviorDefTable) == "table" )
	
	for behaviorName, behavior in ipairs( behaviorDefTable ) do
		//TODO Check for duplicates
		table.insert( gBehaviorsIndex, table.getn(gBehaviorsIndex) + 1, behaviorName )
	end

end

if bDefTblSize > 0 bIndxTblSize == 0 then
//Call immediatley as setup, but only when gBehaviorsIndex is not in a "ready-state"
	GenerateBehaviorIndexes( gNanoBotBehaviors )
else
	//todo error
end


//-----------------------------------------------------------------------------


function GetBehaviorDefinition( behaviorName )

	assert( type( behaviorName ) == "string" )
	assert( type( gNanoBotBehaviors[ behaviorName ] ) == "string" )
	
	return gNanoBotBehaviors[ behaviorName ]

end




