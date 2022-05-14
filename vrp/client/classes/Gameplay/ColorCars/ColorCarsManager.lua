-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/ColorCarsManager.lua
-- *  PURPOSE:     ColorCarsManager class
-- *
-- ****************************************************************************

ColorCarsManager = inherit(Singleton)

function ColorCarsManager:constructor()
    addRemoteEvents{"ColorCars:createLobbyGUI", "ColorCars:receiveClientLobbyInfos", "ColorCars:receivePasswordCheckResult", "ColorCars:receiveMaxPlayersCheckResult", "ColorCars:syncMatchGUI", "ColorCars:bindVehicleCollisionEvent", "ColorCars:syncNewCatcher", "ColorCars:changeLobbyOwner", "ColorCars:sendLobbyNotFoundMessage"}
    self.m_LobbyInfos = {}
    self.m_TimeBetweenCatch = 3000

    addEventHandler("ColorCars:createLobbyGUI", root, bind(self.Event_openLobbyGUI, self))
    addEventHandler("ColorCars:receiveClientLobbyInfos", root, bind(self.Event_receiveLobbyInfos, self))
    addEventHandler("ColorCars:receivePasswordCheckResult", root, bind(self.Event_receivePasswordResult, self))
    addEventHandler("ColorCars:receiveMaxPlayersCheckResult", root, bind(self.Event_receiveMaxPlayersResult, self))
    addEventHandler("ColorCars:syncMatchGUI", root, bind(self.Event_syncMatchGUI, self))
    addEventHandler("ColorCars:bindVehicleCollisionEvent", root, bind(self.Event_bindVehicleCollisionEvent, self))
    addEventHandler("ColorCars:syncNewCatcher", root, bind(self.Event_syncNewCatcher, self))
    addEventHandler("ColorCars:changeLobbyOwner", root, bind(self.Event_changeLobbyOwner, self))
    addEventHandler("ColorCars:sendLobbyNotFoundMessage", root, bind(self.Event_sendLobbyNotFoundMessage, self))
end

function ColorCarsManager:createLobby(lobbyName, lobbyPassword, maxPlayers)
    self.m_ClickedLobby = localPlayer
    triggerServerEvent("ColorCars:createLobby", resourceRoot, lobbyName, lobbyPassword, maxPlayers)
    self:openMatchGUI()
    SuccessBox:new(_"Lobby erstellt")
    InfoBox:new(_"Sollte das Match Fenster stören, \n kannst du es jeder Zeit verschieben", 10000)
end

function ColorCarsManager:addPlayer(lobby)
    triggerServerEvent("ColorCars:addPlayerToLobby", resourceRoot, lobby, localPlayer)
    self:openMatchGUI()
    InfoBox:new(_"Lobby beigetreten")
    InfoBox:new(_"Sollte das Match Fenster stören, \n kannst du es jeder Zeit verschieben", 10000)
end

function ColorCarsManager:removePlayer()
    removeEventHandler("onClientVehicleCollision", self.m_Vehicle, bind(self.Event_checkCollidedVehicles, self))
    triggerServerEvent("ColorCars:removePlayerFromLobby", resourceRoot, self.m_ClickedLobby, localPlayer)
    self.m_ClickedLobby = nil
    self.m_LastCatch = nil
    self.m_Catcher = nil
    self.m_Vehicle = nil    
    self:deleteGUI()
    InfoBox:new(_"Lobby verlassen")
end

function ColorCarsManager:deleteGUI()
    if not self.m_ColorCarsGUI then return end
    
    delete(self.m_ColorCarsGUI:getSingleton())
    self.m_ColorCarsGUI = nil
end

function ColorCarsManager:Event_openLobbyGUI(marker)
    self:deleteGUI()
    self.m_ColorCarsGUI = ColorCarsLobbyGUI:new(marker)
    self:requestLobbyInfos()
end

function ColorCarsManager:openCreateLobbyGUI()
    self:deleteGUI()
    self.m_ColorCarsGUI = ColorCarsCreateLobbyGUI:new()
