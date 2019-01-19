-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Minigames/Pong.lua
-- *  PURPOSE:     Pong Game - Server
-- *
-- ****************************************************************************
Pong = inherit(Object)
addRemoteEvents{"pongQuestion", "pongQuestionAccept", "pongQuestionDecline", "pongPlayerReady", "pongPlayerMove", "pongPlayerFailed", "pongPlayerLeave"}

Pong.Map = {}

function Pong:constructor(ePlayerHost, ePlayerTarget, bFastGame)
    --outputChatBox(("Game created. \nHost: %s\nTarget: %s"):format(tostring(getPlayerName(ePlayerHost)), tostring(getPlayerName(ePlayerTarget)))) --TODO: DEV
    Pong.Map[ePlayerHost] = self
    Pong.Map[ePlayerTarget] = self

    self.m_PlayerEnemy = {}
    self.m_PlayerEnemy[ePlayerHost] = ePlayerTarget
    self.m_PlayerEnemy[ePlayerTarget] = ePlayerHost

    self.m_Players = {ePlayerHost, ePlayerTarget}
    self.m_PlayersReady = {}

    self:createGameplay()

    ePlayerHost:triggerEvent("pongGameSession", ePlayerTarget, "host", {self.m_Points, self.m_FirstDirectionX, self.m_FirstDirectionY})
    ePlayerTarget:triggerEvent("pongGameSession", ePlayerHost, "target", {self.m_Points, self.m_FirstDirectionX, self.m_FirstDirectionY})

    --ePlayerHost:setFrozen(true)
    --ePlayerTarget:setFrozen(true)

    self.m_State = "idle"
end

function Pong:destructor()
	self.m_Players[1]:triggerEvent("pongSetGameState", "close")
	self.m_Players[2]:triggerEvent("pongSetGameState", "close")
	self.m_Players[1].pongPlaying = false
	self.m_Players[2].pongPlaying = false
end

function Pong:createGameplay()
    self.m_Points = {}
    self.m_Points[self.m_Players[1]] = 0
    self.m_Points[self.m_Players[2]] = 0

    self.m_FirstDirectionX = math.random(1,2) == 1 and "host" or "target"
    self.m_FirstDirectionY = math.floor(math.random(1, 100)/100 + 0.5) == 0 --true = "up" | false = "down"
end

function Pong:checkReady()
    if #self.m_PlayersReady == 2 then
        self.m_State = "play"
        self.m_Players[1]:triggerEvent("pongSetGameState", "play")
        self.m_Players[2]:triggerEvent("pongSetGameState", "play")
    end
end

function Pong:isPlayerReady(ePlayer)
    for _, v in pairs(self.m_PlayersReady) do
       if v == ePlayer then return true end
    end
end

-- PongLobby

-- Managing

addEventHandler("pongPlayerLeave", root,
	function()
		local instance = Pong.Map[client]

		if instance then
			delete(instance)
		end
	end
)

addEventHandler("pongPlayerMove", resourceRoot,
    function(isMoving, direction_or_position)
        local instance = Pong.Map[client]

        if isMoving then
            instance.m_PlayerEnemy[client]:triggerEvent("pongInterpolateEnemyPosition", direction_or_position)
        else
            instance.m_PlayerEnemy[client]:triggerEvent("pongSetEnemyPosition", direction_or_position)
        end
    end
)

addEventHandler("pongPlayerFailed", resourceRoot,
    function()
        local instance = Pong.Map[client]

        instance.m_PlayerEnemy[client]:triggerEvent("pongSetGameState", "failed")

        instance.m_Points[instance.m_PlayerEnemy[client]] = instance.m_Points[instance.m_PlayerEnemy[client]] + 1

        instance.m_FirstDirectionX = math.random(1,2) == 1 and "host" or "target"
        instance.m_Players[1]:triggerEvent("pongUpdateGameplay", instance.m_Points, instance.m_FirstDirectionX, instance.m_FirstDirectionY)
        instance.m_Players[2]:triggerEvent("pongUpdateGameplay", instance.m_Points, instance.m_FirstDirectionX, instance.m_FirstDirectionY)

        setTimer(
			function(instance, player)
				if instance.m_Points[instance.m_PlayerEnemy[player]] >= 10 then
				   	local playerWon = instance.m_PlayerEnemy[player]
					instance.m_Players[1]:triggerEvent("pongSetGameState", "playerWon", playerWon)
					instance.m_Players[2]:triggerEvent("pongSetGameState", "playerWon", playerWon)

					setTimer(function(player) delete(Pong.Map[player]) end, 3000, 1, player)
					return
				end

				instance.m_Players[1]:triggerEvent("pongSetGameState", "ready")
				instance.m_Players[2]:triggerEvent("pongSetGameState", "ready")

				setTimer(
					function(instance)
						instance.m_Players[1]:triggerEvent("pongSetGameState", "play")
						instance.m_Players[2]:triggerEvent("pongSetGameState", "play")
					end, 3000, 1, instance
				)
        	end, 3000, 1, instance, client
		)
    end
)

addEventHandler("pongPlayerReady", resourceRoot,
    function()
        local instance = Pong.Map[client]
        if not instance:isPlayerReady(client) then
            table.insert(instance.m_PlayersReady, client)
        end

        instance:checkReady()
    end
)

addEventHandler("pongQuestionAccept", root,
	function(host)
		Pong:new(host, client)

		client.pongPlaying = true
		host.pongSendRequest = false
	end
)

addEventHandler("pongQuestionDecline", root,
	function(host)
		if host.pongSendRequest then
			host:sendError(_("Der Spieler %s hat abgelehnt!", host, client.name))
			host.pongSendRequest = false
		end
	end
)

addEventHandler("pongQuestion", root,
    function(target)
		if client.pongSendRequest then client:sendError(_("Du hast dem Spieler bereits eine Anfrage gesendet", client)) return end
		client:sendShortMessage(_("Du hast eine Pong-Anfrage an %s gesendet!", client, target:getName()))
		client.pongSendRequest = true
		target:triggerEvent("onAppDashboardGameInvitation", client, "Pong!", "pongQuestionAccept", "pongQuestionDecline", client)
	end
)
