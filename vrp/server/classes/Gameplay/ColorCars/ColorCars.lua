-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/ColorCars/ColorCars.lua
-- *  PURPOSE:     ColorCars class
-- *
-- ****************************************************************************

ColorCars = inherit(Object)
ColorCars.SpawnPosition = {
    {Vector3(-1343.98, 935.94, 1036.70), 5.758}, {Vector3(-1296.02, 959.40, 1037.03), 46.637}, 
    {Vector3(-1277.31, 1002.17, 1037.70), 89.451}, {Vector3(-1293.23, 1029.79, 1038.19), 123.297}, 
    {Vector3(-1335.85, 1053.58, 1038.67), 147.121}, {Vector3(-1387.46, 1058.70, 1038.84), 175.429}, 
    {Vector3(-1426.74, 1057.35, 1038.88), 172.527}, {Vector3(-1474.35, 1047.95, 1038.82), 200.747}, 
    {Vector3(-1511.85, 1017.48, 1038.37), 243.385}, {Vector3(-1511.16, 970.55, 1037.58), 297.538}
}

function ColorCars:constructor(lobbyOwner, lobbyName, password, maxPlayers)
    self.m_LobbyOwner = lobbyOwner
    self.m_LobbyName = lobbyName
    self.m_LobbyPassword = password
    self.m_MaxPlayers = maxPlayers
    self.m_LobbyDimension = DimensionManager:getSingleton():getFreeDimension()
    self.m_LastCatch = 0
    self.m_TimeBetweenCatch = 3000
    self.m_Players = {}
    self.m_PlayerVehicle = {}
    self.m_PlayerCatchScore = {}
    self.m_Catcher = lobbyOwner
end

function ColorCars:destructor()
    ColorCarsManager:getSingleton():deleteLobby(self.m_LobbyOwner)
    DimensionManager:getSingleton():freeDimension(self.m_LobbyDimension)
    self = nil
end

function ColorCars:setCatcher(newCatcher)
    self.m_Catcher = newCatcher
    self:setCarToCatcher(newCatcher)

    ColorCarsManager:getSingleton():syncNewCatcher(self.m_LobbyOwner, newCatcher)
end

function ColorCars:setLobbyOwner(newOwner)
    ColorCarsManager:getSingleton():changeOwner(self.m_LobbyOwner, newOwner)
    self.m_LobbyOwner = newOwner
end

function ColorCars:addPlayer(player)
    table.insert(self.m_Players, player)
    self.m_PlayerCatchScore[player] = 0
    self:createColorCar(player)

    player.m_RemoveOnQuit = bind(self.removePlayerOnQuit, self)
    addEventHandler("onPlayerQuit", player, player.m_RemoveOnQuit)
end

function ColorCars:removePlayer(player)
    removeEventHandler("onPlayerQuit", player, player.m_RemoveOnQuit)
    player.m_RemoveOnQuit = nil

    table.removevalue(self.m_Players, player)
    self.m_PlayerCatchScore[player] = nil
    
    self:deleteColorCar(player)
    
    player:setPosition(2690.84, -1700.05, 10.44)
    player:setDimension(0)
    player:setInterior(0)

    if #self.m_Players == 0 then
        return delete(self) 
    end

    if player == self.m_LobbyOwner then
        self:setLobbyOwner(self.m_Players[1])
    end
    
    if player == self.m_Catcher then
        self:setCatcher(self.m_Players[math.random(1, #self.m_Players)])
    end
    ColorCarsManager:getSingleton():syncMatchGUI(self.m_LobbyOwner)
end

function ColorCars:removePlayerOnQuit()
    self:removePlayer(source)
end

function ColorCars:createColorCar(player)
    self.m_PlayerVehicle[player] = createVehicle(495, ColorCars.SpawnPosition[#self.m_Players][1], 0, 0, ColorCars.SpawnPosition[#self.m_Players][2])
    self.m_PlayerVehicle[player]:setData("disableCollisionCheck", true, true)
    self.m_PlayerVehicle[player]:setInterior(15)
    self.m_PlayerVehicle[player]:setDimension(self.m_LobbyDimension)
    self.m_PlayerVehicle[player]:setDamageProof(true)
    self.m_PlayerVehicle[player]:setColor(0,255,0)
    self.m_FuelTimer = setTimer(
        function(vehicle)
            vehicle:setFuel(100)
        end, 1800000, 1, self.m_PlayerVehicle[player])
    
    player:triggerEvent("ColorCars:bindVehicleCollisionEvent", self.m_PlayerVehicle[player], self.m_Catcher)
    player:setInterior(15)
    player:setDimension(self.m_LobbyDimension)
    player:warpIntoVehicle(self.m_PlayerVehicle[player])
    toggleControl(player, "enter_exit", false)

    if player == self.m_Catcher then
        self:setCarToCatcher(player)
    end
end

function ColorCars:deleteColorCar(player)
    player:removeFromVehicle()
    self.m_PlayerVehicle[player]:destroy()
    self.m_PlayerVehicle[player] = nil
    killTimer(self.m_FuelTimer)
    
    toggleControl(player, "enter_exit", true)
end

function ColorCars:setCarToCatcher(player)
    self.m_PlayerVehicle[player]:setColor(255, 0, 0)
end

function ColorCars:setCarToNormal(player)
    self.m_PlayerVehicle[player]:setColor(0, 255, 0)
end

function ColorCars:isLobbyFull()
    if #self.m_Players == self.m_MaxPlayers then
        return true
    end
    return false
end

function ColorCars:checkPassword(password)
    if self.m_LobbyPassword == password then
        return true
    end
    return false
end

function ColorCars:checkIfNewCatcherIsValid(oldCatcher, newCatcher)
    if getTickCount() < self.m_LastCatch + self.m_TimeBetweenCatch then return end
    self.m_LastCatch = getTickCount()
    self:setCarToNormal(oldCatcher)
    self:setCatcher(newCatcher)
    self:addCatchScorePoint(oldCatcher)

    ColorCarsManager:getSingleton():syncMatchGUI(self.m_LobbyOwner)
    ColorCarsManager:getSingleton():syncNewCatcher(self.m_LobbyOwner, newCatcher)
end

function ColorCars:addCatchScorePoint(player)
    self.m_PlayerCatchScore[player] = self.m_PlayerCatchScore[player] + 1
end