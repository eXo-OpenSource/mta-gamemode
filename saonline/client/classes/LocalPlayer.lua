-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/LocalPlayer.lua
-- *  PURPOSE:     Local player class
-- *
-- ****************************************************************************
LocalPlayer = inherit(Player)

function LocalPlayer:constructor()
	self.m_Locale = "en"
	self.m_Karma = 0
	
	-- Since the local player exist only once, we can add the events here
	addEvent("karmaSet", true)
	addEventHandler("karmaSet", root, bind(self.Event_karmaSet, self))
end

function LocalPlayer:destructor()

end

function LocalPlayer:getLocale()
	return self.m_Locale
end

function LocalPlayer:setLocale(locale)
	self.m_Locale = locale
end

function LocalPlayer:sendMessage(text, r, g, b, ...)
	outputChatBox(text:format(...), r, g, b, true)
end


-- Events
function LocalPlayer:Event_karmaSet(karma)
	self.m_Karma = karma
	KarmaBar:getSingleton():setKarma(karma)
end
