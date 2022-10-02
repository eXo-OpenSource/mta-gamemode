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
ColorCars.PowerUpNames = {"Superboost", "Superjump", "Vehiclechange", "Ghostmode"}
ColorCars.PowerUps =    {["Superboost"] = {["DisplayName"] = "Super Boost", ["Stackable"] = true, ["InstantActive"] = false, 
                        ["Description"] = "Du hast ein Superboost erhalten.\nDu kannst es mit ALT aktivieren!", ["Client"] = true},
                        
                        ["Superjump"] = {["DisplayName"] = "Super Sprung", ["Stackable"] = true, ["InstantActive"] = false, 
                        ["Description"] = "Du hast ein Superjump erhalten.\nDu kannst es mit SHIFT aktivieren!", ["Client"] = true},
                        
                        ["Vehiclechange"] = {["DisplayName"] = "Fahrzeug änderung", ["Stackable"] = false, ["InstantActive"] = true, 
                        ["Description"] = "Du hast ein neues Fahrzeug erhalten\nDies hält für 30 Sekunden!", ["Client"] = false},
                        
                        ["Ghostmode"] = {["DisplayName"] = "Geist", ["Stackable"] = false, ["InstantActive"] = true, 
                        ["Description"] = "Du bist nun ein Geist und kannst nicht berührt werden\nDies hält für 15 Sekunden!", ["Client"] = true}
}
ColorCars.PowerUpVehicleChange = {411, 415, 560, 503, 530, 574, 559,}

ColorCars.MarkerPosition = {Vector3(-1518.98, 1008.02, 1037.22), Vector3(-1390.19, 1061.36, 1037.89), Vector3(-1278.81, 992.99, 1036.55), Vector3(-1399.42, 1002.50, 1023.58), Vector3(-1410.64, 930.16, 1040.888)}

ColorCars.Types = {[1] = "permanent", [2] = "temporary"}

function ColorCars:constructor(lobbyOwner, lobbyName, password, maxPlayers, isServer)
    self.m_LobbyOwner = lobbyOwner
    self.m_LobbyName = lobbyName
    self.m_LobbyType = isServer and ColorCars.Types[1] or ColorCars.Types[2]
    self.m_LobbyPassword = password
    self.m_MaxPlayers = maxPlayers
    self.m_Catcher = isServer and "none" or lobbyOwner
    self.m_LobbyDimension = DimensionManager:getSingleton():getFreeDimension()
    self.m_LastCatch = 0
    self.m_TimeBetweenCatch = 3000
    self.m_Players = {}
    self.m_PlayerVehicle = {}
    self.m_FuelTimer = {}
    self.m_PlayerCatchScore = {}
    self.m_PlayerPowerUps = {}
    self.m_PowerUpSpawnTimer = setTimer(bind(self.spawnPowerUpMarker, self), math.random(30000, 40000), 0)
end

function ColorCars:destructor()
    ColorCarsManager:getSingleton():deleteLobby(self.m_LobbyOwner)
    DimensionManager:getSingleton():freeDimension(self.m_LobbyDimension)
    killTimer(self.m_PowerUpSpawnTimer)
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
    self.m_PlayerPowerUps[player] = {}
    self:createColorCar(player)
    player:createStorage(false)
    self:syncGhostMode(player)
    player.colorCarsLobby = self
    player:setData("isInColorCars", true, true)

    if self.m_Catcher == "none" then
        self:setCatcher(player)
    end

    player:triggerEvent("ColorCars:openMatchGUI")
    ColorCarsManager:getSingleton():syncMatchGUI(self.m_LobbyOwner)
    player:sendInfo(_("Sollte das Match Fenster stören,\n kannst du es jederzeit verschieben.", player), 10000)

    self.m_SuportboostPowerUp = bind(self.powerUpSuperBoost, self, player)
    self.m_SuperjumpPowerUp = bind(self.powerUpSuperJump, self, player)
    bindKey(player, "lalt", "down", self.m_SuportboostPowerUp)
    bindKey(player, "lshift", "down", self.m_SuperjumpPowerUp)

    self:sendShortMessage(("%s hat die Lobby betreten."):format(player:getName()))
    player:sendShortMessage("Du bist der Lobby beigetreten.")
end

