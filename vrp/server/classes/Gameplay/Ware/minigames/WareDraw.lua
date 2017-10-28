-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareDraw.lua
-- *  PURPOSE:     WareDraw class
-- *
-- ****************************************************************************
WareDraw = inherit(Object)
WareDraw.modeDesc = "Male in x unterschiedlichen Farben"
WareDraw.timeScale = 1

addRemoteEvents{"Ware:onDrawColor"}

function WareDraw:constructor(super)
	self.m_Super = super
	self.m_ColorAmount = math.random(2, 7)

	WareMath.modeDesc = ("Male in %d unterschiedlichen Farben"):format(self.m_ColorAmount)

	for key, p in pairs(self.m_Super.m_Players) do
		p:triggerEvent("setWareDrawListenerOn", self.m_ColorAmount)
	end

	self.onDrawBind = bind(self.Event_onDraw, self)
	addEventHandler("Ware:onDrawColor", root, self.onDrawBind)
end

function WareDraw:Event_onDraw(colors)
	if client.bInWare then
		if client.bInWare == self.m_Super then
			if #colors == self.m_ColorAmount then
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
