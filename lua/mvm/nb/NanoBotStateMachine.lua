//=============================================================================
//
//	NanoBot - Marine vs Marine AI Player
//		Author: Brock 'McGlaspie' Gillespie
//
//
//=============================================================================

assert(Server)

Script.Load("lua/Globals.lua")
Script.Load("lua/Utility.lua")


kNanoBotState = enum({ 
	'Idle', 'Combat', 'Traveling', 'Retreating', 'Waiting' 'Building', 'Repairing', 'Evading' 
})


//-----------------------------------------------------------------------------


class 'State'


function State:OnCreate()
	self.
end

function State:enter( bot )

end


function State:execute( bot )

end


function State:exit( bot )

end




//=============================================================================


class 'NanoBotStateMachine'




