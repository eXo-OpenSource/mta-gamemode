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

	self.m_OnPlayerDamage = bind(CatchGame.onPlayerDamage, self)
	addEventHandler("onPlayerDamage", root, self.m_OnPlayerDamage)

	setTimer(function() self:startup() end, 5000, 1)
	setTimer(function() self:timesup() end, 65000, 1)
end

function CatchGame:destructor()
	CatchGame.Map[self.m_Players[1]] = nil
	CatchGame.Map[self.m_Players[2]] = nil

	self.m_CatchMarker:destroy()
	removeEventHandler("onPlayerDamage", root, self.m_OnPlayerDamage)
end

function CatchGame:startup()
	self.m_CatchingPlayer = self.m_Players[math.random(1, 2)]

	self.m_CatchingPlayer:sendInfo(("Du bist an der Reihe und musst %s fangen!"):format(self.m_PlayerEnemy[self.m_CatchingPlayer].name))
	self.m_PlayerEnemy[self.m_CatchingPlayer]:sendInfo(("%s ist an der Reihe und muss dich fangen!"):format(self.m_CatchingPlayer.name))

	self.m_CatchingPlayer:triggerEvent("Countdown", 60, "Fangen")
	self.m_PlayerEnemy[self.m_CatchingPlayer]:triggerEvent("Countdown", 60, "Fangen")

	self.m_CatchMarker:attach(self.m_CatchingPlayer, 0, 0, 1.5)
end

function CatchGame:timesup()
	self.m_CatchingPlayer:sendInfo(("Die Zeit ist um!\nDu hast gegen %s verloren!"):format(self.m_PlayerEnemy[self.m_CatchingPlayer].name))
	self.m_PlayerEnemy[self.m_CatchingPlayer]:sendInfo(("Die Zeit ist um!\nDu hast gegen %s gewonnen!"):format(self.m_CatchingPlayer.name))

	delete(self)
end

function CatchGame:onPlayerDamage(attacker, attackerweapon, bodypart, loss)
	if attackerweapon == 0 and (attacker == self.m_CatchingPlayer and source == self.m_PlayerEnemy[attacker]) then
		if source:getArmor() > 0 then
			source:setArmor(source:getArmor() + loss)
		else
			source:setHealth(source:getHealth() + loss)
		end

		attacker:sendInfo(("Du hast %s gefangen!"):format(source.name))
		source:sendInfo(("Du wurdest von %s gefangen!"):format(attacker.name))

		self.m_CatchingPlayer = source
		self.m_CatchMarker:attach(self.m_CatchingPlayer, 0, 0, 1.5)
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
