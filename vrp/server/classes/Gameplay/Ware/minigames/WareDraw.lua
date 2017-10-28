-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareDraw.lua
-- *  PURPOSE:     WareDraw class
-- *
-- ****************************************************************************
WareDraw = inherit(Object)
WareDraw.modeDesc = "Male in 6 unterschiedlichen Farben"
WareDraw.timeScale = 1

addRemoteEvents{"Ware:onDrawColor"}

function WareDraw:constructor(super)
	self.m_Super = super
	for key, p in pairs(self.m_Super.m_Players) do
		p:triggerEvent("setWareDrawListenerOn")
	end
	self.onDrawBind = bind(self.Event_onDraw, self)
	addEventHandler("Ware:onDrawColor", root, self.onDrawBind)

end

function WareDraw:Event_onDraw(colors)
	if client.bInWare then
		if client.bInWare == self.m_Super then
			if #colors >= 6 then
				self.m_Super:addPlayerToWinners(client)
			end
		end
	end
end

function WareDraw:destructor()
	for key, p in pairs(self.m_Super.m_Players) do
		p:triggerEvent("setWareDrawListenerOff")
	end
	removeEventHandler("Ware:onDrawColor", root, self.onDrawBind)
end
