-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/LocalPlayer.lua
-- *  PURPOSE:     Local player class
-- *
-- ****************************************************************************
LocalPlayer = inherit(Player)
addRemoteEvents{"retrieveInfo", "playerWasted", "playerRescueWasted", "playerCashChange", "disableDamage",
"playerSendToHospital", "abortDeathGUI", "sendTrayNotification","setClientTime", "setClientAdmin", "toggleRadar", "onTryPickupWeapon", "onServerRunString", "playSound", "stopBleeding", "restartBleeding", "setCanBeKnockedOffBike", "setOcclusion"
,"onTryEnterExit"}

local screenWidth,screenHeight = guiGetScreenSize()
function LocalPlayer:constructor()
	self.m_Locale = "de"
	self.m_Job = false
	self.m_Rank = 0
	self.m_LoggedIn = false
	self.m_JoinTime = getTickCount()
	self.FPS = {startTick = getTickCount(), counter = 0, frames = 0 }

	self.m_AFKTimer = setTimer ( bind(self.checkAFK, self), 5000, 0)
	self.m_AFKCheckCount = 0
	self.m_CurrentAFKTime = 0
	self.m_AFKTime = 0
	self.m_AFKStartTime = 0
	self.m_LastMortemPickup = getTickCount()
	self.m_LastPositon = self:getPosition()
	self.m_PlayTime = setTimer(bind(self.setPlayTime, self), 60000, 0)
	self.m_FadeOut = bind(self.fadeOutScope, self)
	self.m_OnDeathTimerUp = bind(self.onDeathTimerUp, self)
	-- Since the local player exist only once, we can add the events here
	addEventHandler("retrieveInfo", root, bind(self.Event_retrieveInfo, self))
	addEventHandler("onClientPlayerWasted", root, bind(self.playerWasted, self))
	addEventHandler("playerWasted", root, bind(self.Event_playerWasted, self))
	addEventHandler("playerCashChange", self, bind(self.playCashChange, self))
	addEventHandler("disableDamage", self, bind( self.disableDamage, self ))
	addEventHandler("abortDeathGUI", self, bind( self.abortDeathGUI, self ))
	addEventHandler("sendTrayNotification", self, bind( self.sendTrayNotification, self ))
	addEventHandler("setClientTime", self, bind(self.Event_onGetTime, self))
	addEventHandler("setClientAdmin", self, bind(self.Event_setAdmin, self))
	addEventHandler("toggleRadar", self, bind(self.Event_toggleRadar, self))
	addEventHandler("onClientPlayerSpawn", self, bind(LocalPlayer.Event_onClientPlayerSpawn, self))
	addEventHandler("onClientPreRender", root, bind(LocalPlayer.calcFPS, self))
	addEventHandler("onClientRender",root,bind(self.renderPedNameTags, self))
	addEventHandler("onTryPickupWeapon", root, bind(self.Event_OnTryPickup, self))
	addEventHandler("onServerRunString", root, bind(self.Event_RunString, self))
	addEventHandler("playSound", root, bind(self.Event_PlaySound, self))
	addEventHandler("playSFX", root, bind(self.Event_PlaySFX, self))
	addEventHandler("playSFX3D", root, bind(self.Event_PlaySFX3D, self))
	addEventHandler("stopBleeding", root, bind(self.stopDeathBleeding, self))
	addEventHandler("restartBleeding", root, bind(self.restartDeathBleeding, self))
	addEventHandler("setCanBeKnockedOffBike", root, bind(self.serverSetCanBeKnockedOffBike, self))
	addEventHandler("onClientObjectBreak",root,bind(self.Event_OnObjectBrake,self))
	addEventHandler("setOcclusion",root,function( bool ) setOcclusionsEnabled(bool) end)
	addEventHandler("onTryEnterExit", root, bind(self.Event_tryEnterExit, self)) 

	addCommandHandler("noafk", bind(self.onAFKCodeInput, self))
	addCommandHandler("anim", bind(self.startAnimation, self))

	self.m_DeathRenderBind = bind(self.deathRender, self)

	--Alcoholsystem
	self.m_AlcoholDecreaseBind = bind(self.alcoholDecrease, self)
	self:setPrivateSyncChangeHandler("AlcoholLevel", bind(self.onAlcoholLevelChange, self))
	
	self:setPrivateSyncChangeHandler("SessionID", function()
		core:onWebSessionCreated()
	end)

	self.m_RenderAlcoholBind = bind(self.Event_RenderAlcohol,self)
	self.m_CancelEvent = function()	cancelEvent() end
	
	local col = createColRectangle(1034.28, -1389.45, 1210.74-1034.28, 1389.45-1253.37) 
	self.m_NoOcclusionZone = NonOcclusionZone:new(col)
	
	local col2 = createColRectangle(802.48, -1314.53, 951.69-802.48, 1314.53-1155.58 ) 
	self.m_NoOcclusionZone = NonOcclusionZone:new(col2)

	local col3 = createColCuboid(1894.46, 968.18, 9.82, 1920.30-1894.46, 1018.40-968.18, 5) -- triad base
	self.m_NoOcclusionZone = NonOcclusionZone:new(col3)

	local col4 = createColCuboid(2305.70, -0.12, 24.74, 2316.60-2305.70, 22.43, 5 ) -- palo bank
	self.m_NoOcclusionZone = NonOcclusionZone:new(col4)

	local col5 = createColRectangle(2350.23, -2666.53, 100,  250) -- ls docks
	self.m_NoOcclusionZone = NonOcclusionZone:new(col5)

	NetworkMonitor:new()
