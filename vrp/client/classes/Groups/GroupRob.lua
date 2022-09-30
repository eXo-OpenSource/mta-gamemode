-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Player/GroupRob.lua
-- *  PURPOSE:     GroupRob
-- *
-- ****************************************************************************




GroupRob = inherit(Singleton)
addRemoteEvents{"onClientStartHouseRob", "onClientEndHouseRob"}

function GroupRob:constructor() 
	self.m_CurrentRob = false
	self.m_DoneRob = bind( self.onRobDone, self)
	self.m_OnRobFind = bind(self.onRobFind, self)
	addEventHandler("onClientStartHouseRob", root, bind(self.initiateRob, self))
	addEventHandler("onClientEndHouseRob", root, bind(self.stopRob, self))
	addEventHandler("onClientPlayerWasted", localPlayer, bind(self.stopRob, self))
end


function GroupRob:destructor() 

end

function GroupRob:stopRob() 
	if self.m_CountDown then 
		delete(self.m_CountDown)
	end
	if isTimer(self.m_RobFindTimer) then 
		killTimer(self.m_RobFindTimer)
	end
	if isTimer(self.m_RobExpireTimer) then 
		killTimer(self.m_RobExpireTimer)
	end
end

function GroupRob:onRobFind( )
	local randomFind = math.random(1,10)
	if randomFind >= 7 then 
		triggerServerEvent("playerFindRobableItem", localPlayer)
	else
		triggerServerEvent("playerRobTryToGiveWanted", localPlayer)
	end
end

function GroupRob:onRobDone() 
	outputChatBox(_"Du suchst alle Ecken ab und findest nichts mehr. Verlasse nun das Haus!", 200,200,0)
	if self.m_CountDown then 
		delete(self.m_CountDown)
	end
	if isTimer(self.m_RobFindTimer) then 
		killTimer(self.m_RobFindTimer)
	end
	if isTimer(self.m_RobExpireTimer) then 
		killTimer(self.m_RobExpireTimer)
	end
end


function GroupRob:initiateRob( int, house, enterPos )
	self.m_CurrentRob = house
	self.m_EnterPosition = enterPos
	self.m_EnterInt = int
	if self.m_CountDown then 
		delete(self.m_CountDown)
	end
	self.m_CountDown = Countdown:new( 240, "Durchsuchen")
	self.m_RobExpireTimer = setTimer(self.m_DoneRob, 240*1000, 1)
	self.m_RobFindTimer = setTimer(self.m_OnRobFind, 10000, 0)
end


function GroupRob:Event_onRender() 
	
end