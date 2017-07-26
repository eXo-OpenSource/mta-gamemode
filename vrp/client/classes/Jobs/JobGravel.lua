-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobGravel.lua
-- *  PURPOSE:     JobGravel
-- *
-- ****************************************************************************

JobGravel = inherit(Job)

addRemoteEvents{"gravelUpdateData", "gravelOnDozerSpawn", "gravelDisableCollission", "gravelOnSync"}

function JobGravel:constructor()
	Job.constructor(self, 16, 585.01, 869.73, -42.50, 270, "Gravel.png", {190, 160, 4}, "files/images/Jobs/HeaderGravel.png", _(HelpTextTitles.Jobs.Gravel):gsub("Job: ", ""), _(HelpTexts.Jobs.Gravel), self.onInfo)
	self:setJobLevel(JOB_LEVEL_GRAVEL)

	-- add job to help menu
	HelpTextManager:getSingleton():addText("Jobs", _(HelpTextTitles.Jobs.Gravel):gsub("Job: ", ""), "jobs.gravel")

	self.m_OnRockColHitBind = bind(self.onRockColHit, self)
	self.m_OnRockColLeaveBind = bind(self.onRockColLeave, self)
	self.m_OnRockClickBind = bind(self.onRockClick, self)
	self.Event_onDebugRender = bind(self.onDebugRender, self)
	addEventHandler("gravelDisableCollission", root, bind(self.Event_disableGravelCollission, self))
	addEventHandler("gravelOnSync", root, bind(self.Event_onRockSync, self))

end

function JobGravel:start()
	QuestionBox:new(_"Willst du das Tutorial zum Kiesgruben-Job ansehen?", bind(self.onInfo, self))

	self.m_Rocks = {}
	self.m_RockCols = {}
	self.m_DestroyGravelCollider = {}
	self:generateRocks()

	self.m_GravelDeliverCol = {
		createColSphere(677.01, 827.03, -28.20, 5),
		createColSphere(687.68, 846.27, -28.21, 5)
	}

	self.m_DumperDeliverCol = createColSphere(824.22, 919.35, 13.35, 10)
	self.m_DumperDeliverMarker = createMarker(824.22, 919.35, 13.35, "cylinder", 8, 255, 125, 0, 100)
	self.m_DumperDeliverBlip = Blip:new("Marker.png", 824.22, 919.35, 999)
	self.m_DumperDeliverBlip:setColor(BLIP_COLOR_CONSTANTS.Red)
	self.m_DumperDeliverBlip:setDisplayText("Dumper-Abgabe")

	addEventHandler("onClientColShapeHit", self.m_DumperDeliverCol, bind(self.onDumperDeliverColHit, self))

	for index, col in pairs(self.m_GravelDeliverCol) do
		col.track = "Track"..index
		addEventHandler("onClientColShapeHit", col, bind(self.onCollectingColHit, self))
	end

	table.insert(self.m_DestroyGravelCollider, createColCuboid(Vector3(544.3, 919.9, -44) - Vector3(5, 5, 0.5), Vector3(10, 10, 2)))
	table.insert(self.m_DestroyGravelCollider, createColCuboid(Vector3(594.7, 926.3, -43) - Vector3(5, 5, 0.5), Vector3(10, 10, 2)))

	for index, collider in pairs(self.m_DestroyGravelCollider) do
		addEventHandler("onClientColShapeHit", collider, bind(self.onGravelDestroyHit, self))
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
		self:dozerCleanup()

		self.m_Vehicle = vehicle

		vehicle.col1 = createColSphere(0, 0, 0, 1.5)
		vehicle.col1:attach(vehicle, -1.2, 3.8, -0.8)
		vehicle.col1.vehicle = vehicle
		self.m_VehicleCol1 = vehicle.col1

		vehicle.col2 = createColSphere(0, 0, 0, 1.5)
		vehicle.col2:attach(vehicle, 1.2, 3.8, -0.8)
		vehicle.col2.vehicle = vehicle
		self.m_VehicleCol2 = vehicle.col2

		addEventHandler("onClientColShapeHit", vehicle.col1, bind(self.onDozerColHit, self))
		addEventHandler("onClientColShapeHit", vehicle.col2, bind(self.onDozerColHit, self))
		addEventHandler("onClientVehicleCollision", vehicle, bind(self.onDozerCollide, self))

		setTimer(bind(self.dozerCheckCleanup, self), 500, 1)
	end)

	if self.m_Timer then self.m_Timer:destroy() end
	self.m_Timer = setTimer(bind(self.syncGravel, self), 1000, 0)

	if getDevelopmentMode() then
		addEventHandler("onClientRender", root, self.Event_onDebugRender)
	end
