-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        server/classes/Player.lua
-- *  PURPOSE:     Player class
-- *
-- ****************************************************************************
Player = inherit(MTAElement)
registerElementClass("player", Player)

function Player:constructor()
	self.m_Character = false
	self.m_Account = false
	self.m_Locale = "en"
end

function Player:destructor()
end

function Player:triggerEvent(ev, ...)
	triggerClientEvent(self, ev, self, ...)
end

function Player:getAccount()
	return self.m_Account
end

function Player:getLocale()
	return self.m_Locale
end

function Player:setLocale(locale)
	self.m_Locale = locale
end

function Player:sendMessage(text, r, g, b, ...)
	outputChatBox(text:format(...), self, r, g, b, true)
end

function Player:getPhonePartner()
	return self.m_PhonePartner
end

function Player:setPhonePartner(partner)
	self.m_PhonePartner = partner
end
