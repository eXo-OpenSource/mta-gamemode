-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/EasterSlotmachine.lua
-- *  PURPOSE:     EasterSlotmachine class - from iLife
-- *
-- ****************************************************************************
EasterSlotmachine = inherit(Object)
EasterSlotmachine.Slots = {
	[1] = "VIP",
	[2] = "Easter_Egg",
	[3] = "Vehicle",
	[4] = "Money",
	[5] = "Easter_Eggs",
	[6] = "Bunny_Ears",
}
slot_machines = {}

function EasterSlotmachine:constructor(x, y, z, rx, ry, rz, int, dim)
	if not int then
		int = 0
	end
	if not dim then
		dim = 0
	end

	self.ms_Settings = {}

	-- Methods
	self.m_ResultFunc = bind(self.doResult, self)
	self.m_ResetFunc = bind(self.reset, self)
	self.m_StartFunc = bind(self.startPlayer, self)
	self.m_HebelClickFunc = function(btn, state, player)
		local dist = getDistanceBetweenPoints3D(source:getPosition(), player:getPosition())
		if dist <= 5 then
			if btn == "left" and state == "down" then
				self:startPlayer(player)
			end
		end
	end;
	-- Instances

	self.m_Objects = {}

	self.m_Objects.rolls = {}
	-- self.hebel
	-- self.wood
	-- self.gun
	self.canSpin = true

	self.ms_Settings.iconNames = {
		[900] = EasterSlotmachine.Slots[1],
		[1100] = EasterSlotmachine.Slots[1],
		[1300] = EasterSlotmachine.Slots[2],
		[1400] = EasterSlotmachine.Slots[4],
		[1500] = EasterSlotmachine.Slots[4],
		[1600] = EasterSlotmachine.Slots[4],
		[1700] = EasterSlotmachine.Slots[6],
		[1800] = EasterSlotmachine.Slots[3],
		[1900] = EasterSlotmachine.Slots[6],
		[2000] = EasterSlotmachine.Slots[4],
		[2100] = EasterSlotmachine.Slots[6],
		[2300] = EasterSlotmachine.Slots[6],
		[2140] = EasterSlotmachine.Slots[5],
	}

	-- Objects
	-- EasterSlotmachine


	self.m_Objects.slotmachine = createObject(2325, x, y, z, rx, ry, rz)
	self.m_Objects.slotmachine:setData("Easter", true, true)
	self.m_BankAccountServer = BankServer.get("event.easter")

	setObjectScale(self.m_Objects.slotmachine, 2)

	slot_machines[self.m_Objects.slotmachine] = self.m_Objects.slotmachine;
	-- Rolls

	for i = 1, 3, 1 do
		self.m_Objects.rolls[i] = createObject(2347, x, y, z)
		setElementData(self.m_Objects.rolls[i], "EasterSlotmachine", true)
		setObjectScale(self.m_Objects.rolls[i], 2)
		attachElements(self.m_Objects.rolls[i], self.m_Objects.slotmachine, -0.45+i/4, 0, 0)
	end

	-- Lever ( Hebel )

	self.m_Objects.hebel = createObject(1319, x, y, z)
	attachElements(self.m_Objects.hebel, self.m_Objects.slotmachine, 0.9, -0.3, 0, 50, 0, rz*(360)/90)
	setElementFrozen(self.m_Objects.hebel, true)
	setElementData(self.m_Objects.hebel, "SLOTMACHINE:LEVER", true)
	self.m_Objects.hebel:setData("clickable", true, true)

	-- Wood

	self.m_Objects.wood = createObject(3260, x, y, z)
	setObjectScale(self.m_Objects.wood, 0.7)
	attachElements(self.m_Objects.wood, self.m_Objects.slotmachine, 0, 0.5, -0.5)


	-- Dimension and Interior

	for index, object in pairs(self.m_Objects) do
		if type(object) == "table" then
			for index, e1 in pairs(object) do
				setElementInterior(e1, int)
				setElementDimension(e1, dim)
			end
		else
			setElementInterior(object, int)
			setElementDimension(object, dim)
		end
	end

--	outputDebugString("[CALLING] EasterSlotmachine: Constructor")

	-- Events --
	addEventHandler("onElementClicked", self.m_Objects.hebel, self.m_HebelClickFunc)
	setElementData(self.m_Objects.hebel, "SLOTMACHINE:ID", self) -- Store the Object in the element data
end

-- ///////////////////////////////
-- ///// reset		 		//////
-- ///// Returns: bool		//////
-- ///////////////////////////////

function EasterSlotmachine:reset()
	if self.canSpin == false then
		self.canSpin = true

		return true;
	end
end

-- Premium
-- Vehicle
-- 20 Ostereier
-- Geld (20k)
-- 5 Ostereier
-- Hasenohren

