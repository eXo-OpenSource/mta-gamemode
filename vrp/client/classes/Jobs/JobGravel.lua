-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobGravel.lua
-- *  PURPOSE:     JobGravel
-- *
-- ****************************************************************************

JobGravel = inherit(Job)

addRemoteEvents{"gravelUpdateData", "gravelOnDozerSpawn"}

function JobGravel:constructor()
	Job.constructor(self, 16, 585.01, 869.73, -42.50, 270, "Gravel.png", "files/images/Jobs/HeaderGravel.png", _(HelpTextTitles.Jobs.Gravel):gsub("Job: ", ""), _(HelpTexts.Jobs.Gravel), self.onInfo)

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

	self.m_MinedRocks = 0

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
		addEventHandler("onClientColShapeHit", col, bind(self.onCollectingColHit, self))
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

	addEventHandler("gravelOnDozerSpawn", root, function(vehicle)
		vehicle.col1 = createColSphere(0, 0, 0, 1.2)
		vehicle.col1:attach(vehicle, -1, 3, -0.8)
		vehicle.col1.vehicle = vehicle

		vehicle.col2 = createColSphere(0, 0, 0, 1.2)
		vehicle.col2:attach(vehicle, 1, 3, -0.8)
		vehicle.col2.vehicle = vehicle
		addEventHandler("onClientColShapeHit", vehicle.col1, bind(self.onDozerColHit, self))
		addEventHandler("onClientColShapeHit", vehicle.col2, bind(self.onDozerColHit, self))
	end)
end

function JobGravel:onInfo()
	if localPlayer.vehicle then
		ErrorBox:new(_"Bitte erst aus dem Fahrzeug aussteigen!")
		return
	end

	setCameraMatrix(745.26507568359,806.82489013672,24.597700119019,744.47778320313,807.21868896484,24.123294830322,0,70)
	outputChatBox(_"#0000FF[Kiesgrube]#FFFFFF Es gibt verschiedene Aufgaben in der Kiesgrube.",255,255,255,true)
	-- ### 1
	setTimer(function()
	setCameraMatrix(650.06768798828,810.92419433594,-0.32589998841286,650.95715332031,811.03039550781,-0.77037560939789,0,70)
	outputChatBox(_"#0000FF[Kiesgrube]#FFFFFF Als erstes müssen mit der Spitzhacke die hellen Felsen abgebaut werden.",255,255,255,true)
	end, 4000, 1)
	-- ### 2
	setTimer(function()
	setCameraMatrix(723.49090576172,855.93347167969,-4.5064997673035,722.77587890625,855.54370117188,-5.0868692398071,0,70)
	outputChatBox(_"#0000FF[Kiesgrube]#FFFFFF Die gewonnen Steine müssen mit Bulldozern in diese Behälter geschoben werden.",255,255,255,true)
	end, 8000, 1)
	-- ### 3
	setTimer(function()
	setCameraMatrix(614.17028808594,922.25207519531,-5.7822999954224,614.50836181641,921.46221923828,-6.2939896583557,0,70)
	outputChatBox(_"#0000FF[Kiesgrube]#FFFFFF Steine werden automatisch über die Förderbänder ins Lager transportiert.",255,255,255,true)
	end, 12000, 1)
	--- ### 4

	setTimer(function()
	setCameraMatrix(510.34188842773,898.67626953125,-14.97889995575,511.17974853516,899.00653076172,-15.413551330566,0,70)
	outputChatBox(_"#0000FF[Kiesgrube]#FFFFFF Anschließend können die Steine hier in einen Dumper geladen werden,",255,255,255,true)
	end, 16000, 1)

	setTimer(function()
	setCameraMatrix(881.95788574219,847.56042480469,38.781200408936,881.10424804688,847.98742675781,38.482925415039,0,70)
	outputChatBox(_"#0000FF[Kiesgrube]#FFFFFF vorsichtig aus der Grube transportiert und hier oben abgegeben werden.",255,255,255,true)
	end, 20000, 1)
	-- ### LAST
	setTimer(function()
	setCameraTarget(localPlayer,localPlayer)
	localPlayer:setPosition(588.85, 869.45, -42.50)
	end, 24000,1)
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

	if JobGravel.GravelProgress then delete(JobGravel.GravelProgress) end
end


function JobGravel:generateRocks()
	for index, data in pairs(JobGravel.RockPositions) do
		if self.m_Rocks[index] and isElement(self.m_Rocks[index]) then self.m_Rocks[index]:destroy() end
		local x, y, z, rot = unpack(data["rock"])
		self.m_Rocks[index] = createObject(900, x, y, z, 0, 0, rot)
		self.m_RockCols[index] = createColSphere(data["col"], 6)
		self.m_RockCols[index].Rock = self.m_Rocks[index]
		self.m_RockCols[index].Times = math.random(4, 10)
		addEventHandler("onClientColShapeHit", self.m_RockCols[index], self.m_OnRockColHitBind)
		addEventHandler("onClientColShapeLeave", self.m_RockCols[index], self.m_OnRockColLeaveBind)
		setObjectBreakable(self.m_Rocks[index], true)
	end
end

function JobGravel:onDozerColHit(hitElement, dim)
	if hitElement:getModel() == 2936 then
		hitElement.vehicle = source.vehicle
	end
end

function JobGravel:onRockColHit(hit, dim)
	if hit == localPlayer and dim and not hit.vehicle then
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

				local times = localPlayer.m_GravelCol.Times
				local rockDestroyed = false

				localPlayer:setAnimation("sword", "sword_4", 1500, true, true, false, false)

				if JobGravel.GravelProgress and localPlayer.m_GravelCol.Times then
					JobGravel.GravelProgress:setProgress(localPlayer.m_GravelColClicked, localPlayer.m_GravelCol.Times)
				end

				if localPlayer.m_GravelColClicked >= localPlayer.m_GravelCol.Times then
					localPlayer.m_GravelCol.Rock:destroy()
					localPlayer.m_GravelCol:destroy()
					self:onRockColLeave(localPlayer, true)
					self.m_MinedRocks = self.m_MinedRocks+1
					rockDestroyed = true
				end

				triggerServerEvent("onGravelMine", localPlayer, rockDestroyed, times)


				setTimer(function() localPlayer.m_GravelClickPause = false end, 1500, 1)

				if self.m_MinedRocks >= #JobGravel.RockPositions then
					self:generateRocks()
				end
			end
		end
	end
end

function JobGravel:onCollectingColHit(hitElement, dim)
	if hitElement:getModel() == 2936 then
		triggerServerEvent("gravelOnCollectingContainerHit", hitElement, source.track, hitElement.vehicle)
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

function JobGravelProgress:setProgress(prog, max)
	if not prog then delete(self) return end
	prog = math.floor(prog/max*100)
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
