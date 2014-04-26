
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/SelectableMixin.lua")
Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/WeldableMixin.lua")
Script.Load("lua/mvm/PickupableMixin.lua")
Script.Load("lua/mvm/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")

if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
	Script.Load("lua/mvm/CommanderGlowMixin.lua")
end



local newNetworkVars = {}

AddMixinNetworkVars( LOSMixin, newNetworkVars )
AddMixinNetworkVars( FireMixin, newNetworkVars )
AddMixinNetworkVars( DetectableMixin, newNetworkVars )
AddMixinNetworkVars( ElectroMagneticMixin, newNetworkVars )


//-----------------------------------------------------------------------------


function Exosuit:OnCreate ()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    
    InitMixin(self, PickupableMixin, { kRecipientType = "Marine" })
    
    InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, ElectroMagneticMixin)

    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)
    
    if Client then
		InitMixin(self, CommanderGlowMixin)
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, ColoredSkinsMixin)
    end
    
end


function Exosuit:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    if Server then
        
        self:SetModel(Exosuit.kModelName, kAnimationGraph)
        
        self:SetIgnoreHealth(true)
        self:SetMaxArmor(kExosuitArmor)
        self:SetArmor(kExosuitArmor)
    
    end
    
    if Client then
		self:InitializeSkin()
	end
    
    InitMixin(self, HiveVisionMixin)
    InitMixin(self, WeldableMixin)
    
end


function Exosuit:OverrideVisionRadius()
	return 0
end

function Exosuit:GetIsVulnerableToEMP()
	return true
end

//function Exosuit:GetIsFlameAble()
//	return false
//end


if Client then
	
	function Exosuit:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinAtlasIndex = self:GetTeamNumber() - 1
	end
	
	function Exosuit:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function Exosuit:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function Exosuit:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


function Exosuit:GetIsValidRecipient(recipient)
	
	if HasMixin(recipient, "Team") then	//prevent JP?
		return not recipient:isa("Exo") and self:GetTeamNumber() == recipient:GetTeamNumber()
	end
	
	return false
	
end


//function Exosuit:OnEntityChange( oldId, newId )
	//ScriptActor.OnEntityChange( oldId, newId )
//end


//-----------------------------------------------------------------------------


Class_Reload( "Exosuit", newNetworkVars )

