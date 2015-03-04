-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/LasertagEvent.lua
-- *  PURPOSE:     Lasertag event class
-- *
-- ****************************************************************************
LasertagEvent = inherit(Event)

function LasertagEvent:constructor()
	self.m_FuncRender = bind(self.renderLasers, self)
end

function LasertagEvent:destructor()
	removeEventHandler("onClientPreRender", root, self.m_FuncRender)
end

function LasertagEvent:onStart()
	addEventHandler("onClientPreRender", root, self.m_FuncRender)
end

function LasertagEvent:renderLasers()
	for k, player in pairs(self:getPlayers()) do
		local x1, y1, z1 = player:getTargetStart()
		local x2, y2, z2 = player:getTargetEnd()

		if x1 and x2 then
			dxDrawLine3D(x1, y1, z1, x2, y2, z2, Color.Red)
		end
	end
end
