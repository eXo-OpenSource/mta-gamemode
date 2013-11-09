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
	addEvent("voiceCallIncoming", true)
	addEventHandler("voiceCallIncoming", root, bind(self.Event_voiceCallIncoming, self))
end

function AppCall:onOpen(form)
	-- Create main activity
	MainActivity:new(self, form)
end

function AppCall:onClose()
	
end

-- Events
function PhoneApp:Event_voiceCallIncoming(caller)
	if not caller then return end
	
	Phone:getSingleton():openApp(self)
	IncomingCallActivity:new(self, self:getForm(), caller)
end

-- Activities
MainActivity = inherit(AppActivity)

function MainActivity:constructor(app, form)
	AppActivity.constructor(self, app, form)
	
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

	if self.m_CheckVoice:isChecked() then
		triggerServerEvent("voiceCallStart", root, player)
	else
		triggerServerEvent("chatCallStart", root, player)
	end
end


IncomingCallActivity = inherit(AppActivity)

function IncomingCallActivity:constructor(app, form, caller)
	AppActivity.constructor(self, app, form)

	self.m_CallLabel = GUILabel:new(8, 10, 200, 20, "Incoming call from "..getPlayerName(caller), 3, self)
	self.m_CallLabel:setColor(Color.Black)
	self.m_ButtonAnswer = GUIButton:new(8, 200, 100, 40, "Answer", self)
	self.m_ButtonAnswer.m_BackgroundColor = Color.Green
	self.m_ButtonBusy = GUIButton:new(113, 200, 100, 40, "Busy", self)
	self.m_ButtonBusy.m_BackgroundColor = Color.Red
	
	-- Play ring sound
	self.m_RingSound = playSound("files/audio/Ringtone.mp3", true)
end
