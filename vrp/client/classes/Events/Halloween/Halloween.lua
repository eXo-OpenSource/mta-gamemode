Halloween = inherit(Singleton)
addRemoteEvents{"setHalloweenDarkness", "Halloween:sendQuestState"}

function Halloween:constructor()

	WareClient:new()

	Blip:new("Ghost.png", 945.57, -1103.55, 400):setDisplayText("Halloween-Friedhof")

	--Drawing Contest
	local ped = Ped.create(151, Vector3(906.59998, -1065.7, 24.8), 270)
	--DrawContest.createPed(151, Vector3(1488.87, -1777.00, 13.55), 0, "Halloween", "Zeichen-Wettbewerb") -- Temporary for 06.11.2017

	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Halloween", "Zeichen-Wettbewerb")
	ped.SpeakBubble:setBorderColor(Color.Orange)
	ped.SpeakBubble:setTextColor(Color.Orange)
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			DrawContestOverviewGUI:getSingleton():open()
		end
	)

	--Ware Ped
	local ped = Ped.create(68, Vector3(934.79999, -1070.5, 25), 118)
	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Halloween", "Ware-Games")
	ped.SpeakBubble:setBorderColor(Color.Orange)
	ped.SpeakBubble:setTextColor(Color.Orange)
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			triggerServerEvent("Ware:onPedClick", localPlayer)
		end
	)

	--Bonus Ped
	local ped = Ped.create(264, Vector3(813.40002, -1103.1, 25.8), 270)
	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Halloween", "Prämien-Shop")
	ped.SpeakBubble:setBorderColor(Color.Orange)
	ped.SpeakBubble:setTextColor(Color.Orange)
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			BonusGUI:new()
		end
	)

	--water in grave yard

	createWater(884, -1112, 23, 908, -1112, 23, 884, -1090, 23, 908, -1090, 23)
	setWaveHeight(0.2)
	local bloodPoolColShape = createColSphere(895.49, -1101.41, 24.70, 40)
	addEventHandler("onClientColShapeHit", bloodPoolColShape, function(hitElement)
		if hitElement == localPlayer then
			setTimer(function()
				if localPlayer:isWithinColShape(bloodPoolColShape) then
					self:addRandomBloodInPool()
				else
					killTimer(sourceTimer)
				end
			end, 50, 0)
		end
	end)

	HalloweenSign:new()

	self.m_Font = VRPFont(18)
	self.m_TeamNameTexture = dxCreateRenderTarget(1000, 100, true)
	self:Event_restore(true)

	self.m_DarkRenderBind = bind(Halloween.renderDarkness, self)
	if core:get("Event", "HalloweenDarkness", true) then
		addEventHandler("onClientRender", root, self.m_DarkRenderBind)
		--self.m_GhostTimer = setTimer(bind(self.createGhost, self), 200, 0)
	end
	if core:get("Event", "HalloweenSound", true) then
		self:setAmbientSoundEnabled(true)
	end
	addEventHandler("onClientRestore", root, bind(self.Event_restore, self))
	addEventHandler("setHalloweenDarkness", root, bind(self.setDarkness, self))
	--addEventHandler("onClientPlayerWeaponSwitch", root, bind(self.onClientPlayerWeaponSwitch, self))
	addEventHandler("Halloween:sendQuestState", root, bind(self.receiveQuestState, self))
	addEventHandler("onClientPlayerWeaponFire", root, bind(self.onClientPlayerWeaponFire, self))

	self.m_Quests = {
		GhostFinderQuest,
		GhostKillerQuest,
		BigSmokeQuest,
		KillBigSmokeQuest,
	}
	self.m_QuestPed = Ped.create(148, 930.69, -1123.8, 23.98)
	self.m_QuestPed:setData("NPC:Immortal", true)
	self.m_QuestPed:setFrozen(true)
	self.m_QuestPed.SpeakBubble = SpeakBubble3D:new(self.m_QuestPed, "Halloween", "Quests")
	self.m_QuestPed.SpeakBubble:setBorderColor(Color.Orange)
	self.m_QuestPed.SpeakBubble:setTextColor(Color.Orange)
	setElementData(self.m_QuestPed, "clickable", true)
	self.m_QuestPed:setData("onClickEvent", 
		function()
			Halloween:getSingleton():requestQuestState()
		end
	)
	self.m_WastedBind = bind(self.abortQuest, self)

	CustomModelManager:getSingleton():loadImportTXD("files/models/events/halloween/shotgspa.txd", 351)
	CustomModelManager:getSingleton():loadImportDFF("files/models/events/halloween/shotgspa.dff", 351)
	WEAPON_NAMES[27] = "Geistvertreiber"