end

function LocalPlayer:startLookAt( )
	if self.m_LookAtTimer and isTimer(self.m_LookAtTimer) then 
		self:stopLookAt()
	end
	self.m_LookAtTimer = setTimer(bind(self.Event_PreRender, self), 100, 0)
end

function LocalPlayer:stopLookAt()
	if self.m_LookAtTimer and isTimer(self.m_LookAtTimer) then 
		killTimer(self.m_LookAtTimer)
	end
	setPedLookAt(localPlayer, 0, 0,0, 0)
end

function LocalPlayer:destructor()
end

-- Short getters
function LocalPlayer:getLocale()	return self.m_Locale 	end
function LocalPlayer:getJob()		return self.m_Job 		end

-- Short setters
function LocalPlayer:setLocale(locale)	self.m_Locale = locale 	end
function LocalPlayer:setJob(job)		self.m_Job = job		end


function LocalPlayer:sendMessage(text, r, g, b, ...)
	outputChatBox(text:format(...), r, g, b, true)
end

function LocalPlayer:getRank()
	return self.m_Rank
end

function LocalPlayer:Event_PreRender()
    local tx, ty, tz = getWorldFromScreenPosition(screenWidth / 2, screenHeight / 2, 10)
	if tx and ty and tz then
		setPedLookAt(localPlayer, tx, ty, tz, -1, 0)
	end
end

function LocalPlayer:Event_onGetTime( realtime )
	setTime(realtime.hour, realtime.minute)
	setMinuteDuration(60000)
end

function LocalPlayer:fadeOutScope()
	if localPlayer.m_IsFading then
		fadeCamera(true,1)
		localPlayer.m_IsFading = false
	end
end

function LocalPlayer:Event_OnObjectBrake( attacker )
	if attacker == localPlayer then
		if getElementModel(source) == 1224 then
			triggerServerEvent("onCrateDestroyed",localPlayer,source)
		end
	end
end


function LocalPlayer:onAlcoholLevelChange()
	if self:getPrivateSync("AlcoholLevel") > 0 then
		if not isTimer(self.m_AlcoholDecreaseTimer) then
			self.m_AlcoholDecreaseTimer = setTimer(self.m_AlcoholDecreaseBind, ALCOHOL_LOSS_INTERVAL*1000, 0)
			addEventHandler("onClientRender",root,self.m_RenderAlcoholBind)
		end
		self:setAlcoholEffect()
	else
		if self.m_AlcoholShader then delete(self.m_AlcoholShader) end
	end
end

function LocalPlayer:alcoholDecrease()
	if self:getPrivateSync("AlcoholLevel") > 0 then
		local newAlcoholLevel = self:getPrivateSync("AlcoholLevel") - ALCOHOL_LOSS
		if newAlcoholLevel < 0 then	newAlcoholLevel = 0	end

		if newAlcoholLevel == 0 then
			if isTimer(self.m_AlcoholDecreaseTimer) then killTimer(self.m_AlcoholDecreaseTimer) end
			if self.m_AlcoholShader then
				delete(self.m_AlcoholShader)
				removeEventHandler("onClientRender",root,self.m_RenderAlcoholBind)
			end
		end

		triggerServerEvent("playerDecreaseAlcoholLevel", localPlayer)
	else
		if isTimer(self.m_AlcoholDecreaseTimer) then killTimer(self.m_AlcoholDecreaseTimer) end
	end
end

