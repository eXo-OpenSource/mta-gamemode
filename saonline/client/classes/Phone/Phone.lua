-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/Phone/Phone.lua
-- *  PURPOSE:     Phone class
-- *
-- ****************************************************************************
Phone = inherit(GUIForm)
inherit(Singleton, Phone)

function Phone:constructor()
	GUIForm.constructor(self, screenWidth-270, screenHeight-500, 250, 490)

	self.m_Apps = {}
	
	-- Register apps
	self:registerApp(AppHelloWorld)
	
	-- Add GUI elements
	self.m_Background = GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/Phone/Phone.png", self)
	
	-- Create app icons
	self.m_IconSurface = GUIScrollableArea:new(0, 0, self.m_Width, self.m_Height, self.m_Width, self.m_Height, false, false, self)
	for k, app in ipairs(self.m_Apps) do
		GUIImage:new(22, 50, 56, 56, app:getIconPath(), self.m_IconSurface)
	end
end

function Phone:destructor()
end

--[[function Phone:drawThis()
	-- Draw phone
	dxDrawImage(screenWidth-270, screenHeight-500, 250, 490, "files/images/Phone/Phone.png") -- 1.96
	
	-- Draw app icons
	for k, app in ipairs(self.m_Apps) do
		dxDrawImage(screenWidth-248, screenHeight-450, 56, 56, app:getIconPath())
	end

	-- Draw app surface
	for k, app in ipairs(self.m_Apps) do
		if app:isOpen() then
			if app.render then
				app:render()
			end
		end
	end
end]]

function Phone:registerApp(app)
	table.insert(self.m_Apps, app)
end

function Phone:open()
	
end

addCommandHandler("phone",
	function()
		local p = Phone:new()
		p:open()
	end
)