-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Jail.lua
-- *  PURPOSE:     Jail server-side class
-- *
-- ****************************************************************************

Jail = inherit(Singleton)

function Jail:constructor()
	self.m_Gates = {}
	self.m_Keypad1 = {}
	self.m_Keypad2 = {}
	self.m_onKeypadClicked = bind(self.onKeypadClick, self)

	self.ms_OffsetFromRotation = {	[0] = {["x"] = 0, ["y"] = 1.5},
									[90] = {["x"] = 1.5, ["y"] = 0},
									[180] = {["x"] = 0, ["y"] = 1.5},
									[270] = {["x"] = 1.5, ["y"] = 0}
								 }

	self.m_OpenVectors = {
		["+x"] = Vector3(1.5, 0, 0),
		["-x"] = Vector3(-1.5, 0, 0),
		["+y"] = Vector3(0, 1.5, 0),
		["-y"] = Vector3(0, -1.5, 0)
	}

	-- Outside
	self:createGate(0, "+y", Vector3(3549.2, -1603.1, 9.2), 0, Vector3(3548.5, -1606.9, 7.8), 270, Vector3(3549.3, -1602.7, 8.1), 90)

	-- Interior
	self:createGate(2, "+x", Vector3(2615.5, -1420, 1042), 90, Vector3(2615.1, -1420, 1040.8), 180, Vector3(2617.5, -1420.9, 1040.8), 0)
	self:createGate(2, "-y", Vector3(2612.9, -1430.5, 1042), 180, Vector3(2613.4, -1426.9, 1040.8), 90, Vector3(2612.8, -1431.3, 1040.8), 270)
	self:createGate(2, "+x", Vector3(2576.1, -1411.2, 1046.1), 270, Vector3(2576.4, -1411.8, 1045.1), 0, Vector3(2576.4, -1411, 1045), 180)

	-- Cells
	self:createGate(2, "-y", Vector3(2603.199, -1432.900, 1041.800), 180,  Vector3(2602.400, -1434.5, 1040.699), 180)
	self:createGate(2, "-y", Vector3(2599.6999511719, -1432.9000244141, 1041.8000488281), 180, Vector3(2600.5, -1434.5, 1040.6999511719), 180)
	self:createGate(2, "-y", Vector3(2589.1999511719, -1432.9000244141, 1041.8000488281), 180, Vector3(2588.5, -1434.5, 1040.6999511719), 180)
	self:createGate(2, "-y", Vector3(2585.8000488281, -1432.8000488281, 1041.8000488281), 180, Vector3(2586.5, -1434.5, 1040.6999511719), 180)
	self:createGate(2, "-y", Vector3(2575.3999023438, -1432.8000488281, 1041.8000488281), 180, Vector3(2574.7001953125, -1434.5, 1040.6999511719), 180)

	self:createGate(2, "+y", Vector3(2579.3999023438, -1410.9000244141, 1041.8000488281), 180, Vector3(2578.5, -1407.0599365234, 1040.6999511719), 0)
	self:createGate(2, "+y", Vector3(2589.8999023438, -1410.9000244141, 1041.8000488281), 180, Vector3(2590.8999023438, -1407.0400390625, 1041), 0)
	self:createGate(2, "+y", Vector3(2593.5, -1410.9000244141, 1041.8000488281), 180, Vector3(2592.8603515625, -1407.0400390625, 1041), 0)
	self:createGate(2, "+y", Vector3(2604, -1410.9000244141, 1041.8000488281), 180, Vector3(2605.1005859375, -1407.0400390625, 1040.8000488281), 0)
	self:createGate(2, "+y", Vector3(2607.6000976563, -1410.9000244141, 1041.8000488281), 180, Vector3(2606.900390625, -1407.0400390625, 1040.8000488281), 0)

	self:createGate(2, "+y", Vector3(2615.8999023438, -1430.5999755859, 1041.8000488281), 90)

	InteriorEnterExit:new(Vector3(-539.21, -495.13, 25.52), Vector3(2618.6, -1417.1, 1040.4), 90, 270, 2)
	InteriorEnterExit:new(Vector3(-720.880, -403.842, 8.11), Vector3(2563.3, -1413.0, 1050.9), 180, 0, 2)
