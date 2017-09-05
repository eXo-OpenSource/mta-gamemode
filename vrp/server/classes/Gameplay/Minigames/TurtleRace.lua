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
	self.m_Players = {}

	self.m_Blip = Blip:new("Horse.png", 318, -1820)
	self.m_Blip:setDisplayText("Schildkröten Rennen", BLIP_CATEGORY.Leisure)
	self.m_Blip:setOptionalColor({50, 170, 20})
end

function TurtleRace:destructor()
end

function TurtleRace:createGame()
	self.m_Turtles = {}

	for i, pos in ipairs(TurtleRace.Positions) do
		local turtle = createObject(1609, pos, Vector3(0, 0, 180))
		turtle:setScale(.5)
		table.insert(self.m_Turtles, {id = i, object = turtle, defaultPosition = pos, toPosition = nil})
	end

	self.m_Map = MapParser:new("files/maps/turtle_race.map")
	self.m_Map:create()
end

function TurtleRace:destroyGame()
	for _, turtle in pairs(self.m_Turtles) do
		turtle.object:destroy()
	end

	if self.m_Map then
		delete(self.m_Map)
	end

	self.m_Turtles = nil
	self.m_Map = nil
end

function TurtleRace:startGame()

	self.m_GameTimer = setTimer(
		function()
			self:updateTurtlePositions()
			self:syncTurtles()
		end, 50, 0
	)

	--for _, turtle in pairs(self.m_Turtles) do

	--end
end

function TurtleRace:updateTurtlePositions()
	for _, turtle in pairs(self.m_Turtles) do
		if turtle.toPosition then
			--outputChatBox("set serverside")
			--turtle.object:setPosition(unpack(turtle.toPosition))
			turtle.object.position = Vector3(unpack(turtle.toPosition))
			if turtle.object.position.y <= TurtleRace.FinishPos then
				if isTimer(self.m_GameTimer) then killTimer(self.m_GameTimer) end
				outputChatBox("WINNDER: " .. tostring(turtle.id))
			end
		end

		local position = turtle.object.position

		position.x = position.x + math.random(-1, 1)/100
		position.y = position.y + math.random(-10, 1)/1000

		turtle.toPosition = {position.x, position.y, position.z}
	end
end

function TurtleRace:syncTurtles()
	local colShape = ColShape.Sphere(TurtleRace.MainPos, 250)
	local players = colShape:getElementsWithin("player")
	colShape:destroy()

	for _, player in pairs(players) do
		outputChatBox("SendTo:" .. tostring(player:getName()))
		player:triggerEvent("turtleRaceSyncTurtles", self.m_Turtles)
	end
end
