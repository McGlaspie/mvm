
if Client then
    Script.Load("lua/mvm/TeamMessageMixin.lua")
end


function MarineSpectator:OnCreate()		//OVERRIDES
	
    TeamSpectator.OnCreate(self)
    //self:SetTeamNumber()	//???
    //Not doing above allow for switching to enemy team?
    
    if Client then
        InitMixin(self, TeamMessageMixin, { kGUIScriptName = "mvm/Hud/Marine/GUIMarineTeamMessage" })
    end
    
end


function MarineSpectator:OnInitialized()
	TeamSpectator.OnInitialized(self)
	//self:SetTeamNumber()	//FIXME Need team lookup, etc
end


//-----------------------------------------------------------------------------


Class_Reload( "MarineSpectator", {} )

