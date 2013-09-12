

Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/PostLoadMod.lua")


local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local oldPGcreate = PhaseGate.OnCreate
function PhaseGate:OnCreate()

	oldPGcreate(self)
	
	InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    
    if Client then
		InitMixin(self, ColoredSkinsMixin)
	end

end


if Client then

	function PhaseGate:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function PhaseGate:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function PhaseGate:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


function PhaseGate:OnUpdateRender()

    PROFILE("PhaseGate:OnUpdateRender")

    if self.clientLinked ~= self.linked then
        self.clientLinked = self.linked
        
        local effects = ConditionalValue( self.linked and self:GetIsVisible(), "phase_gate_linked", "phase_gate_unlinked")
        if self:GetTeamNumber() == kTeam2Index then
			effects = ConditionalValue( self.linked and self:GetIsVisible(), "phase_gate_linked_team2", "phase_gate_unlinked_team2")
        end
        
        //FIXME Gate effect visible to enemy commanders without LOS on gate entity...
        //if HasMixin(self, "LOS") and HasMixin(self:GetLastViewer(), "Team")
        self:TriggerEffects(effects)
        
    end

end

//-----------------------------------------------------------------------------

Class_Reload("PhaseGate", newNetworkVars)

