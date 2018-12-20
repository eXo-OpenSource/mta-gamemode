-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/Events/BattleRoyale.lua
-- * PURPOSE: helper for admin auctions
-- *
-- ****************************************************************************

BattleRoyale = inherit(Singleton)
addRemoteEvents{"battleRoyaleLeavePlane"}

function BattleRoyale:constructor(players)

	self.m_Dimension = 1337
	self.m_PlaneId = 609
	self.m_CurrentZoneId = 0

	self.m_CurrentZone = {
		x = -3051.552,
		y = 1746.986,
		width = 2191.455,
		height = 3649.882
	}

	self.m_NextZone = {
		x = nil,
		y = nil,
		width = nil,
		height = nil
	}

	self.m_Zones = {
		[0] = {
			size = -1,
			travelTime = -1,
			shrinkingTime = -1,
			damage = 0.5
		},
		[1] = {
			size = 1000,
			travelTime = 10,
			shrinkingTime = 10,
			damage = 1.0
		},
		[2] = {
			size = 500,
			travelTime = 5,
			shrinkingTime = 10,
			damage = 3.0
		},
		[3] = {
			size = 250,
			travelTime = 5,
			shrinkingTime = 10,
			damage = 5.0
		},
		[4] = {
			size = 0,
			travelTime = -1,
			shrinkingTime = 10,
			damage = 8.0
		}
	}

	self.m_Zone = ColShape.Rectangle(-3051.552, -1902.896, 2191.455, 3649.882)
	self.m_RadarArea = RadarArea:new(-3051.552, 1746.986, 2191.455, 3649.882, setBytesInInt32(125, 84, 146, 247))
	self.m_Zone:setDimension(self.m_Dimension)

	self.m_TempPlayerPosition = Vector3(-791.063, 2427.318, 157.168)

	self.m_PlaneRoutes = {
		{ start = Vector3(-660.370, -2085.875, 1000), target = Vector3(-3153.856, 1833.804, 1000)}
	}

	self.m_AlivePlayers = {}
	self.m_Status = {
		status = "preparing",
		playersAlive = 0,
		travelTime = 0,
		initialTravelTime = 0,
		zoneDamage = 0,
		canJump = false,
		currentZone = self.m_CurrentZone,
		lastZone = table.copy(self.m_CurrentZone),
		nextZone = self.m_NextZone
	}

	--[[
		Are the players valid?
	]]
	for _, player in ipairs(players) do
		table.insert(self.m_AlivePlayers, player)
		player:setDimension(self.m_Dimension)
		player:setPosition(self.m_TempPlayerPosition + Vector3(math.random(-100, 100) / 10, math.random(-100, 100) / 10, 0))
		self.m_Status.playersAlive = #self.m_AlivePlayers
		player:triggerEvent("battleRoyalePrepare", root)
	end

	triggerClientEvent(self.m_AlivePlayers, "battleRoyaleStatusUpdate", resourceRoot, self.m_Status)
end

