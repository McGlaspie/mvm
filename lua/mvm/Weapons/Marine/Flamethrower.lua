

Script.Load("lua/PostLoadMod.lua")


local newNetworkVars = {}

//-----------------------------------------------------------------------------

//Do locals actually get overridden?
local function BurnSporesAndUmbra(self, startPoint, endPoint)
end


//MvM:Removed check to burn spores and umbra, same otherwise
local function ApplyConeDamage(self, player)
    
    local barrelPoint = self:GetBarrelPoint() - Vector(0, 0.4, 0)
    local ents = {}
    
    local fireDirection = GetNormalizedVector((player:GetEyePos() - Vector(0, 0.3, 0) + player:GetViewCoords().zAxis * kRange) - barrelPoint)
    local extents = Vector(kConeWidth, kConeWidth, kConeWidth)
    local remainingRange = kRange
    local startPoint = barrelPoint
    
    for i = 1, 4 do
    
        if remainingRange <= 0 then
            break
        end
        
        local trace = TraceMeleeBox(self, startPoint, fireDirection, extents, remainingRange, PhysicsMask.Melee, EntityFilterOne(player))
        
        if trace.fraction ~= 1 then
        
            if trace.entity then
            
                if HasMixin(trace.entity, "Live") then
                    table.insertunique(ents, trace.entity)
                end
                
            else
            
                // Make another trace to see if the shot should get deflected.
                local lineTrace = Shared.TraceRay(
					startPoint, 
					startPoint + remainingRange * fireDirection, 
					CollisionRep.LOS, 
					PhysicsMask.Melee, 
					EntityFilterOne(player)
				)
                
                if lineTrace.fraction < 0.8 then
                
                    fireDirection = fireDirection + trace.normal * 0.55
                    fireDirection:Normalize()
                    
                    if Server then
                        CreateFlame(self, player, lineTrace.endPoint, lineTrace.normal, fireDirection)
                    end
                    
                end
                
            end
            
            remainingRange = remainingRange - (trace.endPoint - startPoint):GetLength() - kConeWidth * 2
            startPoint = trace.endPoint + fireDirection * kConeWidth * 2
        
        else
            break
        end

    end
    
    for index, ent in ipairs(ents) do
    
        if ent ~= player then
        
            local toEnemy = GetNormalizedVector(ent:GetModelOrigin() - barrelPoint)
            local health = ent:GetHealth()
            
            self:DoDamage(kFlamethrowerDamage, ent, ent:GetModelOrigin(), toEnemy)	//???? Move after set on fire check?
            
            // Only light on fire if we successfully damaged them
            //???? Is below causing the non-burn bug to some structures? Mixin call order?
            if ent:GetHealth() ~= health and HasMixin(ent, "Fire") then
                ent:SetOnFire(player, self)
            end
            
        end
    
    end

end


if Client then
	
    function Flamethrower:GetUIDisplaySettings()
        return { xSize = 128, ySize = 256, script = "lua/mvm/Hud/GUIFlamethrowerDisplay.lua" }
    end

end


//-----------------------------------------------------------------------------

Class_Reload("Flamethrower", newNetworkVars)

