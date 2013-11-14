-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/Phone/AppSettings.lua
-- *  PURPOSE:     Phone settings app class
-- *
-- ****************************************************************************
AppSettings = inherit(PhoneApp)

function AppSettings:constructor()
	PhoneApp.constructor(self, "Settings", "files/images/Phone/Apps/IconSettings.png")
end

function AppSettings:onOpen(form)
	self.m_Label = GUILabel:new(10, 10, 200, 20, "Settings", 3, form)
	self.m_Label:setColor(Color.Black)
	
	GUILabel:new(10, 60, 200, 20, "Ringtones", 1.5, form):setColor(Color.Black)
	self.m_RingtoneChanger = GUIChanger:new(10, 85, 200, 30, form)
	self.m_RingtoneChanger.onChange = function(text)
		if self.m_Sound and isElement(self.m_Sound) then
			destroyElement(self.m_Sound)
		end
		self.m_Sound = playSound("files/audio/Ringtones/"..text:gsub(" ", "")..".mp3")
	end
	for i=1, 4 do
		self.m_RingtoneChanger:addItem("Ringtone "..i)
	end
end

function AppSettings:onClose()
	if self.m_Sound and isElement(self.m_Sound) then
		destroyElement(self.m_Sound)
	end
end