function EasterSlotmachine:calculateSpin()
	local spinTable = {
		1100, -- Premium -- "increased"
		1800, -- Vehicle
		1800, -- Vehicle
		2140, -- 20 Ostereier
		2140, -- 20 Ostereier
		2140, -- 20 Ostereier
		2140, -- 20 Ostereier
		2140, -- 20 Ostereier
		2140, -- 20 Ostereier
		2140, -- 20 Ostereier
		1500, -- Geld (20k)
		1600, -- Geld (20k)
		2000, -- Geld (20k)
		1600, -- Geld (20k)
		1400, -- Geld (20k)
		1500, -- Geld (20k)
		1500, -- Geld (20k)
		1300, -- Ostereier (x5)
		1300, -- Ostereier (x5)
		1300, -- Ostereier (x5)
		1300, -- Ostereier (x5)
		1300, -- Ostereier (x5)
		1300, -- Ostereier (x5)
		1300, -- Ostereier (x5)
		1300, -- Ostereier (x5)
		1700, -- Hasenohren
		1900, -- Hasenohren
		2100, -- Hasenohren
		2300, -- Hasenohren
		1700, -- Hasenohren
		1700, -- Hasenohren
		1900, -- Hasenohren
		2100, -- Hasenohren
	}

	local rotation = spinTable[math.random(1, #spinTable)]
	return rotation, self.ms_Settings.iconNames[rotation]
end

function EasterSlotmachine:moveLever(player)
	local x, y, z = getElementPosition(self.m_Objects.hebel)
	local _, _, _, rx, ry, rz = getElementAttachedOffsets(self.m_Objects.hebel)
	local _, _, rz = getElementRotation(self.m_Objects.slotmachine)
	detachElements(self.m_Objects.hebel)

	setElementPosition(self.m_Objects.hebel, x, y, z)
	setElementRotation(self.m_Objects.hebel, rx, ry, rz)

	moveObject(self.m_Objects.hebel, 450, x, y, z, 50, 0, 0, "InQuad")

	setTimer(
		function()
			moveObject(self.m_Objects.hebel, 450, x, y, z, -50, 0, 0, "InQuad")
		end, 450, 1
	)

	local int, dim = self.m_Objects.slotmachine:getInterior(), self.m_Objects.slotmachine:getDimension()
	setTimer(triggerClientEvent, 150, 1, root, "onSlotmachineSoundPlay", root, x, y, z, "start_machine", int, dim)


	setTimer(function() self:spin(player) end, 500, 1, player)

	return true;
end

function EasterSlotmachine:spin(player)
	local ergebnis = {}
	for i = 1, 3, 1 do
		local grad, icon = self:calculateSpin()
		local x, y, z = getElementPosition(self.m_Objects.rolls[i])
		local _, _, _, rx, ry, rz = getElementAttachedOffsets(self.m_Objects.rolls[i])
		rx, _, _ = getElementRotation(self.m_Objects.rolls[i])
		_, _, rz = getElementRotation(self.m_Objects.slotmachine)

		if isElementAttached(self.m_Objects.rolls[i]) then
			detachElements(self.m_Objects.rolls[i])

			setElementPosition(self.m_Objects.rolls[i], x, y, z)
			setElementRotation(self.m_Objects.rolls[i], rx, ry, rz)

		end

		moveObject(self.m_Objects.rolls[i], 2500+(i*600), x, y, z, grad, 0, 0, "InQuad")

		ergebnis[i] = icon
	end

	setTimer(self.m_ResultFunc, 4100, 1, ergebnis, player)
	return true;
end

function EasterSlotmachine:checkRolls()
	for i = 1, 3, 1 do
		local x, y, z = getElementPosition(self.m_Objects.rolls[i])
		if not isElementAttached(self.m_Objects.rolls[i]) then
			local rx, ry, _ = getElementRotation(self.m_Objects.rolls[i])

			moveObject(self.m_Objects.rolls[i], 100, x, y, z, -rx, 0, 0, "InQuad")
		end
	end
end

function EasterSlotmachine:start(player)
	if self.canSpin == true then
		self.canSpin = false;
		self:checkRolls()
		setTimer(function()
			self:moveLever(player)
		end, 100, 1)
	end
end

function EasterSlotmachine:giveWin(player, name, x, y, z)
	if name == "Trostpreis" then
		local rnd = math.random(500, 5000)
		player:sendInfo(_("Du hast %d$ gewonnen!", player, rnd))
		self.m_BankAccountServer:transferMoney(player, rnd, "EasterSlotmaschine", "Event", "Easter")

		triggerClientEvent(root, "onSlotmachineSoundPlay", root, x, y, z, "win_stuff")
		StatisticsLogger:addCasino(player, name, rnd)
	elseif name == "Money" then
		local rnd = math.random(15000, 25000)
		player:sendInfo(_("Du hast %d$ gewonnen!", player, rnd))
		self.m_BankAccountServer:transferMoney(player, rnd, "EasterSlotmaschine", "Event", "Easter")

		triggerClientEvent(root, "onSlotmachineSoundPlay", root, x, y, z, "win_stuff")
		StatisticsLogger:addCasino(player, name, rnd)
	elseif name == "Ostereier5" then
		player:sendInfo("Du hast 5 Ostereier gewonnen!")
		player:getInventory():giveItem("Osterei", 5)

		triggerClientEvent(root, "onSlotmachineSoundPlay", root, x, y, z, "win_stuff")
	elseif name == "Ostereier20" then
		player:sendInfo("Du hast 20 Ostereier gewonnen!")
		player:getInventory():giveItem("Osterei", 20)

		triggerClientEvent(root, "onSlotmachineSoundPlay", root, x, y, z, "win_stuff")
		StatisticsLogger:addCasino(player, name, 20)
	elseif name == "Premium" then
		player:sendInfo("Du hast einen Monat Premium gewonnen! Gratulation!")
		player.m_Premium:giveEasterMonth()

		triggerClientEvent(root, "onSlotmachineSoundPlay", root, x, y, z, "win_jackpot")
		StatisticsLogger:addCasino(player, name, 1)
	elseif name == "HasenOhren" then
		player:getInventory():giveItem("Hasenohren", 1)

		triggerClientEvent(root, "onSlotmachineSoundPlay", root, x, y, z, "win_stuff")
		StatisticsLogger:addCasino(player, name, 1)
	elseif name == "Vehicle" then
		local vehicles = {
			{ id=447, name="Seasparrow", 	spawnPosX=1902, spawnPosY=-2630.7, spawnPosZ=13.8, spawnPosXR=0, spawnPosYR=0, spawnPosZR=0 }, 	-- Seasparrow
			{ id=476, name="Rustler", 		spawnPosX=1902, spawnPosY=-2630.7, spawnPosZ=13.3, spawnPosXR=0, spawnPosYR=0, spawnPosZR=0 }	-- Rustler
		}
		local vehicleData = vehicles[math.random(1, 2)]

		player:sendInfo("Du hast einen " .. vehicleData.name .. " gewonnen! Gückwunsch!")
		local vehicle = VehicleManager:getSingleton():createNewVehicle(player, VehicleTypes.Player, vehicleData.id, vehicleData.spawnPosX, vehicleData.spawnPosY, vehicleData.spawnPosZ, vehicleData.spawnPosXR, vehicleData.spawnPosYR, vehicleData.spawnPosZR, 0)
		if vehicle then
			warpPedIntoVehicle(player, vehicle)
			player:triggerEvent("vehicleBought")
		else
			player:sendMessage(_("Fehler beim Erstellen des Fahrzeugs. Bitte benachrichtige einen Admin!", player), 255, 0, 0)
		end

		triggerClientEvent(root, "onSlotmachineSoundPlay", root, x, y, z, "win_jackpot")
		StatisticsLogger:addCasino(player, name, 1)
	else
		player:sendError(_("Unknown Win! %s", player, name))
	end
end

function EasterSlotmachine:doResult(ergebnis, player)
	local x, y, z = getElementPosition(self.m_Objects.slotmachine)

	local result = {}
	for index, name in pairs(EasterSlotmachine.Slots) do
		result[name] = 0
	end

	for _, data in pairs(ergebnis) do
		result[data] = result[data]+1
	end

	if result["VIP"] == 3 then
		self:giveWin(player, "Premium", x, y, z)
	elseif result["Easter_Egg"] == 3 then
		self:giveWin(player, "Ostereier5", x, y, z)
	elseif result["Vehicle"] == 3 then
		self:giveWin(player, "Vehicle", x, y, z)
	elseif result["Money"] == 3 then
		self:giveWin(player, "Money", x, y, z)
	elseif result["Easter_Eggs"] == 3 then
		self:giveWin(player, "Ostereier20", x, y, z)
	elseif result["Bunny_Ears"] == 3 then
		self:giveWin(player, "HasenOhren", x, y, z)
	elseif result["VIP"] == 2 or result["Easter_Egg"] == 2 or result["Vehicle"] == 2 or result["Money"] == 2 or result["Easter_Eggs"] == 2 or result["Bunny_Ears"] == 2 then
		self:giveWin(player, "Trostpreis", x, y, z)
	else
		player:sendInfo(_("Du hast leider nichts gewonnen!", player))
		triggerClientEvent(root, "onSlotmachineSoundPlay", root, x, y, z, "win_nothing")
	end

	setTimer(self.m_ResetFunc, 1500, 1)
end

function EasterSlotmachine:startPlayer(player)
	if not self.canSpin then return end

	if player:getInventory():removeItem("Osterei", 2) then
		self:start(player)
	else
		player:sendWarning(_("Du brauchst mind. 2 Ostereier, um spielen zu können", player))
	end
end
