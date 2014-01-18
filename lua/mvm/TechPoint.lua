


if Server then


	
	function TechPoint:SpawnCommandStructure( teamNumber )	//OVERRIDES		
		return CreateEntityForTeam( kTechId.CommandStation, Vector(self:GetOrigin()), teamNumber)
	end



	Class_Reload("TechPoint", {})

end