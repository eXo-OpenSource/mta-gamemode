-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/EasterSlotmachine.lua
-- *  PURPOSE:     EasterSlotmachine class - from iLife
-- *
-- ****************************************************************************
EasterSlotmachine = inherit(Object)

slot_machines = {}

function EasterSlotmachine:constructor(x, y, z, rx, ry, rz, int, dim)
	if not int then
		int = 0
	end
	if not dim then
		dim = 0
	end

	-- Instances
	self.m_Prices = {}

	-- PRICES --
	-- Here you can change the winning things --
	self.m_Prices.bet 					= 5;			-- Bet amount

	self.m_Prices.normalPrice 			= 5; 		-- Minimum Win Ammount (2 Right icons)			-- Info: This ammount will be there in ANY case
	self.m_Prices.maxNormalRandomPrice 	= 700;			-- Maximum Random Win-add Ammount (2 Right icons)
								-- Maximum Win Ammount: normalPrice + maxNormalRandomPrice

	self.m_Prices.normalPrice2 			= 5;			-- Minimum Win Ammount 2 (2 Right Rare Icons)	-- This too
	self.m_Prices.maxNormalRandomPrice2 	= 700;			-- Maximum Random Win-add Ammount 2 (2 Right Rare Icons)
								-- Maximum Win Ammount: normalPrice + maxNormalRandomPrice

	self.m_Prices.jackpot 				= 5000;		-- Jackpot Price
	self.m_Prices.rareJackpot 			= 13370;		-- Rare Jackpot Price

	--  {5, 1, false}
	-- Definition:
	-- {iWeaponID, iWeaponAmmo}

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
		[900] = "69",
		[1100] = "69",
		[1300] = "Gold 1",
		[1400] = "Glocke",
		[1500] = "Glocke",
		[1600] = "Glocke",
		[1700] = "Weintraube",
		[1800] = "Gold 2",
		[1900] = "Weintraube",
		[2000] = "Glocke",
		[2100] = "Weintraube",
		[2300] = "Weintraube",
		[2140] = "Kirsche",
	}

	-- Objects
	-- EasterSlotmachine


	self.m_Objects.slotmachine = createObject(2325, x, y, z, rx, ry, rz)
	self.m_Objects.slotmachine:setData("Easter", true, true)

	setObjectScale(self.m_Objects.slotmachine, 2)

	slot_machines[self.m_Objects.slotmachine] = self.m_Objects.slotmachine;
	-- Rolls

	for i = 1, 3, 1 do
		self.m_Objects.rolls[i] = createObject(2326, x, y, z)
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

function EasterSlotmachine:calculateSpin()
	local rnd = tonumber(math.random(1, 9))
	local grad = 0
	if rnd == 1 then
		if math.random(0, 5) == 5 then
			grad = 1100					-- 69
		else
			grad = 1300					-- Gold 1
		end
	elseif rnd == 2 then
		if math.random(0, 5) == 5 then
			grad = 1100					-- 69
		else
			grad = 2300					-- Weintraube
		end
	elseif rnd == 3 then
		grad = 1600						-- Glocke
	elseif rnd == 4 then
		grad = 2140						-- Kirsche
	elseif rnd == 5 then
		grad = 1800						-- Gold 2
	elseif rnd == 6 then
		grad = 1900						-- Weintraube
	elseif rnd == 7 then
		grad = 1800						-- Glocke
	elseif rnd == 8 then
		grad = 2140						--  -- Kische
	elseif rnd == 9 then
		grad = 2140						-- Kirsche
	end

	return grad, self.ms_Settings.iconNames[grad];
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
	setTimer(triggerClientEvent, 150, 1, getRootElement(), "onSlotmachineSoundPlay", getRootElement(), x, y, z, "start_machine", int, dim)


	setTimer(function() self:spin(player) end, 500, 1, player)

	return true;
end

