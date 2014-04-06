//
//	Modified core/SoundEffect class in order to allow option to
//	keep the SFX entity "alive" when a sound has finished playing.
//	This is optional and default behavior is for it to be destroyed
//	once the Stop or Update routine runs when a sound is completed.
//	Needed this in order to control SFX of PowerPoints
//


local newNetworkVars = {
	keepAlive = "boolean"
}


//-----------------------------------------------------------------------------


local orgSfxCreate = SoundEffect.OnCreate
function SoundEffect:OnCreate()

	orgSfxCreate( self )
	
	self.keepAlive = false	//Used to prevent sounds from being destroyed in
							//special cases when they'll need to be reused.

end


local kDefaultMaxAudibleDistance = 50
local kSoundEndBufferTime = 0.5


if Server then

	function SoundEffect:Stop()		//Overrides
		
		self.playing = false
		self.startTime = 0
		
		-- Destroy when stopped if this is not a map entity and not set to loop.
		if not self:GetIsMapEntity() and self.assetLength >= 0 and self.keepAlive ~= true then
			DestroyEntity(self)
		end
		
	end

	
	function SoundEffect:SetKeepAlive( stayAlive )
		self.keepAlive = stayAlive or false
	end


	local function MvM_SharedUpdate(self)

		PROFILE("SoundEffect:SharedUpdate")
		
		// If the assetLength is < 0, it is a looping sound and needs to be manually destroyed.
		if not self:GetIsMapEntity() and self.playing and self.assetLength >= 0 then
			
			// Add in a bit of time to make sure the Client has had enough time to fully play.
			local endTime = self.startTime + self.assetLength + kSoundEndBufferTime
			if Shared.GetTime() > endTime then
				if self.keepAlive == true then
					self:Stop()
				else
					DestroyEntity(self)
				end
			end
			
		end
		
	end
	
	
	function SoundEffect:OnProcessMove()
		MvM_SharedUpdate( self )
	end
	
	
	function SoundEffect:OnUpdate( deltaTime )
		MvM_SharedUpdate( self )
	end
	
	
end		//End Server



if Client then

	local function DestroySoundEffect(self)
    
        if self.soundEffectInstance then
        
			self.clientPlaying = false
            Client.DestroySoundEffect(self.soundEffectInstance)
            self.soundEffectInstance = nil
            
        end
        
    end
    
    function SoundEffect:OnDestroy()
        DestroySoundEffect(self)
    end

	
    local function SharedUpdate(self)
    
        PROFILE("SoundEffect:SharedUpdate")
        
        if self.predictorId ~= Entity.invalidId then
        
            local predictor = Shared.GetEntity(self.predictorId)
            if Client.GetLocalPlayer() == predictor then
                return
            end
            
        end
       
        if self.clientAssetIndex ~= self.assetIndex then
        
            DestroySoundEffect(self)
            
            self.clientAssetIndex = self.assetIndex
            
            if self.assetIndex ~= 0 then
            
                self.soundEffectInstance = Client.CreateSoundEffect(self.assetIndex)
                self.soundEffectInstance:SetParent(self:GetId())
                
            end
        
        end
        
        // Only attempt to play if the index seems valid.
        if self.assetIndex ~= 0 then
			
            if self.clientPlaying ~= self.playing or self.clientStartTime ~= self.startTime then
				
                self.clientStartTime = self.startTime
                self.clientPlaying = self.playing
                
                if self.playing then
                
                    self.soundEffectInstance:Start()
                    self.soundEffectInstance:SetVolume( self.volume )
                    
                    if self.clientSetParameters then
                    
                        for c = 1, #self.clientSetParameters do
                        
                            local param = self.clientSetParameters[c]
                            self.soundEffectInstance:SetParameter(param.name, param.value, param.speed)
                            
                        end
                        self.clientSetParameters = nil
                        
                    end
                    
                else
                    self.soundEffectInstance:Stop()
                end
                
            end
            
        end
        
        -- Update 3D positional setting.
        if self.soundEffectInstance and self.clientPositional ~= self.positional then
        
            self.soundEffectInstance:SetPositional(self.positional)
            self.clientPositional = self.positional
            
        end
        
    end
    
    function SoundEffect:OnUpdate(deltaTime)
        SharedUpdate(self)
    end
    
    function SoundEffect:OnProcessMove()
        SharedUpdate(self)
    end
    
    function SoundEffect:OnProcessSpectate()
        SharedUpdate(self)
    end

end	//End Client


//-----------------------------------------------------------------------------


Class_Reload( "SoundEffect", newNetworkVars )

