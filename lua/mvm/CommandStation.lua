

Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/TeamColorSkinMixin.lua")
Script.Load("lua/PostLoadMod.lua")

//-----------------------------------------------------------------------------

local newNetworkVars = {}

AddMixinNetworkVars(FireMixin, newNetworkVars)
AddMixinNetworkVars(DetectableMixin, newNetworkVars)

local kCommandStationState = enum( { "Normal", "Locked", "Welcome" } )

//-----------------------------------------------------------------------------

local orgCommandStationCreate = CommandStation.OnCreate
function CommandStation:OnCreate()
	
	orgCommandStationCreate(self)

	InitMixin(self, FireMixin)
	InitMixin(self, DetectableMixin)
	InitMixin(self, TeamColorSkinMixin)

end

//Overrides original
function CommandStation:OnUpdateRender()

	PROFILE("CommandStation:OnUpdateRender")

    CommandStructure.OnUpdateRender(self)
    
    local model = self:GetRenderModel()
    if model then
    
        local state = kCommandStationState.Normal
        local player = Client.GetLocalPlayer()
        
        //FIXME Set to ignore team checks for Spectator team
        if self:GetIsOccupied() and self:GetTeamNumber() == player:GetTeamNumber() then
        
            state = kCommandStationState.Welcome
            
        elseif GetTeamHasCommander( self:GetTeamNumber() ) or self:GetTeamNumber() ~= player:GetTeamNumber() then
        
            state = kCommandStationState.Locked
            
        end
        
        model:SetMaterialParameter("state", state)
        
    end

end


//-----------------------------------------------------------------------------

if Server then
	
	local function MvM_KillPlayersInside(self)
		// Now kill any other players that are still inside the command station so they're not stuck!
		// Draw debug box if players are players on inside aren't dying or players on the outside are
		//DebugCircle(self:GetKillOrigin(), CommandStation.kCommandStationKillConstant, Vector(0, 1, 0), 1, 1, 1, 1, 1)
		for index, player in ipairs( GetEntitiesWithinRange("Player", self:GetOrigin(), 3.25) ) do
			if not player:isa("Commander") and not player:isa("Spectator") then
				if self:GetIsPlayerInside(player) and player:GetId() ~= self.playerIdStartedLogin then
					player:Kill(self, self, self:GetOrigin())
				end
			end
		end
	end
	
	
	//Overrides vanilla - kills oppossing team's comm otherwise
	function CommandStation:LoginPlayer( player )
		local commander = CommandStructure.LoginPlayer(self, player)
		MvM_KillPlayersInside( self )
	end
	
	
end

//-----------------------------------------------------------------------------


Class_Reload("CommandStation", newNetworkVars)