function LocalPlayer:setAlcoholEffect()
	if not self.m_AlcoholShader then
		self.m_AlcoholShader = ZoomBlurShader:new()
	end
	local alcLevel = self:getPrivateSync("AlcoholLevel")
	if self.m_AlcoholShader then
		self.m_AlcoholShader:setValue((alcLevel/10)*0.5)
	end
end

function LocalPlayer:Event_RenderAlcohol()
	local alc = self:getPrivateSync("AlcoholLevel")
	if alc then
		if alc >= 2 then
			toggleControl("sprint",false)
			setPedControlState("walk",true)
		end
	end
end

function LocalPlayer:setAFKTime()
	if not localPlayer:getData("inJail") and not localPlayer:getData("inAdminPrison") then
		if self.m_AFKStartTime > 0 then
			self.m_CurrentAFKTime = (getTickCount() - self.m_AFKStartTime)
		else
			self.m_AFKTime = self.m_AFKTime + self.m_CurrentAFKTime
			self.m_CurrentAFKTime = 0
		end
	end
end

function LocalPlayer:getPlayTime()
	self:setAFKTime()
	return (self:getPrivateSync("LastPlayTime") and self.m_JoinTime and math.floor(self:getPrivateSync("LastPlayTime") + (getTickCount()-self.m_JoinTime-self.m_CurrentAFKTime-self.m_AFKTime)/1000/60)) or 0
end

function LocalPlayer:setPlayTime()
	setElementData(self, "playingTime", self:getPlayTime())
end

function LocalPlayer:isLoggedIn()
	return self.m_LoggedIn
end

function LocalPlayer:getStatistics(stat)
	if stat then
		return self:getPrivateSync("Stat_"..stat)
	end
end

function LocalPlayer:getPoints()
	return self:getPrivateSync("Points")
end

function LocalPlayer:getWeaponLevel()
	return self:getPrivateSync("WeaponLevel") or 0
end

function LocalPlayer:getVehicleLevel()
	return self:getPrivateSync("VehicleLevel") or 0
end

function LocalPlayer:getSkinLevel()
	return self:getPrivateSync("SkinLevel") or 0
end

function LocalPlayer:getJobLevel()
	return self:getPrivateSync("JobLevel") or 0
end

function LocalPlayer:getFishingLevel()
	return self:getPrivateSync("FishingLevel") or 0
end

function LocalPlayer:getSessionId()
	return self:getPrivateSync("SessionID") or ""
end

function LocalPlayer:playCashChange( bNoSound )
	if not bNoSound then
		playSound( "files/audio/cash_register.ogg" )
	end
end

function LocalPlayer:disableDamage(bstate)
	if bstate then
		Guns:getSingleton():disableDamage(bstate)
		addEventHandler("onClientPlayerDamage", localPlayer, self.m_CancelEvent, true, "high")
	else
		Guns:getSingleton():disableDamage(bstate)
		removeEventHandler("onClientPlayerDamage", localPlayer, self.m_CancelEvent)
	end
end

function LocalPlayer:playerWasted( killer, weapon, bodypart)
	if source == localPlayer then
		if localPlayer:getPublicSync("Faction:Duty") and localPlayer:getFaction() then
			if localPlayer:getFaction():isStateFaction() then
				triggerServerEvent("factionStateToggleDuty", localPlayer, true)
			elseif localPlayer:getFaction():isRescueFaction() then
				triggerServerEvent("factionRescueToggleDuty", localPlayer, false, true)
			elseif localPlayer:getFaction():isEvilFaction() then
				triggerServerEvent("factionEvilToggleDuty", localPlayer, true)
			end
		end

		if localPlayer:getPublicSync("Company:Duty") then
			triggerServerEvent("companyToggleDuty", localPlayer, true)
		end
		triggerServerEvent("Event_ClientNotifyWasted", localPlayer, killer, weapon, bodypart)
	end
end

