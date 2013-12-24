// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\SupplyUserMixin.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//		Modified by: Brock Gillespie (mcglaspie@gmail.com) - added support for override handler
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/SupplyUserMixin.lua")


function SupplyUserMixin:__initmixin()
    
    assert(Server)    
    
    local team = self:GetTeam()
    if team and team.AddSupplyUsed then
		
		if self.OverrideAddSupply then
			self:OverrideAddSupply(team)
		else
			team:AddSupplyUsed( LookupTechData(self:GetTechId(), kTechDataSupply, 0) )
		end
		
		self.supplyAdded = true
		
    end
    
end


local function RemoveSupply(self)
	
    if self.supplyAdded then
        
        local team = self:GetTeam()
        if team and team.RemoveSupplyUsed then
            
            if self.OverrideRemoveSupply then
				self:OverrideRemoveSupply(team)
			else
				team:RemoveSupplyUsed( LookupTechData(self:GetTechId(), kTechDataSupply, 0) )
            end
            
            self.supplyAdded = false
            
        end
        
    end
    
end


function SupplyUserMixin:OnKill()
    RemoveSupply(self)
end

function SupplyUserMixin:OnDestroy()
    RemoveSupply(self)
end
