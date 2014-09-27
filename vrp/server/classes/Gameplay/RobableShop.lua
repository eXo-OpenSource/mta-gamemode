-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/NPC.lua
-- *  PURPOSE:     Robable shop class
-- *
-- ****************************************************************************
RobableShop = inherit(Object)

function RobableShop:constructor(enterPosition, interiorPosition, enterRotation, exitRotation, interiorId, pedPosition, pedSkin)
	-- Create enter/exit markers
	InteriorEnterExit:new(enterPosition, interiorPosition, enterRotation, exitRotation, interiorId)

	-- Create NPC(s)
	self.m_Ped = ShopNPC:new(pedSkin, pedPosition.x, pedPosition.y, pedPosition.z, 180)
	setElementInterior(self.m_Ped, interiorId)
end

function RobableShop.initalizeAll()
	RobableShop:new(Vector3(2104.8, -1806.5, 13.5), Vector3(372, -133.5, 1001.5), 0, 90, 5, Vector3(374.76, -117.26, 1001.5), 155)
end
