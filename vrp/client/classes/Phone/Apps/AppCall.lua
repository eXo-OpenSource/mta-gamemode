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

	-- Add event handlers
	addRemoteEvents{"callIncoming", "callReplace", "callAnswer", "callBusy"}

	addEventHandler("callIncoming", root, bind(self.Event_callIncoming, self))
	addEventHandler("callBusy", root, bind(self.Event_callBusy, self))
	addEventHandler("callAnswer", root, bind(self.Event_callAnswer, self))
	addEventHandler("callReplace", root, bind(self.Event_callReplace, self))
end

function AppCall:onOpen(form)
	-- Create main activity
	MainActivity:new(self)
end

function AppCall:onClose()
	for k, activity in pairs(self.m_Activities) do
		if instanceof(activity, IncomingCallActivity, true) then
			if activity:getCaller() then
				activity:busy()
			end
		elseif instanceof(activity, CallResultActivity, true) then
			if activity.m_InCall == true then
				activity:ButtonReplace_Click()
			end
		end
	end
	-- Todo: Tell the callee that we closed the app
end

-- Events
function PhoneApp:Event_callIncoming(caller, voiceEnabled)
	if not caller then return end

	Phone:getSingleton():openApp(self)
	IncomingCallActivity:new(self, caller, voiceEnabled)
end

function PhoneApp:Event_callBusy(callee)
	-- Create busy activity
	Phone:getSingleton():openApp(self)
	for k, activity in ipairs(self.m_Activities) do
		if instanceof(activity, IncomingCallActivity, true) then
			activity:busy()
		end
	end
	--CallResultActivity:new(self, "player", callee, CALL_RESULT_BUSY)
end

function PhoneApp:Event_callAnswer(callee, voiceCall)
	-- Create answer activity
	Phone:getSingleton():openApp(self)
	CallResultActivity:new(self, "player", callee, CALL_RESULT_ANSWER, voiceCall)
end

function PhoneApp:Event_callReplace(responsiblePlayer)
	for k, activity in ipairs(self.m_Activities) do
		if instanceof(activity, IncomingCallActivity, true) then
			activity:busy()
		end
	end
	CallResultActivity:new(self, "player", callee, CALL_RESULT_REPLACE)
end


-- Activities
MainActivity = inherit(AppActivity)

