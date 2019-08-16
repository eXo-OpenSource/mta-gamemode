-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Minigames/BlackJack/BlackJackManager.lua
-- *  PURPOSE:     BlackJackManager
-- *
-- ****************************************************************************

BlackJackManager = inherit(Singleton)
addRemoteEvents{"BlackJackManager:onReady", "BlackJackManager:onHit", "BlackJackManager:onStand", "BlackJackManager:onCancel", "BlackJackManager:onReset"}

function BlackJackManager:constructor() 
	self.m_Players = {}
	
	addEventHandler("BlackJackManager:onReady", root, bind(self.Event_onPlayerReady, self))

	addEventHandler("BlackJackManager:onHit", root, bind(self.Event_onPlayerHit, self))

	addEventHandler("BlackJackManager:onStand", root, bind(self.Event_onPlayerStand, self))

	addEventHandler("BlackJackManager:onCancel", root, bind(self.Event_onPlayerCancel, self))

	addEventHandler("BlackJackManager:onReset", root, bind(self.Event_onPlayerReset, self))
end

function BlackJackManager:destructor() 

end

function BlackJackManager:Event_onPlayerReady()
	if client and self.m_Players[client] then 
		self.m_Players[client]:start()
	end
end

function BlackJackManager:Event_onPlayerHit() 
	if self.m_Players[client] then 
		self.m_Players[client]:hit()
	end
end

function BlackJackManager:Event_onPlayerStand() 
	if self.m_Players[client] then 
		self.m_Players[client]:stand()
	end
end

function BlackJackManager:Event_onPlayerCancel() 
	if self.m_Players[client] then 
		self.m_Players[client]:cancel()
	end
end

function BlackJackManager:Event_onPlayerReset() 
	if self.m_Players[client] then 
		self.m_Players[client]:reset()
	end
end


function BlackJackManager:start(player) 
	if not self.m_Players[player] then 
		self.m_Players[player] = BlackJack:new(player)
	end
end

