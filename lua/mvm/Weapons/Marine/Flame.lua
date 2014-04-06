

Script.Load("lua/mvm/ScriptActor.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/DamageMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")


local newNetworkVars = {}

AddMixinNetworkVars(LOSMixin, newNetworkVars )


function Flame:OnCreate()	//OVERRIDES

    ScriptActor.OnCreate(self)
    
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)	//May cause serious lag hit...
    
end


//function Flame:OverrideCheckVision()
//	return false
//end

function Flame:OverrideVisionRadius()
	return 0
end




Class_Reload( "Flame", {} )

