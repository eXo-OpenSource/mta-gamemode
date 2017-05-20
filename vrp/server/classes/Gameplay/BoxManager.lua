-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/BoxManager.lua
-- *  PURPOSE:     Boxing Manager class
-- *
-- ****************************************************************************
BoxManager = inherit(Singleton)
BoxManager.Data = {
	[1] = {
		["BoxPos"] = Vector3(758.67, 2.57, 1001.59),
		["BoxRot"] = 214.80,
		["SpawnPos"] = Vector3(763.67, 4.44, 1000.71),
		["Skin"] = 81
	},
	[2] = {
		["BoxPos"] = Vector3(762.90, -1.63, 1001.59),
		["BoxRot"] = 44.80,
		["SpawnPos"] = Vector3(764.03, 7.27, 1000.72),
		["Skin"] = 80
	}
}

function BoxManager:constructor()
	InteriorEnterExit:new(Vector3(2229.85, -1721.20, 13.56), Vector3(772.45, -5.16, 1000.73), 130, 0, 5)
	self.m_Marker = createMarker(761.66, 5.27, 1000, "cylinder", 1, 255, 0, 0, 200)
	self.m_Marker:setInterior(5)
	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onMarkerHit, self))


	self.m_BoxHallCol = createColSphere(761.66, 5.27, 1000, 30)
	self.m_BoxHallCol:setInterior(5)

	addRemoteEvents{"boxingRequestFight", "boxingAcceptFight", "boxingDeclineFight"}
	addEventHandler("boxingRequestFight", root, bind(self.requestFight, self))
	addEventHandler("boxingAcceptFight", root, bind(self.acceptFight, self))
	addEventHandler("boxingDeclineFight", root, bind(self.declineFight, self))

	PlayerManager:getSingleton():getWastedHook():register(
		function(player, killer, weapon)
			if player.boxing then
				player:triggerEvent("abortDeathGUI", true)
				self:onWasted(player)
				self:respawnPlayer(player, killer)
				return true
			end
		end
	)

	Player.getQuitHook():register(
		function(player)
			if player.boxing then
				self:onWasted(player)
			end
		end
	)

	self.m_BoxFight = {
		["active"] = false,
		["players"]= false,
		["money"]= 0
	}

end

