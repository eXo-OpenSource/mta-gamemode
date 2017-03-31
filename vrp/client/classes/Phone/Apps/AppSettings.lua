-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppSettings.lua
-- *  PURPOSE:     Phone settings app class
-- *
-- ****************************************************************************
AppSettings = inherit(PhoneApp)

function AppSettings:constructor()
	PhoneApp.constructor(self, "Einstellungen", "IconSettings.png")
end

function AppSettings:onOpen(form)
	self.m_Label = GUILabel:new(10, 10, 200, 50, _"Einstellungen", form)
	self.m_Label:setColor(Color.Black)

	GUILabel:new(10, 65, 200, 20, _"Handy", form):setColor(Color.Black)
	self.m_PhoneChanger = GUIChanger:new(10, 85, 200, 30, form)
	self.m_PhoneChanger.onChange =
		function(text)
		-- Save it
			Phone:getSingleton():setPhone(text)
			core:getConfig():set("Phone", "Phone", text)
		end
	self.m_PhoneChanger:addItem("iPhone")
	self.m_PhoneChanger:addItem("Android-Phone")
	if core:get("Phone", "Phone") then
		self.m_PhoneChanger:setSelectedItem(core:get("Phone", "Phone"))
	end

	GUILabel:new(10, 130, 200, 20, _"Hintergrund", form):setColor(Color.Black)
	self.m_BackgroundChanger = GUIChanger:new(10, 150, 200, 30, form)
	self.m_BackgroundChanger.onChange =
		function(text)
			-- Save it
			Phone:getSingleton():setBackground(text)
			core:getConfig():set("Phone", "Background", text)
		end
	-- Todo: table? // Convert to jpg
	self.m_BackgroundChanger:addItem("Xperia_X")
	self.m_BackgroundChanger:addItem("Google_Pixel")
	self.m_BackgroundChanger:addItem("iOS_7")
	self.m_BackgroundChanger:addItem("iOS_10")
	self.m_BackgroundChanger:addItem("Nexus")
	self.m_BackgroundChanger:addItem("Xperia_Z3")
	self.m_BackgroundChanger:addItem("OnePlus_3T")

	if core:get("Phone", "Background") then
		self.m_BackgroundChanger:setSelectedItem(core:get("Phone", "Background"))
	end

	GUILabel:new(10, 195, 200, 20, _"Klingelton", form):setColor(Color.Black)
	self.m_RingtoneChanger = GUIChanger:new(10, 215, 200, 30, form)
	self.m_RingtoneChanger.onChange = function(text)
		if self.m_Sound and isElement(self.m_Sound) then
			destroyElement(self.m_Sound)
		end
		local path = "files/audio/Ringtones/"..text:gsub(" ", "")..".mp3"
		self.m_Sound = playSound(path)

		-- Save it
		core:getConfig():set("Phone", "Ringtone", path)
	end

	local items = {}
	for i = 1, 14 do
		local path = "files/audio/Ringtones/Klingelton"..i..".mp3"
		items[path] = self.m_RingtoneChanger:addItem(_("Klingelton %d", i))
	end
	local selected = core:getConfig():get("Phone", "Ringtone", "files/audio/Ringtones/Klingelton1.mp3"), true
	self.m_RingtoneChanger:setIndex(items[selected], true)

end

function AppSettings:onClose()
	if self.m_Sound and isElement(self.m_Sound) then
		destroyElement(self.m_Sound)
	end
end
