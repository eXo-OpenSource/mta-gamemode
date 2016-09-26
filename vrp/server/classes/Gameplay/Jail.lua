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
									[270] = {["x"] = 1.5, ["y"] = 0},
									[90] = {["x"] = 1.5, ["y"] = 0}
								 }

	--Schleusen
	self:createGate(Vector3(186.50, 363.50, 7985.30), 0,  Vector3(186.60, 361.10, 7984.10), 90, Vector3(186.10, 365.10, 7984.10), 270)
	self:createGate(Vector3(180.00, 351.40, 7985.30), 0,  Vector3(180.10, 349.30, 7984.10), 90, Vector3(179.60, 349.40, 7984.10), 270)
	self:createGate(Vector3(175.70, 350.90, 7985.30), 0,  Vector3(175.90, 348.90, 7984.10), 90, Vector3(174.80, 352.20, 7984.10), 0)
	self:createGate(Vector3(176.30, 358.60, 7985.30), 0,  Vector3(176.30, 356.50, 7984.10), 90, Vector3(176.20, 356.50, 7984.10), 270)
	self:createGate(Vector3(144.20, 352.30, 7985.30), 0,  Vector3(144.10, 349.00, 7984.10), 270,Vector3(144.70, 352.30, 7984.10), 0)
	self:createGate(Vector3(142.40, 359.10, 7985.30), 270,Vector3(139.60, 358.30, 7984.10), 90, Vector3(139.60, 359.80, 7984.10), 90)
	self:createGate(Vector3(151.46, 368.27, 7985.30), 0,  Vector3(151.20, 366.30, 7984.10), 270,Vector3(151.80, 366.70, 7984.10), 180)
	self:createGate(Vector3(176.20, 367.80, 7985.30), 0,  Vector3(176.40, 365.70, 7984.10), 90, Vector3(175.60, 366.10, 7984.10), 180)
	self:createGate(Vector3(181.70, 365.60, 7985.30), 270,Vector3(180.10, 364.50, 7984.10), 90, Vector3(180.10, 366.60, 7984.10), 90)

	--Cells Left
	self:createGate(Vector3(173.70, 349.10, 7985.30), 270,  Vector3(171.70, 349.20, 7984.10), 180)
	self:createGate(Vector3(169.80, 349.10, 7985.30), 270,  Vector3(167.60, 349.20, 7984.10), 180)
	self:createGate(Vector3(165.90, 349.10, 7985.30), 270,  Vector3(163.80, 349.20, 7984.10), 180)
	self:createGate(Vector3(162.00, 349.10, 7985.30), 270,  Vector3(159.90, 349.20, 7984.10), 180)
	self:createGate(Vector3(158.20, 349.10, 7985.30), 270,  Vector3(156.10, 349.20, 7984.10), 180)
	self:createGate(Vector3(154.30, 349.10, 7985.30), 270,  Vector3(152.20, 349.20, 7984.10), 180)
	self:createGate(Vector3(150.50, 349.10, 7985.30), 270,  Vector3(148.40, 349.20, 7984.10), 180)
	self:createGate(Vector3(146.50, 349.10, 7985.30), 270,  Vector3(144.50, 349.20, 7984.10), 180)

	-- Cells Right
	self:createGate(Vector3(153.68, 369.50, 7985.24), 270,  Vector3(155.60, 369.40, 7984.10), 0)
	self:createGate(Vector3(157.60, 369.50, 7985.24), 270,  Vector3(159.50, 369.40, 7984.10), 0)
	self:createGate(Vector3(161.65, 369.50, 7985.24), 270,  Vector3(163.50, 369.40, 7984.10), 0)
	self:createGate(Vector3(165.60, 369.50, 7985.24), 270,  Vector3(167.50, 369.40, 7984.10), 0)
	self:createGate(Vector3(169.60, 369.50, 7985.24), 270,  Vector3(171.50, 369.40, 7984.10), 0)
	self:createGate(Vector3(173.43, 369.50, 7985.24), 270,  Vector3(175.30, 369.40, 7984.10), 0)

	InteriorEnterExit:new(Vector3(-589.67, -489.02, 25.53), Vector3(183.25, 372.91, 7983.66), 0, 180) -- Cells
	InteriorEnterExit:new(Vector3(-507.75, -533.01, 25.52), Vector3(246.43, 107.30, 1003.22), 0, 270, 10, 2) -- Frontdoor
	InteriorEnterExit:new(Vector3(-550.63, -496.07, 25.53), Vector3(215.85, 126.73, 1003.22), 180, 0, 10, 2) -- Backdoor

end

function Jail:createGate(gatePos, gateRot, keypad1Pos, keypad1Rot, keypad2Pos, keypad2Rot)
	local Id = #self.m_Gates+1
	self.m_Gates[Id] = createObject(2930, gatePos, 0, 0, gateRot)
	self.m_Gates[Id].closed = true
	self.m_Gates[Id].moving = false

	self.m_Keypad1[Id] = createObject(2886, keypad1Pos, 0, 0, keypad1Rot)
	self.m_Keypad1[Id].Id = Id
	addEventHandler( "onElementClicked", self.m_Keypad1[Id], self.m_onKeypadClicked)
	createMarker(keypad1Pos.x, keypad1Pos.y, keypad1Pos.z, 3, "corona")
	if keypad2Pos then
		self.m_Keypad2[Id] = createObject(2886, keypad2Pos, 0, 0, keypad2Rot)
		self.m_Keypad2[Id].Id = Id
		addEventHandler( "onElementClicked", self.m_Keypad2[Id], self.m_onKeypadClicked)
	end
end

function Jail:onKeypadClick(button, state, player)
	if button == "left" and state == "down" then
		if source.Id and isElement(self.m_Gates[source.Id]) then
			if player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
				local gate = self.m_Gates[source.Id]
				local pos = gate:getPosition()
				local rot = gate:getRotation()
				local offset = self.ms_OffsetFromRotation[math.floor(rot.z)]
				if not gate.moving == true then
					if gate.closed == true then
						gate:move(1500, pos.x + offset["x"], pos.y + offset["y"], pos.z)
						gate.closed = false
						--outputChatBox("Gate "..source.Id.." geöffnet", player, 255, 0, 0)
					else
						gate:move(1500, pos.x - offset["x"], pos.y - offset["y"], pos.z)
						gate.closed = true
						--outputChatBox("Gate "..source.Id.." geschlossen", player, 255, 0, 0)
					end
					gate.moving = true
					setTimer(function(gate)
						gate.moving = false
					end,1500, 1, gate)
				end
			else
				player:sendError(_("Du bist nicht befugt!", player))
			end
		else
			player:sendError("Internal Error! No Id!")
		end
	end
end

Jail.Cells = {
	Vector3(173.48, 347.3, 7983.66);
	Vector3(169.21, 347.3, 7984.08);
	Vector3(166.23, 347.3, 7983.66);
	Vector3(161.73, 347.3, 7983.66);
	Vector3(158.58, 347.3, 7983.66);
	Vector3(153.99, 347.3, 7983.66);
	Vector3(150.21, 347.3, 7983.66);
	Vector3(146.76, 347.3, 7983.66);
	Vector3(153.31, 371.2, 7983.66);
	Vector3(157.16, 371.2, 7983.66);
	Vector3(160.97, 371.2, 7983.66);
	Vector3(164.57, 371.2, 7983.66);
	Vector3(169.02, 371.2, 7983.66);
	Vector3(172.77, 371.2, 7983.66);
}
