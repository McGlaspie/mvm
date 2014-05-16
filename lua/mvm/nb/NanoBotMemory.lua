//=============================================================================
//
//	NanoBot AI Memory
//		Author: Brock 'McGlaspie' Gillespie
//
//	Simple "Database" for each bot to remember the last events it performed
//	or took part in. Behaviors can access this data to further define their
//	results.
//
//	This is essentially just a hashmap of Strings as indicies and X-type as data.
//	Bot memories are not concerned with what data is contained in them.
//
//=============================================================================


assert(Server)


//Used "shared" memory instead? With Pub/Priv limitors based on bot id?


//-----------------------------------------------------------------------------


class 'NanoBotMemory'


function NanoBotMemory:Reset()
	self.memory = nil
	self:Initialize()
end


function NanoBotMemory:Initialize()
	self.memory = {}
end


function NanoBotMemory:GetMemory( memoryName )

	assert( type(memoryName) == "string" )	//enums?
	
	if self.memory[ memoryName ] then
		return self.memory[ memoryName ]
	end
	
	return nil

end


function NanoBotMemory:HasMemory( memoryName )

	assert( memoryName )
	assert( type(memoryName) == "string" )
	
	return self.memory[memoryName] ~= nil

end


function NanoBotMemory:CreateMemory( memoryName, data )
	
	assert( memoryName )
	assert( type(memoryName) == "string" )
	assert( data )
	
	//should overrides be allowed?
	self.memory[ memoryName ] = data
	
end



