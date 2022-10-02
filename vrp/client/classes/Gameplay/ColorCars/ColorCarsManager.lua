-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/ColorCarsManager.lua
-- *  PURPOSE:     ColorCarsManager class
-- *
-- ****************************************************************************

ColorCarsManager = inherit(Singleton)

function ColorCarsManager:constructor()
    addRemoteEvents{
    "ColorCars:createLobbyGUI", "ColorCars:receiveClientLobbyInfos", "ColorCars:receivePasswordCheckResult",
    "ColorCars:receiveMaxPlayersCheckResult", "ColorCars:syncMatchGUI", "ColorCars:bindVehicleCollisionEvent",
    "ColorCars:syncNewCatcher", "ColorCars:changeLobbyOwner", "ColorCars:powerUpGhostMode", "ColorCars:openMatchGUI",
    "ColorCars:deleteGUI", "ColorCars:syncGhostMode",
    }

    self.m_LobbyInfos = {}
    self.m_GhostModeTimer = {}
    self.m_TimeBetweenCatch = 3000

    addEventHandler("ColorCars:createLobbyGUI", root, bind(self.Event_openLobbyGUI, self))
    addEventHandler("ColorCars:receiveClientLobbyInfos", root, bind(self.Event_receiveLobbyInfos, self))
    addEventHandler("ColorCars:receivePasswordCheckResult", root, bind(self.Event_receivePasswordResult, self))
    addEventHandler("ColorCars:receiveMaxPlayersCheckResult", root, bind(self.Event_receiveMaxPlayersResult, self))
    addEventHandler("ColorCars:syncMatchGUI", root, bind(self.Event_syncMatchGUI, self))
    addEventHandler("ColorCars:openMatchGUI", root, bind(self.openMatchGUI, self))
    addEventHandler("ColorCars:deleteGUI", root, bind(self.deleteGUI, self))
    addEventHandler("ColorCars:bindVehicleCollisionEvent", root, bind(self.Event_bindVehicleCollisionEvent, self))
    addEventHandler("ColorCars:syncNewCatcher", root, bind(self.Event_syncNewCatcher, self))
    addEventHandler("ColorCars:changeLobbyOwner", root, bind(self.Event_changeLobbyOwner, self))
    addEventHandler("ColorCars:powerUpGhostMode", root, bind(self.Event_powerUpGhostMode, self))
    addEventHandler("ColorCars:syncGhostMode", root, bind(self.Event_syncGhostMode, self))
end

function ColorCarsManager:createLobby(lobbyName, lobbyPassword, maxPlayers)
    self.m_ClickedLobby = localPlayer
    triggerServerEvent("ColorCars:createLobby", resourceRoot, localPlayer, lobbyName, lobbyPassword, maxPlayers)
end

function ColorCarsManager:addPlayer(lobby)
    triggerServerEvent("ColorCars:addPlayerToLobby", resourceRoot, lobby, localPlayer)
end

function ColorCarsManager:removePlayer()
    removeEventHandler("onClientVehicleCollision", self.m_Vehicle, bind(self.Event_checkCollidedVehicles, self))
    triggerServerEvent("ColorCars:removePlayerFromLobby", resourceRoot, self.m_ClickedLobby, localPlayer)
    self.m_ClickedLobby = nil
    self.m_LastCatch = nil
    self.m_Catcher = nil
    self.m_Vehicle = nil    
    self:deleteGUI()
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

function ColorCarsManager:openCreateLobbyGUI(marker)
    self:deleteGUI()
    self.m_ColorCarsGUI = ColorCarsCreateLobbyGUI:new(marker)
end

function ColorCarsManager:openPasswordGUI(lobby, marker)
    self.m_ClickedLobby = lobby
    self:deleteGUI()
    self.m_ColorCarsGUI = ColorCarsPasswordGUI:new(marker)
end

function ColorCarsManager:openMatchGUI()
    self:deleteGUI()
    self.m_ColorCarsGUI = ColorCarsMatchGUI:new()
end

function ColorCarsManager:Event_syncMatchGUI(playerInfo, catcher, scoreInfo)
    self.m_Players = playerInfo
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
    for i = #self.m_LobbyInfos, 1, -1 do
        v = self.m_LobbyInfos[i]
        local ColorCarsLobby = ColorCarsLobbyGUI:getSingleton().m_LobbyGridList:addItem(v["LobbyName"], ("%s / %s"):format(v["Players"], v["maxPlayers"]), v["hasPassword"] and "Ja" or "Nein")
        ColorCarsLobby.m_Lobby = v["LobbyOwner"]
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
        ErrorBox:new(_"Das eingegebene Passwort ist falsch.")
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
        ErrorBox:new(_"Die Lobby ist voll.")
    end
end

function ColorCarsManager:requestLobbyInfos()
    triggerServerEvent("ColorCars:requestClientLobbyInfos", resourceRoot)
end

function ColorCarsManager:Event_receiveLobbyInfos(lobbys)
    self.m_LobbyInfos = lobbys
    self:refreshLobbyGUI()
end

function ColorCarsManager:Event_powerUpGhostMode(ghostPlayer, dim, state, quit)
    self.m_Dimension = dim
    if quit then
        state = true
    else
        state = not state
    end

    if self.m_GhostModeTimer[ghostPlayer] then
        if not state or quit then
            self.m_GhostModeTimer[ghostPlayer]:destroy()
            self.m_GhostModeTimer[ghostPlayer] = nil
        else
            self.m_GhostModeTimer[ghostPlayer] = nil
        end
    end
    if ghostPlayer and ghostPlayer.type == "player" and ghostPlayer.vehicle then
        ghostPlayer.vehicle:setAlpha(state and 255 or 100)
        ghostPlayer:setAlpha(state and 255 or 100)
        localPlayer.vehicle:setCollidableWith(ghostPlayer.vehicle, state)
    end
    if not quit then      
        if localPlayer == ghostPlayer then
            for i , player in pairs(getElementsByType("player")) do
                if player:getDimension() == dim and player:getInterior() == localPlayer:getInterior() then
                    localPlayer.vehicle:setCollidableWith(player.vehicle, state)
                end
            end
        end
        if not state then
            self.m_GhostModeTimer[ghostPlayer] = setTimer(bind(self.Event_powerUpGhostMode, self), 15000, 1, ghostPlayer, dim, false)
        end
    end
end

function ColorCarsManager:Event_syncGhostMode(remainingTime, joinedPlayer, ghostPlayer)
    if joinedPlayer == localPlayer then
        self.m_GhostModeTimer[ghostPlayer] = setTimer(bind(self.Event_powerUpGhostMode, self), remainingTime*1000, 1, ghostPlayer, self.m_Dimension, false)
        ghostPlayer.vehicle:setAlpha(100)
        ghostPlayer:setAlpha(100)
        localPlayer.vehicle:setCollidableWith(ghostPlayer.vehicle, false)
    end
    if ghostPlayer == localPlayer then
        localPlayer.vehicle:setCollidableWith(joinedPlayer.vehicle, false)
    end
end