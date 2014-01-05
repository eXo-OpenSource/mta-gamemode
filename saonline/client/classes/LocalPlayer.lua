-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/LocalPlayer.lua
-- *  PURPOSE:     Local player class
-- *
-- ****************************************************************************
LocalPlayer = inherit(Player)

function LocalPlayer:constructor()
	self.m_Locale = "de"
	self.m_Karma = 0
	self.m_Job = false
	
	-- Since the local player exist only once, we can add the events here
	addEvent("karmaSet", true)
	addEventHandler("karmaSet", root, bind(self.Event_karmaSet, self))
end

function LocalPlayer:destructor()
end

-- Short getters
function LocalPlayer:getLocale()	return self.m_Locale 	end
function LocalPlayer:getJob()		return self.m_Job 		end

-- Short setters
function LocalPlayer:setLocale(locale)	self.m_Locale = locale 	end
function LocalPlayer:setJob(job)		self.m_Job = job		end


function LocalPlayer:sendMessage(text, r, g, b, ...)
	outputChatBox(text:format(...), r, g, b, true)
end


-- Events
function LocalPlayer:Event_karmaSet(karma)
	self.m_Karma = karma
	KarmaBar:getSingleton():setKarma(karma)
end
