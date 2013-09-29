

Script.Load("lua/NS2GameRules.lua")


local kGameEndCheckInterval = 0.75
local kPregameLength = 3
local kTimeToReadyRoom = 8
local kPauseToSocializeBeforeMapcycle = 30		//TODO - This should notify players map change is about to occur
local kGameStartMessageInterval = 10

// How often to send the "No commander" message to players in seconds.
local kSendNoCommanderMessageRate = 50


if Server then

    Script.Load("lua/mvm/ReadyRoomTeam.lua")
	
	
	function NS2Gamerules:BuildTeam(teamType)        
        return MarineTeam()
    end
    
    
    
    function NS2Gamerules:UpdateTechPoints()
    
        if self.timeToSendTechPoints == nil or Shared.GetTime() > self.timeToSendTechPoints then
        
            local spectators = Shared.GetEntitiesWithClassname("Spectator")
            if spectators:GetSize() > 0 then
                
                local powerNodes = Shared.GetEntitiesWithClassname("PowerPoint")
                //local eggs = Shared.GetEntitiesWithClassname("Egg")
                
                for _, techpoint in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do
					
                    local message = BuildTechPointsMessage(techpoint, powerNodes, {})
                    
                    for _, spectator in ientitylist(spectators) do
                        Server.SendNetworkMessage(spectator, "TechPoints", message, false)
                    end
                    
                end
            
            end
            
            self.timeToSendTechPoints = Shared.GetTime() + 0.5
            
        end
        
    end
    
    
    local kMaxServerAgeBeforeMapChange = 36000
    local function ServerAgeCheck(self)	//ARGH! Stupid fricken locals!!! *shake fist*
    
        if self.gameState ~= kGameState.Started and Shared.GetTime() > kMaxServerAgeBeforeMapChange then
            MapCycle_ChangeMap(Shared.GetMapName())
        end
        
    end
    
    
    local function KillEnemiesNearCommandStructureInPreGame(self, timePassed)
    
        if self:GetGameState() == kGameState.NotStarted then
        
            local commandStations = Shared.GetEntitiesWithClassname("CommandStructure")
            for _, ent in ientitylist(commandStations) do
            
                local enemyPlayers = GetEntitiesForTeam("Player", GetEnemyTeamNumber(ent:GetTeamNumber()))
                for e = 1, #enemyPlayers do
                
                    local enemy = enemyPlayers[e]
                    if enemy:GetDistance(ent) <= 5 then
                        enemy:TakeDamage(25 * timePassed, nil, nil, nil, nil, 0, 25 * timePassed, kDamageType.Normal)
                    end
                    
                end
                
            end
            
        end
        
    end
    
    
    local function CheckForNoCommander(self, onTeam, commanderType)

        self.noCommanderStartTime = self.noCommanderStartTime or { }
        
        if not self:GetGameStarted() then
            self.noCommanderStartTime[commanderType] = nil
        else
        
            local commanderExists = Shared.GetEntitiesWithClassname(commanderType):GetSize() ~= 0
            
            if commanderExists then
                self.noCommanderStartTime[commanderType] = nil
            elseif not self.noCommanderStartTime[commanderType] then
                self.noCommanderStartTime[commanderType] = Shared.GetTime()
            elseif Shared.GetTime() - self.noCommanderStartTime[commanderType] >= kSendNoCommanderMessageRate then
            
                self.noCommanderStartTime[commanderType] = nil
                SendTeamMessage(onTeam, kTeamMessageTypes.NoCommander)
                
            end
            
        end
        
    end
    
    local function ResetPlayerScores()
    
        for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do            
            if player.ResetScores then
                player:ResetScores()
            end            
        end
    
    end
    
    local function StartCountdown(self)
    
        self:ResetGame()
        
        self:SetGameState(kGameState.Countdown)
        ResetPlayerScores()
        self.countdownTime = kCountDownLength
        
        self.lastCountdownPlayed = nil
        
    end
    
    
    // Returns bool for success and bool if we've played in the game already.
    local function GetUserPlayedInGame(self, player)
    
        local success = false
        local played = false
        
        local owner = Server.GetOwner(player)
        if owner then
        
            local userId = tonumber(owner:GetUserId())
            
            // Could be invalid if we're still connecting to Steam
            played = table.find(self.userIdsInGame, userId) ~= nil
            success = true
            
        end
        
        return success, played
        
    end
    
    local function SetUserPlayedInGame(self, player)
    
        local owner = Server.GetOwner(player)
        if owner then
        
            local userId = tonumber(owner:GetUserId())
            
            // Could be invalid if we're still connecting to Steam.
            return table.insertunique(self.userIdsInGame, userId)
            
        end
        
        return false
        
    end
    
    
    local function UpdateAutoTeamBalance(self, dt)
    
        local wasDisabled = false
        
        // Check if auto-team balance should be enabled or disabled.
        local autoTeamBalance = Server.GetConfigSetting("auto_team_balance")
        if autoTeamBalance then
        
            local enabledOnUnbalanceAmount = autoTeamBalance.enabled_on_unbalance_amount or 2
            // Prevent the unbalance amount from being 0 or less.
            enabledOnUnbalanceAmount = enabledOnUnbalanceAmount > 0 and enabledOnUnbalanceAmount or 2
            local enabledAfterSeconds = autoTeamBalance.enabled_after_seconds or 10
            
            local team1Players = self.team1:GetNumPlayers()
            local team2Players = self.team2:GetNumPlayers()
            
            local unbalancedAmount = math.abs(team1Players - team2Players)
            if unbalancedAmount >= enabledOnUnbalanceAmount then
            
                if not self.autoTeamBalanceEnabled then
                
                    self.teamsUnbalancedTime = self.teamsUnbalancedTime or 0
                    self.teamsUnbalancedTime = self.teamsUnbalancedTime + dt
                    
                    if self.teamsUnbalancedTime >= enabledAfterSeconds then
                    
                        self.autoTeamBalanceEnabled = true
                        if team1Players > team2Players then
                            self.team1:SetAutoTeamBalanceEnabled(true, unbalancedAmount)
                        else
                            self.team2:SetAutoTeamBalanceEnabled(true, unbalancedAmount)
                        end
                        
                        SendTeamMessage(self.team1, kTeamMessageTypes.TeamsUnbalanced)
                        SendTeamMessage(self.team2, kTeamMessageTypes.TeamsUnbalanced)
                        Print("Auto-team balance enabled")
                        
                        TEST_EVENT("Auto-team balance enabled")
                        
                    end
                    
                end
                
            // The autobalance system itself has turned itself off.
            elseif self.autoTeamBalanceEnabled then
                wasDisabled = true
            end
            
        // The autobalance system was turned off by the admin.
        elseif self.autoTeamBalanceEnabled then
            wasDisabled = true
        end
        
        if wasDisabled then
        
            self.team1:SetAutoTeamBalanceEnabled(false)
            self.team2:SetAutoTeamBalanceEnabled(false)
            self.teamsUnbalancedTime = 0
            self.autoTeamBalanceEnabled = false
            SendTeamMessage(self.team1, kTeamMessageTypes.TeamsBalanced)
            SendTeamMessage(self.team2, kTeamMessageTypes.TeamsBalanced)
            Print("Auto-team balance disabled")
            
            TEST_EVENT("Auto-team balance disabled")
            
        end
        
    end
        
    
    
    
    function NS2Gamerules:OnUpdate(timePassed)
    
        PROFILE("NS2Gamerules:OnUpdate")
        
        GetEffectManager():OnUpdate(timePassed)
        
        //UpdatePlayerSkill(self)
        
        if Server then
        
            if self.justCreated then
            
                if not self.gameStarted then
                    self:ResetGame()
                end
                
                self.justCreated = false
                
            end
            
            if self:GetMapLoaded() then
            
                self:CheckGameStart()
                self:CheckGameEnd()
                
                self:UpdatePregame(timePassed)
                self:UpdateToReadyRoom()
                self:UpdateMapCycle()
                ServerAgeCheck(self)
                UpdateAutoTeamBalance(self, timePassed)
                
                self.timeSinceGameStateChanged = self.timeSinceGameStateChanged + timePassed
                
                self.worldTeam:Update(timePassed)
                self.team1:Update(timePassed)
                self.team2:Update(timePassed)
                self.spectatorTeam:Update(timePassed)
                
                // Send scores every so often
                self:UpdateScores()
                self:UpdatePings()
                self:UpdateHealth()
                self:UpdateTechPoints()
                
                CheckForNoCommander(self, self.team1, "MarineCommander")
                CheckForNoCommander(self, self.team2, "MarineCommander")
                KillEnemiesNearCommandStructureInPreGame(self, timePassed)
                
            end

            //self.sponitor:Update(timePassed)
            
        end
        
    end
    
    
    function NS2Gamerules:EndGame(winningTeam)
    
        if self:GetGameState() == kGameState.Started then
        
            if self.autoTeamBalanceEnabled then
                TEST_EVENT("Auto-team balance, game ended")
            end
            
            // Set losing team        
            local losingTeam = nil
            if winningTeam == self.team1 then
            
                self:SetGameState(kGameState.Team2Won)
                losingTeam = self.team2            
                PostGameViz("Gold Team Wins")
                
            else
            
                self:SetGameState(kGameState.Team1Won)
                losingTeam = self.team1            
                PostGameViz("Blue Team Wins")
                
            end
            
            winningTeam:ForEachPlayer(function(player) Server.SendNetworkMessage(player, "GameEnd", { win = true }, true) end)
            losingTeam:ForEachPlayer(function(player) Server.SendNetworkMessage(player, "GameEnd", { win = false }, true) end)
            self.spectatorTeam:ForEachPlayer(function(player) Server.SendNetworkMessage(player, "GameEnd", { win = losingTeam:GetTeamType() == kAlienTeamType }, true) end)
            
            self.losingTeam = losingTeam
            
            self.team1:ClearRespawnQueue()
            self.team2:ClearRespawnQueue()
            
            // Automatically end any performance logging when the round has ended.
            Shared.ConsoleCommand("p_endlog")

            //self.sponitor:OnEndMatch(winningTeam)
            self.playerRanking:EndGame(winningTeam)
            TournamentModeOnGameEnd()

        end
        
    end
    
    
    
    local function MvM_CheckAutoConcede(self)

        // This is an optional end condition based on the teams being unbalanced.
        local endGameOnUnbalancedAmount = Server.GetConfigSetting("end_round_on_team_unbalance")
        if endGameOnUnbalancedAmount and endGameOnUnbalancedAmount > 0 then

            local gameLength = Shared.GetTime() - self:GetGameStartTime()
            // Don't start checking for auto-concede until the game has started for some time.
            local checkAutoConcedeAfterTime = Server.GetConfigSetting("end_round_on_team_unbalance_check_after_time") or 300
            if gameLength > checkAutoConcedeAfterTime then

                local team1Players = self.team1:GetNumPlayers()
                local team2Players = self.team2:GetNumPlayers()
                local totalCount = team1Players + team2Players
                // Don't consider unbalanced game end until enough people are playing.

                if totalCount > 6 then
                
                    local team1ShouldLose = false
                    local team2ShouldLose = false
                    
                    if (1 - (team1Players / team2Players)) >= endGameOnUnbalancedAmount then

                        team1ShouldLose = true
                    elseif (1 - (team2Players / team1Players)) >= endGameOnUnbalancedAmount then

                        team2ShouldLose = true
                    end
                    
                    if team1ShouldLose or team2ShouldLose then
                    
                        // Send a warning before ending the game.
                        local warningTime = Server.GetConfigSetting("end_round_on_team_unbalance_after_warning_time") or 30
                        if self.sentAutoConcedeWarningAtTime and Shared.GetTime() - self.sentAutoConcedeWarningAtTime >= warningTime then
                            return team1ShouldLose, team2ShouldLose
                        elseif not self.sentAutoConcedeWarningAtTime then
							
                            Shared.Message( ( team1ShouldLose and "Blue Team" or "Gold Team" ) .. " team auto-concede in " .. warningTime .. " seconds" )
                            Server.SendNetworkMessage("AutoConcedeWarning", { time = warningTime, team1Conceding = team1ShouldLose }, true)
                            self.sentAutoConcedeWarningAtTime = Shared.GetTime()
                            
                        end
                        
                    else
                        self.sentAutoConcedeWarningAtTime = nil
                    end
                    
                end
                
            else
                self.sentAutoConcedeWarningAtTime = nil
            end
            
        end
        
        return false, false
        
    end
    
    
    
    
    function NS2Gamerules:CheckGameEnd()
    
        if self:GetGameStarted() and self.timeGameEnded == nil and not Shared.GetCheatsEnabled() and not self.preventGameEnd then
        
            if self.timeLastGameEndCheck == nil or (Shared.GetTime() > self.timeLastGameEndCheck + kGameEndCheckInterval) then
            
                local team1Lost = self.team1:GetHasTeamLost()
                local team2Lost = self.team2:GetHasTeamLost()
                local team1Won = self.team1:GetHasTeamWon()
                local team2Won = self.team2:GetHasTeamWon()
                
                -- Check for auto-concede if neither team lost.
                if not team1Lost and not team2Lost then
                    team1Lost, team2Lost = MvM_CheckAutoConcede(self)
                end
                
                if (team1Lost and team2Lost) or (team1Won and team2Won) then
                    self:DrawGame()
                elseif team1Lost or team2Won then
                    self:EndGame(self.team2)
                elseif team2Lost or team1Won then
                    self:EndGame(self.team1)
                end
                
                self.timeLastGameEndCheck = Shared.GetTime()
                
            end
            
        end
        
    end
    
    
    
    function NS2Gamerules:UpdatePregame(timePassed)

        if self:GetGameState() == kGameState.PreGame then
        
            local preGameTime = self:GetPregameLength()
            
            if self.timeSinceGameStateChanged > preGameTime then
            
                StartCountdown(self)
                if Shared.GetCheatsEnabled() then
                    self.countdownTime = 1
                end
                
            end
            
        elseif self:GetGameState() == kGameState.Countdown then
        
            self.countdownTime = self.countdownTime - timePassed
            
            // Play count down sounds for last few seconds of count-down
            local countDownSeconds = math.ceil(self.countdownTime)
            if self.lastCountdownPlayed ~= countDownSeconds and (countDownSeconds < 4) then
            
                self.worldTeam:PlayPrivateTeamSound(NS2Gamerules.kCountdownSound)
                self.team1:PlayPrivateTeamSound(NS2Gamerules.kCountdownSound)
                self.team2:PlayPrivateTeamSound(NS2Gamerules.kCountdownSound)
                self.spectatorTeam:PlayPrivateTeamSound(NS2Gamerules.kCountdownSound)
                
                self.lastCountdownPlayed = countDownSeconds
                
            end
            
            if self.countdownTime <= 0 then
				
                self.team1:PlayPrivateTeamSound(NS2Gamerules.kMarineStartSound)
                self.team2:PlayPrivateTeamSound(NS2Gamerules.kMarineStartSound)
                
                self:SetGameState(kGameState.Started)
                //self.sponitor:OnStartMatch()
                self.playerRanking:StartGame()
                
            end
            
        end
        
    end
    
    
    
    // Function for allowing teams to hear each other's voice chat
    function NS2Gamerules:GetCanPlayerHearPlayer(listenerPlayer, speakerPlayer)
//MvM: Stub for future use
        local canHear = false
        
        // Check if the listerner has the speaker muted.
        if listenerPlayer:GetClientMuted(speakerPlayer:GetClientIndex()) then
            return false
        end
        
        // If both players have the same team number, they can hear each other
        if(listenerPlayer:GetTeamNumber() == speakerPlayer:GetTeamNumber()) then
            canHear = true
        end
            
        // Or if cheats or dev mode is on, they can hear each other
        if(Shared.GetCheatsEnabled() or Shared.GetDevMode()) then
            canHear = true
        end
        
        // NOTE: SCRIPT ERROR CAUSED IN THIS FUNCTION WHEN FP SPEC WAS ADDED.
        // This functionality never really worked anyway.
        // If we're spectating a player, we can hear their team (but not in tournamentmode, once that's in)
        //if self:GetIsPlayerFollowingTeamNumber(listenerPlayer, speakerPlayer:GetTeamNumber()) then
        //    canHear = true
        //end
        
        return canHear
        
    end
    

end


//-----------------------------------------------------------------------------

Class_Reload("NS2Gamerules", {})
