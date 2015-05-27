-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/RobableShop.lua
-- *  PURPOSE:     Robable shop class
-- *
-- ****************************************************************************
RobableShop = inherit(Object)

function RobableShop:constructor(enterPosition, interiorPosition, enterRotation, exitRotation, interiorId, pedPosition, pedSkin)
	-- Create enter/exit markers
	InteriorEnterExit:new(enterPosition, interiorPosition, enterRotation, exitRotation, interiorId)

	-- Create NPC(s)
	self.m_Ped = ShopNPC:new(pedSkin, pedPosition.x, pedPosition.y, pedPosition.z, 180)
	self.m_Ped:setInterior(interiorId)
	self.m_Ped.onTargetted = bind(self.Ped_Targetted, self)
end

function RobableShop:Ped_Targetted(ped, attacker)
	-- Play an alarm
	local pos = ped:getPosition()
	triggerClientEvent("shopRobbed", attacker, pos.x, pos.y, pos.z)

	-- Report the crime
	attacker:reportCrime(Crime.ShopRob)

	-- Start giving some money (execute the timer 60 times every second --> overall duration: 60 seconds)
	setTimer(
		function()
			if isElement(attacker) then
				if attacker:getTarget() == ped then
					attacker:giveMoney(math.random(1, 8))
				end
				return
			end
			killTimer(sourceTimer)
		end,
		1000,
		60
	)
end

function RobableShop.initalizeAll()
	RobableShop:new(Vector3(2104.8, -1806.5, 13.5), Vector3(372, -133.5, 1001.5), 0, 90, 5, Vector3(374.76, -117.26, 1001.5), 155)
end
