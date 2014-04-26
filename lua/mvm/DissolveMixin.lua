

Script.Load("lua/DissolveMixin.lua")

local kDissolveSpeed = 0.75
local kDissolveDelay = 5	//move to global

local kDissolveAccentOnLimit = 0.18


function DissolveMixin:__initmixin()

	self.dissolveStart = nil

end


function DissolveMixin:OnKillClient()	//OVERRIDES

    // Start the dissolve effect
    local now = Shared.GetTime()
    
    self.dissolveStart = now + kDissolveDelay
	self.dissolveAmount = 0
	
    self:InstanceMaterials()

end


//TODO Reset event?


function DissolveMixin:OnUpdate( deltaTime )

	PROFILE("DissolveMixin:OnUpdate")
    
    local dissolveStart = self.dissolveStart
    
    if dissolveStart ~= nil then
    
        local model = self:GetRenderModel()
        
        if model then
			
            local now = Shared.GetTime()
			
            if now >= dissolveStart then
				
				self.dissolveAmount = math.min( 1, (now - dissolveStart) / kDissolveSpeed )
				
				if self.GetAccentSkinColor and self.dissolveAmount >= kDissolveAccentOnLimit then
					self.skinAccentColor = self:GetAccentSkinColor()	//Reset for dissolve effect
				end
				
				if 1 - self.dissolveAmount == 0 then
					self.skinAccentColor = Color(0,0,0,0)	//lame attempt to keep Visors from appearing
				end
                
            end
            
        end

    end

end


function DissolveMixin:OnUpdateRender()	//OVERRIDES
	
	PROFILE("DissolveMixin:OnUpdateRender")
	
	if self.dissolveAmount ~= nil then
		
		self:SetOpacity( 1 - self.dissolveAmount, "dissolve" )
	
	end
	
end

