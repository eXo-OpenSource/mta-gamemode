SuperSweeperLobby = inherit(Object)
SuperSweeperLobby.Types = {
    [1] = "permanent", 
    [2] = "temporary",
						 
    ["permanent"] = 1, 
    ["temporary"] = 2
}

SuperSweeperLobby.Name = "Unknown"
SuperSweeperLobby.States = {
	[1] = "preparing",
	[2] = "starting",
	[3] = "running",
						 
    ["preparing"] = 1, 
    ["starting"] = 2, 
    ["running"] = 3
}

function SuperSweeperLobby:constructor(id, name, owner, mode, maxPlayer, map, password, settings)
	self.m_Id = id
	self.m_Type = owner == "Server" and SuperSweeperLobby.Types[1] or SuperSweeperLobby.Types[2]
	self.m_Name = name
    self.m_Mode = mode
	self.m_MaxPlayer = maxPlayer
	self.m_Map = map
	self.m_Password = password or ""
	self.m_Players = {}
	self.m_State = owner == "Server" and SuperSweeperLobby.States[3] or SuperSweeperLobby.States[1]
	self.m_Interior = SuperSweeperManager.Maps[self.m_Map].interior
	self.m_Dimension = 4000 + self.m_Id
	self.m_OnVehicleExplode = bind(self.Event_onVehicleExplode, self)
	self.m_OnVehicleExit = bind(self.Event_onVehicleExit, self)
	self.m_Sweepers = {}

    self.m_Arena = createColRectangle(SuperSweeperManager.Maps[self.m_Map].border.position, SuperSweeperManager.Maps[self.m_Map].border.size)
	self.m_Arena:setInterior(self.m_Interior)
	self.m_Arena:setDimension(self.m_Dimension)
	addEventHandler("onColShapeLeave", self.m_Arena, bind(self.Event_onColShapeLeave, self))

	self.m_DeathZone = createColCuboid(Vector3(SuperSweeperManager.Maps[self.m_Map].border.position.x, SuperSweeperManager.Maps[self.m_Map].border.position.y, SuperSweeperManager.Maps[self.m_Map].border.minHeight) - Vector3(10, 10, 0), Vector3(SuperSweeperManager.Maps[self.m_Map].border.size.x, SuperSweeperManager.Maps[self.m_Map].border.size.y, SuperSweeperManager.Maps[self.m_Map].border.maxHeight) + Vector3(20, 20, 0))
	self.m_DeathZone:setInterior(self.m_Interior)
	self.m_DeathZone:setDimension(self.m_Dimension)
	addEventHandler("onColShapeLeave", self.m_DeathZone, bind(self.Event_onColShapeDeathZoneLeave, self))

	self.m_TimedPulse = TimedPulse:new(5 * 1000)
	self.m_TimedPulse:registerHandler(bind(self.checkIfInArea, self))

	if self.m_Type == SuperSweeperLobby.Types[1] then
		self.m_Owner = "Server"
		self.m_OwnerName = "eXo-RL"
	else
		self.m_Owner = owner
		self.m_OwnerName = owner:getName()
		self:addPlayer(owner)
	end
end

function SuperSweeperLobby:destructor()
	delete(self.m_TimedPulse)
    self.m_Arena:destroy()
    self.m_DeathZone:destroy()
end

function SuperSweeperLobby:checkIfInArea()
	for k, vehicle in ipairs(self.m_Sweepers) do
		if vehicle and isElement(vehicle) then
			if not vehicle.blown then
				if not vehicle:isWithinColShape(self.m_DeathZone) then
					vehicle.m_LastHitBy = "Zone"
					vehicle:blow()
				end

				if vehicle.inWater then
					vehicle.m_LastHitBy = "Water"
					vehicle:blow()
				end
			end
		end
	end
end

function SuperSweeperLobby:Event_onColShapeLeave(element, matchingDimension)
    if element:getType() == "vehicle" and matchingDimension and element.m_SuperSweeper then
        element:setRotation(element.rotation + Vector3(0, 0, 180))
        element:setVelocity(element.velocity * Vector3(-1, -1, -1) + Vector3(0, 0, 0.4) + element.matrix.forward * Vector3(0.1, 0.1, 0))
    end
end

function SuperSweeperLobby:Event_onColShapeDeathZoneLeave(element, matchingDimension)
    if matchingDimension then
		if element:getType() == "vehicle" and element.m_SuperSweeper then
			element.m_LastHitBy = "Zone"
			element:blow()
		elseif element:getType() == "player" and element.m_SuperSweeperLobby then
			if not element.dead then
				element:kill()
			end
		end
	end
