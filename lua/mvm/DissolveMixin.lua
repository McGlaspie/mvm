

Script.Load("lua/DissolveMixin.lua")

local kDissolveSpeed = 0.75
local kDissolveDelay = 5


function DissolveMixin:OnKillClient()	//OVERRIDES

    // Start the dissolve effect
    local now = Shared.GetTime()
    
    self.dissolveStart = now + kDissolveDelay
	
    self:InstanceMaterials()

end


function DissolveMixin:OnUpdateRender()

    PROFILE("DissolveMixin:OnUpdateRender")
    
    local dissolveStart = self.dissolveStart
    
    if dissolveStart ~= nil then
    
        local model = self:GetRenderModel()
        
        if model then
			
            local now = Shared.GetTime()
				
            if now >= dissolveStart then
				
				//FIXME below condition is having no effect
				if HasMixin( self, "ColoredSkins" ) then
					self.skinAccentColor = self:GetAccentSkinColor()	//Reset for dissolve effect
				end
				
                local dissolveAmount = math.min(1, (now - dissolveStart) / kDissolveSpeed)
                
                self:SetOpacity(1 - dissolveAmount, "dissolve")
                
            end
            
        end
        

    end
    
end

