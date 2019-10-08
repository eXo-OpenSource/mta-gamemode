-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Time.lua
-- *  PURPOSE:     Time class
-- *
-- ****************************************************************************

Time = inherit(Singleton)

addRemoteEvents{"requestTimeSync"}

function Time:constructor()
	addEventHandler("requestTimeSync", root, bind(self.Event_requestTimeSync, self))
end

function Time:destructor()
end

function Time:Event_requestTimeSync(clientTick, clientTime)
	client:triggerEvent("onTimeSync", client, clientTick, clientTime, os.time(), getTickCount())
end
