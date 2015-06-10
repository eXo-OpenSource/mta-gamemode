-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/RobableShop.lua
-- *  PURPOSE:     Robable shop class
-- *
-- ****************************************************************************
RobableShop = inherit(Object)

function RobableShop:constructor(pedPosition, pedRotation, pedSkin, interiorId, dimension)
	-- Create NPC(s)
	self:spawnPed(pedPosition, pedRotation, pedSkin, interiorId, dimension)

	-- Respawn ped after a while (if necessary)
	addEventHandler("onPedWasted", self.m_Ped,
		function()
			setTimer(function() self:spawnPed(pedPosition, pedRotation, pedSkin, interiorId, dimension) end, 5*60*1000, 1)
		end
	)
end

function RobableShop:spawnPed(pedPosition, pedRotation, pedSkin, interiorId, dimension)
	if self.m_Ped and isElement(self.m_Ped) then
		self.m_Ped:destroy()
	end

	self.m_Ped = ShopNPC:new(pedSkin, pedPosition.x, pedPosition.y, pedPosition.z, pedRotation)
	self.m_Ped:setInterior(interiorId)
	self.m_Ped:setDimension(dimension)
	self.m_Ped.onTargetted = bind(self.Ped_Targetted, self)
end

function RobableShop:Ped_Targetted(ped, attacker)
	-- Play an alarm
	local pos = ped:getPosition()
	triggerClientEvent("shopRobbed", attacker, pos.x, pos.y, pos.z, ped:getDimension())

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
	--RobableShop:new(Vector3(2104.8, -1806.5, 13.5), Vector3(372, -133.5, 1001.5), 0, 90, 5, Vector3(374.76, -117.26, 1001.5), 155)

	local positions = {
		--model, x,   y,      z,       rotation, interior, dimension
		{202, -28.15, -91.64, 1003.55, 1.3, 18, 0},
		{202, -23.94, -57.77, 1003.55, 357.8, 6, 0},
		{201, -30.84, -30.71, 1003.56, 0.7, 4, 0},
		{73, 295.45, -40.80, 1001.52, 358.4, 1, 0},
		{179, 295.59, -82.85, 1001.52, 1.3, 4, 0},
		{179, 290.30, -104.49, 1001.52, 180.5, 6, 0},
		{179, 312.32, -167.76, 999.59, 0.1, 6, 0},
		{179, 316.12, -133.91, 999.60, 90.7, 7, 0},
		{240, 501.72, -20.50, 1000.68, 93.6, 17, 0},
		{195, 498.10, -77.82, 998.77, 359.2, 11, 0},
		{192, 208.72, -98.30, 1005.26, 180.6, 15, 0},
		{205, 376.53, -65.59, 1001.51, 178.4, 10, 0},
		{168, 681.60, -455.82, -25.61, 358.9, 1, 0},
		{167, 368.62, -4.49, 1001.85, 176.9, 9, 0},
		{194, 204.27, -157.83, 1000.52, 180.1, 16, 0},
		{177, 420.58, -79.16, 1001.80, 176.6, 3, 0},
		{176, -201.12, -5.91, 1002.27, 132.5, 17, 0},
		{11, 820.18, 1.87, 1004.18, 273.3, 3, 0},
		{257, -2655.59, 1408.84, 906.27, 266.6, 3, 0},
		{176, 413.75, -51.22, 1001.90, 177.6, 12, 0},
		{156, 414.59, -16.30, 1001.80, 175.3, 2, 0},
		{209, 380.67, -189.11, 1000.63, 146.8, 17, 0},
		{75, -104.82, -8.91, 1000.72, 180.7, 3, 0},
		{13, 203.67, -41.67, 1001.80, 183.5, 1, 0},
		{252, 1214.98, -15.26, 1000.92, 358.0, 2, 0},
		{22, 207.23, -127.46, 1003.51, 182.3, 3, 0},
		{193, 204.85, -8.55, 1001.21, 272.5, 5, 0},
		{155, 374.78, -117.28, 1001.49, 181.8, 5, 0},
		{191, 161.27, -80.78, 1001.80, 181.5, 18, 0},
	}

	--[[addCommandHandler("int",
		function(player, cmd, id)
			outputChatBox(id)
			local info = positions[tonumber(id)]
			local model, x, y, z, rotation, interior, dimension = unpack(info)

			local i = 1
			setTimer(function()
				player:setInterior(i, x, y, z)
				i = i + 1
				outputChatBox(i)
			end, 500, 20)
		end
	)]]

	for k, info in pairs(positions) do
		local model, x, y, z, rotation, interior, dimension = unpack(info)
		-- Temporary HACK: Create in 6 dimensions
		for i = 0, 5 do
			RobableShop:new(Vector3(x, y, z), rotation, model, interior, i)
		end
	end
end
