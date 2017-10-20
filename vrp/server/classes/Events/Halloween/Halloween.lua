Halloween = inherit(Singleton)

function Halloween:constructor()
	DrawContest:new()
	self.m_TrickOrTreatPIDs = {}

	self.m_EventSign = createObject(1903, 1484.80, -1710.70, 12.4, 0, 0, 90)
	self.m_EventSign:setDoubleSided(true)

	Player.getScreamHook():register(
		function(player, text)
			Halloween:getSingleton():checkForTTScream(player, text)
		end
	)
end

function Halloween:initTTPlayer(pId)
	if not self.m_TrickOrTreatPIDs[pId] then 
		self.m_TrickOrTreatPIDs[pId] = {
			visitedHouses = {},
			lastVisited = getTickCount(),
		} 
	end
end

function Halloween:registerTrickOrTreat(player, houseId)
	if isElement(player) and getElementType(player) == "player" then
		local pId = player:getId()
		self:initTTPlayer(pId)
		local d = self.m_TrickOrTreatPIDs[pId]
		if not d.currentHouseId then
			outputDebug("registered tt", player)
			d.currentHouseId = houseId
			d.trickStarted = getTickCount()
			d.playersNearby = {}
			table.insert(d.playersNearby, player)

			for i, v in pairs(getElementsByType("player")) do
				self:initTTPlayer(v:getId())
				if HouseManager:getSingleton().m_Houses[houseId]:isPlayerNearby(v) and not self.m_TrickOrTreatPIDs[v:getId()].currentHouseId then
					table.insert(d.playersNearby, v)
					self.m_TrickOrTreatPIDs[v:getId()].trickStarted = getTickCount()
					self.m_TrickOrTreatPIDs[v:getId()].currentHouseId = houseId
				end
			end
		end
	end
end

function Halloween:checkForTTScream(player, text)
	local pId = player:getId()
	if player.vehicle or player:getPrivateSync("isAttachedToVehicle") then return end
	
	self:initTTPlayer(pId)
	local d = self.m_TrickOrTreatPIDs[pId]
	if text:lower():gsub("ß", "ss"):find("süsses oder saures") then
		outputDebug("chatted tt", player)
		d.lastMessage = getTickCount()
	end
end

function Halloween:finishTrickOrTreat(player, houseId)
	local pId = player:getId()

	for i, v in pairs(self.m_TrickOrTreatPIDs[pId].playersNearby) do --this includes "player" as he gets inserted in registerTrickOrTreat
		if v and isElement(v) then
			if HouseManager:getSingleton().m_Houses[houseId]:isPlayerNearby(v) then
				local d = self.m_TrickOrTreatPIDs[v:getId()]
				if d.lastMessage and d.lastMessage > d.trickStarted and (getTickCount() - d.lastVisited) < 30000 then
					if d.currentHouseId == houseId then
						player:sendShortMessage("jo hat geklappt für "..inspect(v))
						d.visitedHouses[houseId] = getTickCount()
						d.lastVisited = getTickCount()
						d.currentHouseId = nil
						d.lastMessage = nil
					end
				end
			end
		end
	end
end