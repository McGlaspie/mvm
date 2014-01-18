//
//
// Electro-Magnetic Damage Mixin
// Author: Brock 'McGlaspie' Gillespie - mcglaspie@gmail.com
//
//
//-----------------------------------------------------------------------------


ElectroMagneticMixin = CreateMixin( ElectroMagneticMixin )
ElectroMagneticMixin.type = "EMP"

ElectroMagneticMixin.networkVars =
{
    isEmpAffected = "boolean"
}

ElectroMagneticMixin.expectedCallbacks = {
	GetIsVulnerableToEMP = "Boolean. Unit receives extra damage if true and ElectroMagnetic damage type dealt"
}

ElectroMagneticMixin.optionalCallbacks = {
	OnEmpDamaged = "Event trigger for entity to handle when it is hit by EMP damage"
}


local kEmpEffectsDuration = 2	//static? Move to Balance or DamageType?

local kEmpEffectSmall = PrecacheAsset("cinematics/marine/electrified_sml.cinematic")

local kEmpEffectCinematicTable = {}
kEmpEffectCinematicTable["MAC"] = kEmpEffectSmall
kEmpEffectCinematicTable["ARC"] = kEmpEffectSmall
kEmpEffectCinematicTable["Sentry"] = kEmpEffectSmall
kEmpEffectCinematicTable["SentryBattery"] = kEmpEffectSmall


local function GetElectrifiedCinematic(ent, firstPerson)
	
    //if firstPerson then	//TODO Add this
    //    return kEmp1PCinematic
    //end
    
    return kEmpEffectCinematicTable[ent:GetClassName()] or kEmpEffectSmall
    
end


//-------------------------------------


function ElectroMagneticMixin:__initmixin()
	
	self.isEmpAffected = false
	self.timeEmpStarted = 0
	self.timeOfLastEmpEffect = 0

end


function ElectroMagneticMixin:OnDestroy()
	//TODO stop effects
end


function ElectroMagneticMixin:OnTakeDamage(damage, attacker, doer, point, direction)
    
	if doer and doer.GetDamageType and doer:GetDamageType() == kDamageType.ElectroMagnetic then
		
		self.isEmpAffected = true
		self.timeEmpStarted = Shared.GetTime()
		
		if self.OnEmpDamaged then
			self:OnEmpDamaged()
		end
		
	end
    
end


function ElectroMagneticMixin:GetIsUnderEmpEffect()
	return self.isEmpAffected	
end

//TODO Add same effect (except more pronounced) Onos Stun from stomp



function ElectroMagneticMixin:OnUpdate( deltaTime )
	
	if Shared.GetTime() > self.timeEmpStarted + kEmpEffectsDuration and self.isEmpAffected then
		
		self.isEmpAffected = false
		self.timeEmpStarted = 0
		self.timeOfLastEmpEffect = 0
		
	elseif self.isEmpAffected then
		
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