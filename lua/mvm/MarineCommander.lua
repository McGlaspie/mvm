

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
                              kTechId.DropMines, kTechId.DropJetpack, kTechId.None, kTechId.AssistMenu}


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
	
	//FIXME Prevent ALL surge, regardless of team
	function MarineCommander:TriggerPowerSurge(position, entity, trace)		//OVERRIDES
			
		if trace and trace.entity and HasMixin(trace.entity, "PowerConsumer") then
			
			if HasMixin( trace.entity, "Team") and trace.entity:GetTeamNumber() == self:GetTeamNumber() then
			
				trace.entity:SetPowerSurgeDuration(kPowerSurgeDuration)
				return true
				
			end
			
		end
    
    return false

end

end


//-----------------------------------------------------------------------------


Class_Reload( "MarineCommander", newNetworkVars )
