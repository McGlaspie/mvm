
Script.Load("lua/PostLoadMod.lua")


if Server then
	
	function ResourceTower:CollectResources()	//MvM: changed effect to rines only
		self:TriggerEffects("extractor_collect")
		
		local attached = self:GetAttached()
		if attached and attached.CollectResources then
			attached:CollectResources()	// reduces the resource count of the node
			//????: Could change above to be a server config option, or voted on?
		end

	end

end

//-----------------------------------------------------------------------------

Class_Reload("ResourceTower", {})