end

function SuperSweeperLobby:Event_onVehicleExplode()
	if source.m_Player and isElement(source.m_Player) then
		if not source.m_Player.dead then
			killPed(source.m_Player)
		end
	end
end

function SuperSweeperLobby:Event_onVehicleExit(player)
	if not player.dead then
		player:kill()
	end
end

function SuperSweeperLobby:increaseKill(player, weapon, weaponCheck)
	self.m_Players[player]["Kills"] = self.m_Players[player]["Kills"] + 1
	self:refreshGUI()
end

function SuperSweeperLobby:increaseDead(player, weapon, weaponCheck)
	self.m_Players[player]["Deaths"] = self.m_Players[player]["Deaths"] + 1
	self:refreshGUI()
end

function SuperSweeperLobby:refreshGUI()
	for player, data in pairs(self:getPlayers()) do
		player:triggerEvent("superSweeperRefreshGUI", self.m_Players)
	end
end

function SuperSweeperLobby:getPlayers()
	local players = {}
	local count = 0
	for player, data in pairs(self.m_Players) do
		if isElement(player) then
			players[player] = data
			count = count + 1
		else
			self:removePlayer(player)
		end
	end
	return players, count
end

function SuperSweeperLobby:getPlayerCount()
	local _, count = self:getPlayers()
	return count
end

function SuperSweeperLobby:sendShortMessage(text, ...)
	for player, data in pairs(self:getPlayers()) do
		player:sendShortMessage(_(text, player, ...), "SuperSweeper-Lobby", {255, 125, 0}, ...)
	end
end

function SuperSweeperLobby:addPlayer(player)
	player:createStorage(true)
	player:setData("isInSuperSweeper", true)
	player.m_SuperSweeperLobby = self

	player:triggerEvent("superSweeperSetZone", self.m_Arena)
    
	self:sendShortMessage("%s ist beigetreten!", player:getName())
end

function SuperSweeperLobby:removePlayer(player, isServerStop)
	self.m_Players[player] = nil
	if isElement(player) then
		if player.vehicle then
			player:removeFromVehicle()
		end

		if player.m_SuperSweeperVehicle then
			if player.m_SuperSweeperVehicle.m_Texture then
				delete(player.m_SuperSweeperVehicle.m_Texture)
			end
			if player.m_SuperSweeperVehicle.m_TextureDecal then
				delete(player.m_SuperSweeperVehicle.m_TextureDecal)
			end
			table.removevalue(self.m_Sweepers, player.m_SuperSweeperVehicle)
			player.m_SuperSweeperVehicle:destroy()
			player.m_SuperSweeperVehicle = nil
		end

		if player:isDead() then
			player:respawn(Vector3(-1494.234, 920.223, 7.188), Vector3(0, 0, 0))
		end

		player:restoreStorage()
		player:setDimension(0)
		player:setInterior(0)
		player:setPosition(Vector3(-1494.234, 920.223, 7.188))
		player:setData("isInSuperSweeper", false)
		player:setAlpha(255)
		player.m_SuperSweeperLobby = nil
		player:setFrozen(false)
		player:triggerEvent("superSweeperSetZone", nil)
		player:triggerEvent("showSuperSweeperHUD", false)

		if not isServerStop then
			self:sendShortMessage("%s hat die Lobby verlassen!", player:getName())
			player:sendShortMessage(_("Du hast die Lobby verlassen!", player), "SuperSweeper-Lobby", {255, 125, 0})
		end
	end

	if self.m_Type == SuperSweeperLobby.Types[2] and self:getPlayerCount() == 0 then
		delete(self)
	end
end

function SuperSweeperLobby:respawnPlayer(player, dead, pos)
	pos = pos and pos or Randomizer:getRandomTableValue(SuperSweeperManager.Maps[self.m_Map].spawns)
	if dead then
		fadeCamera(player, false, 2)
		player:triggerEvent("Countdown", 10, "Respawn in")
		setTimer(function()
			if player and isElement(player) then
				spawnPlayer(player, pos.position, 0, player:getModel(), self.m_Interior, self.m_Dimension)

				player:setCameraTarget(player)
				player:fadeCamera(true, 1)
				player:triggerEvent("CountdownStop", "Respawn in")

                self:spawnPlayer(player, pos)
			end
		end, 10000, 1)
	else
		self:spawnPlayer(player, pos)
	end
end

