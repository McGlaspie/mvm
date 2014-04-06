

Script.Load("lua/mvm/Weapons/Weapon.lua")

local kRange = 1.4
local kBuildEffectInterval = 0.2


//-----------------------------------------------------------------------------


function Builder:GetSprintAllowed()
    return false
end


local kNormalRelevancy = bit.bor( kRelevantToTeam1Unit, kRelevantToTeam2Unit )

local function UpdateSoundRelevancy( self , player )

	local playerTeamRelev = ConditionalValue(
		player:GetTeamNumber() == kTeam1Index,
		kRelevantToTeam1Commander,
		kRelevantToTeam2Commander
	)
	local enemyCommRelv = ConditionalValue(
		playerTeamRelev == kRelevantToTeam1Commander,
		kRelevantToTeam2Commander,
		kRelevantToTeam1Commander
	)
	
	local mask = bit.bor( kNormalRelevancy, playerTeamRelev )
	
	if player:GetIsSighted() then
		mask = bit.bor( mask, enemyCommRelv )
	end
	
	self.loopingFireSound:SetExcludeRelevancyMask( mask )
	
end

function Builder:ProcessMoveOnWeapon(player, input)	//OVERRIDES

    Weapon.ProcessMoveOnWeapon(self, player, input)
    
    if Server and not self.loopingFireSound:GetIsPlaying() then
		
		UpdateSoundRelevancy( self, player )
		
        self.loopingFireSound:Start()
        
    end
    
end


local kCinematicName = PrecacheAsset("cinematics/marine/builder/builder_scan.cinematic")
local kCinematicNameTeam2 = PrecacheAsset("cinematics/marine/builder/builder_scan_team2.cinematic")
local kMuzzleAttachPoint = "fxnode_weldermuzzle"

function Builder:OnUpdateRender()

    Weapon.OnUpdateRender(self)
    
    if self.ammoDisplayUI then
    
        local progress = PlayerUI_GetUnitStatusPercentage()
        self.ammoDisplayUI:SetGlobal("weldPercentage", progress)
        
    end
    
    if self.playEffect then
    
        if self.lastBuilderEffect + kBuildEffectInterval <= Shared.GetTime() then
            
            CreateMuzzleCinematic( 
                self, 
                ConditionalValue( self:GetTeamNumber() == kTeam1Index, kCinematicName, kCinematicNameTeam2 ), 
                ConditionalValue( self:GetTeamNumber() == kTeam1Index, kCinematicName, kCinematicNameTeam2 ), 
                kMuzzleAttachPoint
            )
            self.lastBuilderEffect = Shared.GetTime()
            
        end
        
    end
    
end


if Client then

    function Builder:GetUIDisplaySettings()
        return { xSize = 512, ySize = 512, script = "lua/mvm/Hud/GUIWelderDisplay.lua", textureNameOverride = "welder" }
    end
    
end

//-----------------------------------------------------------------------------

Class_Reload("Builder", {})

