

Script.Load("lua/mvm/Player.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/Mixins/FreeLookMoveMixin.lua")
Script.Load("lua/Mixins/OverheadMoveMixin.lua")
Script.Load("lua/FollowMoveMixin.lua")
Script.Load("lua/FreeLookSpectatorMode.lua")
Script.Load("lua/mvm/OverheadSpectatorMode.lua") //Had to be modified for GUI script updates, yay...
Script.Load("lua/FollowingSpectatorMode.lua")
Script.Load("lua/FirstPersonSpectatorMode.lua")
Script.Load("lua/MinimapMoveMixin.lua")
Script.Load("lua/ScoringMixin.lua")


local kSpectatorMapMode = enum( { 'Invisible', 'Small', 'Big' } )

local kSpectatorModeClass = 
{
    [kSpectatorMode.FreeLook] = FreeLookSpectatorMode,
    [kSpectatorMode.Following] = FollowingSpectatorMode,
    [kSpectatorMode.FirstPerson] = FirstPersonSpectatorMode,
    [kSpectatorMode.Overhead] = OverheadSpectatorMode
}

local kDefaultFreeLookSpeed = Player.kWalkMaxSpeed * 3
local kMaxSpeed = Player.kWalkMaxSpeed * 5
local kAcceleration = 100
local kDeltatimeBetweenAction = 0.3


//-----------------------------------------------------------------------------



/**
 * Return the next mode according to the order of
 * kSpectatorMode enumeration and the current mode
 * selected
 */
local function NextSpectatorMode(self, mode)

    if mode == nil then
        mode = self.specMode
    end
    
    local numModes = 0
    for name, _ in pairs(kSpectatorMode) do
    
        if type(name) ~= "number" then
            numModes = numModes + 1
        end
        
    end
    
    local nextMode = (mode % numModes) + 1
    // Following is only used directly through SetSpectatorMode(), never in this function.
    if not self:IsValidMode(nextMode) or nextMode == kSpectatorMode.Following then
        return NextSpectatorMode(self, nextMode)
    else
        return nextMode
    end
    
end


// First Person mode switching handled at:
// GUIFirstPersonSpectate:SendKeyEvent(key, down)
local function UpdateSpectatorMode(self, input)

    assert(Server)
    
    self.timeFromLastAction = self.timeFromLastAction + input.time
    if self.timeFromLastAction > kDeltatimeBetweenAction then
    
        if bit.band(input.commands, Move.Jump) ~= 0 then
        
            self:SetSpectatorMode(NextSpectatorMode(self))
            self.timeFromLastAction = 0
            
        elseif bit.band(input.commands, Move.Weapon1) ~= 0 then
        
            self:SetSpectatorMode(kSpectatorMode.FreeLook)
            self.timeFromLastAction = 0
            
        elseif bit.band(input.commands, Move.Weapon2) ~= 0 then
        
            self:SetSpectatorMode(kSpectatorMode.Overhead)
            self.timeFromLastAction = 0
            
        elseif bit.band(input.commands, Move.Weapon3) ~= 0 then
        
            self:SetSpectatorMode(kSpectatorMode.FirstPerson)
            self.timeFromLastAction = 0
            
        end
        
    end
    
    // Switch away from following mode ASAP while on a playing team.
    // Prefer first person mode in this case.
    if self:GetIsOnPlayingTeam() and self:GetIsFollowing() then
    
        local followTarget = Shared.GetEntity(self:GetFollowTargetId())
        // Disallow following a Player in this case. Allow following Eggs and IPs
        // for example.
        if not followTarget or followTarget:isa("Player") then
            self:SetSpectatorMode(kSpectatorMode.FirstPerson)
        end
        
    end
    
end



//Must override this to ensure modified Player class is used
function Spectator:OnCreate()	//OVERRIDES

    Player.OnCreate(self)
    
    InitMixin(self, CameraHolderMixin, { kFov = kDefaultFov })
    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, FreeLookMoveMixin)
    InitMixin(self, FollowMoveMixin)
    InitMixin(self, OverheadMoveMixin)
    InitMixin(self, MinimapMoveMixin)
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    
    // Default all move mixins to off.
    self:SetFreeLookMoveEnabled(false)
    self:SetFollowMoveEnabled(false)
    self:SetOverheadMoveEnabled(false)
    
    self.specMode = NextSpectatorMode(self)
    
    if Client then
    
        self.mapButtonPressed = false
        self.mapMode = kSpectatorMapMode.Small
        self.showInsight = true
        
    end
    
end




function Spectator:OnProcessMove(input)

    self:UpdateMove(input)
    
    if Server then
    
        if not self:GetIsRespawning() then
            UpdateSpectatorMode(self, input)
        end

    elseif Client then
    
        self:UpdateCrossHairTarget()
        
        // Toggle the insight GUI.
        if self:GetTeamNumber() == kSpectatorIndex then
        
            if bit.band(input.commands, Move.Weapon4) ~= 0 then
            
                self.showInsight = not self.showInsight
                ClientUI.GetScript("mvm/Hud/GUISpectator"):SetIsVisible(self.showInsight)
                
                if self.showInsight then
                
                    self.mapMode = kSpectatorMapMode.Small
                    self:ShowMap(true, false, true)
                    
                else
                
                    self.mapMode = kSpectatorMapMode.Invisible
                    self:ShowMap(false, false, true)
                    
                end
                
            end
            
        end
        
        // This flag must be cleared inside OnProcessMove. See explaination in Commander:OverrideInput().
        self.setScrollPosition = false
        
    end
    
    self:OnUpdatePlayer(input.time)
    
    Player.UpdateMisc(self, input)
    
end





//-----------------------------------------------------------------------------


Class_Reload( "Spectator", {} )

