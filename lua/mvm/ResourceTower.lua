

Script.Load("lua/PostLoadMod.lua")


//-----------------------------------------------------------------------------


if Server then

	function ResourceTower:CollectResources()

		for _, player in ipairs(GetEntitiesForTeam("Player", self:GetTeamNumber())) do
			if not player:isa("Commander") then
				player:AddResources( kPlayerResPerInterval )
			end
		end
		
		local team = self:GetTeam()
		if team then
			
			team:AddTeamResources( kTeamResourcePerTick, true )
			
		end
		
		self:TriggerEffects("extractor_collect")
		
		local attached = self:GetAttached()
		
		if attached and attached.CollectResources then
			
			// reduces the resource count of the node
			attached:CollectResources()
		
		end

	end
	
end


//-----------------------------------------------------------------------------


Class_Reload("ResourceTower", {})

