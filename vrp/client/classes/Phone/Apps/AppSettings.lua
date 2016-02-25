-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppSettings.lua
-- *  PURPOSE:     Phone settings app class
-- *
-- ****************************************************************************
AppSettings = inherit(PhoneApp)

function AppSettings:constructor()
	PhoneApp.constructor(self, "Einstellungen", "files/images/Phone/Apps/IconSettings.png")
end

function AppSettings:onOpen(form)
	self.m_Label = GUILabel:new(10, 10, 200, 50, _"Einstellungen", form)
	self.m_Label:setColor(Color.Black)

	GUILabel:new(10, 60, 200, 20, _"Handy", form):setColor(Color.Black)
	self.m_PhoneChanger = GUIChanger:new(10, 85, 200, 30, form)
	self.m_PhoneChanger.onChange = function(text)
		-- Save it
		Phone:getSingleton():setPhone(text)
		core:getConfig():set("Phone", "Phone", text)
	end
	self.m_PhoneChanger:addItem("iPhone")
	self.m_PhoneChanger:addItem("Android-Phone")
	if core:get("Phone", "Phone") then
		self.m_PhoneChanger:setSelectedItem(core:get("Phone", "Phone"))
	end

	GUILabel:new(10, 125, 200, 20, _"Klingelton", form):setColor(Color.Black)
	self.m_RingtoneChanger = GUIChanger:new(10, 150, 200, 30, form)
	self.m_RingtoneChanger.onChange = function(text)
		if self.m_Sound and isElement(self.m_Sound) then
			destroyElement(self.m_Sound)
		end
		local path = "files/audio/Ringtones/"..text:gsub(" ", "")..".mp3"
		self.m_Sound = playSound(path)

		-- Save it
		core:getConfig():set("Phone", "Ringtone", path)
	end
	for i = 1, 3 do
		self.m_RingtoneChanger:addItem(_("Klingelton %d", i))
	end

end

function AppSettings:onClose()
	if self.m_Sound and isElement(self.m_Sound) then
		destroyElement(self.m_Sound)
	end
end
