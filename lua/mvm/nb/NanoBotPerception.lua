//=============================================================================
//
//	NanoBot - Marine vs Marine AI Player
//		Author: Brock 'McGlaspie' Gillespie
//
//	This file/class is one of the primary components that helps give NBs a more
//  Human-like feel. It governs how a NBs "brain" gets information.
//
//=============================================================================


assert(Server)	//Only?


//Different levels of awareness a NB can have. Primary weight factor in
//providing "skill level"
kNanoBotAwarenessLevel = enum({
	'Idiot', 'SemiAware', 'Aware', 'Sharp', 'Hacker'
})


kNanoBotPerceptionMinRange = 20
kNanoBotPerceptionMinRange = 50


class 'NanoBotPerception'




