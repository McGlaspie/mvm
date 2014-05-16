//=============================================================================
//  NanoBot - Marine vs Marine AI Player
//		Author: Brock 'McGlaspie' Gillespie
//
//
//
//=============================================================================

assert(Server)	//Server-side only

//Simple status value for each leaf/node in NB's decision trees
kBTreeNodeStatus = enum({ 'Invalid', 'Running', 'Success', 'Failed' })

kBTreeNodeType = enum({ 'Invalid', 'Action', 'Event', '' })




