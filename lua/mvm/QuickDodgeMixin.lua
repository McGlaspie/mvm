//
//	Quick-Dodge Mixin
//		Author Brock 'McGlaspie' Gillespie - mcglaspie@gmail.com
//
//	Similar to Fade Shadow step in function, but instead of manipulating
//	the player's model visibility and effects, it controls some animations
//	and movement. This does not impact collision detection.
//
//=============================================================================


QuickDodgeMixin = CreateMixin( QuickDodgeMixin )
QuickDodgeMixin.type = "Dodge"

QuickDodgeMixin.expectedCallbacks = {
    GetVelocity = "Required for movement posotion and speed modifiers",
    GetActiveWeapon = "Required for ViewModel animation",
    GetViewCoords = "Require for camera animation and view modifiers",
    GetIsOnGround = "Required for movement calculation",
    GetIsFlying = "Required for cases when player has a Jetpack or similar ability",
    GetCrouching = "Require to correctly handle crouch moves"
}

QuickDodgeMixin.networkVars = {
	dodging = "private boolean",
	timeLastQuickDodge = "private time",
	timeLastQuickDodgeEnded = "private time",
}


//-----------------------------------------------------------------------------


function QuickDodgeMixin:__initmixin()

	self.dodging = false
	
	self.timeLastQuickDodge = 0
	self.timeLastQuickDodgeEnded = 0
	
end


function QuickDodgeMixin:GetIsDodging()
    return self.dodging
end


function QuickDodgeMixin:GetCanJump()
    return self:GetIsOnGround() and not self:GetIsDodging()
end


function QuickDodgeMixin:GetCanStep()
	return not self.dodging
end


function QuickDodgeMixin:GetMaxSpeed( possible )
	
    if possible then
        return kMaxSpeed
    end
    
    if self:GetIsDodging() then
        return QuickDodgeMixin.kQuickDodgeMaxSpeed
    end
    
    // Take into account crouching.
    return kMaxSpeed
    
end


//Used to prevent weapon jitter on jump-land + dodge
local kQuickDodgeJumpLandDelay = 0.125

function QuickDodgeMixin:GetCanDodge()
	
	return (	//fixm gotta be a better way...
		not self.dodging and not self:GetIsSprinting() and not self:GetCrouching() 
		and not self:GetIsJumping() and not self:GetIsFlying() and self.timeLastQuickDodge == 0
		and self.timeGroundTouched + kQuickDodgeJumpLandDelay < Shared.GetTime()
	)
	
end


local kQuickDodgeTime = 0.175
local kQuickDodgeAllowedInterval = 0.55

function QuickDodgeMixin:OnUpdate( deltaTime )
	
	local now = Shared.GetTime()
	
	if self.dodging then
		
		if now > kQuickDodgeTime + self.timeLastQuickDodge then
			self.timeLastQuickDodgeEnded = now
			self.onGround = true
			self.dodging = false
		end
		
	end
	
	if now > kQuickDodgeAllowedInterval + self.timeLastQuickDodgeEnded then
		self.timeLastQuickDodge = 0
	end

end


local kQuickDodgeJumpForce = 2.15
local kQuickDodgeMaxSpeed = 6.15

function QuickDodgeMixin:PerformDodge( input, velocity )
	
	local direction = self:GetViewCoords():TransformVector( input.move )
	direction:Normalize()
	
	local dodgeVelocity = Vector( direction * kQuickDodgeMaxSpeed * self:GetSlowSpeedModifier() )
	dodgeVelocity.y = kQuickDodgeJumpForce
	
	velocity:Add( dodgeVelocity )
	
	//maxspeed check
	
	self.timeLastQuickDodge = Shared.GetTime()      
	self.dodging = true
	self.onGround = false
	
end


function QuickDodgeMixin:ModifyVelocity( input, velocity, deltaTime )

	local moveModifierButton = bit.band( input.commands, Move.MovementModifier ) ~= 0
    local validDodgeInput = (
		moveModifierButton and input.move.x ~= 0 and input.move.z == 0
		and input.move.y == 0
    )
    
    self:OnUpdate( deltaTime )	//HACKS biatch!
    
    if validDodgeInput and self:GetCanDodge() then
		
		self:PerformDodge( input, velocity )
    
    end

end


function QuickDodgeMixin:OnUpdateAnimationInput( modelMixin )

    PROFILE("QuickDodgeMixin:OnUpdateAnimationInput")
	
    if self:GetIsDodging() and ( not HasMixin(self, "LadderMove") or not self:GetIsOnLadder() ) then
		//TODO Change to use XYZ_jetpacktakeoff, XYZ_jetpackland, XYZ_jetpack?
		// - above will likely result in really jerky animations
        
        if self.dodging and not self.onGround then
			modelMixin:SetAnimationInput("move", "jump")
        end
        
    end
    
end


