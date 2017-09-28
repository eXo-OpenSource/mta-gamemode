-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
TurtleRace = inherit(Singleton)
TurtleRace.MainPos = Vector3(335.34, -1851.64, 3.32)
TurtleRace.FinishPos = -1907
TurtleRace.Positions = {
	[1] = Vector3(355, -1823, 3.2),
	[2] = Vector3(350, -1823, 3.2),
	[3] = Vector3(345, -1823, 3.2),
	[4] = Vector3(340, -1823, 3.2),
	[5] = Vector3(335, -1823, 3.2),
	[6] = Vector3(330, -1823, 3.2),
}
TurtleRace.Fences = {
	[1] = Vector3(351.5, -1825.5, 3.3),
	[2] = Vector3(341.2, -1825.5, 3.3),
	[3] = Vector3(330.5, -1825.5, 3.3),
}

addRemoteEvents{"TurtleRaceAddBet"}
function TurtleRace:constructor()
	self.m_Stats = StatisticsLogger:getSingleton():getGameStats("TurtleRace")

	self.m_State = "None"
	self.m_ColShapeHit = bind(TurtleRace.onColShapeHit, self)

	self.m_Blip = Blip:new("Turtle.png", 318, -1820)
	self.m_Blip:setDisplayText("Schildkröten Rennen", BLIP_CATEGORY.Leisure)
	self.m_Blip:setOptionalColor({50, 170, 20})

	GlobalTimer:getSingleton():registerEvent(TurtleRace.infoMessage, "TurtleRaceInfo", nil, 10, 00)
	GlobalTimer:getSingleton():registerEvent(TurtleRace.infoMessage, "TurtleRaceInfo", nil, 13, 00)
	GlobalTimer:getSingleton():registerEvent(TurtleRace.infoMessage, "TurtleRaceInfo", nil, 16, 00)
	GlobalTimer:getSingleton():registerEvent(TurtleRace.infoMessage, "TurtleRaceInfo", nil, 19, 00)
	GlobalTimer:getSingleton():registerEvent(TurtleRace.infoMessage2, "TurtleRaceInfo2", nil, 20, 05)
	GlobalTimer:getSingleton():registerEvent(bind(TurtleRace.setState, self), "TurtleRaceCreate", nil, 20, 30, "Preparing")
	GlobalTimer:getSingleton():registerEvent(bind(TurtleRace.setState, self), "TurtleRaceStart", nil, 21, 00, "GridCountdown")

	addEventHandler("TurtleRaceAddBet", root, bind(TurtleRace.addBet, self))
end

function TurtleRace:destructor()
end

function TurtleRace.infoMessage()
	PlayerManager:getSingleton():sendShortMessage("Um 21:00 Uhr findet das tägliche Schildkrötenrennen statt! Du kannst am Strand auf eine Schildkröte Geld setzen und das rennen vor Ort anschauen. Viel Glück!", "Schildkrötenrennen", {50, 170, 20}, 10000)
end

function TurtleRace.infoMessage2()
	PlayerManager:getSingleton():sendShortMessage("Pferderennen vorbei? Nichts gewonnen? Versuch dein Glück um 21:00 Uhr beim Schildkrötenrennen am Strand!", "Schildkrötenrennen", {50, 170, 20}, 10000)
end

function TurtleRace:createGame()
	self.m_ColShape = ColShape.Sphere(TurtleRace.MainPos, 250)
	self.m_Turtles = {}
	self.m_Fences = {}

	for _, pos in pairs(TurtleRace.Fences) do
		local fence = createObject(996, pos)
		fence:setFrozen(true)
		table.insert(self.m_Fences, fence)
	end

	for i, pos in ipairs(TurtleRace.Positions) do
		local turtle = createObject(1609, pos, Vector3(0, 0, 180))
		turtle:setScale(.5)
		table.insert(self.m_Turtles, {id = i, object = turtle, defaultPosition = pos, startPosition = {getElementPosition(turtle)}})
	end

	self.m_Map = MapParser:new("files/maps/turtle_race.map")
	self.m_Map:create()

	local players = self.m_ColShape:getElementsWithin("player")
	for _, player in pairs(players) do
		player:triggerEvent("turtleRaceInit", self.m_Turtles)
	end

	addEventHandler("onColShapeHit", self.m_ColShape, self.m_ColShapeHit)
end

function TurtleRace:destroyGame()
	if self.m_Turtles then
		for _, turtle in pairs(self.m_Turtles) do
			turtle.object:destroy()
		end
	end

	if self.m_Fences then
		for _, fence in pairs(self.m_Fences) do
			if isElement(fence) then fence:destroy() end
		end
	end

	if self.m_Map then
		delete(self.m_Map)
	end

	if self.m_ColShape then
		removeEventHandler("onColShapeHit", self.m_ColShape, self.m_ColShapeHit)
		self.m_ColShape:destroy()
	end

	self.m_State = "None"
	self.m_Turtles = nil
	self.m_Map = nil
end

