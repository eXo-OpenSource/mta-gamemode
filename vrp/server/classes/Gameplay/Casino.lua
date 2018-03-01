-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Casino.lua
-- *  PURPOSE:     Casino singleton class
-- *
-- ****************************************************************************
Casino = inherit(Singleton)
Casino.MultiPlayerGameNames = {["chess"] = "Schach"}

function Casino:constructor()
	-- Small Gaming Hall
	InteriorEnterExit:new(Vector3(841.74316 ,-1597.21240 ,13.54688), Vector3(1092.33630, 34.41832, 1098.86780), 0, 0, 12, 2)
	self.m_GameHallCol = createColSphere(1098.79, 22.75, 1098.87, 75)
	self.m_GameHallCol:setInterior(12)
	self.m_GameHallCol:setDimension(2)
	self.m_Chess = createMarker(1103.95, 30.00, 1099.3, "cylinder", 1, 0, 0, 0, 255)
	self.m_Chess:setInterior(12)
	self.m_Chess:setDimension(2)
	addEventHandler("onMarkerHit", self.m_Chess, bind(self.onChessMarkerHit, self))

	addRemoteEvents{"casinoStartMultiplayerGame", "acceptMultiplayerGame", "declineMultiplayerGame"}
	addEventHandler("casinoStartMultiplayerGame", root, bind(self.startMultiplayerGame, self))
	addEventHandler("acceptMultiplayerGame", root, bind(self.acceptMultiplayerGame, self))
	addEventHandler("declineMultiplayerGame", root, bind(self.declineMultiplayerGame, self))

	--Four Dragons Casino
	InteriorEnterExit:new(Vector3(2019.85, 1007.72, 10.82), Vector3(2018.48, 1017.86, 996.88), 90, 270, 10)
	self.m_Blip = Blip:new("Casino.png", 2019.85, 1007.72, root, 300)
	self.m_Blip:setDisplayText("Casino", BLIP_CATEGORY.Leisure)
	self.m_Blip:setOptionalColor({238, 226, 200})

	-- Caligulas Casino
	InteriorEnterExit:new(Vector3(2196.34, 1677.16, 12.37), Vector3(2233.99, 1714.685, 1012.38), 180, 90, 1)
	self.m_Blip = Blip:new("Casino.png", 2196.34, 1677.16, root, 300)
	self.m_Blip:setDisplayText("Casino", BLIP_CATEGORY.Leisure)
	self.m_Blip:setOptionalColor({238, 226, 200})

	Slotmachine:new(2244.2177734375, 1634.9814453125, 1008.7, 0, 0, 307.98718261719,1)
	Slotmachine:new(2228.0625, 1635.673828125, 1008.7, 0, 0, 47.892883300781,1)
	Slotmachine:new(2247.1669921875, 1594.1533203125, 1006.5, 0, 0, 90,1)
	Slotmachine:new(2247.169921875, 1587.5537109375, 1006.5, 0, 0, 90,1)
	Slotmachine:new(2214.0537109375, 1603.6689453125, 1006.7553955078, 0, 0, 90,1)
	Slotmachine:new(2278.8876953125, 1617.419921875, 1006.7782836914, 0, 0, 270,1)
	Slotmachine:new(2253.544921875, 1632.1376953125, 1008.959375, 0, 0, 0,1)
	Slotmachine:new(2260.9892578125, 1632.140625, 1008.959375, 0, 0, 360,1)
	Slotmachine:new(2222.984375, 1632.1484375, 1008.959375, 0, 0, 360,1)
	Slotmachine:new(2214.33984375, 1632.1474609375, 1008.959375, 0, 0, 360,1)
	Slotmachine:new(2223.2060546875, 1571.296875, 1008.959375, 0, 0, 120,1)
	Slotmachine:new(2229.0947265625, 1563.3232421875, 1008.959375, 0, 0, 120,1)
	--Four Dragons
	Slotmachine:new(1957.8083, 1048.6704, 993.01453, 0, 0, 144.97, 10)
    Slotmachine:new(1957.1588, 1047.8843, 993.01453, 0, 0, 324.683, 10)
    Slotmachine:new(1961.726, 1043.1682, 993.01453, 0, 0, 303.471, 10)
    Slotmachine:new(1962.623, 1043.6582, 993.01453, 0, 0, 123.188, 10)
    Slotmachine:new(1965.338, 1037.3625, 993.01453, 0, 0, 101.337, 10)
    Slotmachine:new(1964.3151, 1037.2369, 993.01453, 0, 0, 281.614, 10)
    Slotmachine:new(1964.3154, 998.3501, 993.01453, 0, 0, 258.756, 10)
    Slotmachine:new(1965.3025, 998.07861, 993.01453, 0, 0, 79.037, 10)
    Slotmachine:new(1962.6294, 991.72491, 993.01453, 0, 0, 54.838, 10)
    Slotmachine:new(1961.8351, 992.38422, 993.01453, 0, 0, 235.115, 10)
    Slotmachine:new(1957.1981, 987.87317, 993.01453, 0, 0, 213.529, 10)
    Slotmachine:new(1957.6958, 986.97644, 993.01453, 0, 0, 33.243, 10)

	if EVENT_EASTER then
		EasterSlotmachine:new(1484.71, -1779.22, 14, 0, 0, 0, 0, 0)
		EasterSlotmachine:new(1496.80, -1779.20, 14, 0, 0, 0, 0, 0)
		EasterSlotmachine:new(1496.69, -1796.03, 14, 0, 0, 180, 0, 0)
		EasterSlotmachine:new(1485.75, -1795.99, 14, 0, 0, 180, 0, 0)
		EasterSlotmachine:new(1474.80, -1796.03, 14, 0, 0, 180, 0, 0)
		EasterSlotmachine:new(1464.18, -1796.03, 14, 0, 0, 180, 0, 0)
		EasterSlotmachine:new(1452.44, -1789.24, 14, 0, 0, 90, 0, 0)
		EasterSlotmachine:new(1464.05, -1779.20, 14, 0, 0, 0, 0, 0)
		EasterSlotmachine:new(1475.17, -1779.20, 14, 0, 0, 0, 0, 0)
	end
