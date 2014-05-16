


Script.Load("lua/TeamInfo.lua")


local newNetworkVars = {
	supplyUsed = "integer (0 to " .. kMaxSupply .. ")",		//OVERRIDES
	spawnQueueTotal = "integer (0 to 64)"
}



// Relevant techs must be ordered with children techs coming after their parents
TeamInfo.kRelevantTechIdsMarine =
{

    kTechId.ShotgunTech,
    kTechId.MinesTech,
    kTechId.WelderTech,
    kTechId.GrenadeTech,
    
    kTechId.AdvancedArmory,
    kTechId.AdvancedArmoryUpgrade,
    kTechId.AdvancedWeaponry,

    kTechId.Weapons1,
    kTechId.Weapons2,
    kTechId.Weapons3,
    kTechId.Weapons4,
    kTechId.Armor1,
    kTechId.Armor2,
    kTechId.Armor3,
    kTechId.Armor4,

    kTechId.PrototypeLab,
    kTechId.JetpackTech,
    kTechId.ExosuitTech,
    kTechId.DualMinigunTech,

    kTechId.ARCRoboticsFactory,
    kTechId.UpgradeRoboticsFactory,
    kTechId.MACEMPTech,
    kTechId.MACSpeedTech,
    
    kTechId.Observatory,
    kTechId.PhaseTech,
    
    kTechId.CatPackTech,
    kTechId.NanoShieldTech,
    
}



function TeamInfo:GetRelevantTech()
    return TeamInfo.kRelevantIdMaskMarine, TeamInfo.kRelevantTechIdsMarine
end


//-------------------------------------


if Server then

	function TeamInfo:Reset()
    
        self.teamResources = 0
        self.personalResources = 0
        self.numResourceTowers = 0
        self.latestResearchId = 0
        self.researchDisplayTime = 0
        self.lastTechPriority = 0
        self.lastCommPingTime = 0
        self.lastCommPingPosition = Vector(0,0,0)
        self.totalTeamResources = 0
        self.techActiveMask = 0
        self.techOwnedMask = 0
        self.playerCount = 0
        self.workerCount = 0
        self.kills = 0
        self.supplyUsed = 0
        self.spawnQueueTotal = 0
    
    end

end


function TeamInfo:GetSpawnQueueTotal()
    return self.spawnQueueTotal
end


local function MvM_UpdateInfo(self)

    if self.team then
    
        self:SetTeamNumber(self.team:GetTeamNumber())
        self.teamResources = self.team:GetTeamResources()
        self.playerCount = Clamp(self.team:GetNumPlayers(), 0, 31)
        self.totalTeamResources = self.team:GetTotalTeamResources()
        self.personalResources = 0
        for index, player in ipairs(self.team:GetPlayers()) do
            self.personalResources = self.personalResources + player:GetResources()
        end
        
        local rtCount = 0
        local rtActiveCount = 0
        local rts = GetEntitiesForTeam("ResourceTower", self:GetTeamNumber())
        for index, rt in ipairs(rts) do
        
            if rt:GetIsAlive() then
                rtCount = rtCount + 1
                if rt:GetIsBuilt() then
                    rtActiveCount = rtActiveCount + 1
                end
            end
            
        end
        
        
        self.numCapturedResPoints = rtCount
        self.numResourceTowers = rtActiveCount
        self.kills = self.team:GetKills()
        
        if Server then
        
            if self.lastTechTreeUpdate == nil or (Shared.GetTime() > (self.lastTechTreeUpdate + TeamInfo.kTechTreeUpdateInterval)) then
                if not GetGamerules():GetGameStarted() then
                    self.techActiveMask = 0
                    self.techOwnedMask = 0
                else
                    self:UpdateTechTreeInfo(self.team:GetTechTree())    
                end
            end
        
            if self.latestResearchId ~= 0 and self.researchDisplayTime < Shared.GetTime() then
            
                self.latestResearchId = 0
                self.researchDisplayTime = 0
                self.lastTechPriority = 0
                
            end
            
            local team = self:GetTeam()
            self.numCapturedTechPoint = team:GetNumCapturedTechPoints()
            
            self.spawnQueueTotal = team:GetTotalInRespawnQueue()
            
            self.lastCommPingTime = team:GetCommanderPingTime()
            self.lastCommPingPosition = team:GetCommanderPingPosition() or Vector(0,0,0)
            
            self.supplyUsed = team:GetSupplyUsed()
            
        end
        
    end
    
end



function TeamInfo:OnUpdate(deltaTime)
    MvM_UpdateInfo(self)
end




Class_Reload( "TeamInfo", newNetworkVars )

