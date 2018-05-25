-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppCall.lua
-- *  PURPOSE:     Phone call app class
-- *
-- ****************************************************************************
AppCall = inherit(PhoneApp)

local CALL_RESULT_BUSY = 0
local CALL_RESULT_REPLACE = 1
local CALL_RESULT_ANSWER = 2
CALL_RESULT_CALLING = 3 -- used in AppContacts

function AppCall:constructor()
	PhoneApp.constructor(self, "Telefon", "IconCall.png")
	self.m_EasterEggFont = dxCreateFont(EASTEREGG_FILE_PATH.."/BitBold.ttf", 22*EASTEREGG_FONT_SCALE)
	self.m_EasterEggRenderFunction = function() 
		dxDrawText("SUPER SMASH STROBE", 0,2, screenWidth, screenHeight, tocolor(0, 0, 0, 255), 1, self.m_EasterEggFont, "center", "center") 
		dxDrawText("SUPER SMASH STROBE", 0,0, screenWidth, screenHeight, tocolor(201, 29, 0, 255), 1, self.m_EasterEggFont, "center", "center")
	end

	self.m_IncomingCallSMs = {}

	addRemoteEvents{"callIncoming", "callReplace", "callAnswer", "callBusy", "callIncomingSM", "callRemoveSM"}

	addEventHandler("callIncoming", root, bind(self.Event_callIncoming, self))
	addEventHandler("callIncomingSM", root, bind(self.Event_callIncomingSM, self))
	addEventHandler("callRemoveSM", root, bind(self.Event_callRemoveSM, self))
	addEventHandler("callBusy", root, bind(self.Event_callBusy, self))
	addEventHandler("callAnswer", root, bind(self.Event_callAnswer, self))
	addEventHandler("callReplace", root, bind(self.Event_callReplace, self))
end

function AppCall:onOpen(form)
	self.m_Form = form
	self.m_Width = self.m_Form.m_Width
	self.m_Height = self.m_Form.m_Height

	self:openMain()
end

function AppCall:closeAll()
	if self.m_Background then delete(self.m_Background) end
	if self.m_WebView then delete(self.m_WebView) end
	self.m_Background = GUIRectangle:new(0, 0, self.m_Width, self.m_Height, Color.Clear, self.m_Form)
end

