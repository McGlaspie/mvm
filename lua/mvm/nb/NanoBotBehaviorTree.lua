//=============================================================================
//	NanoBot - AI Behavior Tree
//		Author: Brock 'McGlaspie' Gillespie
//
//	--todo describe functionality and usage
//
//=============================================================================


assert(Server)	//Server-side only


//Simple status value for each leaf/node in NB's btree
kBehaviorStatus = enum({ 'Invalid', 'Running', 'Success', 'Failed' })

/*
--todo describe
*/
kBehaviorTreeNodeType = enum({ 'Invalid', 'Action', 'Selector', 'Sequence' })


//-----------------------------------------------------------------------------

/*
Simple Exmplae BTree:

btree = {
	
	"Idle" = {
		type = kBehaviorTreeNodeType.Action,
		nodes = nil
	},
	{
		state = Combat,
		
		"FindTarget" = {
			type = kBehaviorTreeNodeType.Sequence,
			nodes = {
				"PrioritizeTargets" = {
					type = kBehaviorTreeNodeType.Action
				},
				"AttackTarget" = {
					type = kBehaviorTreeNodeType.Action
				},
			}
		},
		"Evade" = {
			type = kBehaviorTreeNodeType.Sequence,
			nodes = {
				"DecideEvasionMove" = {
					type = kBehaviorTreeNodeType.Selector,
					nodes = {
						"FindCover" = {
							type = kBehaviorTreeNodeType.Action
						},
						"QuickStepEvade" = {
							type = kBehaviorTreeNodeType.Selector,
							nodes = {
								"QuickStepRight" = {
									type = kBehaviorTreeNodeType.Action
								},
								"QuickStepLeft" = {
									type = kBehaviorTreeNodeType.Action
								}
							}
						},
					}
				},
				"Retreat" = {
					type = kBehaviorTreeNodeType.Action
				},
			}
		},
	
	...
	...
}


/*
--todo describe purpose and usage
*/
class 'NanoBotBehaviorTree'


NanoBotBehaviorTree.MaximumTreeDepth = 40	//??


local btree = nil


function NanoBotBehaviorTree:Initialize( treeData )
	
	PROFILE("NanoBotBehaviorTree:Initialize")
	
	assert( treeData )
	assert( type(treeData) == "table" )

	btree = {}
	
	for stateType, stateBehaviors in ipairs( treeData ) do
	
		
	
		for behaviorName, behavior in ipairs( stateBehaviors ) do
			
			if behavior ~= nil and type(behaviorName) == "string" then
				
				if behavior.type then
				
					
				
				else
					
					DebugPrint("")
					break
					
				end
				
			else
				
				DebugPrint("")
				break
			
			end
			
		end
		
	end

end


function NanoBotBehaviorTree:Process( bot, deltaTime )
	
	PROFILE("NanoBotBehaviorTree:Process")
	
	assert( bot )
	--no check on deltaTime, because init-phase can occur without time passed
	
	//Allow current behavior to finish
	if self.currentBehavior.status == kBehaviorStatus.Running then
	//FIXME This will cause some state-based collision issues in individual
	//behavior's logic. State comparison before check?
		
		self:RunBehavior( bot, self.currentBehavior, deltaTime )
		self.lastBehaviorUpdateTime = Shared.GetTime()
		
		if self.currentBehavior.status ~= 
		
	end
	
	//Switch on Bot State and run behaviors
	if self.botState ~= nil and btree[ self.botState ] ~= nil then
		
		for behaviorName, behavior in ipairs( btree[ self ] ) do
			
			--todo switch on BType, call accordingly
			
		end
		
	else
		DebugPrint("BOT Encountered state without behaviors or no state found")
	end

end


//Controller method to call appropriate handler method for a given behavior
function NanoBotBehaviorTree:RunBehavior( bot, behavior, deltaTime )
	
	PROFILE("NanoBotBehaviorTree:RunBehavior")
	
	local bType = kBehaviorTreeNodeType.Invalid
	
	
	
end


function NanoBotBehaviorTree:RunSelector( bot, behavior, deltaTime )
	
	PROFILE("NanoBotBehaviorTree:RunSelector")
	
	
	
end


function NanoBotBehaviorTree:RunSequence( bot, behavior, deltaTime )
	
	PROFILE("NanoBotBehaviorTree:RunSequence")
	
	
	
end


function NanoBotBehaviorTree:RunAction( bot, behavior, deltaTime )
	
	PROFILE("NanoBotBehaviorTree:RunAction")
	
	assert( bot )
	assert( behavior )
	
	local status = kNanoBotStates.Failed
	
	if behavior.PreCondition then
		
	end
	
end



