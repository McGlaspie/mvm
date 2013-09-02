

Script.Load("lua/LOSMixin.lua")


if Server then

	function LOSMixin:UpdateLOS()
    
        local mask = bit.bor(kRelevantToTeam1Unit, kRelevantToTeam2Unit, kRelevantToReadyRoom)
        local teamNum = self:GetTeamNumber()
        
        if self.sighted then
            mask = bit.bor(mask, kRelevantToTeam1Commander, kRelevantToTeam2Commander)
		elseif self:isa("PowerPoint") then	//HAX!! Bleh...
		//FIXME This will have to use override or other mechanism for team captured nodes
			mask = bit.bor(mask, kRelevantToTeam1Commander, kRelevantToTeam2Commander)
		elseif teamNum == kTeam1Index or teamNum == kTeam2Index then
			
			if teamNum == kTeam1Index then
				mask = bit.bor(mask, kRelevantToTeam1Commander)
			elseif teamNum == kTeam2Index then
				mask = bit.bor(mask, kRelevantToTeam2Commander)
			end
		end
        
        self:SetExcludeRelevancyMask(mask)
        self.visibleClient = self.sighted
        
        if self.lastSightedState ~= self.sighted then
        
            if self.OnSighted then
                self:OnSighted(self.sighted)
            end
            
            self.lastSightedState = self.sighted
            
        end
        
    end

end	//Server

