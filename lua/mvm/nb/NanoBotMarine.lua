//=============================================================================
//
//	NanoBot - Marine vs Marine AI Player
//		Author: Brock 'McGlaspie' Gillespie
//
//
//=============================================================================

Script.Load("lua/MarineVariantMixin.lua")


local marineBotNetworkVars = {
	
}


//-----------------------------------------------------------------------------

--todo add mixin netvars needed


class 'NanoBotMarine' (NanoBotPlayer)
	
	
	NanoBotPlayer.kMapName = "NanoBotMarine"
	
	
	function NanoBotMarine:OnCreate()
		
		PROFILE("NanoBotMarine:OnCreate")
		
		NanoBotPlayer.OnCreate( self )
		
		InitMixin( self, LOSMixin )
		InitMixin( self, DamageMixin )
		InitMixin( self, CombatMixin )
		InitMixin( self, SoftTargetMixin )
		InitMixin( self, WebableMixin )
		InitMixin( self, ResearchMixin )
		InitMixin( self, RecycleMixin )
		InitMixin( self, DissolveMixin )
		InitMixin( self, FireMixin )
		InitMixin( self, DetectableMixin )
		InitMixin( self, ElectroMagneticMixin )
		InitMixin( self, MarineVariant )
		
		if Client then
			InitMixin( self, CommanderGlowMixin )
			InitMixin( self, ColoredSkinsMixin )
		end
		
	end


	function NanoBotMarine:OnInitialized()

		PROFILE("NanoBotMarine:OnInitialized")

	end
