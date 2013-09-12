

Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/ColoredSkinsMixin.lua")
Script.Load("lua/PostLoadMod.lua")


// The amount of time until the mine is detonated once armed.
local kTimeArmed = 0.15
// The amount of time it takes other mines to trigger their detonate sequence when nearby mines explode.
local kTimedDestruction = 0.4

local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)

//-----------------------------------------------------------------------------

local oldMineCreate = Mine.OnCreate
function Mine:OnCreate()

	oldMineCreate(self)
	
	InitMixin(self, FireMixin)
	
	if Client then
		InitMixin(self, ColoredSkinsMixin)
	end

end


if Client then

	function Mine:GetBaseSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_BaseColor, kTeam1_BaseColor )
	end

	function Mine:GetAccentSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_AccentColor, kTeam1_AccentColor )
	end
	
	function Mine:GetTrimSkinColor()
		return ConditionalValue( self:GetTeamNumber() == kTeam2Index, kTeam2_TrimColor, kTeam1_TrimColor )
	end

end


local function MvM_CheckEntityExplodesMine(self, entity)

	//Print("CheckEntityExplodesMine() entity:isa( %s )", tostring(entity:GetClassName()) )

    if not self.active then
        return false
    end
    
    if not HasMixin(entity, "Team") or GetEnemyTeamNumber(self:GetTeamNumber()) ~= entity:GetTeamNumber() then
        return false
    end
    
    if not HasMixin(entity, "Live") or not entity:GetIsAlive() or not entity:GetCanTakeDamage() then
        return false
    end
    
    if not ( entity:isa("Player") or entity:isa("Bot") or entity:isa("ARC") ) then	//MACs?
        return false
    end
    
    if entity:isa("Commander") then
        return false
    end
    
    local minePos = self:GetEngagementPoint()
    local targetPos = entity:GetEngagementPoint()
    // Do not trigger through walls. But do trigger through other entities.
    if not GetWallBetween(minePos, targetPos, entity) then
        // If this fails, targets can sit in trigger, no "polling" update performed.
        Arm(self)
        return true
    end
    
    return false
    
end

local function MvM_CheckAllEntsInTriggerExplodeMine(self)

    local ents = self:GetEntitiesInTrigger()
    for e = 1, #ents do
		
        MvM_CheckEntityExplodesMine(self, ents[e])
    end
    
end


function Mine:OnInitialized()
    
    ScriptActor.OnInitialized(self)
    
    if Server then
        
        self.active = false
        
        local activateFunc = function(self)
                                 self.active = true
                                 MvM_CheckAllEntsInTriggerExplodeMine(self)
                             end
        self:AddTimedCallback(activateFunc, kMineActiveTime)
        
        self.armed = false
        self:SetHealth(self:GetMaxHealth())
        self:SetArmor(self:GetMaxArmor())
        self:TriggerEffects("mine_spawn")
        
        InitMixin(self, TriggerMixin)
        self:SetSphere(kMineTriggerRange)
        
    end
    
    self:SetModel(Mine.kModelName)
    
end


if Server then

	function Mine:OnTriggerEntered(entity)
        MvM_CheckEntityExplodesMine(self, entity)
    end
    
    function Mine:OnUpdate(dt)
    
        local now = Shared.GetTime()
        self.lastMineUpdateTime = self.lastMineUpdateTime or now
        if now - self.lastMineUpdateTime >= 0.5 then
            MvM_CheckAllEntsInTriggerExplodeMine(self)
            self.lastMineUpdateTime = now
        end
        
    end

end	//Server


if Client then

    function Mine:OnGetIsVisible(visibleTable, viewerTeamNumber)
        local player = Client.GetLocalPlayer()
        
        if player and player:isa("Commander") and viewerTeamNumber == GetEnemyTeamNumber(self:GetTeamNumber()) then
            visibleTable.Visible = false
        end
    end

end	//Client

//-----------------------------------------------------------------------------

Class_Reload("Mine", newNetworkVars)

