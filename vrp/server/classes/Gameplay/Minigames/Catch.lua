-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
CatchGame = inherit(Object)
CatchGame.Map = {}

addRemoteEvents{"catchQuestion", "catchQuestionAccept", "catchQuestionDecline"}

function CatchGame:constructor(hostPlayer, targetPlayer)
	CatchGame.Map[hostPlayer] = self
	CatchGame.Map[targetPlayer] = self

	self.m_Players = {hostPlayer, targetPlayer}
	self.m_PlayerEnemy = {}
	self.m_PlayerEnemy[hostPlayer] = targetPlayer
	self.m_PlayerEnemy[targetPlayer] = hostPlayer

	hostPlayer:sendInfo("Das Fangen beginnt in 5 Sekunden!")
	targetPlayer:sendInfo("Das Fangen beginnt in 5 Sekunden!")

	self.m_CatchMarker = createMarker(0, 0, 0, "arrow", .4, 255, 80, 0, 125)
	self.m_CatchSphere = createColSphere(0, 0, 0, 1)

	self.m_OnColShapeHit = bind(CatchGame.onColShapeHit, self)
	addEventHandler("onColShapeHit", self.m_CatchSphere, self.m_OnColShapeHit)

	setTimer(function() self:startup() end, 5000, 1)
	setTimer(function() self:timesup() end, 95000, 1)
end

function CatchGame:destructor()
	CatchGame.Map[self.m_Players[1]] = nil
	CatchGame.Map[self.m_Players[2]] = nil

	self.m_CatchMarker:destroy()
	self.m_CatchSphere:destroy()
end

function CatchGame:startup()
	self.m_CatchingPlayer = self.m_Players[math.random(1, 2)]

	self.m_CatchingPlayer:sendInfo(("Du bist an der Reihe und musst %s fangen!"):format(self.m_PlayerEnemy[self.m_CatchingPlayer].name))
	self.m_PlayerEnemy[self.m_CatchingPlayer]:sendInfo(("%s ist an der Reihe und muss dich fangen!"):format(self.m_CatchingPlayer.name))

	self.m_CatchingPlayer:triggerEvent("Countdown", 90, "Fangen")
	self.m_PlayerEnemy[self.m_CatchingPlayer]:triggerEvent("Countdown", 90, "Fangen")

	self.m_CatchSphere:attach(self.m_PlayerEnemy[self.m_CatchingPlayer])
	self.m_CatchMarker:attach(self.m_CatchingPlayer, 0, 0, 1.5)
end

function CatchGame:timesup()
	self.m_CatchingPlayer:sendInfo(("Die Zeit ist um!\nDu hast gegen %s verloren!"):format(self.m_PlayerEnemy[self.m_CatchingPlayer].name))
	self.m_PlayerEnemy[self.m_CatchingPlayer]:sendInfo(("Die Zeit ist um!\nDu hast gegen %s gewonnen!"):format(self.m_CatchingPlayer.name))

	delete(self)
end

function CatchGame:onColShapeHit(hitElement, matchDimension)
	if self.m_LastHit and getTickCount() - self.m_LastHit < 1000 then return end

	if hitElement == self.m_CatchingPlayer then
		self.m_LastHit = getTickCount()

		hitElement:sendInfo(("Du hast %s gefangen!"):format(self.m_PlayerEnemy[hitElement].name))
		self.m_PlayerEnemy[hitElement]:sendInfo(("Du wurdest von %s gefangen!"):format(hitElement.name))

		self.m_CatchingPlayer = self.m_PlayerEnemy[self.m_CatchingPlayer]

		self.m_CatchSphere:destroy() -- duno why.. otherwise server will crash or freeze (NT)
		self.m_CatchSphere = createColSphere(0, 0, 0, 1)

		self.m_CatchSphere:attach(self.m_PlayerEnemy[self.m_CatchingPlayer])
		self.m_CatchMarker:attach(self.m_CatchingPlayer, 0, 0, 1.5)

		addEventHandler("onColShapeHit", self.m_CatchSphere, self.m_OnColShapeHit)
	end
end

addEventHandler("catchQuestionAccept", root,
	function(host)
		host.catchRequestSend = false

		if CatchGame.Map[host] or CatchGame.Map[client] then
			host:sendError("Du oder dein Gegner ist noch in einem Spiel!")
			return
		end

		CatchGame:new(host, client)
	end
)

addEventHandler("catchQuestionDecline", root,
	function(host)
		if host.catchRequestSend then
			host:sendError(_("Der Spieler %s hat abgelehnt!", host, client.name))
			host.catchRequestSend = false
		end
	end
)

addEventHandler("catchQuestion", root,
	function(target)
		if client.catchRequestSend then client:sendError(_("Du hast bereits eine Anfrage an einen Spieler gesendet", client)) return end
		client:sendShortMessage(_("Du hast eine Anfrage an %s gesendet!", client, target:getName()))
		client.catchRequestSend = true
		target:triggerEvent("onAppDashboardGameInvitation", client, "Fangen!", "catchQuestionAccept", "catchQuestionDecline", client)
	end
)
