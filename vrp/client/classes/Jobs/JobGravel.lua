-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobGravel.lua
-- *  PURPOSE:     JobGravel
-- *
-- ****************************************************************************

JobGravel = inherit(Job)

function JobGravel:constructor()
	Job.constructor(self, 16, 585.01, 869.73, -42.50, 270, "Pizza.png", "files/images/Jobs/HeaderPizzaDelivery.png", _(HelpTextTitles.Jobs.Gravel):gsub("Job: ", ""), _(HelpTexts.Jobs.Gravel), self.onInfo)

	-- add job to help menu
	HelpTextManager:getSingleton():addText("Jobs", _(HelpTextTitles.Jobs.Gravel):gsub("Job: ", ""), _(HelpTexts.Jobs.Gravel))

	self.m_OnRockColHitBind = bind(self.onRockColHit, self)
	self.m_OnRockColLeaveBind = bind(self.onRockColLeave, self)
	self.m_OnRockClickBind = bind(self.onRockClick, self)

end

function JobGravel:start()
	self.m_Rocks = {}
	self.m_RockCols = {}
	self:generateRocks()
end

function JobGravel:generateRocks()
	for index, data in pairs(JobGravel.RockPositions) do
		if self.m_Rocks[index] and isElement(self.m_Rocks[index]) then self.m_Rocks[index]:destroy() end
		local x, y, z, rot = unpack(data["rock"])
		self.m_Rocks[index] = createObject(900, x, y, z, 0, 0, rot)
		self.m_RockCols[index] = createColSphere(data["col"], 4)
		self.m_RockCols[index].Rock = self.m_Rocks[index]
		addEventHandler("onClientColShapeHit", self.m_RockCols[index], self.m_OnRockColHitBind)
		addEventHandler("onClientColShapeLeave", self.m_RockCols[index], self.m_OnRockColLeaveBind)
		setObjectBreakable(self.m_Rocks[index], true)
	end
end

function JobGravel:onRockColHit(hit, dim)
	if hit == localPlayer and dim then
		localPlayer.m_GravelCol = source
		localPlayer.m_GravelColClicked = 0
		addEventHandler("onClientKey", root, self.m_OnRockClickBind)
	end
end

function JobGravel:onRockColLeave(hit, dim)
	if hit == localPlayer and dim then
		localPlayer.m_GravelCol = nil
		localPlayer.m_GravelColClicked = nil
		removeEventHandler("onClientKey", root, self.m_OnRockClickBind)
	end
end

function JobGravel:onRockClick(key, press)
	if key == "mouse1" and press then
		if localPlayer.m_GravelColClicked then
			if not localPlayer.m_GravelClickPause then
				localPlayer.m_GravelClickPause = true
				localPlayer.m_GravelColClicked = localPlayer.m_GravelColClicked+1
				if localPlayer.m_GravelColClicked > 5 then
					localPlayer.m_GravelCol.Rock:destroy()
					localPlayer.m_GravelCol:destroy()
					self:onRockColLeave(localPlayer, true)
					createObject(2936 ,713.96, 837.82, -30.23)
				end
				setTimer(function() localPlayer.m_GravelClickPause = false end, 2000, 1)
			end
		end
	end
end

JobGravel.RockPositions = {
	{["rock"] = {742.6, 850.3, -31, 0}, ["col"] = Vector3(723.60, 847.23, -30.25)},
	{["rock"] = {736.6, 832.9, -31, 174}, ["col"] = Vector3(721.75, 833.14, -30.19)},
	{["rock"] = {731.9, 812.3, -31, 132}, ["col"] = Vector3(718.48, 818.11, -29.27)},
	{["rock"] = {719.2, 794.0, -31, 92}, ["col"] = Vector3(709.56, 802.59, -28.78)},
	{["rock"] = {708.3, 777.9, -31, 94}, ["col"] = Vector3(700.65, 790.70, -29.26)},
	{["rock"] = {690.7, 773.0, -31, 16}, ["col"] = Vector3(688.77, 784.75, -28.38)},
}
