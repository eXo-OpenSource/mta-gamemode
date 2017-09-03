-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
TurtleRace = inherit(Singleton)
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

	for _, pos in pairs(TurtleRace.Positions) do
		local turtle = createObject(1609, pos, Vector3(0, 0, 180))
		turtle:setScale(.5)
		table.insert(self.m_Turtles, turtle)
	end

	-- load map tho
end
