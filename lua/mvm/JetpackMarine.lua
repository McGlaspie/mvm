

//Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/ElectroMagneticMixin.lua")


local newNetworkVars = {}


//TODO Move below into Balance file(s)?
JetpackMarine.kJetpackFuelReplenishDelay = .8	//.7
JetpackMarine.kJetpackGravity = -11		//-12
JetpackMarine.kVerticalThrustAccelerationMod = 2
JetpackMarine.kVerticalFlyAccelerationMod = 1.5	//1.45
JetpackMarine.kJetpackAcceleration = 17.5		//16

JetpackMarine.kJetpackArmorBonus = kJetpackArmor

JetpackMarine.kJetpackTakeOffTime = .25		//.39

JetpackMarine.kFlySpeed = 9	//8



AddMixinNetworkVars( ElectroMagneticMixin, newNetworkVars )


//-----------------------------------------------------------------------------


local orgJpMarineCreate = JetpackMarine.OnCreate
function JetpackMarine:OnCreate()

	orgJpMarineCreate( self )
	
	InitMixin( self, ElectroMagneticMixin )
	
end

local orgJpMarineInit = JetpackMarine.OnInitialized
function JetpackMarine:OnInitialized()

	orgJpMarineInit( self )	
	
end


function JetpackMarine:GetAirFrictionForce()
    return .5
end

function JetpackMarine:GetAcceleration()

    local acceleration = 0

    if self:GetIsJetpacking() then

        acceleration = JetpackMarine.kJetpackAcceleration
        acceleration = acceleration * self:GetInventorySpeedScalar()

    else
        acceleration = Marine.GetAcceleration(self)
    end
    
    return acceleration * self:GetSlowSpeedModifier()
    
end


function JetpackMarine:GetMaxBackwardSpeedScalar()
	
    if not self:GetIsOnGround() then
        return 1
    end

    return 0.85	//FIXME Move to BalanceMisc
    
end


function JetpackMarine:GetIsVulnerableToEMP()
	return true
end

function JetpackMarine:OnEmpDamaged()
	Print("JP Marine EMP Dmged")
end

function JetpackMarine:GetFuel()	//OVERRIDES

	local deltaTime = Shared.GetTime() - self.timeJetpackingChanged
    local rate = -kJetpackUseFuelRate
    
    if not self.jetpacking then
		
		rate = ConditionalValue(
			( self:GetIsUnderEmpEffect() or self:GetIsOnFire() ),
			0,
			kJetpackReplenishFuelRate
		)
        
        deltaTime = math.max( 0, deltaTime - JetpackMarine.kJetpackFuelReplenishDelay )
        
    end
    
    return Clamp( self.jetpackFuelOnChange + rate * deltaTime, 0, 1 )

end


//-----------------------------------------------------------------------------


Class_Reload( "JetpackMarine", newNetworkVars )