function BattleRoyale:start()
	local route = 1
	local flightDuration = 60 * 1000
	local rotation = findRotationVector(self.m_PlaneRoutes[route].start, self.m_PlaneRoutes[route].target)
	self.m_Plane = createVehicle(self.m_PlaneId, self.m_PlaneRoutes[route].start, Vector3(0, 0, rotation))
	self.m_PlaneTrash = createObject(1337, self.m_PlaneRoutes[route].start, Vector3(0, 0, rotation))
	self.m_PlaneSnowman = createPed(244, self.m_PlaneRoutes[route].start)

	self.m_Plane:setDimension(self.m_Dimension)
	self.m_PlaneTrash:setDimension(self.m_Dimension)
	self.m_PlaneSnowman:setDimension(self.m_Dimension)

	self.m_Plane:setCollisionsEnabled(false)
	self.m_PlaneTrash:setCollisionsEnabled(false)
	self.m_PlaneSnowman:setCollisionsEnabled(false)
	self.m_PlaneTrash:setAlpha(0)

	self.m_Plane:attach(self.m_PlaneTrash)
	self.m_Plane:setFrozen(true)
	self.m_PlaneSnowman:warpIntoVehicle(self.m_Plane)

	for _, player in ipairs(self.m_AlivePlayers) do
		player:setPosition(self.m_PlaneRoutes[route].start)
		player:attach(self.m_PlaneTrash, 0, -3, 0)
		player:setCollisionsEnabled(false)
		player:setAlpha(0)
		player:setHealth(100)
		player:setArmor(0)
		player:takeAllWeapons()
		player:giveWeapon(46)
		player.m_BattleRoyale = true
		player.m_OnPlane = true
		player.m_InventoryBlocked = true -- TODO: implement this!!!
		player.m_DoNotSaveWeapons = true -- TODO: implement it!!!!
	end


	addEventHandler("onColShapeHit", self.m_Zone, function(hitElement, dimMatch)
		if dimMatch then
			if hitElement == self.m_Plane then
				self.m_Status.canJump = true

				triggerClientEvent(self.m_AlivePlayers, "battleRoyaleStatusUpdate", resourceRoot, self.m_Status)
			end
		end
	end)

	addEventHandler("onColShapeLeave", self.m_Zone, function(hitElement, dimMatch)
		if dimMatch then
			if hitElement == self.m_Plane then
				for _, player in ipairs(self.m_AlivePlayers) do
					if player.m_OnPlane then
						player.m_OnPlane = false
						player:detach()
						player:setAlpha(255)
						player:setCollisionsEnabled(true)
					end
				end
			end
		end
	end)

	self.m_PlaneTrash:move(flightDuration, self.m_PlaneRoutes[route].target)
	setTimer(bind(self.startRound, self), 10 * 1000, 1)

	self.m_Status.status = "starting"

	triggerClientEvent(self.m_AlivePlayers, "battleRoyaleStatusUpdate", resourceRoot, self.m_Status)

	self.m_LeavePlaneEvent = bind(self.leavePlane, self)
	addEventHandler("battleRoyaleLeavePlane", root, self.m_LeavePlaneEvent)


	PlayerManager:getSingleton():getWastedHook():register(
		function(player, killer, weapon)
			if player.m_BattleRoyale then
				for _, v in pairs(self.m_AlivePlayers) do
					outputChatBox(player:getName() .. " ist gestorben.", v)
				end

				table.removevalue(self.m_AlivePlayers, player)
				player.m_BattleRoyale = false
				player:setPosition(0,0,3)
				player:setDimension(0)

				return true
			end
		end
	)
	--[[
		Command results: vector3: { x = -660.370, y = -2085.875, z = 26.222 }
[eXo]MegaThorx executed command: me.position
Command results: vector3: { x = -3153.856, y = 1833.804, z = -1.744 }
	]]

	--[[
		Remove all weapons from players
		Teleport players to a position?? TBD
		Spawn plane
		Set camera on plane

	Player.getQuitHook():register(
		function(player)
			if player.deathmatchLobby then
				player.deathmatchLobby:removePlayer(player)
			end
		end
	)

	Player.getChatHook():register(
		function(player, text, type)
			if player.deathmatchLobby then
				return player.deathmatchLobby:onPlayerChat(player, text, type)
			end
		end
	)
	]]
end


function BattleRoyale:startRound()
	self.m_Status.status = "running"
	self:calculateNextZone()
	self.m_RoundTickEvent = bind(self.roundTick, self)
	setTimer(self.m_RoundTickEvent, 1000, 0)
	-- triggerClientEvent(self.m_AlivePlayers, "battleRoyaleStatusUpdate", resourceRoot, self.m_Status)
end

function BattleRoyale:calculateNextZone()
	local zoneId = self.m_CurrentZoneId + 1
	if self.m_Zones[zoneId] then
		self.m_NextZone.x = self.m_CurrentZone.x + math.random(0, self.m_CurrentZone.width - self.m_Zones[zoneId].size)
		self.m_NextZone.y = self.m_CurrentZone.y - math.random(0, self.m_CurrentZone.height - self.m_Zones[zoneId].size)

		self.m_NextZone.width = self.m_Zones[zoneId].size
		self.m_NextZone.height = self.m_Zones[zoneId].size
		self.m_Status.travelTime = self.m_Zones[zoneId].travelTime
		self.m_Status.shrinkingTime = self.m_Zones[zoneId].shrinkingTime
		self.m_Status.intialShrinkingTime = self.m_Status.shrinkingTime
		self.m_Status.zoneDamage = self.m_Zones[zoneId].damage

		if self.m_NextZoneArea then
			delete(self.m_NextZoneArea)
		end

		self.m_NextZoneArea = RadarArea:new(self.m_NextZone.x, self.m_NextZone.y, self.m_NextZone.width, self.m_NextZone.height, setBytesInInt32(180, 113, 247, 84))
	else
		self.m_NextZone = {
			x = nil,
			y = nil,
			width = nil,
			height = nil
		}
	end

	self.m_Status.nextZone = self.m_NextZone

	triggerClientEvent(self.m_AlivePlayers, "battleRoyaleStatusUpdate", resourceRoot, self.m_Status)