function AppCall:openMain()
	self:closeAll()

	local parent, width, height = self.m_Background, self.m_Background.m_Width, self.m_Background.m_Height
	self.m_TabPanel = GUIPhoneTabPanel:new(0, 0, width, height, parent)
	self.m_Tabs = {}
	self.m_Tabs["Keyboard"] = self.m_TabPanel:addTab(_"Ziffernblock", FontAwesomeSymbols.Phone)
	self.m_Label = GUILabel:new(10, 10, 200, 50, _"Telefon", self.m_Tabs["Keyboard"]) -- 3
	self.m_Edit = GUIEdit:new(10, 60, 200, 40, self.m_Tabs["Keyboard"])
	self.m_Edit:setCaption(_"Telefonnummer")
	self.m_ButtonDelete = GUIButton:new(215, 60, 40, 40, "⌫", self.m_Tabs["Keyboard"]):setBackgroundColor(Color.Red):setBarEnabled(false)
	self.m_ButtonDelete.onLeftClick = function() self.m_Edit:setText(self.m_Edit:getText():sub(1, #self.m_Edit:getText() - 1)) end

	self.m_ButtonCallNumpad = GUIButton:new(self.m_Width-110, 370, 100, 30, _"Anrufen", self.m_Tabs["Keyboard"]):setBackgroundColor(Color.Green):setBarEnabled(false)
	self.m_ButtonCallNumpad.onLeftClick = bind(self.ButtonCallNumpad_Click, self)

	self.m_NumpadButton = {}
	self:addNumpadButton("1", 1, 0)
	self:addNumpadButton("2", 2, 0)
	self:addNumpadButton("3", 3, 0)
	self:addNumpadButton("4", 1, 1)
	self:addNumpadButton("5", 2, 1)
	self:addNumpadButton("6", 3, 1)
	self:addNumpadButton("7", 1, 2)
	self:addNumpadButton("8", 2, 2)
	self:addNumpadButton("9", 3, 2)
	self:addNumpadButton("0", 2, 3)
	self:addNumpadButton("*", 1, 3)
	self:addNumpadButton("#", 3, 3)

	self.m_Tabs["Players"] = self.m_TabPanel:addTab(_"Spieler", FontAwesomeSymbols.Player)
	self.m_PlayerListGrid = GUIGridList:new(10, 10, self.m_Width-20, self.m_Height-145, self.m_Tabs["Players"])
	self.m_PlayerListGrid:addColumn(_"Spieler", 0.7)
	self.m_PlayerListGrid:addColumn(_"Num.", 0.3)
	GUILabel:new(10, 330, 50, 25, "Suche:", self.m_Tabs["Players"])
	self.m_PlayerSearch = GUIEdit:new(65, 330, 185, 25, self.m_Tabs["Players"])
	self.m_PlayerSearch.onChange = function () self:searchPlayer() end

	self.m_ButtonAddToContacts = GUIButton:new(10, 370, 30, 30, "+", self.m_Tabs["Players"]):setBackgroundColor(Color.LightBlue):setBarEnabled(false)
	self.m_ButtonAddToContacts.onLeftClick = bind(self.ButtonAddContact_Click, self)

	self.m_ButtonCallPlayers = GUIButton:new(self.m_Width-110, 370, 100, 30, _"Anrufen", self.m_Tabs["Players"]):setBackgroundColor(Color.Green):setBarEnabled(false)
	self.m_ButtonCallPlayers.onLeftClick = bind(self.ButtonCallPlayer_Click, self)
	--self.m_CheckVoicePlayers = GUICheckbox:new(10, 375, 120, 20, _"Sprachanruf", self.m_Tabs["Players"]):setFontSize(1.2)

	self.m_TabPanel.onTabChanged = function(tabId)
		if tabId == self.m_Tabs["Players"].TabIndex then
			triggerServerEvent("requestPhoneNumbers", localPlayer)
		end
	end

	self.m_Tabs["Service"] = self.m_TabPanel:addTab(_"Service", FontAwesomeSymbols.Book)
	self.m_ServiceListGrid = GUIGridList:new(10, 10, self.m_Width-20, self.m_Height-110, self.m_Tabs["Service"])
	self.m_ServiceListGrid:addColumn(_"Frak/Untern.", 0.7)
	self.m_ServiceListGrid:addColumn(_"Num.", 0.3)
	self.m_ButtonCallService = GUIButton:new(self.m_Width-110, 370, 100, 30, _"Anrufen", self.m_Tabs["Service"]):setBackgroundColor(Color.Green):setBarEnabled(false)
	self.m_ButtonCallService.onLeftClick = function() self:startSpecialCall(self.m_ServiceListGrid) end

	self.m_Tabs["Group"] = self.m_TabPanel:addTab(_"Firmen/Gangs", FontAwesomeSymbols.Group)
	self.m_GroupListGrid = GUIGridList:new(10, 10, self.m_Width-20, self.m_Height-110, self.m_Tabs["Group"])
	self.m_GroupListGrid:addColumn(_"Firma/Gang", 0.7)
	self.m_GroupListGrid:addColumn(_"Num.", 0.3)
	self.m_ButtonCallGroup = GUIButton:new(self.m_Width-110, 370, 100, 30, _"Anrufen", self.m_Tabs["Group"]):setBackgroundColor(Color.Green):setBarEnabled(false)
	self.m_ButtonCallGroup.onLeftClick = function() self:startSpecialCall(self.m_GroupListGrid) end

	triggerServerEvent("requestPhoneNumbers", localPlayer)

	addRemoteEvents{"receivePhoneNumbers"}
	addEventHandler("receivePhoneNumbers", root, bind(self.Event_receivePhoneNumbers, self))

	self.m_InCall = false
end

function AppCall:addNumpadButton(text, column, row)
	self.m_NumpadButton[text] = GUIButton:new(60*column-20, 120+60*row, 55, 55, tostring(text), self.m_Tabs["Keyboard"]):setBarEnabled(false)
	self.m_NumpadButton[text].onLeftClick = function()
		self.m_Edit:setText(self.m_Edit:getText()..text)
	end
end

function AppCall:ButtonCallNumpad_Click()
	if self.m_Edit:getText() then
		if self.m_Edit:getText():lower() ==  ("hotlinestrobe"):lower() then
			if isTimer(self.m_ArcadeGameTimer) then killTimer(self.m_ArcadeGameTimer) end
			removeEventHandler("onClientRender", root, self.m_EasterEggRenderFunction )
			addEventHandler("onClientRender", root, self.m_EasterEggRenderFunction )
			self.m_ArcadeGameTimer = setTimer(function()
				EasterEggArcade.Game:getSingleton():restart()
				removeEventHandler("onClientRender", root, self.m_EasterEggRenderFunction )
			end, 3000, 1)
			Phone:getSingleton():close()
			playSound(EASTEREGG_SFX_PATH.."gameboy_start.ogg", false)
			return
		end
	end
	
	local number = tonumber(self.m_Edit:getText())
	if not number or string.len(number) < 3 then
		ErrorBox:new(_"Ungültige Telefonnummer eingegeben!")
		return
	end

	if not self.m_PhoneNumbers[number] then
		ErrorBox:new(_"Diese Telefonnummer ist nicht vergeben!")
		return
	end

	if self.m_PhoneNumbers[number]["OwnerType"] == "player" then
		if getPlayerFromName(self.m_PhoneNumbers[number]["OwnerName"]) then
			local player = getPlayerFromName(self.m_PhoneNumbers[number]["OwnerName"])
			self:openInCall("player", player, CALL_RESULT_CALLING, self.m_CheckVoiceNumpad:isChecked())
			triggerServerEvent("callStart", root, player, self.m_CheckVoiceNumpad:isChecked())
		else
			ErrorBox:new(_"Der Spieler ist nicht online!")
		end
	else
		self:openInCall(self.m_PhoneNumbers[number]["OwnerType"], self.m_PhoneNumbers[number]["OwnerName"], CALL_RESULT_CALLING, false)
		triggerServerEvent("callStartSpecial", root, number)
	end
end

function AppCall:startSpecialCall(grid)
	local number = tonumber(grid:getSelectedItem().Number)
	self:openInCall(self.m_PhoneNumbers[number]["OwnerType"], self.m_PhoneNumbers[number]["OwnerName"], CALL_RESULT_CALLING, false)
	triggerServerEvent("callStartSpecial", root, number)
end

function AppCall:ButtonCallPlayer_Click()
	local player = getPlayerFromName(self.m_PlayerListGrid:getSelectedItem().Owner)
	if not player then
		ErrorBox:new(_"Dieser Spieler ist nicht online!")
		return
	end
	if player == localPlayer then
		ErrorBox:new(_"Du kannst dich nicht selbst anrufen!")
		return
	end

	self:openInCall("player", player, CALL_RESULT_CALLING, false)

	triggerServerEvent("callStart", root, player, false)
end

function AppCall:ButtonAddContact_Click()
	local item = self.m_PlayerListGrid:getSelectedItem()
	local playerContacts = fromJSON(core:get("ContactList", "Players", "[ [ ] ]"))

	for _, contact in pairs(playerContacts) do
		if contact[1] == item.Owner then
			ErrorBox:new("Kontakt ist bereits in der Kontaktliste!")
			return
		end
	end

	if item.Owner and item.Number then
		table.insert(playerContacts, {tostring(item.Owner), item.Number})
		core:set("ContactList", "Players", toJSON(playerContacts))
	end
end

function AppCall:searchPlayer()
	self.m_PlayerListGrid:clear()

	for number, numData in pairs(self.m_PhoneNumbers) do
		if numData["OwnerType"] == "player" then
			if #self.m_PlayerSearch:getText() < 3 or string.find(string.lower(numData["OwnerName"]), string.lower(self.m_PlayerSearch:getText())) then
				local item = self.m_PlayerListGrid:addItem(numData["OwnerName"], tostring(number))
				item.Owner = numData["OwnerName"]
				item.Number = number
			end
		end
	end
end

function AppCall:Event_receivePhoneNumbers(list)
	self.m_PhoneNumbers = list
	local grid = {["player"] = self.m_PlayerListGrid, ["group"] = self.m_GroupListGrid, ["faction"] = self.m_ServiceListGrid, ["company"] = self.m_ServiceListGrid }

	for index, key in pairs(grid) do key:clear() end
	for number, numData in pairs(list) do
		local item = grid[numData["OwnerType"]]:addItem(numData["OwnerName"], tostring(number))
		item.Owner = numData["OwnerName"]
		item.Number = number
	end
end

function AppCall:openIncoming(caller, voiceEnabled)
	self:closeAll()
	local parent, width, height = self.m_Background, self.m_Background.m_Width, self.m_Background.m_Height

	self.m_Caller = caller
	self.m_VoiceEnabled = voiceEnabled

	self.m_CallLabel = GUILabel:new(8, 10, width, 30, _("Eingehender Anruf von \n%s", caller:getName()), parent):setMultiline(true):setAlignX("center")
	self.m_CallLabel:setColor(Color.Black)
	self.m_WebView = GUIWebView:new(width/2-70, 70, 140, 200, INGAME_WEB_PATH .. "/ingame/skinPreview/skinPreview.php?skin="..caller:getModel(), true, parent)
	self.m_ButtonAnswer = GUIButton:new(10, height-50, 110, 30, _"Annehmen", parent)
	self.m_ButtonAnswer:setBackgroundColor(Color.Green)
	self.m_ButtonAnswer.onLeftClick = bind(self.ButtonAnswer_Click, self)
	self.m_ButtonBusy = GUIButton:new(width-120, height-50, 110, 30, _"Ablehnen", parent)
	self.m_ButtonBusy:setBackgroundColor(Color.Red)
	self.m_ButtonBusy.onLeftClick = bind(self.ButtonBusy_Click, self)

	-- Play ring sound
	self:playRingSound(true)
	showCursor(false)
end

function AppCall:showIncomingCallShortMessage(caller, voiceEnabled, message, title, tblColor)
	self:playRingSound(true,true)
	local shortMessage = ShortMessage:new(message.._"\nKlicke hier, um abzuheben.", title, tocolor(unpack(tblColor)), -1)
	shortMessage.m_Callback = function()
		if not Phone:getSingleton():isOn() then
			ErrorBox:new(_"Dein Handy ist ausgeschaltet!")
			return "forceOpen"
		end
		if shortMessage.m_CallData then
			self.m_Caller = shortMessage.m_CallData.caller
			self.m_VoiceEnabled = shortMessage.m_CallData.voiceEnabled
			triggerServerEvent("callAnswerSpecial", localPlayer, shortMessage.m_CallData.caller, shortMessage.m_CallData.voiceEnabled)
			--self:removeIncomingCallShortMessage(shortMessage.m_CallData.caller, localPlayer)
			--Phone:getSingleton():openApp(self)
			--self:ButtonAnswer_Click()
			return "forceOpen"
		end
	end
	shortMessage.m_CallData = {
		caller = caller,
		voiceEnabled = voiceEnabled
	}
	self.m_IncomingCallSMs[caller] = shortMessage
end

function AppCall:removeIncomingCallShortMessage(caller, callee)
	if self.m_IncomingCallSMs[caller] then
		if callee and callee.getName then
			if caller.getName then
				self.m_IncomingCallSMs[caller]:setText(_("%s hat den Anruf von %s entgegengenommen.", callee:getName(), caller:getName()))
			else
				self.m_IncomingCallSMs[caller]:setText(_("%s hat den Anruf entgegengenommen.", callee:getName()))
			end
		else
			if caller.getName then
				self.m_IncomingCallSMs[caller]:setText(_("%s hat den Anruf abgebrochen.", caller:getName()))
			else
				self.m_IncomingCallSMs[caller]:setText(_"Der Anruf wurde abgebrochen.")
			end
		end
		self.m_IncomingCallSMs[caller]:setTimeout(3000)
		self.m_IncomingCallSMs[caller].m_TimeoutFunc = function()
			self.m_IncomingCallSMs[caller] = nil
		end
		self:playRingSound(false)
	end
end

function AppCall:playRingSound(state, singleRing)
	if state and not self.m_RingSound then
		local ringsound = core:getConfig():get("Phone", "Ringtone", "files/audio/Ringtones/Klingelton1.mp3")
		if ringsound == CUSTOM_RINGSOUND_PATH and not fileExists(CUSTOM_RINGSOUND_PATH) then
			ringsound = "files/audio/Ringtones/Klingelton1.mp3"
			core:getConfig():set("Phone", "Ringtone", ringsound)
		end
		self.m_RingSound = playSound(ringsound, not singleRing)
	elseif not state and self.m_RingSound then
		if isElement(self.m_RingSound) then destroyElement(self.m_RingSound) end
		self.m_RingSound = false
	end
end

function AppCall:ButtonAnswer_Click()
	self:playRingSound(false)
	if isElement(self.m_Caller) then -- He might have quit meanwhile
		triggerServerEvent("callAnswer", root, self.m_Caller, self.m_VoiceEnabled)
		self:openInCall("player",self.m_Caller, CALL_RESULT_ANSWER, self.m_VoiceEnabled)
	end
end

function AppCall:ButtonBusy_Click()
	self:busy()
	Phone:getSingleton():close()
end

function AppCall:busy()
	self:playRingSound(false)
	if isElement(self.m_Caller) then -- He might have quit meanwhile
		triggerServerEvent("callBusy", root, self.m_Caller)
	end
	self.m_Caller = nil
	self:openMain()
end

function AppCall:getCaller()
	return self.m_Caller
end

function AppCall:openInCall(calleeType, callee, resultType, voiceCall)
	self:closeAll()
	local parent, width, height = self.m_Background, self.m_Background.m_Width, self.m_Background.m_Height

	self.m_InCall = true

	self.m_Callee = callee
	self.m_CalleeType = calleeType

	self.m_ResultLabel = GUILabel:new(0, 10, self.m_Width, 40, "", parent):setAlignX("center")
	if resultType == CALL_RESULT_ANSWER then
		self.m_Caller = callee
		self.m_ResultLabel:setText(_"Verbunden mit")
		self.m_ResultLabel:setColor(Color.Green)
		GUILabel:new(0, 50, self.m_Width, 30, callee:getName(), parent):setColor(Color.Black):setAlignX("center")
		if voiceCall then
			GUILabel:new(8, self.m_Height-110, self.m_Width, 20, _"Drücke z für Voicechat", parent):setColor(Color.Black):setAlignX("center")
		end
		GUIWebView:new(self.m_Width/2-70, 80, 140, 200, INGAME_WEB_PATH .. "/ingame/skinPreview/skinPreview.php?skin="..callee:getModel(), true, parent)
		self.m_ButtonSendLocation = GUIButton:new(10, self.m_Height-100, self.m_Width-20, 40, _"Position senden", parent)
		self.m_ButtonSendLocation:setBackgroundColor(Color.Green)
		self.m_ButtonSendLocation.onLeftClick = function()
			if self.m_LastClick and getTickCount() - self.m_LastClick < 10000 then
				ErrorBox:new(_"Bitte warte ein paar Sekunden bevor du deine Position aktualisierst")
				return
			end

			self.m_LastClick = getTickCount()
			triggerServerEvent("callSendLocation", root, self.m_Callee)
		end
		self.m_ButtonReplace = GUIButton:new(10, self.m_Height-50, self.m_Width-20, 40, _"Auflegen", parent)
		self.m_ButtonReplace:setBackgroundColor(Color.Red)
		self.m_ButtonReplace.onLeftClick = bind(self.ButtonReplace_Click, self)
	elseif resultType == CALL_RESULT_BUSY then
		self.m_ResultLabel:setText("Abgelehnt...")
		self.m_ResultLabel:setColor(Color.Red)
		setTimer(
			function()
				if self:isOpen() and Phone:getSingleton():isOpen() then
					self:openMain()
				end

				self.m_InCall = false
				self.m_Caller = false
			end, 3000, 1
		)
	elseif resultType == CALL_RESULT_REPLACE then
		self.m_ResultLabel:setText(_"Aufgelegt")
		self.m_ResultLabel:setColor(Color.Red)
		self:playRingSound(false)
		setTimer(
			function()
				if self:isOpen() and Phone:getSingleton():isOpen() then
					self:openMain()
				end

				self.m_InCall = false
				self.m_Caller = false
			end, 3000, 1
		)
	elseif resultType == CALL_RESULT_CALLING then
		self.m_ResultLabel:setText(_"Anrufen...")
		self.m_ResultLabel:setColor(Color.Black)
		if calleeType == "player" then
			GUILabel:new(0, 50, self.m_Width, 30, callee:getName(), parent):setColor(Color.Black):setAlignX("center")
		else
			GUILabel:new(0, 50, self.m_Width, 30, callee, parent):setColor(Color.Black):setAlignX("center")
		end
		self.m_ButtonReplace = GUIButton:new(10, self.m_Height-50, self.m_Width-20, 40, _"Auflegen", parent)
		self.m_ButtonReplace:setBackgroundColor(Color.Red)
		self.m_ButtonReplace.onLeftClick = bind(self.ButtonReplace_Click, self)
	end
end

function AppCall:ButtonReplace_Click()
	if self.m_CalleeType == "player" then
		if self.m_Callee and isElement(self.m_Callee) then
			triggerServerEvent("callReplace", root, self.m_Callee)
		end
	else
		triggerServerEvent("callAbbortSpecial", localPlayer)
	end

	self.m_Caller = nil
end

function AppCall:onClose()
	if self.m_InCall then
		self:ButtonReplace_Click()
	end
end

function AppCall:Event_callIncoming(caller, voiceEnabled)
	if not caller then return end

	Phone:getSingleton():closeAllApps()
	Phone:getSingleton():openApp(self)
	self:openIncoming(caller, voiceEnabled)
end


function AppCall:Event_callIncomingSM(caller, voiceEnabled, message, title, tblColor)
	outputDebug(caller, voiceEnabled, message, title, tblColor)
	if not caller then return end
	
	self:showIncomingCallShortMessage(caller, voiceEnabled, message, title, tblColor)
end

function AppCall:Event_callRemoveSM(caller, callee)
	self:removeIncomingCallShortMessage(caller, callee)
end

function AppCall:Event_callBusy(callee)
	Phone:getSingleton():openApp(self)
	if self.m_InCall then
		self:busy()
	end
end

function AppCall:Event_callAnswer(callee, voiceCall)
	Phone:getSingleton():openApp(self)
	self:openInCall("player", callee, CALL_RESULT_ANSWER, voiceCall)
end

function AppCall:Event_callReplace(responsiblePlayer)
	Phone:getSingleton():openApp(self)
	if self.m_InCall then
		self:busy()
	end
	self:openInCall("player", callee, CALL_RESULT_REPLACE)
end

function AppCall:startCall(type, target)
	if Phone:getSingleton():isOn()then
		Phone:getSingleton():onShow()
		Phone:getSingleton():closeAllApps()

		if not self:isOpen() then
			Phone:getSingleton():openApp(self)
		end

		self:openInCall(type, target, CALL_RESULT_CALLING, false)
		triggerServerEvent("callStart", root, target, false)
	else
		WarningBox:new("Dein Handy ist ausgeschaltet!")
	end
end
