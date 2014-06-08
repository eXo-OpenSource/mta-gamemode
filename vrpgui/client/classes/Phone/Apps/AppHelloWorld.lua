-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppHelloWorld.lua
-- *  PURPOSE:     Hello world phone app class
-- *
-- ****************************************************************************
AppHelloWorld = inherit(PhoneApp)

function AppHelloWorld:constructor()
	PhoneApp.constructor(self, "FirstApp", "files/images/Phone/Apps/IconHelloWorld.png")
end

function AppHelloWorld:onOpen(form)
	self.m_Label = GUILabel:new(10, 10, 200, 20, "Hello world!", form)
	self.m_Label:setColor(Color.Black)
end

function AppHelloWorld:onClose()
	outputChatBox("Bye!", 255, 255, 0)
end