end

function Casino:onChessMarkerHit(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		hitElement:triggerEvent("openChessGui", self.m_GameHallCol)
	end
end

function Casino:startMultiplayerGame(game, target)
	if target and isElement(target) then
		QuestionBox:new(client, target, _("Möchtest du mit %s eine Runde %s spielen?", target, client:getName(), Casino.MultiPlayerGameNames[game]), "acceptMultiplayerGame", "declineMultiplayerGame", client, target, game)
		client:sendShortMessage(_("Du hast eine %s-Anfrage an %s gesendet!", client, Casino.MultiPlayerGameNames[game], target:getName()))
	else
		client:sendInfo(_("Spieler nicht gefunden!", client))
	end
end

function Casino:acceptMultiplayerGame(player, target, game)
	if player and isElement(player) and target and isElement(target) then
		if player:isWithinColShape(self.m_GameHallCol) and target:isWithinColShape(self.m_GameHallCol) then
			player:sendShortMessage(_("%s hat die %s-Anfrage akzeptiert!", player, target:getName(), Casino.MultiPlayerGameNames[game]))
			target:sendShortMessage(_("Du hast die %s-Anfrage von %s akzeptiert!", target, Casino.MultiPlayerGameNames[game], target:getName()))
			if game == "chess" then
				ChessSessionManager:getSingleton():Event_newGame(player, target)
			else
				target:sendError(_("Unbekanntes Spiel!", target))
				target:sendError(_("Unbekanntes Spiel!", target))
			end
		else
			player:sendWarning(_("Du oder dein Partner ist nicht mehr in der Halle!", player))
			target:sendWarning(_("Du oder dein Partner ist nicht mehr in der Halle!", target))
		end
	else
		player:sendWarning(_("Dein Spielpartner ist offline gegangen!", player))
		target:sendWarning(_("Dein Spielpartner ist offline gegangen!", target))
	end
end

function Casino:declineMultiplayerGame(player, target, game)
	player:sendShortMessage(_("%s hat die %s-Anfrage abgelehnt!", player, target:getName(), Casino.MultiPlayerGameNames[game]))
	target:sendShortMessage(_("Du hast die %s-Anfrage von %s abgelehnt!", target, Casino.MultiPlayerGameNames[game], target:getName()))

end
