-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        server/classes/Player.lua
-- *  PURPOSE:     Player class
-- *
-- ****************************************************************************
Player = inherit(MTAElement)
registerElementClass("player", Player)
addEventHandler("onPlayerConnect", root, 
	function(name)
		local player = getPlayerFromName(name)
		Async.create(Player.connect)(player)
	end
)

function Player:constructor()
	self.m_Character = false
	self.m_Account = false
	self.m_Locale = "en"
end

function Player:connect()
	if not Ban.checkBan(self) then return end
end

function Player:destructor()
end

function Player:getCharacterId()
	return 1 --self.m_Character and self.m_Character:getId()
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

function Player:sendError(text, ...)
	self:triggerEvent("errorBox", text:format(...))
end

function Player:sendWarning(text, ...)
	self:triggerEvent("warningBox", text:format(...))
end

function Player:sendInfo(text, ...)
	self:triggerEvent("infoBox", text:format(...))
end

function Player:sendSuccess(text, ...)
	self:triggerEvent("successBox", text:format(...))
end

function Player:getPhonePartner()
	return self.m_PhonePartner
end

function Player:setPhonePartner(partner)
	self.m_PhonePartner = partner
end

-- Moving to character class?
function Player:getJob()
	return self.m_Job
end

function Player:setJob(job)
	self.m_Job = job
end