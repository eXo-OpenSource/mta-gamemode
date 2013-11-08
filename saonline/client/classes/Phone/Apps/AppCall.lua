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
		localPlayer:rpc("voiceCallStart", player)
	else
		localPlayer:rpc("chatCallStart", player)
	end
end
