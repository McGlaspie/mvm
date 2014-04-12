
Script.Load("lua/ScoringMixin.lua")



function ScoringMixin:AddScore(points, res, wasKill)

    // Should only be called on the Server.
    if Server then
    
        // Tell client to display cool effect.
        if points ~= nil and points ~= 0 then
			
            local displayRes = ConditionalValue(type(res) == "number", res, 0)
            Server.SendNetworkMessage(Server.GetOwner(self), "MvM_ScoreUpdate", { points = points, res = displayRes, wasKill = wasKill == true }, true)
            self.score = Clamp(self.score + points, 0, self:GetMixinConstants().kMaxScore or 100)

            if not self.scoreGainedCurrentLife then
                self.scoreGainedCurrentLife = 0
            end

            self.scoreGainedCurrentLife = self.scoreGainedCurrentLife + points    

        end
    
    end
    
end