function LocalPlayer:onDeathTimerUp()
	self.m_Death = false
	if self.m_DeathMessage then
		delete(self.m_DeathMessage)
	end
	if isTimer(self.m_WastedTimer) then killTimer(self.m_WastedTimer) end
	triggerServerEvent("factionRescueReviveAbort", self, self)
	self.m_CanBeRevived = false
	if isElement(self.m_DeathAudio) then
		destroyElement(self.m_DeathAudio)
	end

	local soundLength = 20 -- Length of Halleluja in Seconds
	if core:get("Other", "HallelujaSound", true) and fileExists("files/audio/Halleluja.mp3") then
		self.m_Halleluja = playSound("files/audio/Halleluja.mp3")
		soundLength = self.m_Halleluja:getLength()
	end
	triggerServerEvent("destroyPlayerWastedPed",localPlayer)
	ShortMessage:new(_"Dir konnte leider niemand mehr helfen!\nBut... have a good flight to heaven!", (soundLength-1)*1000)

	-- render camera drive
	self.m_Add = 0
	addEventHandler("onClientPreRender", root, self.m_DeathRenderBind)
	fadeCamera(false, soundLength)

	setTimer(
		function()
			-- stop moving
			removeEventHandler("onClientPreRender", root, self.m_DeathRenderBind)
			fadeCamera(true, 0.5)

			-- now death gui
			DeathGUI:new(self:getPublicSync("DeathTime"),
				function()
					HUDRadar:getSingleton():show()
					HUDUI:getSingleton():show()
					showChat(true)
					-- Trigger it back to the Server (TODO: Maybe is this Event unsafe..?)
					triggerServerEvent("factionRescueWastedFinished", localPlayer)
				end
			)
		end, soundLength*1000, 1
	)
end

function LocalPlayer:createWastedTimer()
	local start = getTickCount()
	self.m_WastedTimer = setTimer(
		function()
			local timeGone = getTickCount() - start
			if timeGone >= MEDIC_TIME-500 then
				self.m_OnDeathTimerUp()
			else
				if localPlayer:isPremium() then
					self.m_DeathMessage.m_Text = _("Du bist schwer verletzt und verblutest in %s Sekunden...\n(Drücke hier um dich umzubringen)", math.floor((MEDIC_TIME - timeGone)/1000))
				else
					self.m_DeathMessage.m_Text = _("Du bist schwer verletzt und verblutest in %s Sekunden...", math.floor((MEDIC_TIME - timeGone)/1000))
				end
				self.m_DeathMessage:anyChange()
			end
		end, 1000, MEDIC_TIME/1000
	)
end

function LocalPlayer:createDeathShortMessage()
	if localPlayer:isPremium() then
		self.m_DeathMessage = ShortMessage:new(_("Du bist schwer verletzt und verblutest in %s Sekunden...\n(Drücke hier um dich umzubringen)", MEDIC_TIME/1000), nil, nil, MEDIC_TIME,
			function()
				if self.m_Death then
					self.m_OnDeathTimerUp()
				else
					ErrorBox:new(_"Du bist nicht mehr tot!")
					return
				end
			end
		)
	else
		self.m_DeathMessage = ShortMessage:new(_("Du bist schwer verletzt und verblutest in %s Sekunden...", MEDIC_TIME/1000), nil, nil, MEDIC_TIME)
	end
end

function LocalPlayer:Event_playerWasted()
	-- Hide UI Elements
	HUDRadar:getSingleton():hide()
	HUDUI:getSingleton():hide()
	Phone:getSingleton():close()
	showChat(false)
	self.m_Death = true
	triggerServerEvent("Event_setPlayerWasted", self)

	setGameSpeed(0.1)
	self.m_DeathAudio = playSound("files/audio/death_ahead.mp3")
	setSoundVolume(self.m_DeathAudio,1)
	local x,y,z = getPedBonePosition(localPlayer,5)
	setSkyGradient(10,10,10,30,30,30)
	setTimer(Camera.setMatrix,5000,1, x, y, z+3, x, y, z)
	setTimer(setGameSpeed,5000,1,1)
	setTimer(resetSkyGradient,30000,1)
	if localPlayer:getInterior() > 0 then
		self.m_OnDeathTimerUp()
		return
	end

	self.m_CanBeRevived = true
	self:createDeathShortMessage()
	self:createWastedTimer()
end

function LocalPlayer:stopDeathBleeding()
	if self.m_WastedTimer then
		killTimer(self.m_WastedTimer)
	end
	if self.m_DeathMessage then
		delete(self.m_DeathMessage)
	end
	self.m_DeathBleedingMessage = ShortMessage:new(_"Ein Arzt schützt dich vor dem verbluten bis ein Rettungswagen eintrifft!", nil, nil, math.huge)
end

function LocalPlayer:restartDeathBleeding()
	if self.m_DeathBleedingMessage then
		delete(self.m_DeathBleedingMessage)
	end
	self:createDeathShortMessage()
	self:createWastedTimer()
end

