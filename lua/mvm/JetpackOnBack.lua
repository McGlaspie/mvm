

Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/PostLoadMod.lua")

//-----------------------------------------------------------------------------

//Hmm, something doesn't seem right with this...

function JetpackOnBack:OnCreate()

	ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    
    self:SetUpdates(true)
    
    self.flying = false
    self.thrustersOpen = false
    self.timeFlyingEnd = 0
    
    self:SetModel(kModelName, kAnimationGraph)

end

//-----------------------------------------------------------------------------

Class_Reload("JetpackOnBack", {})