function SuperSweeperLobby:spawnPlayer(player, spawnLocation)
	player:setDimension(self.m_Dimension)
	player:setInterior(self.m_Interior)
	player:setPosition(spawnLocation.position)
	player:setHealth(100)
	player:setHeadless(false)
	player:setAlpha(255)
	
	if player.m_SuperSweeperVehicle then
		if player.m_SuperSweeperVehicle.m_Texture then
			delete(player.m_SuperSweeperVehicle.m_Texture)
		end
		if player.m_SuperSweeperVehicle.m_TextureDecal then
			delete(player.m_SuperSweeperVehicle.m_TextureDecal)
		end
		table.removevalue(self.m_Sweepers, player.m_SuperSweeperVehicle)
		player.m_SuperSweeperVehicle:destroy()
	end

	local vehicle = WeaponVehicle.create(574, spawnLocation.position, spawnLocation.rotation)
	vehicle:setEngineState(true)
	vehicle:setInterior(self.m_Interior)
	vehicle:setDimension(self.m_Dimension)
	vehicle.m_SuperSweeper = true
	vehicle.m_Texture = VehicleTexture:new(vehicle, "files/images/Textures/Empty.png", "vehiclegrunge256", true)
	vehicle.m_TextureDecal = VehicleTexture:new(vehicle, "files/images/Textures/SuperSweeper/sweeper_decal.png", "sweeper92decal128", true)
	vehicle.m_Player = player
	vehicle:setData("superSweeper", false, true)
	vehicle:setData("canUseCruiseControl", false, true)
	vehicle:setData("canUseLimiter", false, true)
	vehicle:setData("speedoDisabled", true, true)
	vehicle:setData("disableSeatBelt", true, true)
	vehicle:setData("disableAdminRepair", true, true)
	vehicle.m_DisableToggleEngine = true
	vehicle.m_DisableToggleHandbrake = true

	vehicle:setHandling("maxVelocity", 100)
	vehicle:setHandling("engineAcceleration", 6)

	addEventHandler("onVehicleExplode", vehicle, self.m_OnVehicleExplode)
	addEventHandler("onVehicleStartExit", vehicle, self.m_OnVehicleExit)

	self:setWeapon(vehicle, self:getSpawnWeapon(player)) 
	player:warpIntoVehicle(vehicle)
	player.m_SuperSweeperVehicle = vehicle
	table.insert(self.m_Sweepers, player.m_SuperSweeperVehicle)
	player.m_SeatBelt = true
	setElementData(player, "isBuckeled", true)
	triggerClientEvent(player, "playSeatbeltAlarm", vehicle, false)
	player:triggerEvent("showSuperSweeperHUD", true)
end

function SuperSweeperLobby:getSpawnWeapon(player)
	return "colt 45"
end

function SuperSweeperLobby:setWeapon(vehicle, weapon)
	if SuperSweeperManager.Weapon[vehicle.model] then
		local settings = SuperSweeperManager.Weapon[vehicle.model][weapon]

		if settings then
			vehicle:setWeapon(weapon, settings.offset, settings.rotation) 
		end
	end
end

function SuperSweeperLobby:onPlayerChat(player, text, type)
	if type == 0 then
		local receivedPlayers = {}
		for playeritem, data in pairs(self.m_Players) do
			playeritem:outputChat(("[%s] #808080%s: %s"):format(self.m_Name, player:getName(), text), 125, 255, 0, true)
			if playeritem ~= player then
				receivedPlayers[#receivedPlayers+1] = playeritem
			end
		end
		StatisticsLogger:getSingleton():addChatLog(player, "superSweeper", text, receivedPlayers)
		return true
	end
end

function SuperSweeperLobby:getPlayerString()
	local playerString = ""
	for player, data in pairs(self:getPlayers()) do
		playerString = playerString..player:getName()..", "
	end

	return string.sub(playerString, 0, #playerString-2)
end

function SuperSweeperLobby:onWasted(player, killer, weapon)
	local killer = nil
	local weapon = nil

	if player.m_SuperSweeperVehicle and player.m_SuperSweeperVehicle.m_LastHitBy then
		local vehicle = player.m_SuperSweeperVehicle.m_LastHitBy
		if vehicle.m_Player and isElement(vehicle.m_Player) then
			weapon = vehicle:getData("weapon")
			killer = vehicle.m_Player
		else
			killer = vehicle
		end
	end
	
	player:triggerEvent("superSweeperStartDeathScreen", killer or player, true)
	player:triggerEvent("showSuperSweeperHUD", false)
end