function MainActivity:constructor(app)
	AppActivity.constructor(self, app)
	self.m_TabPanel = GUIPhoneTabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_Tabs = {}
	self.m_Tabs["Keyboard"] = self.m_TabPanel:addTab(_"Ziffernblock", FontAwesomeSymbols.Phone)
	self.m_Label = GUILabel:new(10, 10, 200, 50, _"Telefon", self.m_Tabs["Keyboard"]) -- 3
	self.m_Edit = GUIEdit:new(10, 60, 200, 40, self.m_Tabs["Keyboard"])
	self.m_Edit:setCaption(_"Telefonnummer")
	self.m_ButtonDelete = GUIButton:new(215, 60, 40, 40, "⌫", self.m_Tabs["Keyboard"]):setBackgroundColor(Color.Red)
	self.m_ButtonDelete.onLeftClick = function() self.m_Edit:setText(self.m_Edit:getText():sub(1, #self.m_Edit:getText() - 1)) end

	self.m_ButtonCallNumpad = GUIButton:new(self.m_Width-110, 370, 100, 30, _"Anrufen", self.m_Tabs["Keyboard"]):setBackgroundColor(Color.Green)
	self.m_ButtonCallNumpad.onLeftClick = bind(self.ButtonCallNumpad_Click, self)
	--self.m_CheckVoiceNumpad = GUICheckbox:new(10, 375, 120, 20, _"Sprachanruf", self.m_Tabs["Keyboard"]):setFontSize(1.2)
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

	self.m_ButtonAddToContacts = GUIButton:new(10, 370, 30, 30, "+", self.m_Tabs["Players"]):setBackgroundColor(Color.LightBlue)
	self.m_ButtonAddToContacts.onLeftClick = bind(self.ButtonAddContact_Click, self)

	self.m_ButtonCallPlayers = GUIButton:new(self.m_Width-110, 370, 100, 30, _"Anrufen", self.m_Tabs["Players"]):setBackgroundColor(Color.Green)
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
	self.m_ButtonCallService = GUIButton:new(self.m_Width-110, 370, 100, 30, _"Anrufen", self.m_Tabs["Service"]):setBackgroundColor(Color.Green)
	self.m_ButtonCallService.onLeftClick = bind(self.ButtonCallService_Click, self)

	self.m_Tabs["Group"] = self.m_TabPanel:addTab(_"Firmen/Gangs", FontAwesomeSymbols.Group)
	self.m_GroupListGrid = GUIGridList:new(10, 10, self.m_Width-20, self.m_Height-110, self.m_Tabs["Group"])
	self.m_GroupListGrid:addColumn(_"Firma/Gang", 0.7)
	self.m_GroupListGrid:addColumn(_"Num.", 0.3)
	self.m_ButtonCallGroup = GUIButton:new(self.m_Width-110, 370, 100, 30, _"Anrufen", self.m_Tabs["Group"]):setBackgroundColor(Color.Green)
	self.m_ButtonCallGroup.onLeftClick = bind(self.ButtonCallGroup_Click, self)

	triggerServerEvent("requestPhoneNumbers", localPlayer)

	addRemoteEvents{"receivePhoneNumbers"}
	addEventHandler("receivePhoneNumbers", root, bind(self.Event_receivePhoneNumbers, self))

	app.m_InCall = false

end

function MainActivity:addNumpadButton(text, column, row)
	self.m_NumpadButton[text] = GUIButton:new(60*column-20, 120+60*row, 55, 55, tostring(text), self.m_Tabs["Keyboard"])
	self.m_NumpadButton[text].onLeftClick = function()
		self.m_Edit:setText(self.m_Edit:getText()..text)
	end
end

function MainActivity:ButtonCallNumpad_Click()
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
			CallResultActivity:new(self:getApp(), "player", player, CALL_RESULT_CALLING, self.m_CheckVoiceNumpad:isChecked())
			triggerServerEvent("callStart", root, player, self.m_CheckVoiceNumpad:isChecked())
		else
			ErrorBox:new(_"Der Spieler ist nicht online!")
		end
	else
		CallResultActivity:new(self:getApp(), self.m_PhoneNumbers[number]["OwnerType"], self.m_PhoneNumbers[number]["OwnerName"], CALL_RESULT_CALLING, false)
		triggerServerEvent("callStartSpecial", root, number)
	end
end

function MainActivity:ButtonCallService_Click()
	local number = tonumber(self.m_ServiceListGrid:getSelectedItem().Number)
	CallResultActivity:new(self:getApp(), self.m_PhoneNumbers[number]["OwnerType"], self.m_PhoneNumbers[number]["OwnerName"], CALL_RESULT_CALLING, false)
	triggerServerEvent("callStartSpecial", root, number)
end

function MainActivity:ButtonCallGroup_Click()
	local number = tonumber(self.m_GroupListGrid:getSelectedItem().Number)
	CallResultActivity:new(self:getApp(), self.m_PhoneNumbers[number]["OwnerType"], self.m_PhoneNumbers[number]["OwnerName"], CALL_RESULT_CALLING, false)
	triggerServerEvent("callStartSpecial", root, number)
end

function MainActivity:ButtonCallPlayer_Click()
	local player = getPlayerFromName(self.m_PlayerListGrid:getSelectedItem().Owner)
	if not player then
		ErrorBox:new(_"Dieser Spieler ist nicht online!")
		return
	end
	if player == localPlayer then
		ErrorBox:new(_"Du kannst dich nicht selbst anrufen!")
		return
	end

	--CallResultActivity:new(self:getApp(), "player", player, CALL_RESULT_CALLING, self.m_CheckVoicePlayers:isChecked())
	CallResultActivity:new(self:getApp(), "player", player, CALL_RESULT_CALLING, false)

	--triggerServerEvent("callStart", root, player, self.m_CheckVoicePlayers:isChecked())
	triggerServerEvent("callStart", root, player, false)

end

function MainActivity:ButtonAddContact_Click()
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

function MainActivity:searchPlayer()
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

function MainActivity:Event_receivePhoneNumbers(list)
	self.m_PhoneNumbers = list
	local grid = {["player"] = self.m_PlayerListGrid, ["group"] = self.m_GroupListGrid, ["faction"] = self.m_ServiceListGrid, ["company"] = self.m_ServiceListGrid }

	for index, key in pairs(grid) do key:clear() end
	for number, numData in pairs(list) do
		local item = grid[numData["OwnerType"]]:addItem(numData["OwnerName"], tostring(number))
		item.Owner = numData["OwnerName"]
		item.Number = number
	end
end

IncomingCallActivity = inherit(AppActivity)

function IncomingCallActivity:constructor(app, caller, voiceEnabled)
	AppActivity.constructor(self, app)
	self.m_Caller = caller
	self.m_VoiceEnabled = voiceEnabled

	self.m_CallLabel = GUILabel:new(8, 10, self.m_Width, 30, _("Eingehender Anruf von \n%s", caller:getName()), self):setMultiline(true):setAlignX("center")
	self.m_CallLabel:setColor(Color.Black)
	GUIWebView:new(self.m_Width/2-70, 70, 140, 200, "http://exo-reallife.de/ingame/skinPreview/skinPreview.php?skin="..caller:getModel(), true, self)
	self.m_ButtonAnswer = GUIButton:new(10, self.m_Height-50, 110, 30, _"Annehmen", self)
	self.m_ButtonAnswer:setBackgroundColor(Color.Green)
	self.m_ButtonAnswer.onLeftClick = bind(self.ButtonAnswer_Click, self)
	self.m_ButtonBusy = GUIButton:new(self.m_Width-120, self.m_Height-50, 110, 30, _"Ablehnen", self)
	self.m_ButtonBusy:setBackgroundColor(Color.Red)
	self.m_ButtonBusy.onLeftClick = bind(self.ButtonBusy_Click, self)

	-- Play ring sound
	self.m_RingSound = playSound(core:getConfig():get("Phone", "Ringtone", "files/audio/Ringtones/Klingelton1.mp3"), true)
	showCursor(false)
end

function IncomingCallActivity:ButtonAnswer_Click()
	if self.m_RingSound and isElement(self.m_RingSound) then
		destroyElement(self.m_RingSound)
	end
	if isElement(self.m_Caller) then -- He might have quit meanwhile
		triggerServerEvent("callAnswer", root, self.m_Caller, self.m_VoiceEnabled)

		-- Show active call activity
		CallResultActivity:new(self:getApp(), "player",self.m_Caller, CALL_RESULT_ANSWER, self.m_VoiceEnabled)
	end
end

function IncomingCallActivity:ButtonBusy_Click()
	self:busy()
	Phone:getSingleton():close()
end

function IncomingCallActivity:busy()
	if self.m_RingSound and isElement(self.m_RingSound) then
		destroyElement(self.m_RingSound)
	end
	if isElement(self.m_Caller) then -- He might have quit meanwhile
		triggerServerEvent("callBusy", root, self.m_Caller)
	end
	self.m_Caller = nil
	MainActivity:new(self:getApp())
end

function IncomingCallActivity:getCaller()
	return self.m_Caller
end

CallResultActivity = inherit(AppActivity)

function CallResultActivity:constructor(app, calleeType, callee, resultType, voiceCall)
	AppActivity.constructor(self, app)

	app.m_InCall = true

	self.m_Callee = callee
	self.m_CalleeType = calleeType

	self.m_ResultLabel = GUILabel:new(0, 10, self.m_Width, 40, "", self):setAlignX("center")
	if resultType == CALL_RESULT_ANSWER then
		self.m_Caller = callee
		self.m_ResultLabel:setText(_"Verbunden mit")
		self.m_ResultLabel:setColor(Color.Green)
		GUILabel:new(0, 50, self.m_Width, 30, callee:getName(), self):setColor(Color.Black):setAlignX("center")
		if voiceCall then
			GUILabel:new(8, self.m_Height-110, self.m_Width, 20, _"Drücke z für Voicechat", self):setColor(Color.Black):setAlignX("center")
		end
		GUIWebView:new(self.m_Width/2-70, 80, 140, 200, "http://exo-reallife.de/ingame/skinPreview/skinPreview.php?skin="..callee:getModel(), true, self)
		self.m_ButtonSendLocation = GUIButton:new(10, self.m_Height-100, self.m_Width-20, 40, _"Position senden", self)
		self.m_ButtonSendLocation:setBackgroundColor(Color.Green)
		self.m_ButtonSendLocation.onLeftClick = function()
			if self.m_LastClick and getTickCount() - self.m_LastClick < 10000 then
				ErrorBox:new(_"Bitte warte ein paar Sekunden bevor du deine Position aktualisierst")
				return
			end

			self.m_LastClick = getTickCount()
			triggerServerEvent("callSendLocation", root, self.m_Callee)
		end
		self.m_ButtonReplace = GUIButton:new(10, self.m_Height-50, self.m_Width-20, 40, _"Auflegen", self)
		self.m_ButtonReplace:setBackgroundColor(Color.Red)
		self.m_ButtonReplace.onLeftClick = bind(self.ButtonReplace_Click, self)
	elseif resultType == CALL_RESULT_BUSY then
		self.m_ResultLabel:setText("Abgelehnt...")
		self.m_ResultLabel:setColor(Color.Red)
		setTimer(
			function()
				if self:isOpen() and Phone:getSingleton():isOpen() then
					MainActivity:new(app)
					app.m_InCall = false
				end
			end, 3000, 1
		)
	elseif resultType == CALL_RESULT_REPLACE then
		self.m_ResultLabel:setText(_"Aufgelegt")
		self.m_ResultLabel:setColor(Color.Red)
		setTimer(
			function()
				if self:isOpen() and Phone:getSingleton():isOpen() then
					MainActivity:new(app)
					app.m_InCall = false
				end
			end, 3000, 1
		)
	elseif resultType == CALL_RESULT_CALLING then
		self.m_ResultLabel:setText(_"Anrufen...")
		self.m_ResultLabel:setColor(Color.Black)
		if calleeType == "player" then
			GUILabel:new(0, 50, self.m_Width, 30, callee:getName(), self):setColor(Color.Black):setAlignX("center")
		else
			GUILabel:new(0, 50, self.m_Width, 30, callee, self):setColor(Color.Black):setAlignX("center")
		end
		self.m_ButtonReplace = GUIButton:new(10, self.m_Height-50, self.m_Width-20, 40, _"Auflegen", self)
		self.m_ButtonReplace:setBackgroundColor(Color.Red)
		self.m_ButtonReplace.onLeftClick = bind(self.ButtonReplace_Click, self)
	end
end

function CallResultActivity:ButtonReplace_Click()
	if self.m_CalleeType == "player" then
		if self.m_Callee and isElement(self.m_Callee) then
			triggerServerEvent("callReplace", root, self.m_Callee)
		end
	else
		triggerServerEvent("callAbbortSpecial", localPlayer)
	end
end
