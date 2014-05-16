//=============================================================================
//	NanoBot - AI Behavior Tree
//		Author: Brock 'McGlaspie' Gillespie
//
//	--todo describe functionality and usage
//
//=============================================================================


assert(Server)	//Server-side only


//Simple status value for each leaf/node in NB's decision trees
kBehaviorTreeNodeStatus = enum({ 'Invalid', 'Running', 'Success', 'Failed' })

kBehaviorTreeNodeType = enum({ 
	'Invalid', 		//Denotes a node has not initialized
	'Action', 		//Denotes some activity will be performed
	'Selector', 		//Signifies input or trigger to added to self
	'Sequence',		//A series of behavior nodes (Left to Right)
	'Condition'		//Logical action that branches tree
})


//-----------------------------------------------------------------------------



/*
--todo describe purpose and usage
*/
class 'BehaviorTree'



