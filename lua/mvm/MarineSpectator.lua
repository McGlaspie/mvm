

Script.Load("lua/PostLoadMod.lua")

//-----------------------------------------------------------------------------

function MarineSpectator:OnCreate()
	
    TeamSpectator.OnCreate(self)
    //self:SetTeamNumber()	//???
    //Not doing above allow for switching to enemy team?
    
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    
    if Client then
        InitMixin(self, TeamMessageMixin, { kGUIScriptName = "mvm/Hud/Marine/GUIMarineTeamMessage" })
    end
    
end


function MarineSpectator:OnInitialized()
	TeamSpectator.OnInitialized(self)
	//self:SetTeamNumber()
end

//-----------------------------------------------------------------------------

Class_Reload("MarineSpectator", {})