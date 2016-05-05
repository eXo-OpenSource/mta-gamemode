-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Slotmachine.lua
-- *  PURPOSE:     Slotmachine class - from iLife
-- *
-- ****************************************************************************
Slotmachine = inherit(Object)

slot_machines = {}

function Slotmachine:constructor(x, y, z, rx, ry, rz, int, dim)
	if not int then
		int = 0
	end
	if not dim then
		dim = 0
	end

	-- Instances
	self.prices = {}

	-- PRICES --
	-- Here you can change the winning things --
	self.prices.bet 					= 250;			-- Bet amount

	self.prices.normalPrice 			= 5; 		-- Minimum Win Ammount (2 Right icons)			-- Info: This ammount will be there in ANY case
	self.prices.maxNormalRandomPrice 	= 700;			-- Maximum Random Win-add Ammount (2 Right icons)
								-- Maximum Win Ammount: normalPrice + maxNormalRandomPrice

	self.prices.normalPrice2 			= 5;			-- Minimum Win Ammount 2 (2 Right Rare Icons)	-- This too
	self.prices.maxNormalRandomPrice2 	= 700;			-- Maximum Random Win-add Ammount 2 (2 Right Rare Icons)
								-- Maximum Win Ammount: normalPrice + maxNormalRandomPrice

	self.prices.jackpot 				= 5000;		-- Jackpot Price
	self.prices.rareJackpot 			= 13370;		-- Rare Jackpot Price

	--  {5, 1, false}
	-- Definition:
	-- {iWeaponID, iWeaponAmmo}

	self.settings = {}


	-- Methods
	self.resultFunc = function(...) self:doResult(...) end;
	self.resetFunc = function(...) self:reset() end;
	self.startFunc = function(player) self:startPlayer(player) end;
	self.hebelClickFunc	= function(btn, state, player)
		if btn == "left" and state == "down" then
			self:startPlayer(player)
		end
	end;
	-- Instances

	self.objects = {}

	self.objects.rolls = {}
	-- self.hebel
	-- self.wood
	-- self.gun
	self.canSpin = true

	self.settings.iconNames = {
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
	-- Slotmachine


	self.objects.slotmachine = createObject(2325, x, y, z, rx, ry, rz)
	setObjectScale(self.objects.slotmachine, 2)

	slot_machines[self.objects.slotmachine] = self.objects.slotmachine;
	-- Rolls

	for i = 1, 3, 1 do
		self.objects.rolls[i] = createObject(2347, x, y, z)
		setObjectScale(self.objects.rolls[i], 2)
		attachElements(self.objects.rolls[i], self.objects.slotmachine, -0.45+i/4, 0, 0)
	end

	-- Lever ( Hebel )

	self.objects.hebel = createObject(1319, x, y, z)
	attachElements(self.objects.hebel, self.objects.slotmachine, 0.9, -0.3, 0, 50, 0, rz*(360)/90)
	setElementFrozen(self.objects.hebel, true)
	setElementData(self.objects.hebel, "SLOTMACHINE:LEVER", true)
	self.objects.hebel:setData("clickable", true, true)

	-- Wood

	self.objects.wood = createObject(3260, x, y, z)
	setObjectScale(self.objects.wood, 0.7)
	attachElements(self.objects.wood, self.objects.slotmachine, 0, 0.5, -0.5)


	-- Dimension and Interior

	for index, object in pairs(self.objects) do
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

--	outputDebugString("[CALLING] Slotmachine: Constructor")

	-- Events --
	addEventHandler("onElementClicked", self.objects.hebel, self.hebelClickFunc)
	setElementData(self.objects.hebel, "SLOTMACHINE:ID", self) -- Store the Object in the element data
end

-- ///////////////////////////////
-- ///// reset		 		//////
-- ///// Returns: bool		//////
-- ///////////////////////////////

function Slotmachine:reset()
	if self.canSpin == false then
		self.canSpin = true

		return true;
	end
end

function Slotmachine:calculateSpin()
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

	return grad, self.settings.iconNames[grad];
end

function Slotmachine:moveLever(player)
	local x, y, z = getElementPosition(self.objects.hebel)
	local _, _, _, rx, ry, rz = getElementAttachedOffsets(self.objects.hebel)
--	local rx, ry, rz = getElementRotation(cSetting["slotmachine_hebel"][id])
	local _, _, rz = getElementRotation(self.objects.slotmachine)
	detachElements(self.objects.hebel)

	setElementPosition(self.objects.hebel, x, y, z)
	setElementRotation(self.objects.hebel, rx, ry, rz)


	moveObject(self.objects.hebel, 450, x, y, z, 50, 0, 0, "InQuad")

	setTimer(function()
		moveObject(self.objects.hebel, 450, x, y, z, -50, 0, 0, "InQuad")
	end, 450, 1)

	local int, dim = self.objects.slotmachine:getInterior(), self.objects.slotmachine:getDimension()
	setTimer(triggerClientEvent, 150, 1, getRootElement(), "onSlotmachineSoundPlay", getRootElement(), x, y, z, "start_machine", int, dim)


	setTimer(function() self:spin(player) end, 500, 1, player)

	return true;
end

function Slotmachine:spin(player)
	local ergebnis = {}
	for i = 1, 3, 1 do
		local grad, icon = self:calculateSpin()
		--	grad, icon = 900, "69"
		local x, y, z = getElementPosition(self.objects.rolls[i])
		local _, _, _, rx, ry, rz = getElementAttachedOffsets(self.objects.rolls[i])
		--if rx == 0 then
		rx, _, _ = getElementRotation(self.objects.rolls[i])
		--end
		local _, _, rz = getElementRotation(self.objects.slotmachine)
		if isElementAttached(self.objects.rolls[i]) then
			detachElements(self.objects.rolls[i])

			setElementPosition(self.objects.rolls[i], x, y, z)
			setElementRotation(self.objects.rolls[i], rx, ry, rz)

		end
		--	outputChatBox(grad-rx)

		--	outputChatBox(rx-grad)
		local s = moveObject(self.objects.rolls[i], 2500+(i*600), x, y, z, grad, 0, 0, "InQuad")

		ergebnis[i] = icon
	end
	setTimer(self.resultFunc, 4100, 1, ergebnis, player)
	return true;
end

function Slotmachine:checkRolls()
	for i = 1, 3, 1 do
		local x, y, z = getElementPosition(self.objects.rolls[i])
		if not isElementAttached(self.objects.rolls[i]) then
			local rx, ry, _ = getElementRotation(self.objects.rolls[i])

			moveObject(self.objects.rolls[i], 100, x, y, z, -rx, 0, 0, "InQuad")
		end
	end
end

function Slotmachine:start(player)
	if self.canSpin == true then
		self.canSpin = false;
		self:checkRolls()
		setTimer(function()
			self:moveLever(player)
		end, 100, 1)
	end
end

function Slotmachine:giveWin(player, name, x, y, z, id)

	if name == "explosion" then
		setTimer(function()
			createExplosion(x, y, z, 1)
		end, 1000, 1)

	elseif name == "normal" then
		local int, dim = self.objects.slotmachine:getInterior(), self.objects.slotmachine:getDimension()
		triggerClientEvent(getRootElement(), "onSlotmachineSoundPlay", getRootElement(), x, y, z, "win_stuff", int, dim)
		local rnd = math.random(0, self.prices.maxNormalRandomPrice)
		player:giveMoney(self.prices.normalPrice+rnd, "Slotmaschine")
		player:sendInfo(_("Du hast %d$ gewonnen!", player, self.prices.normalPrice+rnd))

	elseif name == "win" then
		local int, dim = self.objects.slotmachine:getInterior(), self.objects.slotmachine:getDimension()
		triggerClientEvent(getRootElement(), "onSlotmachineSoundPlay", getRootElement(), x, y, z, "win_stuff", int, dim)
		local rnd = math.random(0, self.prices.maxNormalRandomPrice2)
		player:giveMoney(self.prices.normalPrice2+rnd, "Slotmaschine")
		player:sendInfo(_("Du hast %d$ gewonnen!", player, self.prices.normalPrice2+rnd))
	elseif name == "jackpot" then
		local int, dim = self.objects.slotmachine:getInterior(), self.objects.slotmachine:getDimension()
		triggerClientEvent(getRootElement(), "onSlotmachineSoundPlay", getRootElement(), x, y, z, "win_jackpot", int, dim)
		player:giveMoney(self.prices.jackpot, "Slotmaschine")
		player:sendInfo(_("Du hast %d$ gewonnen!", player, self.prices.jackpot))
		triggerClientEvent(getRootElement(), "onSlotmachineJackpot", getRootElement(), x, y, z)
	elseif name == "rare" then
		local int, dim = self.objects.slotmachine:getInterior(), self.objects.slotmachine:getDimension()
		triggerClientEvent(getRootElement(), "onSlotmachineSoundPlay", getRootElement(), x, y, z, "win_jackpot", int, dim)
		triggerClientEvent(getRootElement(), "onSlotmachineJackpot", getRootElement(), x, y, z)
		outputChatBox(getPlayerName(player).." WON THE RARE JACKPOT!!!", getRootElement(), 0, 255, 0)
		player:sendInfo(_("Du hast %d$ gewonnen!", player, self.prices.rareJackpot))
		player:giveMoney(self.prices.rareJackpot, "Slotmaschine")
	elseif name == "drogen" then
		player:sendInfo(_("Du hast 5 Gramm Weed gewonnen!", player))
		player:getInventory():giveItem("Weed", 5)
		player:refreshInventory()
		triggerClientEvent(getRootElement(), "onSlotmachineSoundPlay", getRootElement(), x, y, z, "win_stuff", int, dim)
	elseif name == "drogenselten" then
		player:sendInfo(_("Du hast einen Magic Mushroom gewonnen!", player))
		player:getInventory():giveItem("Shroom", 1)
		player:refreshInventory()
		triggerClientEvent(getRootElement(), "onSlotmachineSoundPlay", getRootElement(), x, y, z, "win_stuff", int, dim)
	end
end

function Slotmachine:doResult(ergebnis, player)
	local x, y, z = getElementPosition(self.objects.slotmachine)
--	cSetting["can_play"][id] = true
	local kirschen = 0
	local glocken = 0
	local weintrauben = 0
	local gold1 = 0
	local gold2 = 0
	local rare = 0

	for index, data in pairs(ergebnis) do
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

	local restart = true

	if glocken == 2 or weintrauben == 2 or gold1 == 2 or kirschen == 2 then
		self:giveWin(player, "normal", x, y, z ,id)
	elseif glocken == 3 then
		self:giveWin(player, "win", x, y, z, id)
		self:giveWin(player, "drogen", x, y, z, id)

	elseif kirschen == 3 or gold2 == 2 then
		self:giveWin(player, "drogen", x, y, z, id)

	elseif gold2 == 2 then
		restart = false
		self:giveWin(player, "drogenselten", x, y, z, id)
	elseif gold2 == 3 then
		self:giveWin(player, "jackpot", x, y, z, id)
		self:giveWin(player, "drogen", x, y, z, id)

	elseif weintrauben == 3 then
		self:giveWin(player, "explosion", x, y, z, id)
	elseif rare == 3 then
		self:giveWin(player, "rare", x, y, z, id)
	elseif rare == 2 then
		self:giveWin(player, "jackpot", x, y, z, id)
	else
		local int, dim = self.objects.slotmachine:getInterior(), self.objects.slotmachine:getDimension()
		player:sendInfo(_("Du hast leider nichts gewonnen!", player))
		triggerClientEvent(getRootElement(), "onSlotmachineSoundPlay", getRootElement(), x, y, z, "win_nothing", int, dim)
	end
--	self:giveWin(player, "waffen", x, y, z, id)
	if restart == true then
		setTimer(self.resetFunc, 1500, 1, id)
	end
end

function Slotmachine:startPlayer(player)
	if player:getMoney() >= self.prices.bet then
		if self.canSpin == true then
			player:takeMoney(self.prices.bet, "Slotmaschine")
		--	triggerClientEvent(player, "onSlotmachineWintext", player, "#FF0000-$"..self.prices.bet)
			self:start(player)
		end
	else
		player:sendError(_("Dir fehlen %d$ um an dieser Slotmachine zu spielen!", player, self.prices.bet))

	end
end
