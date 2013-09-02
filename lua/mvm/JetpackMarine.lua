

Script.Load("lua/PostLoadMod.lua")


//TODO Move below into Balance file(s)?
JetpackMarine.kJetpackFuelReplenishDelay = .75	//.7
JetpackMarine.kJetpackGravity = -11		//-12
JetpackMarine.kVerticalThrustAccelerationMod = 2
JetpackMarine.kVerticalFlyAccelerationMod = 1.5	//1.45
JetpackMarine.kJetpackAcceleration = 17.5		//16

JetpackMarine.kJetpackArmorBonus = kJetpackArmor

JetpackMarine.kJetpackTakeOffTime = .25		//.39

JetpackMarine.kFlySpeed = 9	//8


//-----------------------------------------------------------------------------

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



//-----------------------------------------------------------------------------

Class_Reload("JetpackMarine", {})
