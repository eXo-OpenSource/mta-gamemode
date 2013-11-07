Player = inherit(MTAElement)
registerElementClass("player", Player)

function Player:constructor()
	self.m_Character = false;
	self.m_Account = false;
end

function Player:destructor()
end

function Player:triggerEvent(ev, ...)
	triggerClientEvent(self, ev, self, ...)
end

function Player:getAccount()
	return self.m_Account
end