function EasterSlotmachine:spin(player)
	local ergebnis = {}
	for i = 1, 3, 1 do
		local grad, icon = self:calculateSpin()
		--	grad, icon = 900, "69"
		local x, y, z = getElementPosition(self.m_Objects.rolls[i])
		local _, _, _, rx, ry, rz = getElementAttachedOffsets(self.m_Objects.rolls[i])
		--if rx == 0 then
		rx, _, _ = getElementRotation(self.m_Objects.rolls[i])
		--end
		local _, _, rz = getElementRotation(self.m_Objects.slotmachine)
		if isElementAttached(self.m_Objects.rolls[i]) then
			detachElements(self.m_Objects.rolls[i])

			setElementPosition(self.m_Objects.rolls[i], x, y, z)
			setElementRotation(self.m_Objects.rolls[i], rx, ry, rz)

		end
		--	outputChatBox(grad-rx)

		--	outputChatBox(rx-grad)
		local s = moveObject(self.m_Objects.rolls[i], 2500+(i*600), x, y, z, grad, 0, 0, "InQuad")

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
	outputChatBox("Won: " .. name)
	triggerClientEvent(getRootElement(), "onSlotmachineSoundPlay", getRootElement(), x, y, z, "win_stuff")
	--StatisticsLogger:addCasino( player, name, self.m_Prices.rareJackpot)

	-- todo
end

function EasterSlotmachine:doResult(ergebnis, player)
	local x, y, z = getElementPosition(self.m_Objects.slotmachine)
	local kirschen = 0
	local glocken = 0
	local weintrauben = 0
	local gold1 = 0
	local gold2 = 0
	local rare = 0

	for _, data in pairs(ergebnis) do
		if data == "69" then
			rare = rare+1
		end
		if data == "Glocke" then
			glocken = glocken+1
		end
		if data == "Gold 1" then
			gold1 = gold1+1

		end
		if data == "Gold 2" then
			gold2 = gold2+1
		end
		if data == "Weintraube" then
			weintrauben = weintrauben+1
		end
		if data == "Kirsche" then
			kirschen = kirschen+1
		end
	end

	outputChatBox("Kirschen: " .. kirschen)
	outputChatBox("Glocken: " .. glocken)
	outputChatBox("Weintrauben: " .. weintrauben)
	outputChatBox("Gold1: " .. gold1)
	outputChatBox("Gold2: " .. gold2)
	outputChatBox("Rare" .. rare)

	if glocken == 2 or weintrauben == 2 or gold1 == 2 or kirschen == 2 then
		self:giveWin(player, "RandomMoney", x, y, z)
	elseif glocken == 3 then
		self:giveWin(player, " - 3x Glocken -", x, y, z)
	elseif kirschen == 3 and gold2 == 1 then
		self:giveWin(player, " - 3x kirschen / 1x gold2 -", x, y, z)
	elseif gold2 == 3 then
		self:giveWin(player, " - 3x gold2 -", x, y, z)
	elseif weintrauben == 3 then
		self:giveWin(player, "HasenOhren", x, y, z)
	elseif rare == 3 then
		self:giveWin(player, "premium", x, y, z)
	elseif rare == 2 then
		self:giveWin(player, "Penismobil", x, y, z)
	else
		local int, dim = self.m_Objects.slotmachine:getInterior(), self.m_Objects.slotmachine:getDimension()
		player:sendInfo(_("Du hast leider nichts gewonnen!", player))
		triggerClientEvent(getRootElement(), "onSlotmachineSoundPlay", getRootElement(), x, y, z, "win_nothing", int, dim)
	end

	setTimer(self.m_ResetFunc, 1500, 1)
end

function EasterSlotmachine:startPlayer(player)
	if not self.canSpin then return end

	if player:getInventory():getItemAmount("Osterei") >= 5 then
		player:getInventory():removeItem("Osterei", 5)
		self:start(player)
	else
		player:sendWarning(_("Du brauchst mind. %s Ostereier, um spielen zu können", player, self.m_Prices.bet))
	end
end
