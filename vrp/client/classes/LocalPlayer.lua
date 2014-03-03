-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/LocalPlayer.lua
-- *  PURPOSE:     Local player class
-- *
-- ****************************************************************************
LocalPlayer = inherit(Player)
addEvent("karmaSet", true)
addEvent("retrieveInfo", true)

function LocalPlayer:constructor()
	self.m_Locale = "de"
	self.m_Karma = 0
	self.m_Job = false
	self.m_Rank = 0
	
	-- Since the local player exist only once, we can add the events here
	addEventHandler("retrieveInfo", root, bind(self.Event_retrieveInfo, self))
	addEventHandler("karmaSet", root, bind(self.Event_karmaSet, self))
	
	addEventHandler("onClientPlayerWasted", localPlayer, bind(self.playerWasted, self))
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

function LocalPlayer:getRank()
	return self.m_Rank
end

function LocalPlayer:playerWasted()
	setTimer(setCameraMatrix, 2000, 1, 1963.7, -1483.8, 101, 2038.2, -1408.4, 23)
	setTimer(function() setCameraTarget(localPlayer) end, 20000, 1)
end

-- Events
function LocalPlayer:Event_retrieveInfo(info)
	self.m_Rank = info.Rank
end

function LocalPlayer:Event_karmaSet(karma)
	self.m_Karma = karma
	KarmaBar:getSingleton():setKarma(karma)
end
