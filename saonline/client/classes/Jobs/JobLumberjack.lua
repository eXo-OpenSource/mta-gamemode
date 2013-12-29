-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobLumberjack.lua
-- *  PURPOSE:     Lumberjack job class
-- *
-- ****************************************************************************
JobLumberjack = inherit(Job)

function JobLumberjack:constructor()
	Job.constructor(self, 1870.84, -1244.95, 12.9, "files/images/Blips/Lumberjack.png", "files/images/Jobs/HeaderTrashman.png", LOREM_IPSUM)
	
	self.m_Trees = {}
	self.m_StackedTrees = {}
	self.m_NumTrees = 0
	
	-- Disable chainsaw damage
	addEventHandler("onClientPlayerDamage", localPlayer,
		function()
			if weapon == 9 then
				cancelEvent()
			end
		end
	)
	
	addEvent("lumberjackTreesLoadUp", true)
	addEventHandler("lumberjackTreesLoadUp", root, bind(JobLumberjack.Event_lumberjackTreesLoadUp, self))
end

function JobLumberjack:start()
	self.m_NumTrees = 0
	local func = bind(JobLumberjack.processTreeDamage, self)

	for k, v in ipairs(JobLumberjack.Trees) do
		local x, y, z = unpack(v)
		local object = createObject(656, x, y, z)
		table.insert(self.m_Trees, object)
		addEventHandler("onClientObjectDamage", object, func)
	end
	
	-- Removals
	for k, v in ipairs(JobLumberjack.Removals) do
		local model, radius, x, y, z = unpack(v)
		removeWorldModel(model, radius, x, y, z)
	end
	
	playSound("http://www.jusonex.net/Lumberjack.mp3")
end

function JobLumberjack:stop()
	for k, v in ipairs(self.m_Trees) do
		if v and isElement(v) then
			destroyElement(v)
		end
	end
	
	-- Restore removed objects
	for k, v in ipairs(JobLumberjack.Removals) do
		local model, radius, x, y, z = unpack(v)
		restoreWorldModel(model, radius, x, y, z)
	end
end

function JobLumberjack:processTreeDamage(loss, attacker)
	if attacker == localPlayer and not source.broken then
		-- Apply new health manually since our tree object is not a breakable/damageable object
		setElementHealth(source, getElementHealth(source) - loss/5)
		
		if getElementHealth(source) <= 0 then
			source.broken = true
			local x, y, z = getElementPosition(source)
			moveObject(source, 4000, x, y, z + 0.5, 88, math.random(0, 88), 0, "InQuad")
			setTimer(
				function(object)
					moveObject(object, 8000, x, y, z - 10)
					
					-- Add tree to stack
					if not self:addStackedTree() then
						localPlayer:sendMessage(_"The wood pile is full. Please transport the trees first to earn more money")
					end
					
					-- "Respawn" the tree after a while
					setTimer(
						function()
							-- Reset rotation and move up again
							setElementRotation(object, 0, 0, 0)
							moveObject(object, 8000, x, y, z)
							object.broken = nil
						end, 20000, 1
					)
				end, 6000, 1, source
			)
		end
	end
end

