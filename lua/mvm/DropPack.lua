
Script.Load("lua/mvm/ScriptActor.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")


//-----------------------------------------------------------------------------


function DropPack:OnCreate()	//OVERRIDES

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)	//bleh...has to be heavy on resources/cycles
    
end


function DropPack:OverrideCheckVision()
	return false
end

function DropPack:OverrideVisionRadius()
	return 0
end


if Server then
	
	
    function DropPack:OnUpdate(deltaTime)	//OVERRIDES
    
        PROFILE("DropPack:OnUpdate")
    
        ScriptActor.OnUpdate(self, deltaTime)    
        
        // update fall

        if self.onGroundPoint and self.onGroundPoint ~= self:GetOrigin() and self.fallSpeed then
            
            self.fallSpeed = math.min(50, self.fallSpeed + deltaTime * 9.81)
            self:SetOrigin(SlerpVector(self:GetOrigin(), self.onGroundPoint, deltaTime * self.fallSpeed))
            
        elseif not self.hitStaticGround then

            if not self.lastOnGroundUpdate or self.lastOnGroundUpdate + 0.1 < Shared.GetTime() then        

                self.lastOnGroundUpdate = Shared.GetTime()
                
                local trace = Shared.TraceRay(self:GetOrigin() + kUpVector * 0.025, self:GetOrigin() - kUpVector * 20, CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterOneAndIsa(self, "Player"))
                if trace.fraction ~= 1 and self:GetOrigin().y - trace.endPoint.y > 0.025 then
                    
                    self.onGroundPoint = Vector(trace.endPoint)
                    self.fallSpeed = 0
                    
                else                
                    self.onGroundPoint = nil                    
                end
                
                if not trace.entity and trace.fraction ~= 1 then
                    self.hitStaticGround = true
                end
                
                if trace.fraction ~= 1 then                
                    
                    local coords = self:GetCoords()
                    coords.yAxis = trace.normal                    
                    coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
                    coords.zAxis = coords.xAxis:CrossProduct(coords.yAxis)
                    
                    self.desiredAngles = Angles()
                    self.desiredAngles:BuildFromCoords(coords)
                    self.setAngleStartTime = Shared.GetTime()
                
                end
            
            end
        
        end
        
        // set angles when on ground

        if self.desiredAngles then
        
            if self.onGroundPoint == nil or self.onGroundPoint == self:GetOrigin() then

                self:SetAngles(SlerpAngles(self:GetAngles(), self.desiredAngles, deltaTime * 5))
                
                if self.setAngleStartTime + 4 < Shared.GetTime() then
                    self.desiredAngles = nil
                end
                
            end
        
        end

        // update pickup

        //local marinesNearby = GetEntitiesForTeamWithinRange("Marine", self:GetTeamNumber(), self:GetOrigin(), self.pickupRange)
        local marinesNearby = GetEntitiesWithinRange("Marine", self:GetOrigin(), self.pickupRange)
        Shared.SortEntitiesByDistance(self:GetOrigin(), marinesNearby)

        for _, marine in ipairs(marinesNearby) do
        
            if self:GetIsValidRecipient(marine) then
            
                self:OnTouch(marine)
                DestroyEntity(self)
                break
                
            end
        
        end
        
    end


Class_Reload( "DropPack", {} )


end //end Server