end

function Jail:createGate(interior, openDir, gatePos, gateRot, keypad1Pos, keypad1Rot, keypad2Pos, keypad2Rot)
	local Id = #self.m_Gates+1
	self.m_Gates[Id] = createObject(2930, gatePos, 0, 0, gateRot)
	self.m_Gates[Id].m_Id = Id
	self.m_Gates[Id]:setInterior(interior)
	self.m_Gates[Id].closed = true
	self.m_Gates[Id].m_OpenDirection = openDir

	if keypad1Pos then
		self.m_Keypad1[Id] = createObject(2886, keypad1Pos, 0, 0, keypad1Rot)
		self.m_Keypad1[Id]:setInterior(interior)
		self.m_Keypad1[Id].Id = Id
		addEventHandler("onElementClicked", self.m_Keypad1[Id], self.m_onKeypadClicked)
	end

	if keypad2Pos then
		self.m_Keypad2[Id] = createObject(2886, keypad2Pos, 0, 0, keypad2Rot)
		self.m_Keypad2[Id]:setInterior(interior)
		self.m_Keypad2[Id].Id = Id
		addEventHandler("onElementClicked", self.m_Keypad2[Id], self.m_onKeypadClicked)
	end
end

function Jail:onKeypadClick(button, state, player)
	if button == "left" and state == "down" then
		if source.Id and isElement(self.m_Gates[source.Id]) then
			if
				player:getFaction()
				and (
					player:getFaction():isStateFaction() and player:isFactionDuty()
					or PrisonBreakManager:getSingleton():getCurrent() and player:getInventory():getItemAmount("Keycard") > 0
				)
			then
				self:moveGate(self.m_Gates[source.Id])
			else
				player:sendError(_("Du bist nicht befugt!", player))
			end
		else
			player:sendError("Internal Error! No Id!")
		end
	end
end

function Jail:moveGate(gate, forceClose)
	local pos = gate:getPosition()
	local rot = gate:getRotation()
	--local offset = self.ms_OffsetFromRotation[math.floor(rot.z)]
	local offset = self.m_OpenVectors[gate.m_OpenDirection]

	if not gate.moving == true then
		if gate.closed == true and not forceClose then
			gate:move(1500, pos.x + offset.x, pos.y + offset.y, pos.z)
			gate.closed = false
			--outputChatBox("Gate "..gate.m_Id.." geöffnet", nil, 255, 0, 0)
		else
			gate:move(1500, pos.x - offset.x, pos.y - offset.y, pos.z)
			gate.closed = true
			--outputChatBox("Gate "..gate.m_Id.." geschlossen", nil, 255, 0, 0)
		end
	end
end

function Jail:closeGates()
	for k, gate in pairs(self.m_Gates) do
		if not gate.closed then
			self:moveGate(gate, true)
		end
	end
end

function Jail:getJailedPlayers()
	local players = {}
	for index, playeritem in pairs(getElementsByType("player")) do
		if playeritem.m_JailTime and playeritem.m_JailTimer and playeritem.m_JailTime > 0 then
			table.insert(players, playeritem)
		end
	end
	return players
end

function Jail:setPrisonBreak(state)
	for index, player in pairs(self:getJailedPlayers()) do
		player:toggleControl("fire", state)
		player:toggleControl("jump", state)
		player:toggleControl("aim_weapon ", state)
		player:triggerEvent("setPrisonBreak", state)
		if state then
			if player:getFaction() and player:getFaction():isEvilFaction() then
				FactionEvil:getSingleton():setPlayerDuty(player, true, true)
			end
		end
	end
end

Jail.Cells = {
	Vector3(2605.349, -1432.842, 1040.356),
	Vector3(2597.938, -1432.681, 1040.356),
	Vector3(2593.084, -1432.652, 1040.356),
	Vector3(2583.848, -1432.813, 1040.356),
	Vector3(2576.950, -1432.271, 1040.356),
	Vector3(2609.203, -1409.459, 1040.356),
	Vector3(2600.166, -1409.026, 1040.356),
	Vector3(2597.006, -1409.341, 1040.356),
	Vector3(2585.856, -1409.066, 1040.356),
	Vector3(2582.765, -1409.199, 1040.356)
}
