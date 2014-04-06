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

ElectroMagneticMixin.networkVars = {
    isPulsed = "boolean"
}

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


Shared.PrecacheSurfaceShader("cinematics/vfx_materials/pulse_gre_elec.surface_shader")

local k1P_EMDamamgeEffect = PrecacheAsset("cinematics/marine/1P_em_damagedstatic.cinematic")


//-------------------------------------


function ElectroMagneticMixin:__initmixin()
	
	self.isPulsed = false
	
	if Client then
		
		self.electrifiedMaterial = nil
		self.timeOfLastEmpEffect = 0
		
	elseif Server then
	
		self.timeEmpStarted = 0
	
	end

end


function ElectroMagneticMixin:OnTakeDamage( damage, attacker, doer, point, direction )
    
	if doer and doer.GetDamageType and doer:GetDamageType() == kDamageType.ElectroMagnetic then
		self:SetPulsed( attacker, doer )
	end
    
end


function ElectroMagneticMixin:SetPulsed( attacker, doer )
	
	if Server and not self:GetIsDestroyed() then
		
		self.timeEmpStarted = Shared.GetTime()
		
		self:TriggerEffects("emp_blasted")
		
		if self.OnEmpDamaged then
			self:OnEmpDamaged()
		end
	
		self.isPulsed = true
	
	end

end


function ElectroMagneticMixin:GetIsUnderEmpEffect()
	return self.isPulsed
end




local function CreateElectrifiedMaterial( self )

	if self.electrifiedMaterial == nil then
		self.electrifiedMaterial = Client.CreateRenderMaterial()
		self.electrifiedMaterial:SetMaterial( "cinematics/vfx_materials/pulse_gre_elec.material" )
	end

end


local function CreateElectrifiedEffect( self )

	local model = self:GetRenderModel()
	
	if model then
		
		CreateElectrifiedMaterial( self )
		model:AddMaterial( self.electrifiedMaterial )
		
	end
	
	if self == Client.GetLocalPlayer() then
		
		local viewEnt = self:GetViewModelEntity()
		
		if viewEnt then
			
			local viewModel = viewEnt:GetRenderModel()
			
			if viewModel then
				CreateElectrifiedMaterial( self )
				viewModel:AddMaterial(  self.electrifiedMaterial  )
			end
			
			//Add 1p cinematic fuzzy screen, garbled UI, etc
		
		end
	
	end

end


local function RemoveElectrifiedEffect( self )

	if self.electrifiedMaterial ~= nil then
		
		local model = self:GetRenderModel()
		if model then
			model:RemoveMaterial( self.electrifiedMaterial )
		end
		
		if self == Client.GetLocalPlayer() then
		
			local viewEnt = self:GetViewModelEntity()
			if viewEnt then
				local viewModel = viewEnt:GetRenderModel()
				if viewModel then
					viewModel:RemoveMaterial( self.electrifiedMaterial )
				end
			end
		
		end
		
	end

end


local function DestroyElectrifiedMaterial( self )
	
	if self.electrifiedMaterial then	//check, because in some cases material never created
		Client.DestroyRenderMaterial( self.electrifiedMaterial )
		self.electrifiedMaterial = nil
	end

end


function ElectroMagneticMixin:OnDestroy()
	if Client then
		DestroyElectrifiedMaterial( self )
	end
end




local function SharedUpdate( self )

	local time = Shared.GetTime()
	
	if Client then
		
		if self.isPulsed and self.timeOfLastEmpEffect == 0 then
			
			self.timeOfLastEmpEffect = time
			CreateElectrifiedEffect( self )
			
		elseif not self.isPulsed and self.timeOfLastEmpEffect ~= 0 then
			
			RemoveElectrifiedEffect( self )
			self.timeOfLastEmpEffect = 0
			
		end
		
	end
	
	if Server then
	    
	    if time > self.timeEmpStarted + kEmpDamageEffectsDuration then
            self.timeEmpStarted = 0
            self.isPulsed = false
		end
		
	end

end

function ElectroMagneticMixin:OnUpdate()
	SharedUpdate( self )
end

function ElectroMagneticMixin:OnProcessMove()
	SharedUpdate( self )
end


