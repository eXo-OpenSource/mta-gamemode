-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/ColorCars/ColorCarsManager.lua
-- *  PURPOSE:     ColorCarsManager class
-- *
-- ****************************************************************************

ColorCarsManager = inherit(Singleton)

function ColorCarsManager:constructor()
    addRemoteEvents{"ColorCars:createLobby", "ColorCars:requestClientLobbyInfos", "ColorCars:addPlayerToLobby", "ColorCars:checkPassword", "ColorCars:checkIsLobbyFull", "ColorCars:removePlayerFromLobby", "ColorCars:requestMatchGUIInfos", "ColorCars:changeCatcher"}

    self.m_ColorCarsMarker = createMarker(2695.80, -1706.67, 10.9, "cylinder", 1, 255, 255, 255)
    self.m_ColorCarsColShape = createColSphere(2695.80, -1706.67, 10.9, 2)
    self.m_ColorCarsBlip = Blip:new("ColorCars.png", 2695.80, -1706.67)
    self.m_ColorCarsBlip:setDisplayText("ColorCars-Arena", BLIP_CATEGORY.Leisure)

    self.m_ColorCarsLobby = {}

    addEventHandler("onColShapeHit", self.m_ColorCarsColShape, bind(self.Event_onColShapeHit, self))
    addEventHandler("ColorCars:addPlayerToLobby", root, bind(self.addPlayerToLobby, self))
    addEventHandler("ColorCars:requestClientLobbyInfos", root, bind(self.Event_sendLobbyInfos, self))
    addEventHandler("ColorCars:createLobby", root, bind(self.Event_createLobby, self))
    addEventHandler("ColorCars:checkPassword", root, bind(self.Event_sendCheckPasswordResult, self))
    addEventHandler("ColorCars:checkIsLobbyFull", root, bind(self.Event_sendCheckIsLobbyFullResult, self))
    addEventHandler("ColorCars:removePlayerFromLobby", root, bind(self.Event_removePlayerFromLobby, self))
    addEventHandler("ColorCars:requestMatchGUIInfos", root, bind(self.syncMatchGUI, self))
    addEventHandler("ColorCars:changeCatcher", root, bind(self.Event_changeCatcher, self))
end

function ColorCarsManager:Event_onColShapeHit(hitElement, matchingDim)
    if hitElement:getType() == "player" and matchingDim then
        hitElement:triggerEvent("ColorCars:createLobbyGUI", self.m_ColorCarsEnterMarker)
    end
end

function ColorCarsManager:Event_createLobby(lobbyName, password, maxPlayers)
    local lobbyOwner = client
    self.m_ColorCarsLobby[lobbyOwner] = ColorCars:new(lobbyOwner, lobbyName, password, maxPlayers)
    

    self:addPlayerToLobby(lobbyOwner, lobbyOwner)

    StatisticsLogger:getSingleton():addColorCarsLog(client, lobbyName, password, maxPlayers)
end

function ColorCarsManager:deleteLobby(lobby)
    self.m_ColorCarsLobby[lobby] = nil
end

function ColorCarsManager:addPlayerToLobby(lobby, player)
    self.m_ColorCarsLobby[lobby]:addPlayer(player)


    player:takeAllWeapons()

    self:syncMatchGUI(lobby)
end

function ColorCarsManager:Event_removePlayerFromLobby(lobby, player)
    self.m_ColorCarsLobby[lobby]:removePlayer(player)
end

function ColorCarsManager:changeOwner(oldOwner, newOwner)
    self.m_ColorCarsLobby[newOwner] = self.m_ColorCarsLobby[oldOwner]
    self.m_ColorCarsLobby[oldOwner] = nil
    
    for i, player in ipairs(self.m_ColorCarsLobby[newOwner].m_Players) do
        player:triggerEvent("ColorCars:changeLobbyOwner", newOwner)
    end
end

function ColorCarsManager:Event_changeCatcher(lobby, newCatcher)
    local oldCatcher = client
    self.m_ColorCarsLobby[lobby]:checkIfNewCatcherIsValid(oldCatcher, newCatcher)
end

function ColorCarsManager:syncNewCatcher(lobby, newCatcher)
    local players = self.m_ColorCarsLobby[lobby].m_Players
    for i, player in ipairs(players) do
        player:triggerEvent("ColorCars:syncNewCatcher", newCatcher)
    end
end
function ColorCarsManager:syncMatchGUI(lobby)
    if not self.m_ColorCarsLobby[lobby] then return end
        
    local infos = self.m_ColorCarsLobby[lobby].m_Players
    local score = self.m_ColorCarsLobby[lobby].m_PlayerCatchScore
    local catcher = self.m_ColorCarsLobby[lobby].m_Catcher
    for i, player in ipairs(infos) do
        player:triggerEvent("ColorCars:syncMatchGUI", infos, catcher, score)
    end
end

function ColorCarsManager:Event_sendLobbyInfos()
    local temptable = {}
    for i, v in pairs(self.m_ColorCarsLobby) do
        temptable[i] = {["Lobbyname"] = v.m_LobbyName, ["Players"] = #v.m_Players, ["hasPassword"] = #v.m_LobbyPassword > 0, ["maxPlayers"] = v.m_MaxPlayers}
    end
    client:triggerEvent("ColorCars:receiveClientLobbyInfos", temptable)
end

function ColorCarsManager:Event_sendCheckPasswordResult(lobby, password)
    client:triggerEvent("ColorCars:receivePasswordCheckResult", self.m_ColorCarsLobby[lobby]:checkPassword(password))
end

function ColorCarsManager:Event_sendCheckIsLobbyFullResult(lobby)
    if not self.m_ColorCarsLobby[lobby] then return client:triggerEvent("ColorCars:sendLobbyNotFoundMessage") end

    client:triggerEvent("ColorCars:receiveMaxPlayersCheckResult", self.m_ColorCarsLobby[lobby]:isLobbyFull())
end