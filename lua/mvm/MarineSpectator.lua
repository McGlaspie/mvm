

Script.Load("lua/PostLoadMod.lua")

//-----------------------------------------------------------------------------

function MarineSpectator:OnCreate()

    TeamSpectator.OnCreate(self)
    self:SetTeamNumber(1)	//??? Uhhh, shit..
    
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    
    if Client then
        InitMixin(self, TeamMessageMixin, { kGUIScriptName = "mvm/Hud/Marine/GUIMarineTeamMessage" })
    end
    
end

//-----------------------------------------------------------------------------

Class_Reload("MarineSpectator", {})