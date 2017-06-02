-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/LocalPlayer.lua
-- *  PURPOSE:     Local player class
-- *
-- ****************************************************************************
LocalPlayer = inherit(Player)
addRemoteEvents{"retrieveInfo", "playerWasted", "playerRescueWasted", "playerCashChange", "disableDamage",
"playerSendToHospital", "abortDeathGUI", "sendTrayNotification","setClientTime", "setClientAdmin", "toggleRadar", "onTryPickupWeapon", "onServerRunString"}

local screenWidth,screenHeight = guiGetScreenSize()
function LocalPlayer:constructor()
	self.m_Locale = "de"
	self.m_Job = false
	self.m_Rank = 0
	self.m_LoggedIn = false
	self.m_JoinTime = getTickCount()

	self.m_AFKTimer = setTimer ( bind(self.checkAFK, self), 5000, 0)
	self.m_AFKCheckCount = 0
	self.m_CurrentAFKTime = 0
	self.m_AFKTime = 0
	self.m_AFKStartTime = 0

	self.m_LastPositon = self:getPosition()
	self.m_PlayTime = setTimer(bind(self.setPlayTime, self), 60000, 0)
	self.m_FadeOut = bind(self.fadeOutScope, self)
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
	addEventHandler("onClientRender",root,bind(self.renderPostMortemInfo, self))
	addEventHandler("onClientRender",root,bind(self.renderPedNameTags, self))
	addEventHandler("onClientRender",root,bind(self.checkWeaponAim, self))
	addEventHandler("onTryPickupWeapon", root, bind(self.Event_OnTryPickup, self))
	addEventHandler("onServerRunString", root, bind(self.Event_RunString, self))
	setTimer(bind(self.Event_PreRender, self),100,0)
	addCommandHandler("noafk", bind(self.onAFKCodeInput, self))
	addCommandHandler("anim", bind(self.startAnimation, self))

	self.m_DeathRenderBind = bind(self.deathRender, self)

	--Alcoholsystem
	self.m_AlcoholDecreaseBind = bind(self.alcoholDecrease, self)
	self:setPrivateSyncChangeHandler("AlcoholLevel", bind(self.onAlcoholLevelChange, self))

	self.m_RenderAlcoholBind = bind(self.Event_RenderAlcohol,self)
	self.m_CancelEvent = function()	cancelEvent() end
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

function LocalPlayer:checkWeaponAim()

end

function LocalPlayer:fadeOutScope()
	if localPlayer.m_IsFading then
		fadeCamera(true,1)
		localPlayer.m_IsFading = false
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
			setControlState("walk",true)
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
				triggerServerEvent("factionRescueToggleDuty", localPlayer)
			end
		end

		if localPlayer:getPublicSync("Company:Duty") then
			triggerServerEvent("companyToggleDuty", localPlayer)
		end
		triggerServerEvent("Event_ClientNotifyWasted", localPlayer, killer, weapon, bodypart)
	end
end

function LocalPlayer:Event_playerWasted()
	-- Hide UI Elements
	HUDRadar:getSingleton():hide()
	HUDUI:getSingleton():hide()
	showChat(false)
	self.m_Death = true
	triggerServerEvent("Event_setPlayerWasted", self)
	local funcA = function()
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
	local SMClick = function()
		if self.m_Death then
			funcA()
		else
			ErrorBox:new(_"Du bist nicht mehr tot!")
			return
		end
	end
	setGameSpeed(0.1)
	self.m_DeathAudio = playSound("files/audio/death_ahead.mp3")
	setSoundVolume(self.m_DeathAudio,1)
	local x,y,z = getPedBonePosition(localPlayer,5)
	setSkyGradient(10,10,10,30,30,30)
	setTimer(Camera.setMatrix,5000,1, x, y, z+3, x, y, z)
	setTimer(setGameSpeed,5000,1,1)
	setTimer(resetSkyGradient,30000,1)
	if localPlayer:getInterior() > 0 then
		funcA()
		return
	end

	local deathTime = MEDIC_TIME
	local start = getTickCount()

	if localPlayer:isPremium() then
		self.m_DeathMessage = ShortMessage:new(_("Du bist schwer verletzt und verblutest in %s Sekunden...\n(Drücke hier um dich umzubringen)", deathTime/1000), nil, nil, deathTime, SMClick)
	else
		self.m_DeathMessage = ShortMessage:new(_("Du bist schwer verletzt und verblutest in %s Sekunden...", deathTime/1000), nil, nil, deathTime)
	end

	self.m_CanBeRevived = true
	self.m_WastedTimer = setTimer(
		function()
			local timeGone = getTickCount() - start
			if timeGone >= deathTime-500 then
				funcA()
			else
				if localPlayer:isPremium() then
					self.m_DeathMessage.m_Text = _("Du bist schwer verletzt und verblutest in %s Sekunden...\n(Drücke hier um dich umzubringen)", math.floor((deathTime - timeGone)/1000))
				else
					self.m_DeathMessage.m_Text = _("Du bist schwer verletzt und verblutest in %s Sekunden...", math.floor((deathTime - timeGone)/1000))
				end
				self.m_DeathMessage:anyChange()
			end
		end, 1000, deathTime/1000
	)
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
		if isElement(self.m_DeathAudio) then destroyElement(self.m_DeathAudio) end
		HUDRadar:getSingleton():show()
		HUDUI:getSingleton():show()
		showChat(true)
		removeEventHandler("onClientPreRender", root, self.m_DeathRenderBind)
	end