end

local interpolate = function(a, b, progress)
	return interpolateBetween(a, 0, 0, b, 0, 0, progress, "Linear")
end

function BattleRoyale:roundTick()

	for _, player in pairs(self.m_AlivePlayers) do
		outputChatBox(player.name .. " x: " .. tostring(self.m_CurrentZone.x < player.position.x) .. ", w: " .. tostring(self.m_CurrentZone.x + self.m_CurrentZone.width > player.position.x) .. ", y: " .. tostring(self.m_CurrentZone.y > player.position.y) .. ", h: " .. tostring(self.m_CurrentZone.y - self.m_CurrentZone.height < player.position.y))
		if self.m_CurrentZone.x > player.position.x or
		self.m_CurrentZone.x + self.m_CurrentZone.width < player.position.x or
		self.m_CurrentZone.y < player.position.y or
		self.m_CurrentZone.y - self.m_CurrentZone.height > player.position.y then
			local damage = self.m_Zones[self.m_CurrentZoneId].damage
			if player:getArmor() > damage then
				player:setArmor(player:getArmor() - damage)
			else
				damage = damage - player:getArmor()
				player:setArmor(0)
				player:setHealth(player:getHealth() - damage)
			end
		end
	end

	if self.m_Status.travelTime > 0 then
		self.m_Status.travelTime = self.m_Status.travelTime - 1
	else
		self.m_Status.travelTime = -1
		self.m_Status.shrinkingTime = self.m_Status.shrinkingTime - 1

		if self.m_Status.shrinkingTime < 0 then
			if self.m_Zones[self.m_CurrentZoneId + 1] then
				self.m_Status.lastZone = table.copy(self.m_Status.currentZone)
				self.m_CurrentZoneId = self.m_CurrentZoneId + 1
				self:calculateNextZone()
			end
		else
			local state = 1 - self.m_Status.shrinkingTime / self.m_Status.intialShrinkingTime

			self.m_Status.currentZone.x = self.m_Status.lastZone.x + math.abs(self.m_Status.lastZone.x - self.m_Status.nextZone.x) * state
			self.m_Status.currentZone.y = self.m_Status.lastZone.y - math.abs(self.m_Status.lastZone.y - self.m_Status.nextZone.y) * state
			self.m_Status.currentZone.width = self.m_Status.lastZone.width - math.abs(self.m_Status.lastZone.x - self.m_Status.currentZone.x) - math.abs((self.m_Status.nextZone.x + self.m_Status.nextZone.width) - (self.m_Status.lastZone.x + self.m_Status.lastZone.width)) * state
			self.m_Status.currentZone.height = self.m_Status.lastZone.height - math.abs(self.m_Status.lastZone.y - self.m_Status.currentZone.y) - math.abs((self.m_Status.nextZone.y - self.m_Status.nextZone.height) - (self.m_Status.lastZone.y - self.m_Status.lastZone.height)) * state

			delete(self.m_RadarArea)
			self.m_RadarArea = RadarArea:new(self.m_Status.currentZone.x, self.m_Status.currentZone.y, self.m_Status.currentZone.width, self.m_Status.currentZone.height, setBytesInInt32(125, 84, 146, 247))
		end
	end



	triggerClientEvent(self.m_AlivePlayers, "battleRoyaleStatusUpdate", resourceRoot, self.m_Status)
end

function BattleRoyale:leavePlane()
	if client.m_OnPlane then
		client.m_OnPlane = false
		client:detach()
		client:setAlpha(255)
		client:setCollisionsEnabled(true)
	end
end

function BattleRoyale:joinEvent(player)
	if self.m_Status.status == "preparing" then
		table.insert(self.m_AlivePlayers, player)
		player:setDimension(self.m_Dimension)
		player:setPosition(self.m_TempPlayerPosition + Vector3(math.random(-100, 100) / 10, math.random(-100, 100) / 10, 0))
		self.m_Status.playersAlive = #self.m_AlivePlayers
		player:triggerEvent("battleRoyalePrepare", root)

		triggerClientEvent(self.m_AlivePlayers, "battleRoyaleStatusUpdate", root, self.m_Status)
	end
end

function BattleRoyale:onWasted()

end