function LocalPlayer:deathRender(deltaTime)
	local pos = localPlayer.position + localPlayer.matrix.up*11
	self.m_Add = self.m_Add+0.005*deltaTime
	Camera.setMatrix(Vector3(pos.x, pos.y, pos.z + self.m_Add), pos)
end

function LocalPlayer:abortDeathGUI(force)
	if self.m_CanBeRevived or force then
		if self.m_WastedTimer and isTimer(self.m_WastedTimer) then killTimer(self.m_WastedTimer) end
		if self.m_DeathMessage then delete(self.m_DeathMessage) end
		if self.m_Halleluja and isElement(self.m_Halleluja) then destroyElement(self.m_Halleluja) end
		if self.m_DeathBleedingMessage then delete(self.m_DeathBleedingMessage) end
		if isElement(self.m_DeathAudio) then destroyElement(self.m_DeathAudio) end
		HUDRadar:getSingleton():show()
		HUDUI:getSingleton():show()
		showChat(true)
		removeEventHandler("onClientPreRender", root, self.m_DeathRenderBind)
	end
end

function LocalPlayer:serverSetCanBeKnockedOffBike(state)
	setPedCanBeKnockedOffBike(self, state)
end

function LocalPlayer:checkAFK()
	if not self:isLoggedIn() then return end
	if DEBUG then return end

	if not self:getPublicSync("AFK") == true then
		if self:getPublicSync("gangwarParticipant") then return end
		local pos = self:getPosition()
		local distance = getDistanceBetweenPoints3D(pos, self.m_LastPositon) or 0
		self.m_LastPositon = pos

		if self:getInterior() == 4 and getDistanceBetweenPoints3D(pos, Vector3(449.03, -88.86, 999.55)) < 50 then
			self:toggleAFK(true, false)
			return
		end

		self.m_AFKCheckCount = self.m_AFKCheckCount + 1
		if distance > 15 then
			self.m_AFKCheckCount = 0
			triggerServerEvent("toggleAFK", localPlayer, false)
			removeEventHandler ( "onClientPedDamage", localPlayer, cancelEvent)
			return
		end
		local afkMinutes = self.m_AFKCheckCount*5/60
		if afkMinutes == 12 then
			if not localPlayer:getData("inJail") and not localPlayer:getData("inAdminPrison") then
				outputChatBox ( "WARNUNG: Du wirst in 3 Minuten zum AFK-Cafe befördert!", 255, 0, 0 )
				self:sendTrayNotification("WARNUNG: Du wirst in 5 Minuten zum AFK-Cafe befördert!", "warning", true)
				self:generateAFKCode()
				return
			end
		elseif afkMinutes == 14 then
			if not localPlayer:getData("inJail") and not localPlayer:getData("inAdminPrison") then
				outputChatBox ( "WARNUNG: Du wirst in einer Minute zum AFK-Cafe befördert!", 255, 0, 0 )
				self:sendTrayNotification("WARNUNG: Du wirst in einer Minute zum AFK-Cafe befördert!", "warning", true)
				return
			end
		elseif afkMinutes >= 15 then
			if not localPlayer:getData("inJail") and not localPlayer:getData("inAdminPrison") then
				self:toggleAFK(true, true)
				return
			end
		end

	else
		if self:getInterior() == 0 then
			self:toggleAFK(false)
		end
	end
end

function LocalPlayer:toggleAFK(state, teleport)
	if not self:isLoggedIn() then return end

	if state == true then
		self.m_AFKCode = false
		GUIForm.closeAll()
		InfoBox:new(_"Du wurdest ins AFK-Cafe teleportiert!")

		if localPlayer:getPublicSync("Faction:Duty") and localPlayer:getFaction() then
			if localPlayer:getFaction():isStateFaction() then
				triggerServerEvent("factionStateToggleDuty", localPlayer, true)
			elseif localPlayer:getFaction():isRescueFaction() then
				triggerServerEvent("factionRescueToggleDuty", localPlayer)
			end
		end

		if localPlayer:getPublicSync("Company:Duty") then
			triggerServerEvent("companyToggleDuty", localPlayer)
		end

		triggerServerEvent("toggleAFK", localPlayer, true, teleport)
		addEventHandler ( "onClientPedDamage", localPlayer, cancelEvent)
		self.m_AFKStartTime = getTickCount()
		NoDm:getSingleton():checkNoDm()
		setInteriorSoundsEnabled(false)

		triggerServerEvent("onOnlineSlotMachineForceOut", localPlayer)
	else
		InfoBox:new(_("Willkommen zurück, %s!", localPlayer:getName()))
		triggerServerEvent("toggleAFK", localPlayer, false)
		removeEventHandler ( "onClientPedDamage", localPlayer, cancelEvent)
		self:setAFKTime() -- Set CurrentAFKTime
		self.m_AFKStartTime = 0
		self:setAFKTime() -- Add CurrentAFKTime to AFKTime + Reset CurrentAFKTime
		NoDm:getSingleton():checkNoDm()
		setInteriorSoundsEnabled(true)
	end
