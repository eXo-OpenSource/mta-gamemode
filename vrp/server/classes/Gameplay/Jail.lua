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
	self:createGate(Vector3(151.46, 368.27, 7985.24), 0,  Vector3(151.20, 366.30, 7984.10), 270,Vector3(151.80, 366.70, 7984.10), 180)
	self:createGate(Vector3(176.20, 367.80, 7985.29), 0,  Vector3(176.40, 365.70, 7984.10), 90, Vector3(175.60, 366.10, 7984.10), 180)
	--Cells
	self:createGate(Vector3(173.70, 349.10, 7985.30), 270,  Vector3(171.70, 349.10, 7985.30), 180)


end
function Jail:createGate(gatePos, gateRot, keypad1Pos, keypad1Rot, keypad2Pos, keypad2Rot)
	local Id = #self.m_Gates+1
	self.m_Gates[Id] = createObject(2930, gatePos, 0, 0, gateRot)
	self.m_Gates[Id].closed = true

	self.m_Keypad1[Id] = createObject(2886, keypad1Pos, 0, 0, keypad1Rot)
	self.m_Keypad1[Id].Id = Id
	addEventHandler( "onElementClicked", self.m_Keypad1[Id], self.m_onKeypadClicked)

	if keypad2Pos then
		self.m_Keypad2[Id] = createObject(2886, keypad2Pos, 0, 0, keypad2Rot)
		self.m_Keypad2[Id].Id = Id
		addEventHandler( "onElementClicked", self.m_Keypad2[Id], self.m_onKeypadClicked)
	end
end

function Jail:onKeypadClick(button, state, player)
	if button == "left" and state == "down" then
		if source.Id and isElement(self.m_Gates[source.Id]) then
			local gate = self.m_Gates[source.Id]
			local pos = gate:getPosition()
			local rot = gate:getRotation()
			local offset = self.ms_OffsetFromRotation[math.floor(rot.z)]
			if gate.closed == true then
				gate:move(1500, pos.x + offset["x"], pos.y + offset["y"], pos.z)
				gate.closed = false
			else
				gate:move(1500, pos.x - offset["x"], pos.y - offset["y"], pos.z)
				gate.closed = true
			end
		else
			player:sendError("Internal Error! No Id!")
		end
	end
end
