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
	self.m_IconSurface = GUIScrollableArea:new(14, 41, 222, 391, self.m_Width, self.m_Height, false, false, self)
	for k, app in ipairs(self.m_Apps) do
		local i = GUIImage:new(8, 9, 56, 56, app:getIconPath(), self.m_IconSurface)
		i.onLeftClick = function() outputChatBox("Clicked app") end
	end
end

function Phone:destructor()
end

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