function BoxManager:onMarkerHit(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		if hitElement:isFactionDuty() or hitElement:isCompanyDuty() then hitElement:sendError("Du kannst diese Aktion im Dienst nicht ausüben!") return end
		hitElement:triggerEvent("openBoxingGUI", self.m_BoxHallCol)
	end
end

function BoxManager:requestFight(target, moneyId)
	if not self.m_BoxFight["active"] then
		local money = BOXING_MONEY[moneyId]
		if client:getMoney() >= money then
			if target:getMoney() >= money then
				if target:isFactionDuty() or target:isCompanyDuty() then client:sendError("Der Spieler ist im Dienst und kann diese Aktion nicht ausüben!") return end

				QuestionBox:new(client, target, _("Möchtest du gegen %s eine Runde Boxen? Einsatz: %d$", target, client:getName(), money), "boxingAcceptFight", "boxingDeclineFight", client, target, money)
				client:sendShortMessage(_("Du hast eine Boxkampf-Herausforderung an %s gesendet! Einsatz: %d$", client, target:getName(), money))
			else
				client:sendError(_("%s hat nicht genug Geld dabei!", client, target:getName()))
			end
		else
			client:sendError(_("Du hast nicht genug Geld dabei!", client))
		end
	else
		client:sendError(_("Der Boxring ist derzeit belegt!", client))
	end
end

function BoxManager:acceptFight(player, target, money)
	if player and isElement(player) and target and isElement(target) then
		if player:isWithinColShape(self.m_BoxHallCol) and target:isWithinColShape(self.m_BoxHallCol) then
			if player:getMoney() >= money then
				if target:getMoney() >= money then
					if not self.m_BoxFight["active"] then
						player:sendShortMessage(_("%s hat die Boxkampf-Anfrage akzeptiert!", player, target:getName()))
						target:sendShortMessage(_("Du hast die Boxkampfs-Anfrage von %s akzeptiert!", target, target:getName()))
						self:startFight(player, target, money)
					else
						client:sendError(_("Der Boxring ist derzeit belegt!", client))
						target:sendError(_("Der Boxring ist derzeit belegt!", target))
					end
				else
					client:sendError(_("%s hat nicht genug Geld dabei!", client, target:getName()))
					target:sendError(_("Du hast nicht genug Geld dabei!", target))
				end
			else
				target:sendError(_("%s hat nicht genug Geld dabei!", target, client:getName()))
				client:sendError(_("Du hast nicht genug Geld dabei!", client))
			end
		else
			player:sendWarning(_("Du oder dein Partner ist nicht mehr in der Halle!", player))
			target:sendWarning(_("Du oder dein Partner ist nicht mehr in der Halle!", target))
		end
	else
		player:sendWarning(_("Dein Boxkampf-Gegner ist offline gegangen!", player))
		target:sendWarning(_("Dein Boxkampf-Gegner ist offline gegangen!", target))
	end
end

function BoxManager:declineFight(player, target, game)
	player:sendShortMessage(_("%s hat die Boxkampf-Anfrage abgelehnt!", player, target:getName()))
	target:sendShortMessage(_("Du hast die Boxkampf-Anfrage von %s abgelehnt!", target, target:getName()))
end

function BoxManager:sendShortMessage(msg)
	for index, playerItem in pairs(self.m_BoxHallCol:getElementsWithin("player")) do
		if playerItem:getDimension() == 0 and playerItem:getInterior() == 5 then
			playerItem:sendShortMessage(msg)
		end
	end
end

function BoxManager:startFight(player1, player2, money)
	self.m_BoxFight["players"] = {player1, player2}
	self.m_BoxFight["active"] = true
	self.m_BoxFight["money"] = money

	local data
	for index, playeritem in pairs(self.m_BoxFight["players"]) do
		data = BoxManager.Data[index]
		playeritem:setPosition(data["BoxPos"])
		playeritem:setRotation(0, 0, data["BoxRot"])
		playeritem:setArmor(0)
		playeritem:setHealth(100)
		playeritem:setModel(data["Skin"])
		setPedFightingStyle(playeritem, 5)
		playeritem:takeMoney(money, "Boxkampf-Einsatz")
		playeritem.boxing = true
		takeAllWeapons(playeritem)
	end
	self:sendShortMessage(_("%s und %s haben einen Boxkampf gestartet!", player1, player1:getName(), player2:getName()))

end

function BoxManager:resetFight()
	for index, playeritem in pairs(self.m_BoxFight["players"]) do
		if playeritem and isElement(playeritem) then
			if not playeritem:isDead() then
				playeritem:setDefaultSkin()
				setPedFightingStyle(playeritem, 4)
				playeritem:setPosition(BoxManager.Data[index]["SpawnPos"])
			end
			playeritem.boxing = false

		end
	end

	self.m_BoxFight["players"] = {}
	self.m_BoxFight["active"] = false
end

function BoxManager:getOpponent(player)
	for index, playeritem in pairs(self.m_BoxFight["players"]) do
		if player ~= playeritem then
			return playeritem
		end
	end
end

function BoxManager:onWasted(looser)
	local winner = self:getOpponent(looser)
	winner:sendMessage(_("Du hast den Boxkampf gegen %s gewonnen!", winner, looser:getName()), 0, 255, 0)
	looser:sendMessage(_("Du hast den Boxkampf gegen %s verloren!", looser, winner:getName()), 0, 255, 0)
	winner:giveMoney(self.m_BoxFight["money"]*2, "Boxkampf-Gewinn")
	self:sendShortMessage(_("%s hat den Boxkampf gegen %s gewonnen!", winner, winner:getName(), looser:getName()))

	self:resetFight()
	return
end

function BoxManager:respawnPlayer(player, killer)
	player:triggerEvent("deathmatchStartDeathScreen", killer or player, false)
	fadeCamera(player, false, 2)
	player:triggerEvent("Countdown", 5, "Respawn in")
	setTimer(function()
		spawnPlayer(player, Vector3(765.34, 5.67, 1000.72), 0, 0, 5, 0)
		player:setDefaultSkin()
		player:setHealth(100)
		player:setArmor(0)
		player:setHeadless(false)
		player:setCameraTarget(player)
		player:fadeCamera(true, 1)
		setElementAlpha(player,255)
		if player.ped_deadDouble then
			if isElement(player.ped_deadDouble) then
				destroyElement(player.ped_deadDouble)
			end
		end
		player:triggerEvent("CountdownStop", "Respawn in")
	end,5000,1)
end
