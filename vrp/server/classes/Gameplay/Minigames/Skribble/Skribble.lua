-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
Skribble = inherit(Singleton)
addRemoteEvents{"onSyncSkribbleData"}

function Skribble:constructor()
	addEventHandler("onSyncSkribbleData", root, bind(Skribble.onSyncData, self))
end

function Skribble:onSyncData(data)
	if isElement(ppp) then
		ppp:triggerEvent("sendSkribbleData", data)
	end
end
