Player = inherit(MTAElement)
registerElementClass("player", Player)

function Player:constructor()
	self.m_Character = false;
end

function Player:destructor()
end

function Player:triggerEvent(ev, ...)
	triggerClientEvent(self, ev, self, ...)
end