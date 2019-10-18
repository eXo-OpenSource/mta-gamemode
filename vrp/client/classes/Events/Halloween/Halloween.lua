Halloween = inherit(Singleton)
addRemoteEvents{"setHalloweenDarkness"}

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
	local col = createColSphere(895.49, -1101.41, 24.70, 40)
	addEventHandler("onClientColShapeHit", col, function()
		setTimer(function()
			if localPlayer:isWithinColShape(col) then
				self:addRandomBloodInPool()
			else
				killTimer(sourceTimer)
			end
		end, 50, 0)
	end)

	HalloweenSign:new()

	self.m_Font = VRPFont(18)
	self.m_TeamNameTexture = dxCreateRenderTarget(1000, 100, true)
	self:Event_restore(true)

	self.m_DarkRenderBind = bind(Halloween.renderDarkness, self)
	if core:get("Event", "HalloweenDarkness", true) then
		addEventHandler("onClientRender", root, self.m_DarkRenderBind)
	end
	addEventHandler("onClientRestore", root, bind(self.Event_restore, self))
	addEventHandler("setHalloweenDarkness", root, bind(self.setDarkness, self))

	self.m_Ghosts = {}
	self.m_GhostTimer = setTimer(bind(self.createGhost, self), 200, 0)
end

function Halloween:Event_restore(clear)
	if not clear then return end
	dxSetRenderTarget(self.m_TeamNameTexture, true)
		local xoffs = 0
		local color = tocolor(200, 200, 200, 200)
		dxDrawText("Stumpy\nHeisi", xoffs, 20, xoffs+60, 100, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 55
		dxDrawText("G.Eazy\nOpposite", xoffs, 20, xoffs+60, 100, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 58
		dxDrawImage(xoffs-15, 20, 90, 60, "files/images/Events/Halloween/pedalo.png")
		xoffs = xoffs + 60 + 58
		dxDrawText("Padty\nfreaK", xoffs, 20, xoffs+60, 100, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 58
		dxDrawText("DeanW.\nSaiya\nrottby\nPoldi\nRefrigerator", xoffs, 5, xoffs+60, 115, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 58
		dxDrawText("Swatbird\nSven.Salvarez\nzomb4k33l\nBlack", xoffs, 20, xoffs+60, 100, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 57
		dxDrawText("Renn\nkleiner\nMann", xoffs, 20, xoffs+60, 100, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 57
		dxDrawText("Strobe\nPewX\nMasterM", xoffs, 20, xoffs+60, 100, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 57
		dxDrawText("MegaThorx\nStivik\nSnake", xoffs, 20, xoffs+60, 100, color, 1, getVRPFont(self.m_Font), "center")
		xoffs = xoffs + 60 + 57
	dxSetRenderTarget()
end

function Halloween:setDarkness(force)
	if core:get("Event", "HalloweenDarkness", true) or force then
		if EVENT_HALLOWEEN then -- ask again in case somebody has this option saved in preferences
			removeEventHandler("onClientRender", root, self.m_DarkRenderBind)
			addEventHandler("onClientRender", root, self.m_DarkRenderBind)
		end
	else
		removeEventHandler("onClientRender", root, self.m_DarkRenderBind)
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

function Halloween:createGhost()
	local x, y, z = getElementPosition(localPlayer)
	local ghost = HalloweenGhost:new(Vector3(x+math.random(-20, 20), y+math.random(-20, 20), z+math.random(10, 20)), math.random(1, 360))
	setTimer(
		function()
			ghost:move(math.random(15, 30))
		end
	, 500, 1)
end

HalloweenSign = inherit(GUIForm3D)
inherit(Singleton, HalloweenSign)

function HalloweenSign:constructor()
	--1903, 1484.80, -1710.70
	--rechts -> höher
	GUIForm3D.constructor(self, Vector3(1507.69, -1753.78, 16.09), Vector3(0, 0, 0), Vector2(4.4, 2.09), Vector2(1200,600), 50)
end

function HalloweenSign:onStreamIn(surface)
	self.m_Url = INGAME_WEB_PATH .. "/ingame/other/HalloweenSign.php"
	GUIWebView:new(0, 0, 1200, 600, self.m_Url, true, surface)
end