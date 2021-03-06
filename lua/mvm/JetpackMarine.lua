
Script.Load("lua/mvm/Marine.lua")


local newNetworkVars = {
	jetpackFuel = "float (0 to 1 by 0.01)"
}


//TODO Move below into Balance file(s)?

JetpackMarine.kJetpackFuelReplenishDelay = .8		//.7
/*
//FIXME Below values are NOT used
JetpackMarine.kVerticalThrustAccelerationMod = 2
JetpackMarine.kVerticalFlyAccelerationMod = 1.5		//1.45
JetpackMarine.kJetpackAcceleration = 17.5			//16

JetpackMarine.kJetpackGravity = -11					//-16
JetpackMarine.kJetpackTakeOffTime = .39

JetpackMarine.kJetpackArmorBonus = kJetpackArmor

JetpackMarine.kJetpackTakeOffTime = .25				//.39

JetpackMarine.kFlySpeed = 9
*/
JetpackMarine.kJetpackFuelReplenishDelay = .4
JetpackMarine.kJetpackGravity = -15
JetpackMarine.kJetpackTakeOffTime = .39

local kFlySpeed = 9
local kFlyFriction = 0.0
local kFlyAcceleration = 28


//-----------------------------------------------------------------------------


local orgJpMarineCreate = JetpackMarine.OnCreate
function JetpackMarine:OnCreate()

	Marine.OnCreate(self)
    
    self.jetpackMode = JetpackMarine.kJetpackMode.Disabled
    
    self.jetpackLoopId = Entity.invalidId
	
	if Server then
		self.jetpackFuel = 1	//Full tank
	end
	
end

local orgJpMarineInit = JetpackMarine.OnInitialized
function JetpackMarine:OnInitialized()

	orgJpMarineInit( self )
	
end


//???? Add modifyvelocity func?


function JetpackMarine:GetMaxBackwardSpeedScalar()
	
    if not self:GetIsOnGround() then
        return 1
    end
	
    return Marine.kWalkBackwardSpeedScalar
    
end


function JetpackMarine:GetIsVulnerableToEMP()	//OVERRIDES Marine
	return true
end


function JetpackMarine:OnEmpDamaged()
	//TODO trigger JP sputter/choke sound
end



function JetpackMarine:ModifyVelocity(input, velocity, deltaTime)

    if self:GetIsJetpacking() then
        
        local verticalAccel = 22
        
        if self:GetIsWebbed() then
            verticalAccel = 5
        elseif input.move:GetLength() == 0 then
            verticalAccel = 26
        end
    
        self.onGround = false
        local thrust = math.max(0, -velocity.y) / 6
        velocity.y = math.min(5, velocity.y + verticalAccel * deltaTime * (1 + thrust * 2.5))
 
    end
    
    if not self.onGround then
		
        // do XZ acceleration
        local prevXZSpeed = velocity:GetLengthXZ() //+ 0.05	//slight boost to horizontal movements
        local maxSpeedTable = { maxSpeed = math.max(kFlySpeed, prevXZSpeed) }
        self:ModifyMaxSpeed(maxSpeedTable)
        local maxSpeed = maxSpeedTable.maxSpeed        
        
        if not self:GetIsJetpacking() then
            maxSpeed = prevXZSpeed
        end
        
        local wishDir = self:GetViewCoords():TransformVector(input.move)
        local acceleration = 0
        wishDir.y = 0
        wishDir:Normalize()
        
        acceleration = kFlyAcceleration
        
        velocity:Add(wishDir * acceleration * self:GetInventorySpeedScalar() * deltaTime)

        if velocity:GetLengthXZ() > maxSpeed then
        
            local yVel = velocity.y
            velocity.y = 0
            velocity:Normalize()
            velocity:Scale(maxSpeed)
            velocity.y = yVel
            
        end 
        
        if self:GetIsJetpacking() then
            velocity:Add(wishDir * 0.7 * deltaTime)
        end
    
    end

end


function JetpackMarine:GetFuel()	//OVERRIDES
	
	//Moving out of pure server allows update to happen
	//but unsure if this will allow for consistent behavior
	
	local fuelRechargePrevent = ( self:GetIsUnderEmpEffect() or self:GetIsOnFire() )
	local deltaTime = Shared.GetTime() - self.timeJetpackingChanged
	local rate = -kJetpackUseFuelRate
	local fuel = self.jetpackFuel
	
	if not self.jetpacking then
		
		rate = kJetpackReplenishFuelRate
		deltaTime = math.max( 0, deltaTime - JetpackMarine.kJetpackFuelReplenishDelay )
		
	end
	
	if fuelRechargePrevent and rate == kJetpackReplenishFuelRate then
		self.jetpackFuel = Clamp( self.jetpackFuelOnChange, 0, 1 )
	else
		self.jetpackFuel = Clamp( self.jetpackFuelOnChange + (rate * deltaTime), 0, 1 )
	end
	
	
	/* Org
	local dt = Shared.GetTime() - self.timeJetpackingChanged
    local rate = -kJetpackUseFuelRate
    
    if not self.jetpacking then
        rate = kJetpackReplenishFuelRate
        dt = math.max(0, dt - JetpackMarine.kJetpackFuelReplenishDelay)
    end
    return Clamp(self.jetpackFuelOnChange + rate * dt, 0, 1)
	
	*/
	
	return self.jetpackFuel

end


//-----------------------------------------------------------------------------


Class_Reload( "JetpackMarine", newNetworkVars )