end


function LocalPlayer:renderPedNameTags()
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("3D/PedNameTag") end

	local nameTag, mortemTag, x, y, z
	local px, py, pz, tx, ty, tz
	px, py, pz = getCameraMatrix( )

	for k, ped in pairs(getElementsByType("ped", root, true)) do
		if DEBUG then ExecTimeRecorder:getSingleton():addIteration("3D/PedNameTag") end
		nameTag = getElementData(ped, "Ped:fakeNameTag")
		mortemTag = getElementData(ped, "NPC:isDyingPed")
		if mortemTag then mortemTag = getElementData(ped,"NPC:namePed") or "Unbekannt" end

		if nameTag or mortemTag then
			x,y,z = getElementPosition(ped)
			local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
			if dist <= 20 then
				if isLineOfSightClear( Vector3(px, py, pz), Vector3(x, y, z), true, false, false, true, false, false, false,localPlayer ) then
					if x and y and z then
						x,y = getScreenFromWorldPosition(x,y,z+1)
						if x and y then
							if nameTag then
								if DEBUG then ExecTimeRecorder:getSingleton():addIteration("3D/PedNameTag", true) end
								dxDrawText(nameTag, x, y, nil, nil, tocolor(0, 0, 0, 255), 5/dist, "default-bold", "center", "center")
								dxDrawText(nameTag, x+1, y+1, nil, nil, tocolor(200, 200, 200, 255), 5/dist, "default-bold", "center", "center")
							elseif mortemTag then
								if DEBUG then ExecTimeRecorder:getSingleton():addIteration("3D/PedNameTag", true) end
								dxDrawText("* "..mortemTag.." kriecht blutend am Boden! *", x, y+1, x, y+1, tocolor(0, 0, 0, 255), 5/dist, "default-bold", "center", "center")
								dxDrawText("* "..mortemTag.." kriecht blutend am Boden! *", x, y, x, y, tocolor(200, 150, 0, 255), 5/dist, "default-bold", "center", "center")
							end
						end
					end
				end
			end
		end
	end
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("3D/PedNameTag") end
end

function LocalPlayer:calcFPS()
	if getTickCount() - self.FPS.startTick >= 1000 then
		if self.FPS.frames ~= self.FPS.counter then
			self.FPS.frames = self.FPS.counter
		end
		self.FPS.counter = 0
		self.FPS.startTick = getTickCount()
	else
		self.FPS.counter = self.FPS.counter + 1
	end
end

function LocalPlayer:Event_OnTryPickup( pickup )
	if pickup then
		self.m_MortemWeaponPickup = pickup
	end
end