end

function JobGravel:Event_onRockSync(data)
	for k, v in pairs(data) do
		v.element:setPosition(v.position)
		v.element:setVelocity(v.velocity)
	end
end

function JobGravel:onGravelDestroyHit(hitElement)
	if hitElement:getType() == "object" then
		if hitElement:getModel() == 2936 then
			if hitElement:getData("syncer") == localPlayer then
				triggerServerEvent("gravelOnDestroy", hitElement)
			end
		end
	end
end

function JobGravel:dozerCheckCleanup()
	if self.m_Vehicle and isElement(self.m_Vehicle) then
		setTimer(bind(self.dozerCheckCleanup, self), 500, 1)
	else
		self:dozerCleanup()
	end
end

function JobGravel:dozerCleanup()
	if self.m_VehicleCol1 then
		destroyElement(self.m_VehicleCol1)
		self.m_VehicleCol1 = nil
	end

	if self.m_VehicleCol2 then
		destroyElement(self.m_VehicleCol2)
		self.m_VehicleCol2 = nil
	end
end

function JobGravel:onInfo()
	if localPlayer.vehicle then
		ErrorBox:new(_"Bitte erst aus dem Fahrzeug aussteigen!")
		return
	end
	CutscenePlayer:getSingleton():playCutscene("GravelJob",
		function()
			fadeCamera(true)
			setCameraTarget(localPlayer)
		end, 0)
end

function JobGravel:Event_disableGravelCollission(gravel)
	gravel:setCollidableWith(localPlayer, false)
	setTimer(function()
		gravel:setCollidableWith(localPlayer, true)
	end, 4000, 1)
end

function JobGravel:stop()
	for index, element in pairs(self.m_Rocks) do
		if element and isElement(element) then element:destroy() end
	end
	for index, element in pairs(self.m_RockCols) do
		if element.Blip then delete(element.Blip) end
		if element and isElement(element) then element:destroy() end
	end
	for index, element in pairs(self.m_GravelDeliverCol) do
		if element and isElement(element) then element:destroy() end
	end
	for index, element in pairs(self.m_DestroyGravelCollider) do
		if element and isElement(element) then element:destroy() end
	end

	if self.m_DumperDeliverCol and isElement(self.m_DumperDeliverCol) then self.m_DumperDeliverCol:destroy() end
	if self.m_DumperDeliverMarker and isElement(self.m_DumperDeliverMarker) then self.m_DumperDeliverMarker:destroy() end
	if self.m_DumperDeliverBlip then delete(self.m_DumperDeliverBlip) end

	removeEventHandler("onClientKey", root, self.m_OnRockClickBind)

	if self.m_Timer and isElement(self.m_Timer) then self.m_Timer:destroy() end
	removeEventHandler("onClientRender", root, self.Event_onDebugRender)
	-- delete infopanels
	delete(self.m_GravelImage)

	if JobGravel.GravelProgress then delete(JobGravel.GravelProgress) end
end


function JobGravel:generateRocks()
	self.m_MinedRocks = 0

	for index, data in pairs(JobGravel.RockPositions) do
		if self.m_Rocks[index] and isElement(self.m_Rocks[index]) then self.m_Rocks[index]:destroy() end
		if self.m_RockCols[index] and isElement(self.m_RockCols[index]) then
			if self.m_RockCols[index].Blip then delete(self.m_RockCols[index].Blip) end
			self.m_RockCols[index]:destroy()
		end

		local x, y, z, rot = unpack(data["rock"])
		self.m_Rocks[index] = createObject(900, x, y, z, 0, 0, rot)
		self.m_RockCols[index] = createColSphere(data["col"], 6)
		self.m_RockCols[index].Blip = Blip:new("Marker.png", data["col"].x, data["col"].y)
		self.m_RockCols[index].Blip:setColor(BLIP_COLOR_CONSTANTS.Yellow)
		self.m_RockCols[index].Blip:setSize(Blip.getDefaultSize()/2)
		self.m_RockCols[index].Blip:setDisplayText("Stein")
		self.m_RockCols[index].Rock = self.m_Rocks[index]
		self.m_RockCols[index].Times = math.random(4, 10)
		addEventHandler("onClientColShapeHit", self.m_RockCols[index], self.m_OnRockColHitBind)
		addEventHandler("onClientColShapeLeave", self.m_RockCols[index], self.m_OnRockColLeaveBind)
		setObjectBreakable(self.m_Rocks[index], true)
	end
