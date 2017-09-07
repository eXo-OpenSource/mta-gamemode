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

addRemoteEvents{"TurtleRaceAddBet"}
function TurtleRace:constructor()
	self.m_State = "None"
	self.m_ColShapeHit = bind(TurtleRace.onColShapeHit, self)

	self.m_Blip = Blip:new("Horse.png", 318, -1820)
	self.m_Blip:setDisplayText("Schildkröten Rennen", BLIP_CATEGORY.Leisure)
	self.m_Blip:setOptionalColor({50, 170, 20})
	
	self.m_InfoMessage = bind(TurtleRace.infoMessage, self)
	GlobalTimer:getSingleton():registerEvent(self.m_InfoMessage, "TurtleRaceInfo", nil, 10, 00)
	GlobalTimer:getSingleton():registerEvent(self.m_InfoMessage, "TurtleRaceInfo", nil, 13, 00)
	GlobalTimer:getSingleton():registerEvent(self.m_InfoMessage, "TurtleRaceInfo", nil, 16, 00)
	GlobalTimer:getSingleton():registerEvent(self.m_InfoMessage, "TurtleRaceInfo", nil, 19, 00)
	GlobalTimer:getSingleton():registerEvent(bind(TurtleRace.infoMessage2, self), "TurtleRaceInfo2", nil, 20, 05)
	GlobalTimer:getSingleton():registerEvent(bind(TurtleRace.createGame, self), "TurtleRaceCreate", nil, 20, 30)
	GlobalTimer:getSingleton():registerEvent(bind(TurtleRace.startGame, self), "TurtleRaceStart", nil, 21, 00)
end

function TurtleRace:destructor()
end

-- Todo: replace chatbox output with global shortmessage luLz
function TurtleRace:infoMessage()
	outputChatBox("[Turtle-Race] Um 21:00 Uhr findet das tägliche Schildkrötenrennen statt, du kannst am Strand", root, 50, 170, 20)
	outputChatBox("auf eine Schildkröte Geld setzen und um 21:00 Uhr das rennen anschauen. Viel Glück!", root, 50, 170, 20)
end

function TurtleRace:infoMessage2()
	outputChatBox("[Turtle-Race] Pferderennen vorbei? Um 21:00 Uhr startet das Schildkrötenrennen am Strand!", root, 50, 170, 20)
end

function TurtleRace:createGame()
	self.m_State = "Preparing"
	self.m_ColShape = ColShape.Sphere(TurtleRace.MainPos, 250)
	self.m_Turtles = {}

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
	self.m_State = "None"
	for _, turtle in pairs(self.m_Turtles) do
		turtle.object:destroy()
	end

	if self.m_Map then
		delete(self.m_Map)
	end

	if self.m_ColShape then
		self.m_ColShape:destroy()
	end

	self.m_Turtles = nil
	self.m_Map = nil
	
	removeEventHandler("onColShapeHit", self.m_ColShape, self.m_ColShapeHit)
end

function TurtleRace:startGame()
	self.m_State = "Running"
	self:updateTurtlePositions()
	self:syncTurtles()

	self.m_GameTimer = setTimer(
		function()
			self:updateTurtlePositions()
			self:syncTurtles()
		end, 1000, 0
	)
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
				self.m_State = "Finished"
				outputChatBox("WINNER: " .. tostring(turtle.id))
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

function TurtleRace:syncTurtles()
	local players = self.m_ColShape:getElementsWithin("player")
	
	if self.m_State == "Running" then	
		for _, player in pairs(players) do
			player:triggerEvent("turtleRaceSyncTurtles", self.m_Turtles)
		end
	elseif self.m_State == "Finished" then
		for _, player in pairs(players) do
			player:triggerEvent("turtleRaceStop")
		end
	end
end