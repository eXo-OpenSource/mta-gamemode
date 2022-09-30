-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/ColorCars/ColorCarsManager.lua
-- *  PURPOSE:     ColorCarsManager class
-- *
-- ****************************************************************************

ColorCarsManager = inherit(Singleton)
ColorCarsManager.Lobbys = {}
function ColorCarsManager:constructor()
    addRemoteEvents{"ColorCars:createLobby", "ColorCars:requestClientLobbyInfos", "ColorCars:addPlayerToLobby", "ColorCars:checkPassword", "ColorCars:checkIsLobbyFull", "ColorCars:removePlayerFromLobby", "ColorCars:requestMatchGUIInfos", "ColorCars:changeCatcher"}

    self.m_BankServer = BankServer.get("gameplay.colorcars") or BankServer:create("gameplay.colorcars")

    self:loadServerLobbys()
    self.m_ColorCarsMarker = createMarker(2695.80, -1706.67, 10.9, "cylinder", 1, 255, 255, 255)
    self.m_ColorCarsColShape = createColSphere(2695.80, -1706.67, 10.9, 2)
    self.m_ColorCarsBlip = Blip:new("ColorCars.png", 2695.80, -1706.67)
    self.m_ColorCarsBlip:setDisplayText("ColorCars-Arena", BLIP_CATEGORY.Leisure)

    addEventHandler("onColShapeHit", self.m_ColorCarsColShape, bind(self.Event_onColShapeHit, self))
    addEventHandler("ColorCars:addPlayerToLobby", root, bind(self.addPlayerToLobby, self))
    addEventHandler("ColorCars:requestClientLobbyInfos", root, bind(self.Event_sendLobbyInfos, self))
    addEventHandler("ColorCars:createLobby", root, bind(self.createPlayerLobby, self))
    addEventHandler("ColorCars:checkPassword", root, bind(self.Event_sendCheckPasswordResult, self))
    addEventHandler("ColorCars:checkIsLobbyFull", root, bind(self.Event_sendCheckIsLobbyFullResult, self))
    addEventHandler("ColorCars:removePlayerFromLobby", root, bind(self.Event_removePlayerFromLobby, self))
    addEventHandler("ColorCars:requestMatchGUIInfos", root, bind(self.syncMatchGUI, self))
    addEventHandler("ColorCars:changeCatcher", root, bind(self.Event_changeCatcher, self))

    Player.getChatHook():register(
		function(player, text, type)
			if player.colorCarsLobby then
				return player.colorCarsLobby:onPlayerChat(player, text, type)
			end
		end
	)

    Player.getQuitHook():register(
		function(player)
			if player.colorCarsLobby then
				player.colorCarsLobby:removePlayer(player)
			end
		end
	)

    PlayerManager:getSingleton():getWastedHook():register(
		function(player, killer, weapon)
			if player.colorCarsLobby then
                player.colorCarsLobby:removePlayer(player)
            end
		end
	)
    
    PlayerManager:getSingleton():getAFKHook():register(
		function(player)
			if player.colorCarsLobby then
				player.colorCarsLobby:removePlayer(player)
			end
		end
	)

    core:getStopHook():register(
		function()
			for id, lobby in pairs(ColorCarsManager.Lobbys) do
				for i, player in pairs(lobby.m_Players) do
					lobby:removePlayer(player)
				end
			end
		end
	)
end

function ColorCarsManager:loadServerLobbys()
    self:createLobby("Server1", "ColorCars Lobby #1", "", 15, true)
    self:createLobby("Server2", "ColorCars Lobby #2", "", 15, true)
    self:createLobby("Server3", "ColorCars Lobby #3", "", 15, true)
end

function ColorCarsManager:Event_onColShapeHit(hitElement, matchingDim)
    if hitElement:getType() == "player" and matchingDim and hitElement:isLoggedIn() and not hitElement.inVehicle then
        hitElement:triggerEvent("ColorCars:createLobbyGUI", self.m_ColorCarsMarker) 
    end
end

function ColorCarsManager:createLobby(lobbyOwner, lobbyName, password, maxPlayers, isServer)
    ColorCarsManager.Lobbys[lobbyOwner] = ColorCars:new(lobbyOwner, lobbyName, password, maxPlayers, isServer)
    StatisticsLogger:getSingleton():addColorCarsLog(isServer and 0 or lobbyOwner:getId(), lobbyName, password, maxPlayers, isServer)
end