end

function JobGravel:onDozerColHit(hitElement, dim)
	if hitElement:getModel() == 2936 then
		triggerServerEvent("gravelOnDozerHit", hitElement, source.vehicle)
	end
end

function JobGravel:onDozerCollide(gravel)
	if gravel and gravel:getModel() == 2936 then
		if getElementData(gravel, "mined") then
			if getElementData(gravel, "syncer") ~= localPlayer then
				setElementData(gravel, "syncer", localPlayer, true)
			end

			if not getElementData(gravel, "lastSync") or getElementData(gravel, "lastSync") < getRealTime().timestamp then
				setElementData(gravel, "lastSync", getRealTime().timestamp, true)
				gravel.m_LastPosition = gravel.position
				
				triggerServerEvent("gravelOnSync", gravel, gravel.position.x, gravel.position.y, gravel.position.z, gravel.velocity.x, gravel.velocity.y, gravel.velocity.z)
			end
		end
	end
end

function JobGravel:syncGravel()
	for k, v in ipairs(getElementsByType("object", root, true)) do
		if v:getModel() == 2936 then
			if getElementData(v, "mined") and getElementData(v, "syncer") == localPlayer then
				if not getElementData(v, "lastSync") or getElementData(v, "lastSync") < getRealTime().timestamp then
					if not v.m_LastPosition or not (v.position.x == v.m_LastPosition.x and v.position.y == v.m_LastPosition.y and v.position.z == v.m_LastPosition.z) then 
						setElementData(v, "lastSync", getRealTime().timestamp, true)
						v.m_LastPosition = v.position
						
						triggerServerEvent("gravelOnSync", v, v.position.x, v.position.y, v.position.z, v.velocity.x, v.velocity.y, v.velocity.z)
					end
				end
			end
		end
	end
end

function JobGravel:onDebugRender()
	for k, v in ipairs(getElementsByType("object", root, true)) do
		if v:getModel() == 2936 then
			if v:getData("mined") then
				local vX, vY = getScreenFromWorldPosition(v.position, 0, false)
				if vX and vY then
					local syncer = "none"
					local lastSync = 0
					local moved = not v.m_LastPosition or not (v.position.x == v.m_LastPosition.x and v.position.y == v.m_LastPosition.y and v.position.z == v.m_LastPosition.z)

					if getElementData(v, "syncer") then syncer = getElementData(v, "syncer"):getName() end
					if getElementData(v, "lastSync") then lastSync = getElementData(v, "lastSync") end

		
					local text = "Syncer: "..syncer 
					text = text .. "\nLastSync: " .. lastSync 
					text = text .. "\nMoved: " .. tostring(moved)
					text = text .. "\nCurPos: " .. tostring(v.position)
					text = text .. "\nLstPos: " .. tostring(v.m_LastPosition) 

					dxDrawText(text, vX - 1, vY - 1, nil, nil, tocolor(0, 0, 0, 255))
					dxDrawText(text, vX, vY)
				end
			end
		end
	end
end

function JobGravel:onRockColHit(hit, dim)
	if hit == localPlayer and dim and not hit.vehicle then
		triggerServerEvent("gravelTogglePickaxe", localPlayer, true)
		localPlayer.m_GravelCol = source
		localPlayer.m_GravelColClicked = 0
		addEventHandler("onClientKey", root, self.m_OnRockClickBind)
		JobGravel.GravelProgress = JobGravelProgress:new()
	end
end

function JobGravel:onRockColLeave(hit, dim)
	if hit == localPlayer and dim then
		triggerServerEvent("gravelTogglePickaxe", localPlayer)
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
				playSound3D(("files/audio/jobs/pickaxe%d.mp3"):format(math.random(1,4)), localPlayer:getPosition())
				triggerServerEvent("onGravelMine", localPlayer, rockDestroyed, times)


				setTimer(function() localPlayer.m_GravelClickPause = false end, 2200, 1)

				if self.m_MinedRocks >= #JobGravel.RockPositions then
					self:generateRocks()
				end
			end
		end
	end
end

function JobGravel:onCollectingColHit(hitElement, dim)
	if hitElement:getModel() == 2936 then
		triggerServerEvent("gravelOnCollectingContainerHit", hitElement, source.track)
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
