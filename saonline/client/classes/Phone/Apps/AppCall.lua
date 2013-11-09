-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/Phone/AppCall.lua
-- *  PURPOSE:     Phone call app class
-- *
-- ****************************************************************************
AppCall = inherit(PhoneApp)

function AppCall:constructor()
	PhoneApp.constructor(self, "Phone", "files/images/Phone/Apps/IconCall.png")
	
	-- Add event handlers
	addEvent("callIncoming", true)
	addEvent("callBusy", true)
	addEvent("callAnswer", true)
	addEventHandler("callIncoming", root, bind(self.Event_callIncoming, self))
	addEventHandler("callBusy", root, bind(self.Event_callBusy, self))
	addEventHandler("callAnswer", root, bind(self.Event_callAnswer, self))
end

function AppCall:onOpen(form)
	-- Create main activity
	MainActivity:new(self)
end

function AppCall:onClose()
	for k, activity in ipairs(self.m_Activities) do
		if instanceof(activity, IncomingCallActivity, true) then
			if activity:getCaller() then
				activity:busy()
			end
		end
	end
end

-- Events
function PhoneApp:Event_callIncoming(caller, isVoiceCall)
	if not caller then return end
	
	Phone:getSingleton():openApp(self)
	IncomingCallActivity:new(self, caller)
end

function PhoneApp:Event_callBusy(callee)
	-- Create busy activity
	Phone:getSingleton():openApp(self)
	CallResultActivity:new(self, callee, false)
end

function PhoneApp:Event_callAnswer(callee, voiceCall)
	-- Create answer activity
	Phone:getSingleton():openApp(self)
	CallResultActivity:new(self, callee, true, voiceCall)
end


-- Activities
MainActivity = inherit(AppActivity)

function MainActivity:constructor(app)
	AppActivity.constructor(self, app)
	
	self.m_Label = GUILabel:new(8, 10, 200, 20, "Call", 3, self)
	self.m_Label:setColor(Color.Black)
	self.m_Edit = GUIEdit:new(8, 70, 206, 25, self)
	self.m_Edit:setCaption("Player name")
	self.m_ButtonCall = GUIButton:new(8, 100, 206, 40, "Call", self)
	self.m_ButtonCall.onLeftClick = bind(self.ButtonCall_Click, self)
	self.m_CheckVoice = GUICheckbox:new(8, 150, 206, 20, "Voice call", self)
end

function MainActivity:ButtonCall_Click()
	local player = getPlayerFromName(self.m_Edit:getText())
	if not player then
		outputChatBox("This player is not online", 255, 0, 0)
		return
	end

	triggerServerEvent("callStart", root, player, self.m_CheckVoice:isChecked())
end


IncomingCallActivity = inherit(AppActivity)

function IncomingCallActivity:constructor(app, caller)
	AppActivity.constructor(self, app)
	self.m_Caller = caller

	self.m_CallLabel = GUILabel:new(8, 10, 200, 20, "Incoming call from "..getPlayerName(caller), 3, self)
	self.m_CallLabel:setColor(Color.Black)
	self.m_ButtonAnswer = GUIButton:new(8, 200, 100, 40, "Answer", self)
	self.m_ButtonAnswer:setBackgroundColor(Color.Green)
	self.m_ButtonAnswer.onLeftClick = bind(self.ButtonAnswer_Click, self)
	self.m_ButtonBusy = GUIButton:new(113, 200, 100, 40, "Busy", self)
	self.m_ButtonBusy:setBackgroundColor(Color.Red)
	self.m_ButtonBusy.onLeftClick = bind(self.ButtonBusy_Click, self)
	
	-- Play ring sound
	self.m_RingSound = playSound("files/audio/Ringtone.mp3", true)
end

function IncomingCallActivity:ButtonAnswer_Click()
	if self.m_RingSound and isElement(self.m_RingSound) then
		destroyElement(self.m_RingSound)
	end
	if isElement(self.m_Caller) then -- He might have quit meanwhile
		triggerServerEvent("callAnswer", root, self.m_Caller)
	end
end

function IncomingCallActivity:ButtonBusy_Click()
	self:busy()
	Phone:getSingleton():close()
end

function IncomingCallActivity:busy()
	self.m_Caller = nil
	if self.m_RingSound and isElement(self.m_RingSound) then
		destroyElement(self.m_RingSound)
	end
	if isElement(self.m_Caller) then -- He might have quit meanwhile
		triggerServerEvent("callBusy", root, self.m_Caller)
	end
end

function IncomingCallActivity:getCaller()
	return self.m_Caller
end


CallResultActivity = inherit(AppActivity)

function CallResultActivity:constructor(app, callee, answer, voiceCall)
	AppActivity.constructor(self, app)
	
	self.m_ResultLabel = GUILabel:new(8, 10, 200, 20, "", 3, self)
	if answer then
		self.m_ResultLabel:setText("Answered")
		self.m_ResultLabel:setColor(Color.Green)
		if voiceCall then
			GUILabel:new(8, 80, 200, 20, "", 1, "Press z to speak", self)
		end
	else
		self.m_ResultLabel:setText("Busy")
		self.m_ResultLabel:setColor(Color.Red)
		setTimer(
			function()
				if self:isOpen() then
					MainActivity:new(app)
				end 
			end, 2000, 1
		)
	end
end