function ColorCarsManager:createPlayerLobby(lobbyOwner, lobbyName, password, maxPlayers)
    if lobbyOwner:isFactionDuty() and lobbyOwner:getFaction():isStateFaction() then
		lobbyOwner:sendError(_("Du darfst im Dienst nicht in eine ColorCars Lobby!", lobbyOwner))
		return
	end

    if lobbyOwner:getMoney() >= 1000 then 
        lobbyOwner:transferMoney(self.m_BankServer, 1000, "ColorCars Lobby", "Gameplay", "ColorCars")
    else
        return lobbyOwner:sendError(_("Du hast nicht genug Geld dabei. (1000$)", lobbyOwner)) 
    end
    self:createLobby(lobbyOwner, lobbyName, password, maxPlayers, false)
    ColorCarsManager.Lobbys[lobbyOwner]:addPlayer(lobbyOwner)
    lobbyOwner:sendSuccess(_("Lobby erstellt!", lobbyOwner))
end

function ColorCarsManager:deleteLobby(lobby)
    ColorCarsManager.Lobbys[lobby] = nil
end

function ColorCarsManager:addPlayerToLobby(lobby, player)
	if player:isFactionDuty() and player:getFaction():isStateFaction() then
		player:sendError(_("Du darfst im Dienst nicht in eine ColorCars Lobby!", player))
		return
	end

    ColorCarsManager.Lobbys[lobby]:addPlayer(player)
end

function ColorCarsManager:Event_removePlayerFromLobby(lobby, player)
    ColorCarsManager.Lobbys[lobby]:removePlayer(player)
end

function ColorCarsManager:changeOwner(oldOwner, newOwner)
    ColorCarsManager.Lobbys[newOwner] = ColorCarsManager.Lobbys[oldOwner]
    ColorCarsManager.Lobbys[oldOwner] = nil
    
    for i, player in ipairs(ColorCarsManager.Lobbys[newOwner].m_Players) do
        player:triggerEvent("ColorCars:changeLobbyOwner", newOwner)
    end
end

function ColorCarsManager:Event_changeCatcher(lobby, newCatcher)
    local oldCatcher = client
    ColorCarsManager.Lobbys[lobby]:checkIfNewCatcherIsValid(oldCatcher, newCatcher)
end

function ColorCarsManager:syncNewCatcher(lobby, newCatcher)
    local players = ColorCarsManager.Lobbys[lobby].m_Players
    for i, player in ipairs(players) do
        player:triggerEvent("ColorCars:syncNewCatcher", newCatcher)
    end
end
function ColorCarsManager:syncMatchGUI(lobby)
    if not ColorCarsManager.Lobbys[lobby] then return end
        
    local infos = ColorCarsManager.Lobbys[lobby].m_Players
    local score = ColorCarsManager.Lobbys[lobby].m_PlayerCatchScore
    local catcher = ColorCarsManager.Lobbys[lobby].m_Catcher
    for i, player in ipairs(infos) do
        player:triggerEvent("ColorCars:syncMatchGUI", infos, catcher, score)
    end
end

function ColorCarsManager:Event_sendLobbyInfos()
    local temptable = {}
    local id = 1
    for i, v in pairs(ColorCarsManager.Lobbys) do
        temptable[id] = {["LobbyOwner"] = i, ["LobbyName"] = v.m_LobbyName, ["Players"] = #v.m_Players, ["hasPassword"] = #v.m_LobbyPassword > 0, ["maxPlayers"] = v.m_MaxPlayers}
        id = id + 1
    end
    client:triggerEvent("ColorCars:receiveClientLobbyInfos", temptable)
end

function ColorCarsManager:Event_sendCheckPasswordResult(lobby, password)
    if not ColorCarsManager.Lobbys[lobby] then
        client:sendError(_("Keine Lobby gefunden.", client))
        client:triggerEvent("ColorCars:createLobbyGUI", self.m_ColorCarsMarker) 
    end

    client:triggerEvent("ColorCars:receivePasswordCheckResult", ColorCarsManager.Lobbys[lobby]:checkPassword(password))
end

function ColorCarsManager:Event_sendCheckIsLobbyFullResult(lobby)
    if not ColorCarsManager.Lobbys[lobby] then
        client:sendError(_("Keine Lobby gefunden.", client))
        client:triggerEvent("ColorCars:createLobbyGUI", self.m_ColorCarsMarker) 
    end

    client:triggerEvent("ColorCars:receiveMaxPlayersCheckResult", ColorCarsManager.Lobbys[lobby]:isLobbyFull())
end