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
end

function AppCall:onOpen(form)
	self.m_Label = GUILabel:new(8, 10, 200, 20, "Call", 3, form)
	self.m_Label:setColor(Color.Black)
	self.m_Edit = GUIEdit:new(8, 70, 206, 25, form)
	self.m_Edit:setCaption("Player name")
	self.m_ButtonCall = GUIButton:new(8, 100, 206, 40, "Call", form)
	self.m_ButtonCall.onLeftClick = bind(self.ButtonCall_Click, self)
	self.m_CheckVoice = GUICheckbox:new(8, 150, 206, 20, "Voice call", form)
end

function AppCall:onClose()
	
end

function AppCall:ButtonCall_Click()
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

function AppCall:incomingCall(caller)
	-- Todo: Optimize this; Use something like Android's activities
	self.m_Label:setVisible(false)
	self.m_Edit:setVisible(false)
	self.m_ButtonCall:setVisible(false)
	self.m_CheckVoice:setVisible(false)
	
	-- Create call elements
	self.m_CallLabel = GUILabel:new(8, 10, 200, 20, "Incoming call from "..getPlayerName(caller), 3, self:getForm())
	self.m_ButtonAnswer = GUIButton:new(8, 200, 100, 40, "Answer", self:getForm())
	self.m_ButtonAnswer.m_BackgroundColor = Color.Green
	self.m_ButtonBusy = GUIButton:new(113, 200, 100, 40, "Busy", self:getForm())
	self.m_ButtonBusy.m_BackgroundColor = Color.Red
	
	-- Play ring sound
	playSound("files/audio/Ringtone.mp3", true)
end
