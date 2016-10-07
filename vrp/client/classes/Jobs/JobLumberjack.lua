-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobLumberjack.lua
-- *  PURPOSE:     Lumberjack job class
-- *
-- ****************************************************************************
JobLumberjack = inherit(Job)

function JobLumberjack:constructor()
	Job.constructor(self, 16, 1104.27, -298.06, 73.99, 90, "Lumberjack.png", "files/images/Jobs/HeaderLumberjack.png", _(HelpTextTitles.Jobs.Lumberjack):gsub("Job: ", ""), _(HelpTexts.Jobs.Lumberjack))

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

	-- add job to help menu
	HelpTextManager:getSingleton():addText("Jobs", _(HelpTextTitles.Jobs.Lumberjack):gsub("Job: ", ""), _(HelpTexts.Jobs.Lumberjack))
end

function JobLumberjack:start()
	self.m_NumTrees = 0
	local func = bind(JobLumberjack.processTreeDamage, self)

	for k, v in ipairs(JobLumberjack.Trees) do
		local x, y, z, rotation = unpack(v)
		local object = createObject(656, x, y, z, 0, 0, rotation)
		object.Blip = Blip:new("SmallPoint.png", x, y)
		table.insert(self.m_Trees, object)
		addEventHandler("onClientObjectDamage", object, func)
	end

	-- Removals
	for k, v in ipairs(JobLumberjack.Removals) do
		local model, radius, x, y, z = unpack(v)
		removeWorldModel(model, radius, x, y, z)
	end

	self.m_SawMillBlip = Blip:new("RedSaw.png", -1969.8, -2432.6)
	ShortMessage:new(_"Säge die auf der Karte markierten Bäume mit der Motorsäge um.")
	-- Show text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.Jobs.Lumberjack), _(HelpTexts.Jobs.Lumberjack))
end

function JobLumberjack:stop()
	for k, v in ipairs(self.m_Trees) do
		if v and v.Blip then delete(v.Blip) end
		if v and isElement(v) then
			destroyElement(v)
		end
	end

	-- Restore removed objects
	for k, v in ipairs(JobLumberjack.Removals) do
		local model, radius, x, y, z = unpack(v)
		restoreWorldModel(model, radius, x, y, z)
	end

	if self.m_SawMillBlip then
		delete(self.m_SawMillBlip)
		self.m_SawMillBlip = nil
	end

	-- Reset text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.General.Main), _(HelpTexts.General.Main), false)
end

function JobLumberjack:processTreeDamage(loss, attacker)
	if attacker == localPlayer and not source.broken then
		-- Apply new health manually since our tree object is not a breakable/damageable object
		setElementHealth(source, getElementHealth(source) - loss/5)

		if getElementHealth(source) <= 0 then
			source.broken = true
			local x, y, z = getElementPosition(source)
			moveObject(source, 4000, x, y, z + 0.5, 88, math.random(0, 88), 0, "InQuad")
			setElementCollisionsEnabled(source, false)

			setTimer(
				function(object)
					moveObject(object, 8000, x, y, z - 10)

					-- Add tree to stack
					if not self:addStackedTree() then
						localPlayer:sendMessage(_"Der Holzstapel ist voll. Bitte transportiere die Bäume zum Sägewerk! (rote Säge auf der Map)")
					end

					-- "Respawn" the tree after a while
					setTimer(
						function(object)
							-- Reset rotation and move up again
							setElementRotation(object, 0, 0, 0)
							moveObject(object, 8000, x, y, z)
							setElementCollisionsEnabled(object, true)
							object.broken = nil
						end, 20000, 1, object
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
	{1000, -291.39999, 71.7, 0},
	{988.40002, -295.5, 68.4, 330},
	{997.70001, -308.20001, 71.2, 329.996},
	{988.59998, -326.79999, 68.9, 353.996},
	{975.29999, -300, 65.7, 329.996},
	{1003.90002, -321.10001, 71.7, 329.996},
	{966.70001, -317.29999, 64.2, 329.996},
	{997.59998, -351.20001, 71.7, 329.996},
	{996.59998, -338.39999, 70.2, 329.996},
	{973.20001, -332.29999, 66.2, 329.996},
	{982.40002, -345.5, 67.9, 329.996},
	{964.20001, -292.10001, 62.4, 329.996},
	{986, -358.60001, 67.9, 297.996},
	{999, -373.20001, 70.7, 297.993},
	{970, -356.20001, 66.2, 291.996},
	{958.90002, -329.70001, 62.2, 299.996},
	{958, -305.20001, 60.9, 7.996},
	{964.59998, -343.39999, 63.7, 189.995},
	{997.59998, -389.10001, 70.7, 259.993},
	{957.40002, -355, 62.7, 189.992},
	{982.59998, -373.79999, 68.2, 257.995},
	{967.79999, -372.5, 65.7, 299.992},
	{943.79999, -364.39999, 58.7, 299.987},
	{955.29999, -374.5, 63, 299.987},
	{949.59998, -342.29999, 60, 299.987},
	{931.79999, -372.29999, 56, 327.987},
	{910.09998, -366.39999, 46.8, 7.986},
	{933.79999, -348.79999, 55.3, 257.987},
	{922.20001, -358.10001, 52.6, 7.982},
	{945, -329.29999, 57.6, 301.986},
	{946, -312.89999, 57.6, 301.981},
	{985.59998, -312.60001, 67.9, 329.996}
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
	{1043.0, -348.3, 74, 85.9},
	{1042.8, -354.3, 74, 85.9},
	{1042.7, -360.8, 74, 85.9}
}
