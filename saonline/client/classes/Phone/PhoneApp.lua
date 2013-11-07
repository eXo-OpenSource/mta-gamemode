-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/Phone/PhoneApp.lua
-- *  PURPOSE:     PhoneApp class
-- *
-- ****************************************************************************
PhoneApp = inherit(Singleton)

function PhoneApp:constructor()
	self.m_IsOpen = false
end

function PhoneApp:destructor()
end

function PhoneApp:isOpen()
	return self.m_IsOpen
end

PhoneApp.open = pure_virtual
PhoneApp.close = pure_virtual
PhoneApp.getIconPath = pure_virtual