function ColorCars:removePlayer(player)
    self:powerUpGhostMode(player, self.m_LobbyDimension, false, false, true)
    table.removevalue(self.m_Players, player)
    self.m_PlayerCatchScore[player] = nil
    self:deleteColorCar(player)
    player:restoreStorage()
    player.colorCarsLobby = nil
    player:setData("isInColorCars", false, true)

    unbindKey(player, "lalt", "down", self.m_SuportboostPowerUp)
    unbindKey(player, "lshift", "down", self.m_SuperjumpPowerUp)

    player:triggerEvent("ColorCars:deleteGUI")

    player:setPosition(2690.84, -1700.05, 10.44)
    player:setDimension(0)
    player:setInterior(0)
    player:setCameraTarget() -- without the players camera flies over the whole map
    
    self:sendShortMessage(("%s hat die Lobby verlassen."):format(player:getName()))
    player:sendShortMessage("Du hast die Lobby verlassen.")

    if #self.m_Players == 0 and self.m_LobbyType == ColorCars.Types[2] then
        return delete(self) 
    end

    if player == self.m_LobbyOwner then
        self:setLobbyOwner(self.m_Players[1])
    end
    
    if player == self.m_Catcher and #self.m_Players ~= 0 then
        self:setCatcher(self.m_Players[math.random(1, #self.m_Players)])
    elseif #self.m_Players == 0 then
        self.m_Catcher = "none" 
    end
    ColorCarsManager:getSingleton():syncMatchGUI(self.m_LobbyOwner)
end

function ColorCars:createColorCar(player)
    local pos = ColorCars.SpawnPosition[#self.m_Players][1]
    self.m_PlayerVehicle[player] = TemporaryVehicle.create(495, pos.x, pos.y, pos.z, ColorCars.SpawnPosition[#self.m_Players][2])
    self.m_PlayerVehicle[player]:setData("disableCollisionCheck", true, true)
    self.m_PlayerVehicle[player]:setInterior(15)
    self.m_PlayerVehicle[player]:setDimension(self.m_LobbyDimension)
    self.m_PlayerVehicle[player]:setDamageProof(true)
    self.m_PlayerVehicle[player]:setColor(0,255,0)
    self.m_FuelTimer[player] = setTimer(
        function(vehicle)
            vehicle:setFuel(100)
        end, 1800000, 0, self.m_PlayerVehicle[player])
    
    player:triggerEvent("ColorCars:bindVehicleCollisionEvent", self.m_PlayerVehicle[player], self.m_Catcher)
    player:setInterior(15)
    player:setDimension(self.m_LobbyDimension)
    player:warpIntoVehicle(self.m_PlayerVehicle[player])
    self.m_PlayerVehicle[player]:setEngineState(true)
    toggleControl(player, "enter_exit", false)

    if player == self.m_Catcher then
        self:setCarToCatcher(player)
    end
end

function ColorCars:deleteColorCar(player)
    player:removeFromVehicle()
    self.m_PlayerVehicle[player]:destroy()
    self.m_PlayerVehicle[player] = nil
    killTimer(self.m_FuelTimer[player])

    if self.m_PlayerPowerUps[player]["Vehiclechange"] then
        killTimer(self.m_PlayerPowerUps[player]["Vehiclechange"])
    end

    toggleControl(player, "enter_exit", true)
end

function ColorCars:setCarToCatcher(player)
    self.m_PlayerVehicle[player]:setColor(255, 0, 0)
end

function ColorCars:setCarToNormal(player)
    self.m_PlayerVehicle[player]:setColor(0, 255, 0)
end

function ColorCars:sendShortMessage(text, ...)
	local color = {255, 0, 255}
	for k, player in pairs(self.m_Players) do
		player:sendShortMessage(_(text, player), "ColorCars", color, ...)
	end
end

function ColorCars:onPlayerChat(player, text, type)
	if type == 0 then
		local receivedPlayers = {}
		for i, playeritem in pairs(self.m_Players) do
			playeritem:outputChat(("[%s] #808080%s: %s"):format("ColorCars", player:getName(), text), 125, 255, 0, true)
			if playeritem ~= player then
				receivedPlayers[#receivedPlayers+1] = playeritem
			end
		end
		StatisticsLogger:getSingleton():addChatLog(player, "colorcars", text, receivedPlayers)
		return true
	end
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
    self:addCatchScorePoint(oldCatcher, 1)
    ColorCarsManager:getSingleton():syncNewCatcher(self.m_LobbyOwner, newCatcher)
end

function ColorCars:addCatchScorePoint(player, amount)
    self.m_PlayerCatchScore[player] = self.m_PlayerCatchScore[player] + tonumber(amount)
    ColorCarsManager:getSingleton():syncMatchGUI(self.m_LobbyOwner)
end





function ColorCars:spawnPowerUpMarker()
    if self.m_PowerUpMarker then 
        removeEventHandler("onMarkerHit", self.m_PowerUpMarker, self.m_PowerUpPickUp)
        self.m_PowerUpMarker:destroy() 
    end 

    local randomMarker = ColorCars.MarkerPosition[math.random(1, #ColorCars.MarkerPosition)]
    self.m_PowerUpMarker = createMarker(randomMarker, "cylinder", 6)
    self.m_PowerUpMarker:setDimension(self.m_LobbyDimension)
    self.m_PowerUpMarker:setInterior(15)
    self.m_PowerUpPickUp = bind(self.givePowerUp, self)
    addEventHandler("onMarkerHit", self.m_PowerUpMarker, self.m_PowerUpPickUp)
end

function ColorCars:givePowerUp(hitElement, matchingDim)
    if not table.find(self.m_Players, hitElement) or not matchingDim then return end
    
    removeEventHandler("onMarkerHit", self.m_PowerUpMarker, self.m_PowerUpPickUp)
    self.m_PowerUpMarker:destroy()
    self.m_PowerUpMarker = nil

    local powerUpName = ColorCars.PowerUpNames[math.random(1, #ColorCars.PowerUpNames)]

    hitElement:sendShortMessage(ColorCars.PowerUps[powerUpName]["Description"])
    
    if ColorCars.PowerUps[powerUpName]["InstantActive"] then
        return self:activateInstantPowerUp(hitElement, powerUpName)
        
    end

    if self.m_PlayerPowerUps[hitElement][powerUpName] then
        if ColorCars.PowerUps[powerUpName]["Stackable"] then
            self.m_PlayerPowerUps[hitElement][powerUpName] = tonumber(self.m_PlayerPowerUps[hitElement][powerUpName]) + 1 
        else
            return end
    else
        self.m_PlayerPowerUps[hitElement][powerUpName] = 1
    end
end

function ColorCars:activateInstantPowerUp(player, powerUp)
    if powerUp == "Vehiclechange" then self:powerUpVehicleChange(player)
    elseif powerUp == "Ghostmode" then self:powerUpGhostMode(player, self.m_LobbyDimension, true, getRealTime().timestamp)
    end
end

function ColorCars:hasPlayerPowerUp(player, powerUp)
    if not self.m_PlayerPowerUps[player][powerUp] then return false end

    if tonumber(self.m_PlayerPowerUps[player][powerUp]) >= 1 then
        self.m_PlayerPowerUps[player][powerUp] = tonumber(self.m_PlayerPowerUps[player][powerUp]) - 1
        return true
    end
    return false
end

function ColorCars:powerUpSuperBoost(player)
    local vehicle = getPedOccupiedVehicle(player)
    if self:hasPlayerPowerUp(player, "Superboost") then
        if vehicle then
            local vx, vy, vz = getElementVelocity(vehicle)
            setElementVelocity(vehicle, vx*1.5, vy, vz)
        end
    end
end

function ColorCars:powerUpSuperJump(player) 
    local vehicle = getPedOccupiedVehicle(player) 
    if self:hasPlayerPowerUp(player, "Superjump") then
        if vehicle then
            local vx, vy, vz = getElementVelocity(vehicle)
            setElementVelocity(vehicle, vx, vy, 0.3)
        end
    end

end

function ColorCars:powerUpVehicleChange(player)
    local vehicle = getPedOccupiedVehicle(player) 
    if self.m_PlayerPowerUps[player]["Vehiclechange"] then killTimer(self.m_PlayerPowerUps[player]["Vehiclechange"]) end
    
    if vehicle then
        vehicle:setModel(ColorCars.PowerUpVehicleChange[math.random(1, #ColorCars.PowerUpVehicleChange)])
        self.m_PlayerPowerUps[player]["Vehiclechange"] = setTimer(
            function()
                vehicle:setModel(495)
                self.m_PlayerPowerUps[player]["Vehiclechange"] = nil
            end, 30000, 1)
    end
end

function ColorCars:powerUpGhostMode(ghostPlayer, dim, state, timestamp, quit)
    self.m_PlayerPowerUps[ghostPlayer]["GhostMode"] = timestamp
    for i, player in pairs(self.m_Players) do
        player:triggerEvent("ColorCars:powerUpGhostMode", ghostPlayer, dim, state, quit)
    end   
end

function ColorCars:syncGhostMode(joinedPlayer)
    for i, player in pairs(self.m_Players) do
        if self.m_PlayerPowerUps[player]["GhostMode"] then
            if self.m_PlayerPowerUps[player]["GhostMode"] + 15 >= getRealTime().timestamp then
                local remainingTime = (self.m_PlayerPowerUps[player]["GhostMode"] + 15 - getRealTime().timestamp)
                player:triggerEvent("ColorCars:syncGhostMode", remainingTime, joinedPlayer, player)
                joinedPlayer:triggerEvent("ColorCars:syncGhostMode", remainingTime, joinedPlayer, player)
            end
        end
    end
end