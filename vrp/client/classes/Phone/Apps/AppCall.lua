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
local CALL_RESULT_CALLING = 3

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
	triggerServerEvent("requestPhoneNumbers", localPlayer)
end

function AppCall:onClose()
	for k, activity in ipairs(self.m_Activities) do
		if instanceof(activity, IncomingCallActivity, true) then
			if activity:getCaller() then
				activity:busy()
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
	CallResultActivity:new(self, callee, CALL_RESULT_BUSY)
end

function PhoneApp:Event_callAnswer(callee, voiceCall)
	-- Create answer activity
	Phone:getSingleton():openApp(self)
	CallResultActivity:new(self, callee, CALL_RESULT_ANSWER, voiceCall)
end

function PhoneApp:Event_callReplace(responsiblePlayer)
	CallResultActivity:new(self, callee, CALL_RESULT_REPLACE)
end


-- Activities
MainActivity = inherit(AppActivity)

function MainActivity:constructor(app)
	AppActivity.constructor(self, app)
	self.m_TabPanel = GUIPhoneTabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_Tabs = {}
	self.m_Tabs["Keyboard"] = self.m_TabPanel:addTab(_"Anrufen", FontAwesomeSymbols.Phone)
	self.m_Label = GUILabel:new(10, 10, 200, 50, _"Telefon", self.m_Tabs["Keyboard"]) -- 3
	self.m_Edit = GUIEdit:new(10, 60, 200, 40, self.m_Tabs["Keyboard"])
	self.m_Edit:setCaption(_"Telefonnummer")
	self.m_ButtonDelete = GUIButton:new(215, 60, 40, 40, FontAwesomeSymbols.Back, self.m_Tabs["Keyboard"])
		:setFont(FontAwesome(20))
		:setBackgroundColor(Color.Red)
	self.m_ButtonDelete.onLeftClick = function() self.m_Edit:setText(self.m_Edit:getText():sub(1, #self.m_Edit:getText() - 1)) end

	self.m_ButtonCall = GUIButton:new(140, 370, 100, 30, _"Anrufen", self.m_Tabs["Keyboard"]):setBackgroundColor(Color.Green)
	self.m_ButtonCall.onLeftClick = bind(self.ButtonCall_Click, self)
	self.m_CheckVoice = GUICheckbox:new(10, 375, 120, 20, _"Sprachanruf", self.m_Tabs["Keyboard"]):setFontSize(1.2)
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

	self.m_Tabs["Players"] = self.m_TabPanel:addTab(_"Spieler", FontAwesomeSymbols.Book)
	self.m_PlayerListGrid = GUIGridList:new(10, 10, self.m_Width-20, self.m_Height-110, self.m_Tabs["Players"])
	self.m_PlayerListGrid:addColumn(_"Spieler", 0.5)
	self.m_PlayerListGrid:addColumn(_"Nummer", 0.4)
	self.m_TabPanel:addTab(_"Test1", FontAwesomeSymbols.Book)
	self.m_TabPanel:addTab(_"Test2", FontAwesomeSymbols.Book)
	self.m_ButtonCallPlayers = GUIButton:new(140, 370, 100, 30, _"Anrufen", self.m_Tabs["Players"]):setBackgroundColor(Color.Green)
	self.m_ButtonCallPlayers.onLeftClick = bind(self.ButtonCall_Click, self)
	self.m_CheckVoicePlayers = GUICheckbox:new(10, 375, 120, 20, _"Sprachanruf", self.m_Tabs["Players"]):setFontSize(1.2)
	addRemoteEvents{"receivePhoneNumbers"}
	addEventHandler("receivePhoneNumbers", root, bind(self.Event_receivePhoneNumbers, self))

end

function MainActivity:addNumpadButton(text, column, row)
	self.m_NumpadButton[text] = GUIButton:new(60*column-20, 120+60*row, 55, 55, tostring(text), self.m_Tabs["Keyboard"])
	self.m_NumpadButton[text].onLeftClick = function()
		self.m_Edit:setText(self.m_Edit:getText()..text)
	end
end

function MainActivity:ButtonCall_Click()
	local player = getPlayerFromName(self.m_Edit:getText())
	if not player then
		ErrorBox:new(_"Dieser Spieler ist nicht online!")
		return
	end
	if player == localPlayer then
		ErrorBox:new(_"Du kannst dich nicht selbst anrufen!")
		return
	end

	CallResultActivity:new(self:getApp(), player, CALL_RESULT_CALLING, self.m_CheckVoice:isChecked())
	triggerServerEvent("callStart", root, player, self.m_CheckVoice:isChecked())
end

function MainActivity:Event_receivePhoneNumbers(list)
	self.m_PlayerListGrid:clear()
	for index, number in pairs(list) do
		if number["type"] == "player" then
			self.m_PlayerListGrid:addItem(number["ownerName"], tostring(index))
		end
	end
end

IncomingCallActivity = inherit(AppActivity)

function IncomingCallActivity:constructor(app, caller, voiceEnabled)
	AppActivity.constructor(self, app)
	self.m_Caller = caller
	self.m_VoiceEnabled = voiceEnabled

	self.m_CallLabel = GUILabel:new(8, 10, 200, 20, _("Eingehender Anruf von %s", caller:getName()), self)
	self.m_CallLabel:setColor(Color.Black)
	self.m_ButtonAnswer = GUIButton:new(8, 200, 100, 40, "Answer", self)
	self.m_ButtonAnswer:setBackgroundColor(Color.Green)
	self.m_ButtonAnswer.onLeftClick = bind(self.ButtonAnswer_Click, self)
	self.m_ButtonBusy = GUIButton:new(113, 200, 100, 40, "Busy", self)
	self.m_ButtonBusy:setBackgroundColor(Color.Red)
	self.m_ButtonBusy.onLeftClick = bind(self.ButtonBusy_Click, self)

	-- Play ring sound
	self.m_RingSound = playSound(core:getConfig():get("Phone", "Ringtone", "files/audio/Ringtones/Ringtone1.mp3"), true)
end

function IncomingCallActivity:ButtonAnswer_Click()
	if self.m_RingSound and isElement(self.m_RingSound) then
		destroyElement(self.m_RingSound)
	end
	if isElement(self.m_Caller) then -- He might have quit meanwhile
		triggerServerEvent("callAnswer", root, self.m_Caller, self.m_VoiceEnabled)

		-- Show active call activity
		CallResultActivity:new(self:getApp(), self.m_Caller, CALL_RESULT_ANSWER, self.m_VoiceEnabled)
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
end

function IncomingCallActivity:getCaller()
	return self.m_Caller
end


CallResultActivity = inherit(AppActivity)

function CallResultActivity:constructor(app, callee, resultType, voiceCall)
	AppActivity.constructor(self, app)
	self.m_Callee = callee

	self.m_ResultLabel = GUILabel:new(8, 10, 200, 40, "", self)
	if resultType == CALL_RESULT_ANSWER then
		self.m_ResultLabel:setText(_"Angenommen")
		self.m_ResultLabel:setColor(Color.Green)
		if voiceCall then
			GUILabel:new(8, 80, 200, 25, _"Drücke z für Voicechat", self):setColor(Color.Black)
		end
		self.m_ButtonReplace = GUIButton:new(8, 222, 205, 40, _"Auflegen", self)
		self.m_ButtonReplace:setBackgroundColor(Color.Red)
		self.m_ButtonReplace.onLeftClick = bind(self.ButtonReplace_Click, self)
	elseif resultType == CALL_RESULT_BUSY then
		self.m_ResultLabel:setText("Busy")
		self.m_ResultLabel:setColor(Color.Red)
		setTimer(
			function()
				if self:isOpen() then
					MainActivity:new(app)
				end
			end, 3000, 1
		)
	elseif resultType == CALL_RESULT_REPLACE then
		self.m_ResultLabel:setText(_"Aufgelegt")
		self.m_ResultLabel:setColor(Color.Red)
		setTimer(
			function()
				if self:isOpen() then
					MainActivity:new(app)
				end
			end, 3000, 1
		)
	elseif resultType == CALL_RESULT_CALLING then
		self.m_ResultLabel:setText(_"Anrufen...")
		self.m_ResultLabel:setColor(Color.Black)
	end
end

function CallResultActivity:ButtonReplace_Click()
	if self.m_Callee and isElement(self.m_Callee) then
		triggerServerEvent("callReplace", root, self.m_Callee)
	end
	MainActivity:new(self:getApp())
end
