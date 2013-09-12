

Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/PostLoadMod.lua")


local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local oldProtoLabCreate = PrototypeLab.OnCreate
function PrototypeLab:OnCreate()
	oldProtoLabCreate()
	
	InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    
    if Client then
		InitMixin(self, ColoredSkinsMixin)
	end
    
end


if Client then

	function PrototypeLab:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function PrototypeLab:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function PrototypeLab:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


function PrototypeLab:GetTechButtons(techId)

    return { 
		kTechId.JetpackTech, 
		kTechId.ExosuitTech, 
		kTechId.DualMinigunTech, 
		kTechId.ClawRailgunTech 	//TODO Duel-Rail
	}
    
end

function PrototypeLab:GetItemList()
	//TODO Duel-Rail
    return { kTechId.Jetpack, kTechId.Exosuit, kTechId.DualMinigunExosuit, kTechId.ClawRailgunExosuit }
end

//-----------------------------------------------------------------------------

Class_Reload("PrototypeLab", newNetworkVars)
