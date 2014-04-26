

if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")
end


local kRagdollDuration = 5	//6
//move to global?


function CreateRagdoll(fromEntity)	//OVERRIDES

    local useModelName = fromEntity:GetModelName()
    local useGraphName = fromEntity:GetGraphName()
    local useTeamNumber = fromEntity.GetTeamNumber and fromEntity:GetTeamNumber() or 0
    
    if useModelName and string.len(useModelName) > 0 and useGraphName and string.len(useGraphName) > 0 then
		
        local ragdoll = CreateEntity( Ragdoll.kMapName, fromEntity:GetOrigin() )
        
        ragdoll:SetCoords(fromEntity:GetCoords())
        ragdoll:SetModel(useModelName, useGraphName)
        ragdoll.teamNumber = useTeamNumber
        
        if fromEntity.GetPlayInstantRagdoll and fromEntity:GetPlayInstantRagdoll() then
            ragdoll:SetPhysicsType(PhysicsType.Dynamic)
            ragdoll:SetPhysicsGroup(PhysicsGroup.RagdollGroup)
        else    
            ragdoll:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)    
        end
        
        ragdoll:CopyAnimationState(fromEntity)	//would this solve T-pose bug?
		
    end	//else?
    
end

//Sucks to have to add this...BUT, if it doesn't propagate, no shiny colors...
local newNetworkVars = {
	teamNumber = "integer (0 to 4)"
}


//-----------------------------------------------------------------------------

local orgRagdollCreate = Ragdoll.OnCreate
function Ragdoll:OnCreate()

	orgRagdollCreate(self)
	
	self.teamNumber = kTeamReadyRoom
	
	if Client then
		InitMixin( self, ColoredSkinsMixin )
	end

end


function Ragdoll:OnInitialized()	//ADDED

	if Client then
		self:InitializeSkin()
	end

end


if Client then
	
	function Ragdoll:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor()
		self.skinAccentColor = self:GetAccentSkinColor()
		self.skinTrimColor = self:GetTrimSkinColor()
		self.skinColoringEnabled = true
		self.skinAtlasIndex = Clamp( self.teamNumber - 1, 0, kTeam2Index )
	end
	
	function Ragdoll:GetBaseSkinColor()
		return ConditionalValue( self.teamNumber == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end
	
	function Ragdoll:GetAccentSkinColor()
		return ConditionalValue( self.teamNumber == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end

	function Ragdoll:GetTrimSkinColor()
		return ConditionalValue( self.teamNumber == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


function Ragdoll:OnUpdateRender()

    PROFILE("Ragdoll:OnUpdateRender")
    
    local remainingLifeTime = kRagdollDuration - ( Shared.GetTime() - self.creationTime )
    if remainingLifeTime <= 1 then
		
		self.skinAccentColor = self:GetAccentSkinColor()	//team colored dissolve hack
		
        local dissolveAmount = Clamp(1 - remainingLifeTime, 0, 1)
        self:SetOpacity( 1 - dissolveAmount, "dissolveAmount" )
        
    end
    
end


//-----------------------------------------------------------------------------


Class_Reload( "Ragdoll", newNetworkVars )


