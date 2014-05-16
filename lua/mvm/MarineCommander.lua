

Script.Load("lua/mvm/Commander.lua")


local newNetworkVars = {}


local gMarineMenuButtons =
{

    [kTechId.BuildMenu] = { kTechId.CommandStation, kTechId.Extractor, kTechId.InfantryPortal, kTechId.Armory,
                            kTechId.RoboticsFactory, kTechId.ArmsLab, kTechId.None, kTechId.None },
                            
    [kTechId.AdvancedMenu] = { kTechId.Sentry, kTechId.Observatory, kTechId.PhaseGate, kTechId.PrototypeLab, 
                               kTechId.SentryBattery, kTechId.None, kTechId.None, kTechId.None },

    [kTechId.AssistMenu] = { kTechId.AmmoPack, kTechId.MedPack, kTechId.NanoShield, kTechId.Scan,
                             kTechId.PowerSurge, kTechId.CatPack, kTechId.WeaponsMenu, kTechId.None, },
                             
    [kTechId.WeaponsMenu] = { kTechId.DropShotgun, kTechId.DropGrenadeLauncher, kTechId.DropFlamethrower, kTechId.DropWelder,
                              kTechId.DropDemoMines, kTechId.DropJetpack, kTechId.None, kTechId.AssistMenu}


}


//-----------------------------------------------------------------------------


function MarineCommander:GetButtonTable()
    return gMarineMenuButtons
end


// Top row always the same. Alien commander can override to replace. 
function MarineCommander:GetQuickMenuTechButtons(techId)

    // Top row always for quick access
    local marineTechButtons = { kTechId.BuildMenu, kTechId.AdvancedMenu, kTechId.AssistMenu, kTechId.RootMenu }
    local menuButtons = gMarineMenuButtons[techId]    
    
    if not menuButtons then
        menuButtons = {kTechId.None, kTechId.None, kTechId.None, kTechId.None, kTechId.None, kTechId.None, kTechId.None, kTechId.None }
    end

    table.copy(menuButtons, marineTechButtons, true)        

    // Return buttons and true/false if we are in a quick-access menu
    return marineTechButtons
    
end



if Client then
	
	function MarineCommander:GetShowPowerIndicator( locationPowerNode )		//OVERRIDES
	//Note: this may cause lag/glitches when server updated property is changed on PP
		
		if locationPowerNode then
		
			if self:GetTeamNumber() == kTeam1Index then
				return locationPowerNode.scoutedForTeam1
			elseif self:GetTeamNumber() == kTeam2Index then
				return locationPowerNode.scoutedForTeam2
			end
		
		end
		
		return false
		
	end

end


if Server then
	
	function MarineCommander:TriggerPowerSurge(position, entity, trace)		//OVERRIDES
			
		if trace and trace.entity and HasMixin(trace.entity, "PowerConsumer") then
			
			if HasMixin( trace.entity, "Team") and trace.entity:GetTeamNumber() == self:GetTeamNumber() then
				
				if HasMixin( trace.entity, "PowerConsumer") and trace.entity:GetIsPowered() then
					return false
				end
				
				trace.entity:SetPowerSurgeDuration( kPowerSurgeDuration )
				
				return true
				
			end
			
		end
    
		return false

	end
	
	
	local function GetDroppackSoundName(techId)
		
		if techId == kTechId.MedPack then
			return MedPack.kHealthSound
		elseif techId == kTechId.AmmoPack then
			return AmmoPack.kPickupSound
		elseif techId == kTechId.CatPack then
			return CatPack.kPickupSound
		end 
	   
	end
	
	local function GetIsEquipment(techId)
		
		return techId == kTechId.DropWelder or techId == kTechId.DropDemoMines or techId == kTechId.DropShotgun or techId == kTechId.DropGrenadeLauncher or
			techId == kTechId.DropFlamethrower or techId == kTechId.DropJetpack or techId == kTechId.DropExosuit
		
	end
	
	local function GetIsDroppack(techId)
		return techId == kTechId.MedPack or techId == kTechId.AmmoPack or techId == kTechId.CatPack
	end
	
	// check if a notification should be send for successful actions
	function MarineCommander:ProcessTechTreeActionForEntity(techNode, position, normal, pickVec, orientation, entity, trace, targetId)

		local techId = techNode:GetTechId()
		local success = false
		local keepProcessing = false
		
		if techId == kTechId.Scan then
		
			success = self:TriggerScan(position, trace)
			keepProcessing = false
			
		elseif techId == kTechId.NanoShield then
		
			success = self:TriggerNanoShield(position)
			keepProcessing = false
			
		elseif techId == kTechId.PowerSurge then
		
			success = self:TriggerPowerSurge(position, entity, trace)   
			keepProcessing = false 
		 
		elseif GetIsDroppack(techId) then
		
			// use the client side trace.entity here
			local clientTargetEnt = Shared.GetEntity(targetId)
			if clientTargetEnt and clientTargetEnt:isa("Marine") then
				position = clientTargetEnt:GetOrigin() + Vector(0, 0.05, 0)
			end
		
			success = self:TriggerDropPack(position, techId)
			keepProcessing = false
			
		elseif GetIsEquipment(techId) then
			
			//if techId == kTechId.DropMines then
				//orientation = 
			//end
			success = self:AttemptToBuild(techId, position, normal, orientation, pickVec, false, entity)
			
			if success then
				self:ProcessSuccessAction(techId)
				self:TriggerEffects("spawn_weapon", { effecthostcoords = Coords.GetTranslation(position) })
			end    
				
			keepProcessing = false

		else
			success, keepProcessing = Commander.ProcessTechTreeActionForEntity(self, techNode, position, normal, pickVec, orientation, entity, trace, targetId)
		end

		if success then

			local location = GetLocationForPoint(position)
			local locationName = location and location:GetName() or ""
			self:TriggerNotification(Shared.GetStringIndex(locationName), techId)
		
		end   
		
		return success, keepProcessing

	end
	

end


//-----------------------------------------------------------------------------


Class_Reload( "MarineCommander", newNetworkVars )