function LocalPlayer:generateAFKCode()
	local char = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z","0","1","2","3","4","5","6","7","8","9"}
	local code = {}
	for z = 1,4 do
		a = math.random(1,#char)
		x = string.lower(char[a])
		table.insert(code, x)
	end
	local fcode = table.concat(code)
	self.m_AFKCode = fcode
	outputChatBox("Um nicht ins AFK-Cafe zu kommen, gib folgenden Befehl ein: /noafk "..fcode,255,0,0)
end

function LocalPlayer:onAFKCodeInput(cmd, code)
	if self.m_AFKCode then
		if self.m_AFKCode == code then
			outputChatBox("Vorgang abgebrochen.", 255, 0, 0)
			self.m_AFKCheckCount = 0
			self.m_AFKCode = false
		else
			ErrorBox:new(_"Der eingegeben Code ist falsch!")
		end
	else
		ErrorBox:new(_"Der Code ist nicht mehr gültig!")
	end
end

-- Events
function LocalPlayer:Event_retrieveInfo(info)
	self.m_Rank = info.Rank
	self.m_LoggedIn = true
	for i = 1,7 do
		setElementData(localPlayer,"W_A:w"..i-1, core:get("W_ATTACH", "weapon"..i-1, true))
		triggerEvent("Weapon_Attach:recheckWeapons", localPlayer, i-1)
	end
end

function LocalPlayer:Event_setAdmin(player, rank)
	if self:getRank() == rank then

		bindKey("lshift", "down",
			function()
				if self:getRank() >= RANK.Moderator and (DEBUG or self:getPublicSync("supportMode") == true) then
					local vehicle = getPedOccupiedVehicle(self)
					if vehicle and not isCursorShowing() and not vehicle.m_HasDI then
						local vx, vy, vz = getElementVelocity(vehicle)
						setElementVelocity(vehicle, vx, vy, 0.3)
					end
				end
			end
		)
		bindKey("lalt", "down",
			function()
				if self:getRank() >= RANK.Moderator and (DEBUG or self:getPublicSync("supportMode") == true) then
					local vehicle = getPedOccupiedVehicle(self)
					if vehicle and not isCursorShowing() then
						vehicle:setVelocity((vehicle.matrix.forward*1.2)*math.clamp(0.2, vehicle.velocity.length, 5))
					end
				end
			end
		)
		bindKey("lctrl", "down",
			function()
				if self:getRank() >= RANK.Moderator and (DEBUG or self:getPublicSync("supportMode") == true) then
					local vehicle = getPedOccupiedVehicle(self)
					if vehicle and not isCursorShowing() then
						vehicle:setVelocity((vehicle.matrix.forward*0.8)*math.clamp(0.2, vehicle.velocity.length, 5))
					end
				end
			end
		)

		self:setPublicSyncChangeHandler("supportMode", function(state)
			if not state then
				if self.m_AircarsEnabled then
					setWorldSpecialPropertyEnabled("aircars", false)
					self.m_AircarsEnabled = false
					ShortMessage:new(_("Fahrzeug-Flugmodus deaktiviert."))
				end
			end
		end)
		
		self:setPublicSyncChangeHandler("gangwarParticipant", function(state)
			if state then
				if ego.Active then
					delete(ego:getSingleton())
					ego.Active = false
				end
			end
		end)
		--[[bindKey("f5", "down",
			function()
				if self:getRank() >= RANK.Moderator then
					if MapGUI:isInstantiated() then
						delete(MapGUI:getSingleton())
					else
						MapGUI:getSingleton(
							function(posX, posY, posZ)
								localPlayer:setPosition(posX, posY, posZ)
								localPlayer:setInterior(0)
								localPlayer:setDimension(0)
							end
							)
					end
				end
			end
		)]]

		if rank >= ADMIN_RANK_PERMISSION["runString"] then
			addCommandHandler("dcrun", function(cmd, ...)
				if self:getRank() >= ADMIN_RANK_PERMISSION["runString"] then
					local codeString = table.concat({...}, " ")
					runString(codeString, localPlayer)
				end
			end)
		end
	else
		ErrorBox:new(_"Clientside Admin konnte nicht verifiziert werden!")
	end
end

function LocalPlayer:hasAdminRightTo(strPerm)
	return ADMIN_RANK_PERMISSION[strPerm] and self:getRank() >= ADMIN_RANK_PERMISSION[strPerm]
end

function LocalPlayer:Event_RunString(codeString, sendResponse)
	local result = runString(codeString, localPlayer, true)

	if sendResponse then
		triggerServerEvent("onClientRunStringResult", source, tostring(result))
	else
		if source == localPlayer then
			triggerServerEvent("onClientRunStringResult", source, tostring(result))
		end
	end

	outputDebug("Running server string: "..tostring(codeString))
end

function LocalPlayer:Event_PlaySound(path)
	if type(path) == "string" then
		playSound(path)
	end
end

function LocalPlayer:Event_PlaySFX(container, bankId, soundId, looped)
	playSFX(container, bankId, soundId, looped)
end

function LocalPlayer:Event_PlaySFX3D(container, bankId, soundId, x, y, z, looped)
	playSFX3D(container, bankId, soundId, x, y, z, looped)
end

function LocalPlayer:getAchievements ()
	return table.setIndexToInteger(fromJSON(self:getPrivateSync("Achievements"))) or {[0] = false}
end

function LocalPlayer:Event_toggleRadar(state)
	HUDRadar:getSingleton():setEnabled(state)
end

function LocalPlayer:sendTrayNotification(text, icon, sound)
	createTrayNotification("eXo-RL: "..text, icon, sound)
end

function LocalPlayer:getWorldObject()
	local lookAt = localPlayer.position + (Camera.matrix.forward)*3
	local result = {processLineOfSight(localPlayer.position, lookAt, true, false, false, true, false, false, false, true, localPlayer, true) }

	if result[1] then
		if result[5] then
			return result[5], {getElementPosition(result[5])}, {getElementRotation(result[5])} -- If we want to trigger to server, we can't use Vectors
		elseif result[12] then
			return result[12], {result[13], result[14], result[15]}, {result[16], result[17], result[18]}
		end
	end

	return false
end

function LocalPlayer:getWorldVehicle()
	local lookAt = localPlayer.position + (Camera.matrix.forward)*3
	local result = {processLineOfSight(localPlayer.position, lookAt, true, true, false, false, false, false, false, true, localPlayer, true) }

	if result[1] then
		if result[5] then
			return result[5], {getElementPosition(result[5])}, {getElementRotation(result[5])} -- If we want to trigger to server, we can't use Vectors
		end
	end

	return false
end

function LocalPlayer:Event_onClientPlayerSpawn()


	local col = createColSphere(localPlayer.position, 3)

	for _, player in pairs(getElementsByType("player")) do
		localPlayer:setCollidableWith(player, false)
	end

	addEventHandler("onClientColShapeLeave", col,
		function(element, matchingDimension)
			if element == localPlayer and matchingDimension then
				for _, player in pairs(getElementsByType("player")) do
					localPlayer:setCollidableWith(player, true)
				end

				col:destroy()
			end
		end
	)

	--[[setTimer(
		function()
			outputChatBox("Collision enabled")
			for _, player in pairs(getElementsByType("player")) do
				localPlayer:setCollidableWith(player, true)
			end
		end, 10000, 1
	)]]
	local weaponAttachCheck = core:get("W_ATTACH", "alt_w5holst", false)
	setElementData(localPlayer,"W_A:alt_w5", weaponAttachCheck)
	triggerEvent("Weapon_Attach:recheckWeapons", localPlayer,5)
	nextframe(function()
		NoDm:getSingleton():checkNoDm()
	end)
end

function LocalPlayer:startAnimation(_, ...)
	if localPlayer:getData("isTasered") then return end
	if localPlayer.vehicle then return end
	if localPlayer:isOnFire() then return end

	triggerServerEvent("startAnimation", localPlayer, table.concat({...}, " "))
end

function LocalPlayer:vehiclePickUp()
	if self.vehicle then return end

	if self:getPrivateSync("isAttachedToVehicle") then
		triggerServerEvent("attachPlayerToVehicle", self)
		return
	end

	if not self.contactElement or self.contactElement:getType() ~= "vehicle" then return end
	if self.contactElement:getVehicleType() == VehicleType.Boat or VEHICLE_PICKUP[self.contactElement:getModel()] then
		triggerServerEvent("attachPlayerToVehicle", self)
	end
end

addEvent("showModCheck", true)
addEventHandler("showModCheck",localPlayer, function(tbl)
	local w,h = guiGetScreenSize()
	local tx = dxGetFontHeight(3,"default-bold")
	local tx2 = dxGetFontHeight(2,"default")
	addEventHandler("onClientRender", root, function()
		dxDrawRectangle(0,0,w,h,tocolor(255,255,255,255))
		dxDrawImage(w*0.5-w*0.05,h*0.02,w*0.1,w*0.1,"files/images/warning.png")
		dxDrawText("Warnung! Folgende Modifikationen müssen entfernt werden, da sie in der Größe sehr stark abweichen!",0,h*0.3-tx*1.1,w,0,tocolor(150,0,0,255),3,"default-bold","center","top")
		dxDrawText("Originale GTA3.img ist im Forum verfügbar! https://goo.gl/L6i7dR",0,h*0.3,w,0,tocolor(0,0,0,255),2,"default-bold","center","top")
		dxDrawLine(0,h*0.3+tx,w,h*0.3+tx,tocolor(150,0,0,255))
		for i = 1,#tbl do
			dxDrawText(i.."# "..tbl[i],0,(h*0.3)+tx+i*(tx2*1.5),w,h,tocolor(0,0,0,255),2,"default","center","top")
		end
	end)
end)

function LocalPlayer:deactivateBlur(bool)
	if bool then
		setBlurLevel(0)
	else
		setBlurLevel(36)
	end
end

function LocalPlayer:Event_tryEnterExit(object, name, icon)
	if not self.m_LastEntrance or self.m_LastEntrance + 500 < getTickCount() then 
		if self.m_Entrance and self.m_Entrance:isInstantiated() then self.m_Entrance:delete() end
		self.m_Entrance = InteriorEnterExitGUI:new(object, name, icon)
		self.m_LastEntrance = getTickCount()
	end
end