//
//
// Electro-Magnetic Damage Mixin
// Author: Brock 'McGlaspie' Gillespie - mcglaspie@gmail.com
//
//	FIXME This should handled via GameEffects for Server
//
//-----------------------------------------------------------------------------


ElectroMagneticMixin = CreateMixin( ElectroMagneticMixin )
ElectroMagneticMixin.type = "EMP"

ElectroMagneticMixin.networkVars = {}

/*
ElectroMagneticMixin.expectedMixins = {
	GameEffectsMixin = ""
}
*/
ElectroMagneticMixin.expectedCallbacks = {
	GetIsVulnerableToEMP = "Boolean. Unit receives extra damage if true and ElectroMagnetic damage type dealt"
}

ElectroMagneticMixin.optionalCallbacks = {
	OnEmpDamaged = "Event trigger for entity to handle when it is hit by EMP damage"
}


local kEmpEffectSmall = PrecacheAsset("cinematics/marine/electrified_sml.cinematic")

local kEmpEffectCinematicTable = {}
kEmpEffectCinematicTable["MAC"] = kEmpEffectSmall
kEmpEffectCinematicTable["ARC"] = kEmpEffectSmall
kEmpEffectCinematicTable["Sentry"] = kEmpEffectSmall
kEmpEffectCinematicTable["SentryBattery"] = kEmpEffectSmall


local function GetElectrifiedCinematic(ent, firstPerson)
	
	//Should be able to re-work parasite effect for this
    //if firstPerson then	//TODO Add this
    //    return kEmp1PCinematic
    //end
    
    return kEmpEffectCinematicTable[ent:GetClassName()] or kEmpEffectSmall
    
end


//-------------------------------------


function ElectroMagneticMixin:__initmixin()
	
	self.timeEmpStarted = 0
	self.timeOfLastEmpEffect = 0

end


function ElectroMagneticMixin:OnDestroy()
	//TODO stop effects
end


function ElectroMagneticMixin:OnTakeDamage(damage, attacker, doer, point, direction)
    
	if doer and doer.GetDamageType and doer:GetDamageType() == kDamageType.ElectroMagnetic then
		
		self:SetGameEffectMask( kGameEffect.IsPulsed, true )
		self.timeEmpStarted = Shared.GetTime()
		
		self:TriggerEffects("emp_blasted")	//TODO Update and change acordingly to size, class, and team
		
		if self.OnEmpDamaged then
			self:OnEmpDamaged()
		end
		
	end
    
end


function ElectroMagneticMixin:GetIsUnderEmpEffect()
	return self:GetGameEffectMask( kGameEffect.IsPulsed )
end

//TODO Add same effect (except more pronounced) Onos Stun from stomp



function ElectroMagneticMixin:OnUpdate( deltaTime )
	
	local isPulsed = self:GetGameEffectMask( kGameEffect.IsPulsed )
	
	if Shared.GetTime() > self.timeEmpStarted + kEmpDamageEffectsDuration and isPulsed then
		
		self.timeEmpStarted = 0
		self.timeOfLastEmpEffect = 0
		self:SetGameEffectMask( kGameEffect.IsPulsed, false )
		
	elseif isPulsed then
		
		if Client and self:GetIsVisible() then
			//self:_UpdateElectrifiedEffects()	//insufficient atm
		end
		
	end

end


if Client then
    
    function ElectroMagneticMixin:_UpdateElectrifiedEffects()
    
		local time = Shared.GetTime()
		
		if not self.timeOfLastEmpEffect or (time > (self.timeOfLastEmpEffect + .25)) then
            
			//local firstPerson = (Client.GetLocalPlayer() == self)
			local cinematicName = GetElectrifiedCinematic(self, false)
			
			/*
			if firstPerson then
				local viewModel = self:GetViewModelEntity()
				if viewModel then
					Shared.CreateAttachedEffect(self, cinematicName, viewModel, Coords.GetTranslation(Vector(0, 0, 0)), "", true, false)
				end
			else
				Shared.CreateEffect(self, cinematicName, self, self:GetAngles():GetCoords())
			end
			*/
			Shared.CreateEffect(self, cinematicName, self, self:GetAngles():GetCoords() )	//does this return a ref?
			
			self.timeOfLastEmpEffect = time
			
		end
    
    end
    
end