end

function LocalPlayer:checkAFK()
	if not self:isLoggedIn() then return end
	if DEBUG then return end

	if not self:getPublicSync("AFK") == true then
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
	else
		InfoBox:new(_("Willkommen zurück, %s!", localPlayer:getName()))
		triggerServerEvent("toggleAFK", localPlayer, false)
		removeEventHandler ( "onClientPedDamage", localPlayer, cancelEvent)
		self:setAFKTime() -- Set CurrentAFKTime
		self.m_AFKStartTime = 0
		self:setAFKTime() -- Add CurrentAFKTime to AFKTime + Reset CurrentAFKTime
		NoDm:getSingleton():checkNoDm()

	end
end

function LocalPlayer:renderPostMortemInfo()
	local peds = getElementsByType("ped", root, true)
	local isMortem,x,y,z, name
	local px, py, pz, tx, ty, tz, dist
	px, py, pz = getCameraMatrix( )
	for k, ped in ipairs( peds) do
		isMortem = getElementData(ped, "NPC:isDyingPed")
		if isMortem then
			x,y,z = getPedBonePosition(ped, 8)
			dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz) <= 20
			if dist then
				if isLineOfSightClear( px, py, pz, x, y, z, true, false, false, true, false, false, false,localPlayer ) then
					if x and y and z then
						x,y = getScreenFromWorldPosition(x,y,z)
						name = getElementData(ped,"NPC:namePed") or "Unbekannt"
						if x and y then
							dxDrawText("* "..name.." kriecht blutend am Boden! *", x,y+1,x,y+1,tocolor(0,0,0,255),1,"default-bold")
							dxDrawText("* "..name.." kriecht blutend am Boden! *", x,y,x,y,tocolor(200,150,0,255),1,"default-bold")
						end
					end
				end
			end
		end
	end
	if self.m_MortemWeaponPickup then
		if getKeyState("lalt") and getKeyState("m") then
			triggerServerEvent("onAttemptToPickupDeathWeapon",localPlayer, self.m_MortemWeaponPickup)
			self.m_MortemWeaponPickup = false
		end
	end
end


function LocalPlayer:renderPedNameTags()
	local peds = getElementsByType("ped", root, true)
	local nameTag,x,y,z, textWidth
	local px, py, pz, tx, ty, tz, dist
	px, py, pz = getCameraMatrix( )
	for k, ped in ipairs( peds) do
		nameTag = getElementData(ped, "Ped:fakeNameTag")
		if nameTag then
			textWidth = dxGetTextWidth(nameTag, 1,"default-bold")
			x,y,z = getPedBonePosition(ped, 3)
			dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz) <= 20
			if dist then
				if isLineOfSightClear( px, py, pz, x, y, z, true, false, false, true, false, false, false,localPlayer ) then
					if x and y and z then
						x,y = getScreenFromWorldPosition(x,y,z+1)
						if x and y then
							dxDrawText(nameTag, x-textWidth/2,y+1,x+textWidth/2,y+1,tocolor(0,0,0,255),1,"default-bold")
							dxDrawText(nameTag, x-textWidth/2,y,x+textWidth/2,y,tocolor(200,200,200,255),1,"default-bold")
						end
					end
				end
			end
		end
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
				if self:getRank() >= RANK.Moderator and self:getPublicSync("supportMode") == true then
					local vehicle = getPedOccupiedVehicle(self)
					if vehicle then
						local vx, vy, vz = getElementVelocity(vehicle)
						setElementVelocity(vehicle, vx, vy, 0.3)
					end
				end
			end
		)
		bindKey("lalt", "down",
			function()
				if self:getRank() >= RANK.Moderator and self:getPublicSync("supportMode") == true then
					local vehicle = getPedOccupiedVehicle(self)
					if vehicle then
						local vx, vy, vz = getElementVelocity(vehicle)
						setElementVelocity(vehicle, vx*1.5, vy*1.5, vz)
					end
				end
			end
		)
		bindKey("f5", "down",
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
		)

		if rank >= RANK.Developer then
			addCommandHandler("dcrun", function(cmd, ...)
				if self:getRank() >= RANK.Servermanager then
					local codeString = table.concat({...}, " ")
					runString(codeString, localPlayer)
				end
			end)
		end
	else
		ErrorBox:new(_"Clientside Admin konnte nicht verifiziert werden!")
	end
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

function LocalPlayer:Event_onClientPlayerSpawn()
	NoDm:getSingleton():checkNoDm()

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
end

function LocalPlayer:startAnimation(_, ...)
	triggerServerEvent("startAnimation", localPlayer, table.concat({...}, " "))
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
