-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/NPC.lua
-- *  PURPOSE:     Robable shop class
-- *
-- ****************************************************************************
RobableShop = inherit(Object)

function RobableShop:constructor(enterPosition, interiorPosition, interiorId, pedPosition, pedSkin)
	-- Create enter/exit markers
	InteriorEnterExit:new(enterPosition, interiorPosition, interiorId)

	-- Create NPC(s)
	self.m_Ped = ShopNPC:new(pedSkin, pedPosition.X, pedPosition.Y, pedPosition.Z, 180)
	setElementInterior(self.m_Ped, interiorId)
end

function RobableShop.initalizeAll()
	RobableShop:new(Vector(2104.8, -1806.5, 13.5), Vector(372, -133.5, 1001.5), 5, Vector(374.76, -117.26, 1001.5), 155)
end