function TurtleRace:onColShapeHit(hitElement, matchingDimension)
	if getElementType(source) ~= "player" then return end
	source:triggerEvent("turtleRaceInit", self.m_Turtles)
end

function TurtleRace:updateTurtlePositions()
	for _, turtle in pairs(self.m_Turtles) do
		if turtle.endPosition then
			turtle.startPosition = turtle.endPosition
			turtle.object.position = Vector3(unpack(turtle.endPosition))
			if turtle.object.position.y <= TurtleRace.FinishPos then
				if isTimer(self.m_GameTimer) then killTimer(self.m_GameTimer) end
				self.m_FinishedTurtle = turtle.id
				self:setState("Finished")
				return
			end
		end

		local position = turtle.object.position

		position.x = position.x + math.random(-3, 3)/10
		position.y = position.y + math.random(-20, -5)/10

		turtle.duration = 1000
		turtle.endPosition = {position.x, position.y, position.z}
	end
end

function TurtleRace:setState(state)
	if state == "Running" and self.m_State == "GridCountdown" then
		self.m_State = state
		self:updateTurtlePositions()
		self:syncTurtles()

		self.m_GameTimer = setTimer(
			function()
				self:updateTurtlePositions()
				self:syncTurtles()
			end, 1000, 0
		)
	elseif state == "GridCountdown" and self.m_State == "Preparing" then
		self.m_State = state

		local players = self.m_ColShape:getElementsWithin("player")
		for _, player in pairs(players) do
			player:triggerEvent("turtleRaceCountdown")
		end

		for _, fence in pairs(self.m_Fences) do
			fence:move(3000, fence.matrix:transformPosition(Vector3(0, 0, -.655)))
		end

		local countdown = 3
		setTimer(
			function()
				countdown = countdown - 1
				if countdown == 0 then self:setState("Running") end
			end, 1000, 3
		)
	elseif state == "Finished" and self.m_State == "Running" then
		self.m_State = state
		local players = self.m_ColShape:getElementsWithin("player")
		for _, player in pairs(players) do
			player:triggerEvent("turtleRaceStop", self.m_FinishedTurtle)
		end

		self:checkWinner()

		setTimer(
			function()
				self:setState("None")
			end, 30000, 1
		)
	elseif state == "Preparing" and self.m_State == "None" then
		self.m_State = state
		self:createGame()
	elseif state == "None" then
		self.m_State = state
		self:destroyGame()
	end
end

function TurtleRace:syncTurtles()
	if self.m_State == "Running" then
		local players = self.m_ColShape:getElementsWithin("player")
		for _, player in pairs(players) do
			player:triggerEvent("turtleRaceSyncTurtles", self.m_Turtles)
		end
	end
end

function TurtleRace:checkWinner()
	local result = sql:queryFetch("SELECT * FROM ??_turtle_bets", sql:getPrefix())
 	for i, row in pairs(result) do
		local player, isOffline = DatabasePlayer.get(row.UserId)

		if row["TurtleId"] == self.m_FinishedTurtle then
			if player then
				if isOffline then player:load() end

				local win = tonumber(row["Bet"]) * 6
				player:giveMoney(win, "Schildkrötenrennen")
				self.m_Stats["Outgoing"] = self.m_Stats["Outgoing"] + win

				if not isOffline then
					player:sendShortMessage(_("Du hast auf die richtige Schildkröte (%s) gesetzt und %s$ gewonnen!", player, self.m_FinishedTurtle, win), _("Schildkrötenrennen", player), {50, 170, 20})
				end
			end
		else
			if not isOffline then
				player:sendShortMessage(_("Du hast auf die falsche Schildkröte (%s) gesetzt und nichts gewonnen!", player, row["TurtleId"]), _("Schildkrötenrennen", player), {50, 170, 20})
			end
		end

		if isOffline then
			delete(player)
		end
	end

	sql:queryExec("TRUNCATE TABLE ??_turtle_bets", sql:getPrefix())
end

function TurtleRace:addBet(turtleId, money)
	if not turtleId or not money then return end
	if self.m_State ~= "None" and self.m_State ~= "Preparing" then client:sendWarning("Du kannst zum aktuellen Zeitpunkt keine Wette setzen!") return end
	if client:getMoney() < money then client:sendError("Du hast nicht genug Geld dabei!") return end

	local row = sql:queryFetchSingle("SELECT * FROM ??_turtle_bets WHERE UserId = ?;", sql:getPrefix(), client:getId())
	if row then client:sendError("Du hast bereits eine Wette am laufen!") return end

	client:takeMoney(money, "Turtle-Race")
	client:sendShortMessage(_("Du hast %s auf Schildkröte %s gesetzt!", client, money, turtleId), _("Schildkrötenrennen", client), {50, 170, 20})
	sql:queryExec("INSERT INTO ??_turtle_bets (UserId, Bet, TurtleId) VALUES (?, ?, ?)", sql:getPrefix(), client:getId(), money, turtleId)

	self.m_Stats["Incoming"] = self.m_Stats["Incoming"] + money
	self.m_Stats["Played"] = self.m_Stats["Played"] + 1
end
