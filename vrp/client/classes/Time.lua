-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Time.lua
-- *  PURPOSE:     Time class
-- *
-- ****************************************************************************

Time = inherit(Singleton)

addRemoteEvents{"onTimeSync"}

function Time.serverToLocal(time)
	return time + Time:getSingleton().m_TimeOffset
end

function Time:constructor()
	self.m_TimeOffset = 0
	self.m_TickOffset = 0

	addEventHandler("requestTimeSync", root, bind(self.Event_onTimeSync, self))
	triggerServerEvent("requestTimeSync", localPlayer, getTickCount(), os.time())
end

function Time:destructor()
end

function Time:Event_onTimeSync(clientTick, clienTime, serverTime, serverTick)
	self.m_TimeOffset = os.time() - serverTime + os.time() - clienTime
	if self.m_TimeOffset > 1 then
		outputChatBox(_("Deine lokale Zeit weicht von der Serverzeit um %s Sekunden ab.", self.m_TimeOffset), 200, 0, 0)
	end
	self.m_TickOffset = getTickCount() - (serverTick + (getTickCount() - clientTick) / 2)
end

