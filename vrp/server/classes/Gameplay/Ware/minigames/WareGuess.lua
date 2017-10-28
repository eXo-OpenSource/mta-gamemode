-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareGuess.lua
-- *  PURPOSE:     WareGuess class
-- *
-- ****************************************************************************
WareGuess = inherit(Object)
WareGuess.modeDesc = "Rate die Anzahl der Fahrzeuge!"
WareGuess.timeScale = 0.7
WareGuess.vehicleIds = {
   602, 496, 401, 518, 527, 589, 419, 462, 509, 522, 598, 583, 482
}

function WareGuess:constructor( super )
	self.m_Super = super
	local x,y,z,width,height = unpack(self.m_Super.m_Arena)
	for key, p in ipairs(self.m_Super.m_Players) do
		showChat(p, true)
		setCameraMatrix(p, x, y, z+15, x+width*0.5, y+height*0.5, z)
		setElementAlpha(p, 0)
	end
	self.m_Numbers = {}
	self.m_WrongPlayers = {}
	self.m_Winners = {}
	self:spawnCars()
end

function WareGuess:spawnCars()
	self.m_Cars = {}
	local x,y,z,width,height = unpack(self.m_Super.m_Arena)
	local randomNumber = math.random(4, 25)
	local randomVehicle
	local rx, ry, rz
	for i = 1, randomNumber do
		randomVehicle =  math.random(1, #WareGuess.vehicleIds)
		rx = math.random(1, width*0.5)
		ry = math.random(1, height*0.5)
		rz = math.random(1, 5)
		rx = x + width*0.2 + rx
		ry = y + height*0.2 + ry
		self.m_Cars[#self.m_Cars+1] = createVehicle(WareGuess.vehicleIds[randomVehicle], rx, ry, z+rz )
		setVehicleDamageProof(self.m_Cars[#self.m_Cars], true)
		setElementDimension(self.m_Cars[#self.m_Cars], self.m_Super.m_Dimension)
	end
	self.m_RightAnswer = randomNumber
end

function WareGuess:checkWinner()
	local nearest = 999
	local nearestPlayers = {}
	for player, number in pairs(self.m_Numbers) do
		if math.abs(self.m_RightAnswer-number) < nearest then
			nearest = number
		end
	end

	for player, number in pairs(self.m_Numbers) do
		if number == nearest then
			self.m_Winners[player] = true
		else
			self.m_WrongPlayers[player] = true
		end
	end
end

function WareGuess:onChat(player, text, type)
	if not tonumber(text) then
		player:sendError("Du hast eine ungültige Zahl eingegeben!")
		return
	end

	if self.m_Numbers[player] then
		player:sendError("Du hast bereits eine Zahl angegeben!")
		return
	end
	self.m_Numbers[player] = tonumber(text)

	if tonumber(text) == self.m_RightAnswer then
		if not self.m_WrongPlayers[player] then
			self.m_Super:addPlayerToWinners(player)
			self.m_Winners[player] = true
		end
	else
		if not self.m_Winners[player] then
			self.m_WrongPlayers[player] = true
			player:triggerEvent("onClientWareFail")
		end
	end
	return false
end

function WareGuess:destructor()
	self:checkWinner()

	for key, p in ipairs(self.m_Super.m_Players) do
		showChat(p, false)
		setCameraTarget(p, p)
		setElementAlpha(p, 255)
	end
	for i = 1, #self.m_Cars do
		destroyElement(self.m_Cars[i])
	end
end
