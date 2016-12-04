-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/LocalPlayer.lua
-- *  PURPOSE:     Local player class
-- *
-- ****************************************************************************
LocalPlayer = inherit(Player)
addRemoteEvents{"retrieveInfo", "playerWasted", "playerRescueWasted", "playerCashChange", "setSupportDamage", "playerSendToHospital", "abortDeathGUI", "sendTrayNotification","setClientTime"}

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
	-- Since the local player exist only once, we can add the events here
	addEventHandler("retrieveInfo", root, bind(self.Event_retrieveInfo, self))
	addEventHandler("onClientPlayerWasted", root, bind(self.playerWasted, self))
	addEventHandler("playerWasted", root, bind(self.Event_playerWasted, self))
	addEventHandler("playerCashChange", self, bind(self.playCashChange, self))
	addEventHandler("setSupportDamage", self, bind( self.toggleDamage, self ))
	addEventHandler("abortDeathGUI", self, bind( self.abortDeathGUI, self ))
	addEventHandler("sendTrayNotification", self, bind( self.sendTrayNotification, self ))
	addEventHandler("setClientTime", self, bind(self.Event_onGetTime, self))
	addCommandHandler("noafk", bind(self.onAFKCodeInput, self))


	self.m_DeathRenderBind = bind(self.deathRender, self)

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

function LocalPlayer:Event_onGetTime( realtime )
	setTime(realtime.hour, realtime.minute)
	setMinuteDuration(60000)
end

function LocalPlayer:setAFKTime()
	if self.m_AFKStartTime > 0 then
		self.m_CurrentAFKTime = (getTickCount() - self.m_AFKStartTime)
	else
		self.m_AFKTime = self.m_AFKTime + self.m_CurrentAFKTime
		self.m_CurrentAFKTime = 0
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

function LocalPlayer:toggleDamage( bstate )
	if bstate then
		addEventHandler( "onClientPlayerDamage", localPlayer, cancelEvent)
	else
		removeEventHandler( "onClientPlayerDamage", localPlayer, cancelEvent)
	end
end

function LocalPlayer:playerWasted( killer, weapon, bodypart)
	if source == localPlayer then
		triggerServerEvent("Event_ClientNotifyWasted", localPlayer, killer, weapon, bodypart)
	end
end

function LocalPlayer:Event_playerWasted()
	local callback = function (sound)
		if isElement(sound) then
			sound:destroy()
		end

		local time = self:getPublicSync("DeathTime")-6000

		fadeCamera(false, 1)
		self.m_WastedTimer2 = setTimer( -- Todo: Remove later
			function ()
				fadeCamera(true,0.5)
				self.m_DeathGUI = DeathGUI:new(time)
				self.m_WastedTimer3 = setTimer(function()
					HUDRadar:getSingleton():show()
					HUDUI:getSingleton():show()
					showChat(true)
					-- Trigger it back to the Server (TODO: Maybe is this Event unsafe..?)
					triggerServerEvent("factionRescueWastedFinished", localPlayer)
				end, time, 1)

			end, 3000, 1
		)
	end

	-- Hide UI Elements
	HUDRadar:getSingleton():hide()
	HUDUI:getSingleton():hide()
	showChat(false)
	triggerServerEvent("Event_setPlayerWasted", localPlayer)
	-- Move camera into the Sky
	setCameraInterior(0)

	self.m_DeathPosition = self:getPosition()
	self.m_Add = 0
	self.m_Halleluja = Sound("files/audio/Halleluja.mp3")
	local soundLength = self.m_Halleluja:getLength()
	ShortMessage:new(_"Dir konnte leider niemand mehr helfen..! Du bist Tod.\n\nBut... have a good flight into the Heaven!", (soundLength-1)*1000)
	addEventHandler("onClientPreRender", root, self.m_DeathRenderBind)
	self.m_WastedTimer4 = setTimer(function()
		self.m_FadeOutShader = FadeOutShader:new()
		self.m_WastedTimer1 = setTimer(callback, 4000, 1, self.m_Halleluja, start)
		removeEventHandler("onClientPreRender", root, self.m_DeathRenderBind)
	end, soundLength*1000, 1)
end

function LocalPlayer:deathRender(deltaTime)
	local pos = self.m_DeathPosition
	self.m_Add = self.m_Add+0.005*deltaTime
	setCameraMatrix(pos.x, pos.y, pos.z + self.m_Add, pos)
end

function LocalPlayer:abortDeathGUI()
	if self.m_FadeOutShader then delete(self.m_FadeOutShader) end
	if self.m_WastedTimer1 and isTimer(self.m_WastedTimer1) then killTimer(self.m_WastedTimer1) end
	if self.m_WastedTimer2 and isTimer(self.m_WastedTimer2) then killTimer(self.m_WastedTimer2) end
	if self.m_WastedTimer3 and isTimer(self.m_WastedTimer3) then killTimer(self.m_WastedTimer3) end
	if self.m_WastedTimer4 and isTimer(self.m_WastedTimer4) then killTimer(self.m_WastedTimer4) end
	if isElement(self.m_Halleluja) then destroyElement(self.m_Halleluja) end
	HUDRadar:getSingleton():show()
	HUDUI:getSingleton():show()
	showChat(true)
	if self.m_DeathGUI then delete(self.m_DeathGUI) end
	removeEventHandler("onClientPreRender", root, self.m_DeathRenderBind)
end

function LocalPlayer:checkAFK()
	if not self:isLoggedIn() then return end

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
		if afkMinutes == 7 then
			outputChatBox ( "WARNUNG: Du wirst in 3 Minuten zum AFK-Cafe befördert!", 255, 0, 0 )
			self:sendTrayNotification("WARNUNG: Du wirst in 5 Minuten zum AFK-Cafe befördert!", "warning", true)
			self:generateAFKCode()
			return
		elseif afkMinutes == 9 then
			outputChatBox ( "WARNUNG: Du wirst in einer Minute zum AFK-Cafe befördert!", 255, 0, 0 )
			self:sendTrayNotification("WARNUNG: Du wirst in einer Minute zum AFK-Cafe befördert!", "warning", true)
			return
		elseif afkMinutes == 10 then
			self:toggleAFK(true, true)
			return
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
		triggerServerEvent("toggleAFK", localPlayer, true, teleport)
		addEventHandler ( "onClientPedDamage", localPlayer, cancelEvent)
		self.m_AFKStartTime = getTickCount()
	else
		InfoBox:new(_("Willkommen zurück, %s!", localPlayer:getName()))
		triggerServerEvent("toggleAFK", localPlayer, false)
		removeEventHandler ( "onClientPedDamage", localPlayer, cancelEvent)
		self:setAFKTime() -- Set CurrentAFKTime
		self.m_AFKStartTime = 0
		self:setAFKTime() -- Add CurrentAFKTime to AFKTime + Reset CurrentAFKTime
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
end

function LocalPlayer:sendTrayNotification(text, icon, sound)
	createTrayNotification("eXo-RL: "..text, icon, sound)
end
