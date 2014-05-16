//=============================================================================
//	NanoBot - Marine vs Marine AI Player
//		Author: Brock 'McGlaspie' Gillespie
//
//
//=============================================================================

Script.Load("lua/ExtentsMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/mvm/TechMixin.lua")
Script.Load("lua/mvm/OrdersMixin.lua")
Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")

if Server then
    Script.Load("lua/InvalidOriginMixin.lua")
end


if Client then
	Script.Load("lua/mvm/ColoredSkinsMixin.lua")	//Used here to support readyroom
end


local botNetworkVars = {
	
}


//-----------------------------------------------------------------------------


AddMixinNetworkVars( TechMixin, botNetworkVars )
AddMixinNetworkVars( BaseModelMixin, botNetworkVars )
AddMixinNetworkVars( ClientModelMixin, botNetworkVars )
AddMixinNetworkVars( LiveMixin, botNetworkVars )
AddMixinNetworkVars( TeamMixin, botNetworkVars )
AddMixinNetworkVars( OrdersMixin, botNetworkVars )
AddMixinNetworkVars( LOSMixin, botNetworkVars )
AddMixinNetworkVars( IdleMixin, botNetworkVars )


/*

*/
class 'NanoBotPlayer' (NanoBot)

	
	NanoBotPlayer.kMapName = "NanoBotPlayer"
	

	function NanoBotPlayer:OnCreate()
		
		PROFILE("NanoBotPlayer:OnCreate")
		
		NanoBot.OnCreate( self )
		
		InitMixin( self, ExtentsMixin )
		InitMixin( self, TechMixin )
		InitMixin( self, BaseModelMixin )
		InitMixin( self, ClientModelMixin )		
		InitMixin( self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance } )
		InitMixin( self, PathingMixin )
		InitMixin( self, EntityChange )
		InitMixin( self, LiveMixin )
		InitMixin( self, TeamMixin )
		
		if Server then
			
			self.playerName = ""
			
		end
		
		if Client then
			InitMixin( self, ColoredSkinsMixin )
		end
		
		self:SetLagCompensated(true)
		self:SetPhysicsType(PhysicsType.Kinematic)
		self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)

	end


	function NanoBotPlayer:OnInitialized()

		PROFILE("NanoBotPlayer:OnInitialized")

		if Server then
			
			--todo add lots of stuff
			
		end
		
		
		if Client then
			self:InitializeSkin()
		end

	end


	function NanoBotPlayer:OnUpdate( deltaTime )

		PROFILE("NanoBotPlayer:OnUpdate")

		NanoBot.OnUpdate( self, deltaTime )	//Must always run first
		
		//Anims, sounds, class specific, etc

	end

	
	function NanoBotPlayer:OnUpdateAnimationInput( modelMixin )

		PROFILE("NanoBotPlayer:OnUpdateAnimationInput")
		
		local moveState = "idle"
		if not self:GetIsIdle() then
			moveState = "run"
		end
		
		modelMixin:SetAnimationInput( "move", moveState )
		
		local activeWeapon = "none"
		local weapon = self:GetActiveWeapon()
		if weapon ~= nil then
		
			if weapon.OverrideWeaponName then
				activeWeapon = weapon:OverrideWeaponName()
			else
				activeWeapon = weapon:GetMapName()
			end
			
		end
		
		modelMixin:SetAnimationInput( "weapon", activeWeapon )
		
		local weapon = self:GetActiveWeapon()
		if weapon ~= nil and weapon.OnUpdateAnimationInput then
			weapon:OnUpdateAnimationInput( modelMixin )
		end
		
	end

	
	function NanoBotPlayer:OnTag()	//needed?
	end
	
	
	function NanoBotPlayer:OnTakeDamage( damage, attacker, doer, point )
		
		if Server then
			
			self.botState = kNanoBotStates.Combat
			
		end
	
	end
		
	

Shared.LinkClassToMap( "NanoBotPlayer", NanoBotPlayer.kMapName, botNetworkVars, true )


//End NanoBotPlayer -----------------------------------------------------------