end

function ColorCarsManager:openPasswordGUI(lobby)
    self.m_ClickedLobby = lobby
    self:deleteGUI()
    self.m_ColorCarsGUI = ColorCarsPasswordGUI:new()
end

function ColorCarsManager:openMatchGUI()
    self:deleteGUI()
    self.m_ColorCarsGUI = ColorCarsMatchGUI:new()
end

function ColorCarsManager:Event_syncMatchGUI(playerInfo, catcher, scoreInfo)
    ColorCarsMatchGUI:getSingleton().m_MatchGridList:clear()
    for i, player in ipairs(playerInfo) do
        local ColorCarsMatch = ColorCarsMatchGUI:getSingleton().m_MatchGridList:addItem(player:getName(), scoreInfo[player])
        if player == catcher then
            ColorCarsMatch:setColorRGB(255, 0, 0)
        else
            ColorCarsMatch:setColorRGB(0, 255, 0)
        end
    end
end

function ColorCarsManager:Event_changeLobbyOwner(newOwner)
    self.m_ClickedLobby = newOwner
end

function ColorCarsManager:Event_bindVehicleCollisionEvent(vehicle, currentCatcher)
    self.m_Vehicle = vehicle
    self.m_Catcher = currentCatcher
    self.m_LastCatch = getTickCount()
    addEventHandler("onClientVehicleCollision", self.m_Vehicle, bind(self.Event_checkCollidedVehicles, self))
end

function ColorCarsManager:Event_checkCollidedVehicles(hitElement)
    if not hitElement then return end 
    if hitElement:getType() ~= "vehicle" then return end
    if source ~= getPedOccupiedVehicle(self.m_Catcher) then return end

    local newCatcher = getVehicleOccupant(hitElement)
    triggerServerEvent("ColorCars:changeCatcher", resourceRoot, self.m_ClickedLobby, newCatcher)
end

function ColorCarsManager:Event_syncNewCatcher(newCatcher)
    self.m_Catcher = newCatcher
end

function ColorCarsManager:refreshLobbyGUI()
    ColorCarsLobbyGUI:getSingleton().m_LobbyGridList:clear()
    for i, v in pairs(self.m_LobbyInfos) do
        local ColorCarsLobby = ColorCarsLobbyGUI:getSingleton().m_LobbyGridList:addItem(v["Lobbyname"], ("%s / %s"):format(v["Players"], v["maxPlayers"]), v["hasPassword"] and "Ja" or "Nein")
        ColorCarsLobby.m_Lobby = i
        ColorCarsLobby.m_HasPassword = v["hasPassword"]
    end
end

function ColorCarsManager:requestPasswordCheck(password)
    triggerServerEvent("ColorCars:checkPassword", resourceRoot, self.m_ClickedLobby, password)
end

function ColorCarsManager:Event_receivePasswordResult(password)
    if password then
        self:requestMaxPlayersCheck(self.m_ClickedLobby)
    else
        ErrorBox:new(_"Das eingegebene Passwort ist falsch")
    end
end

function ColorCarsManager:requestMaxPlayersCheck(lobby)
    self.m_ClickedLobby = lobby
    triggerServerEvent("ColorCars:checkIsLobbyFull", resourceRoot, lobby)
end

function ColorCarsManager:Event_receiveMaxPlayersResult(isFull)
    if not isFull then 
        self:addPlayer(self.m_ClickedLobby)
    else
        ErrorBox:new(_"Die Lobby ist voll")
    end
end

function ColorCarsManager:requestLobbyInfos()
    triggerServerEvent("ColorCars:requestClientLobbyInfos", resourceRoot)
end

function ColorCarsManager:Event_receiveLobbyInfos(lobbys)
    self.m_LobbyInfos = lobbys
    self:refreshLobbyGUI()
end

function ColorCarsManager:Event_sendLobbyNotFoundMessage()
    ErrorBox:new(_"Keine Lobby gefunden")
    self:requestLobbyInfos()
end