end

function Halloween:Event_restore(clear)
	if not clear then return end
	dxSetRenderTarget(self.m_TeamNameTexture, true)
		local xoffs = 0
		local color = tocolor(200, 200, 200, 200)
		dxDrawText("Stumpy\nHeisi", xoffs, 20, xoffs+60, 100, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 55
		dxDrawText("Opposite\nfreaK", xoffs, 20, xoffs+60, 100, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 58
		dxDrawImage(xoffs-15, 20, 90, 60, "files/images/Events/Halloween/pedalo.png")
		xoffs = xoffs + 60 + 58
		dxDrawText("Padty", xoffs, 20, xoffs+60, 100, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 58
		dxDrawText("DeanW.\nSaiya\nrottby\nPoldi\nRefrigerator", xoffs, 5, xoffs+60, 115, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 58
		dxDrawText("Swatbird\nSven.Salvarez\nzomb4k33l\nBlack", xoffs, 20, xoffs+60, 100, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 57
		dxDrawText("Renn\nkleiner\nMann", xoffs, 20, xoffs+60, 100, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 57
		dxDrawText("Strobe\nPewX\nMasterM", xoffs, 20, xoffs+60, 100, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 57
		dxDrawText("MegaThorx\nStiviK\nSnake", xoffs, 20, xoffs+60, 100, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 57
	dxSetRenderTarget()
end

function Halloween:setDarkness(force)
	if core:get("Event", "HalloweenDarkness", true) or force then
		if EVENT_HALLOWEEN then -- ask again in case somebody has this option saved in preferences
			removeEventHandler("onClientRender", root, self.m_DarkRenderBind)
			addEventHandler("onClientRender", root, self.m_DarkRenderBind)
			--self.m_GhostTimer = setTimer(bind(self.createGhost, self), 200, 0)
		end
	else
		removeEventHandler("onClientRender", root, self.m_DarkRenderBind)
		if self.m_GhostTimer and isTimer(self.m_GhostTimer) then
			--killTimer(self.m_GhostTimer)
			--HalloweenGhost.destroyAll()
		end
		setFarClipDistance(math.floor(core:get("Other","RenderDistance",992)) )
		setWeather(0)
		resetSkyGradient()
		resetWaterColor()
		resetFogDistance()
	end
end

function Halloween:addRandomBloodInPool()
	if chance(5) then --create a big "smoke" thing of blood
		local angle = math.random(0, 15)
		local dist = math.random(10, 30)/10
		createEffect("blood_heli", 895.63 + math.sin(angle * 24) * dist, -1101.78 + math.cos(angle * 24) * dist, 21)
	end

	if chance(50) then -- spawn blood on top position
		fxAddBlood(895.63, -1101.78, 24.9, 0, 0, 0, 180, 1)
	else --spawn blood on a random side position
		local angle = math.random(0, 15)
		fxAddBlood(895.63 + math.sin(angle * 24), -1101.78 + math.cos(angle * 24), 23.7, 0, 0, 0, 180, 1)
	end
end

function Halloween:renderDarkness() -- not to be confused with 'dankness'! :thinking:
	setTime(22,0) -- there are stars after 22 o clock
	setFarClipDistance(300)
	setFogDistance(-10)
	setSkyGradient(0, 0, 0, 0, 0, 0)
	setWeather(9)
	setWaterColor(255, 0, 0)
	if chance(25) then
		if chance(50) then
			setTrafficLightState("yellow", "yellow")
		else
			setTrafficLightState("disabled")
		end
	end

	--draw team Member names on tomb stones
	--posX="909" posY="-1056.9" posZ="24.5" rotX="0" rotY="0" rotZ="90"
	dxDrawMaterialLine3D(909, -1057, 24.9, 909, -1057, 24.1, self.m_TeamNameTexture, 8.5, white, 909, -1058, 24.9)
end

function Halloween:setAmbientSoundEnabled(state)
	if state then
		self.m_AmbientSound = playSound3D("files/audio/halloween/cemetery.mp3", 895.63, -1101.78, 24.9, true)
		self.m_AmbientSound:setMaxDistance(150)
		self.m_AmbientSound:setVolume(8)
	else
		self.m_AmbientSound:destroy()
	end
end

function Halloween:createGhost()
	if localPlayer:getInterior() == 0 and localPlayer:getDimension() == 0 then
		local x, y, z = getElementPosition(localPlayer)
		local ghost = HalloweenGhost:new(Vector3(x+math.random(-20, 20), y+math.random(-20, 20), z+math.random(10, 20)), math.random(1, 360), 0, 0, true)
		setTimer(
			function()
				if ghost then
					ghost:move(math.random(15, 30))
				end
			end
		, 500, 1)
	end
end

function Halloween:requestQuestState()
	if not self.m_Quest then
		triggerServerEvent("Halloween:requestQuestState", localPlayer)
	else
		if self.m_Quest:isSucceeded() then
			self.m_Quest:endQuest()
			delete(self.m_Quest)
			self.m_Quest = nil
			triggerServerEvent("Halloween:requestQuestUpdate", localPlayer, self.m_QuestState+1)
			removeEventHandler("onClientPlayerWasted", localPlayer, self.m_WastedBind)
		end
	end
end

function Halloween:receiveQuestState(quest)
	self.m_QuestState = quest
	self:startQuest(self.m_QuestState)
end

function Halloween:startQuest()
	if not self.m_Quests[self.m_QuestState+1] then
		DialogGUI:new(false,
			"Merkwürdig, diese Ereignisse hier, nicht wahr?"
		)
		return
	end
	self.m_Quest = self.m_Quests[self.m_QuestState+1]:new()
	self.m_Quest:startQuest()
	addEventHandler("onClientPlayerWasted", localPlayer, self.m_WastedBind)
end

function Halloween:abortQuest()
	if self.m_Quest then
		delete(self.m_Quest)
		self.m_Quest = nil
		ErrorBox:new("Quest fehlgeschlagen!")
		removeEventHandler("onClientPlayerWasted", localPlayer, self.m_WastedBind)
	end
end

--[[
local worldSoundsToDisable = {21, 22, 23, 71, 72, 73, 74}
function Halloween:onClientPlayerWeaponSwitch(prevSlot, newSlot)
	if getPedWeapon(localPlayer, newSlot) == 27 then
		for key, worldSound in ipairs(worldSoundsToDisable) do
			setWorldSoundEnabled(5, worldSound, false)
		end
	else
		for key, worldSound in ipairs(worldSoundsToDisable) do
			setWorldSoundEnabled(5, worldSound, true)
		end
	end
end
]]

function Halloween:onClientPlayerWeaponFire(weapon)
	if weapon == 27 then
		local x, y, z = getPedWeaponMuzzlePosition(source)
		local sound = playSound3D("files/audio/halloween/laser.mp3", x, y, z)
		sound:setMaxDistance(75)
		sound:setVolume(2)
		sound:setDimension(source:getDimension())
	end
end