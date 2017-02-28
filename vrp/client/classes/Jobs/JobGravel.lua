-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobGravel.lua
-- *  PURPOSE:     JobGravel
-- *
-- ****************************************************************************

JobGravel = inherit(Job)

addRemoteEvents{"gravelUpdateData"}

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

	self.m_GravelDeliverCol = {
		createColSphere(677.01, 827.03, -28.20, 4),
		createColSphere(687.68, 846.27, -28.21, 4)
	}

	self.m_DumperDeliverCol = createColSphere(824.22, 919.35, 13.35, 10)
	self.m_DumperDeliverMarker = createMarker(824.22, 919.35, 13.35, "cylinder", 8, 255, 125, 0, 100)
	self.m_DumperDeliverBlip = Blip:new("Waypoint.png", 824.22, 919.35, 999)
	addEventHandler("onClientColShapeHit", self.m_DumperDeliverCol, bind(self.onDumperDeliverColHit, self))

	for index, col in pairs(self.m_GravelDeliverCol) do
		col.track = "Track"..index
		addEventHandler("onClientColShapeHit", col, bind(self.onDeliverColHit, self))
	end

	-- Create info display
	self.m_GravelImage = GUIImage:new(screenWidth/2-200/2, 10, 200, 50, "files/images/Jobs/GravelDisplay.png")
	self.m_MinedLabel = GUILabel:new(55, 4, 55, 40, "0", self.m_GravelImage):setFont(VRPFont(40))
	self.m_StockLabel = GUILabel:new(150, 4, 50, 40, "0", self.m_GravelImage):setFont(VRPFont(40))

	-- Register update events
	addEventHandler("gravelUpdateData", root, function (stock, mined)
		self.m_StockLabel:setText(tostring(stock))
		self.m_MinedLabel:setText(tostring(mined))
	end)
end

function JobGravel:stop()
	for index, element in pairs(self.m_Rocks) do
		if element and isElement(element) then element:destroy() end
	end
	for index, element in pairs(self.m_RockCols) do
		if element and isElement(element) then element:destroy() end
	end
	for index, element in pairs(self.m_GravelDeliverCol) do
		if element and isElement(element) then element:destroy() end
	end

	if self.m_DumperDeliverCol and isElement(self.m_DumperDeliverCol) then self.m_DumperDeliverCol:destroy() end
	if self.m_DumperDeliverMarker and isElement(self.m_DumperDeliverMarker) then self.m_DumperDeliverMarker:destroy() end
	if self.m_DumperDeliverBlip then delete(self.m_DumperDeliverBlip) end

	-- delete infopanels
	delete(self.m_GravelImage)
end


function JobGravel:generateRocks()
	for index, data in pairs(JobGravel.RockPositions) do
		if self.m_Rocks[index] and isElement(self.m_Rocks[index]) then self.m_Rocks[index]:destroy() end
		local x, y, z, rot = unpack(data["rock"])
		self.m_Rocks[index] = createObject(900, x, y, z, 0, 0, rot)
		self.m_RockCols[index] = createColSphere(data["col"], 6)
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
		JobGravel.GravelProgress = JobGravelProgress:new()
	end
end

function JobGravel:onRockColLeave(hit, dim)
	if hit == localPlayer and dim then
		localPlayer.m_GravelCol = nil
		localPlayer.m_GravelColClicked = nil
		removeEventHandler("onClientKey", root, self.m_OnRockClickBind)
		if JobGravel.GravelProgress then delete(JobGravel.GravelProgress) end
	end
end

function JobGravel:onRockClick(key, press)
	if key == "mouse1" and press then
		if localPlayer.m_GravelColClicked then
			if not localPlayer.m_GravelClickPause then
				localPlayer.m_GravelClickPause = true
				localPlayer.m_GravelColClicked = localPlayer.m_GravelColClicked+1
				localPlayer:setAnimation("sword", "sword_4", 1500, true, true, false, false)
				if localPlayer.m_GravelColClicked > 5 then
					localPlayer.m_GravelCol.Rock:destroy()
					localPlayer.m_GravelCol:destroy()
					self:onRockColLeave(localPlayer, true)
					triggerServerEvent("onGravelMine", localPlayer)
				end
				if JobGravel.GravelProgress then
					JobGravel.GravelProgress:setProgress(localPlayer.m_GravelColClicked)
				end
				setTimer(function() localPlayer.m_GravelClickPause = false end, 1500, 1)
			end
		end
	end
end

function JobGravel:onDeliverColHit(hitElement, dim)
	if hitElement:getModel() == 2936 then
		triggerServerEvent("gravelStartTrack", hitElement, source.track)
	end
end

function JobGravel:onDumperDeliverColHit(hitElement, dim)
	if hitElement:getModel() == 2936 then
		triggerServerEvent("gravelDumperDeliver", hitElement)
	end
end


JobGravelProgress = inherit(GUIForm)
inherit(Singleton, JobGravelProgress)

function JobGravelProgress:constructor()
	GUIForm.constructor(self, screenWidth/2-200/2, 65, 200, 30, false)
	self.m_Progress = GUIProgressBar:new(0,0,self.m_Width, self.m_Height,self)
	self.m_Progress:setForegroundColor(tocolor(50,200,255))
	self.m_Progress:setBackgroundColor(tocolor(180,240,255))
	self.m_ProgLabel = GUILabel:new(0, 0, self.m_Width, self.m_Height, "Abgebaut: 0 %", self):setAlignX("center"):setAlignY("center"):setFont(VRPFont(self.m_Height*0.75)):setColor(Color.Black)
end

function JobGravelProgress:setProgress(prog)
	if not prog then delete(self) return end
	prog = prog*20
	self.m_ProgLabel:setText("Abgebaut: "..prog.." %")
	self.m_Progress:setProgress(prog)
end

JobGravel.RockPositions = {
	{["rock"] = {742.6, 850.3, -31, 0}, ["col"] = Vector3(723.60, 847.23, -30.25)},
	{["rock"] = {736.6, 832.9, -31, 174}, ["col"] = Vector3(721.75, 833.14, -30.19)},
	{["rock"] = {731.9, 812.3, -31, 132}, ["col"] = Vector3(718.48, 818.11, -29.27)},
	{["rock"] = {719.2, 794.0, -31, 92}, ["col"] = Vector3(709.56, 802.59, -28.78)},
	{["rock"] = {708.3, 777.9, -31, 94}, ["col"] = Vector3(700.65, 790.70, -29.26)},
	{["rock"] = {690.7, 773.0, -31, 16}, ["col"] = Vector3(688.77, 784.75, -28.38)},
}