function JobLumberjack:addStackedTree()
	self.m_NumTrees = self.m_NumTrees + 1
	
	if self.m_NumTrees > (#JobLumberjack.WoodStackOffsets * #JobLumberjack.WoodStacks) then
		return false
	end
	
	triggerServerEvent("lumberjackTreeCut", root)
	
	local stackId = math.floor(self.m_NumTrees / #JobLumberjack.WoodStackOffsets) + 1
	local treeId = self.m_NumTrees % #JobLumberjack.WoodStackOffsets + 1
	local stackOffsets = JobLumberjack.WoodStacks[stackId]
	local treeOffsets = JobLumberjack.WoodStackOffsets[treeId]
	local x, y, z = stackOffsets[1] + treeOffsets[1], stackOffsets[2] + treeOffsets[2], stackOffsets[3] + treeOffsets[3]
	self.m_StackedTrees[#self.m_StackedTrees + 1] = createObject(837, x, y, z, 0, 0, 356)
	
	return true
end

function JobLumberjack:Event_lumberjackTreesLoadUp()
	for k, v in ipairs(self.m_StackedTrees) do
		destroyElement(v)
	end
	self.m_StackedTrees = {}
	self.m_NumTrees = 0
end

JobLumberjack.Trees = {
	{1909, -1153.80005, 22.8},
	{1896.80005, -1156.69995, 22.8},
	{1881.80005, -1157.19995, 22.8},
	{1878.80005, -1166.09998, 22.8},
	{1886.69995, -1174.5, 22.8},
	{1898.5, -1167.80005, 22.8},
	{1906.30005, -1171.59998, 22.8},
	{1913.30005, -1166.30005, 22.8},
	{1926.69995, -1157.69995, 20.8},
	{1939.80005, -1164.09998, 18.3},
	{1949.19995, -1151.80005, 19},
	{1950.40002, -1151.5, 22.8},
	{1954.80005, -1163.30005, 18},
	{1956.19995, -1178, 17.8},
	{1944.19995, -1180.59998, 17.8},
	{1935.40002, -1187.80005, 18.5},
	{1929.40002, -1196.19995, 17.5},
	{1928.80005, -1203.59998, 22.8},
	{1928.80005, -1203.59998, 18.5},
	{1916.09998, -1188.59998, 19.5},
	{1925.59998, -1177.30005, 19.8},
	{1907, -1192.80005, 20.3},
	{1894.09998, -1187.59998, 21.3},
	{1882.40002, -1184.69995, 21.8},
	{1875.90002, -1190.09998, 21},
	{1869.09998, -1197.69995, 20.8},
	{1870.09998, -1209.30005, 18.5},
	{1868, -1216.80005, 16.8},
	{1868.09998, -1229.90002, 14.5},
	{1864.80005, -1242.80005, 12.3},
	{1912.90002, -1250.40002, 13.5},
	{1869.5, -1250, 12.3},
	{1908.80005, -1222.5, 16.5},
	{1919, -1221.5, 17.5},
	{1931.30005, -1229, 17.8},
	{1945.40002, -1233.40002, 17.3},
	{1955.59998, -1246.80005, 18},
	{1945, -1247.09998, 17.8},
	{1930.30005, -1250.40002, 15.8},
	{1923.90002, -1247.90002, 16}
}

JobLumberjack.Removals = {
	{740, 44.124584197998, 1869.96875, -1204.55469, 16.58594},
	{620, 22.657041549683, 1880.125, -1152.13281, 20.80469},
	{714, 39.680019378662, 1906.41406, -1152.25781, 22.02344},
	{710, 20.01478767395, 1931.89844, -1171.50781, 33.55469},
	{620, 22.657041549683, 1927.51563, -1191.49219, 18.8125},
	{710, 20.01478767395, 1910.29688, -1205, 33.54688},
	{645, 14.408297538757, 1906.6875, -1199.14062, 19.26563},
	{739, 40.473133087158, 1864.76563, -1224.89062, 15.53906},
	{620, 22.657041549683, 1905.79688, -1248.52344, 12.44531},
	{645, 14.408297538757, 1928.78906, -1222.89062, 18.15625},
	{673, 8.8485546112061, 1932.24219, -1229.85937, 18.23438},
	{620, 22.657041549683, 1953.26563, -1234.17969, 17.74219},
	{620, 22.657041549683, 1935.6875, -1217.35156, 17.60938},
	{645, 14.408297538757, 2004.35156, -1240.09375, 20.69531},
	{739, 40.473133087158, 2011.22656, -1218.98437, 19.125},
	{740, 44.124584197998, 2025.14063, -1244.50781, 22.30469},
	{673, 8.8485546112061, 1990.125, -1226.6875, 19.19531},
	{645, 14.408297538757, 2024.57031, -1211.57812, 20.82813},
	{673, 8.8485546112061, 2020.36719, -1210.8125, 20.41406},
	{620, 22.657041549683, 2018.42969, -1206.65625, 19.23438},
	{620, 22.657041549683, 2029.75, -1227.70312, 19.76563},
	{620, 22.657041549683, 2050.39063, -1208.35156, 21.8125},
	{645, 14.408297538757, 2022.57813, -1176.97656, 20.84375},
	{620, 22.657041549683, 2010.375, -1153.42969, 21.0625},
	{620, 22.657041549683, 2038.8125, -1168.625, 21.02344},
	{700, 11.084518432617, 2040.13281, -1158.09375, 22.39844},
	{620, 22.657041549683, 1998.63281, -1177.21875, 17.85938},
	{700, 11.084518432617, 1989.04688, -1171.11719, 19.49219}
}

JobLumberjack.WoodStackOffsets = {
	{0.000000, 0.000000, 0.000000},
	{0.000000, 0.800050, 0.000000},
	{0.000000, 1.400030, 0.000000},
	{0.000000, 2.100100, 0.000000},
	{0.000000, 0.400030, 0.300000},
	{0.000000, 0.900030, 0.300000},
	{0.199950, 1.800050, 0.500000},
	{0.199950, 1.300050, 0.500000},
	{0.000000, 0.800050, 0.900000},
	{0.000000, 1.000000, 0.900000},
	{0.000000, 1.400030, 0.900000},
	{0.000000, 1.300050, 1.300000},
	{0.000000, 1.000000, 1.300000},
	{0.099610, 1.000250, 1.300000}
}

JobLumberjack.WoodStacks = {
	{1902.5, -1248.3, 14.3},
	{1908.5, -1248.3, 13.9},
	{1895.6, -1248.3, 13.9},
	{1888.9, -1248.3, 13.6}
}
