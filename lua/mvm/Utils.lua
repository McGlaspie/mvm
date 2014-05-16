//
// Various Lua utilities
//
//



function ReplaceGlobalFunc( originalFunction, replaceFunc )
	
	local numReplaced = nil
    local index = 1
	local foundIndex = nil
	
	while true do
		
		local n, v = debug.getupvalue( originalFunction, index )
		if not n then
			break
		end
		
		-- Find the highest index matching the name.
		if n == name then
			foundIndex = index
		end
		
		index = index + 1
		
	end
	
	if foundIndex then
	
		debug.setupvalue(originalFunction, foundIndex, value)
		numReplaced = numReplaced + 1
		
	end
	
	return numReplaced
    
end