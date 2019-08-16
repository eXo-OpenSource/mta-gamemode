-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Minigames/BlackJack/BlackJackManager.lua
-- *  PURPOSE:     BlackJackManager
-- *
-- ****************************************************************************

BlackJackManager = inherit(Singleton)
addRemoteEvents{"BlackJackManager:onReady", "BlackJackManager:onHit", "BlackJackManager:onStand", "BlackJackManager:onCancel", "BlackJackManager:onReset", "BlackJackManager:onInsurance"}

function BlackJackManager:constructor() 
	self.m_Players = {}
	
	addEventHandler("BlackJackManager:onReady", root, bind(self.Event_onPlayerReady, self))

	addEventHandler("BlackJackManager:onHit", root, bind(self.Event_onPlayerHit, self))

	addEventHandler("BlackJackManager:onStand", root, bind(self.Event_onPlayerStand, self))

	addEventHandler("BlackJackManager:onCancel", root, bind(self.Event_onPlayerCancel, self))

	addEventHandler("BlackJackManager:onReset", root, bind(self.Event_onPlayerReset, self))

	addEventHandler("BlackJackManager:onInsurance", root, bind(self.Event_onPlayerInsurance, self))
end

function BlackJackManager:destructor() 

end

function BlackJackManager:Event_onPlayerReady(bet)
	if client and self.m_Players[client] then 
		self.m_Players[client]:start(bet)
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

function BlackJackManager:Event_onPlayerCancel(spectating) 
	if not spectating and self.m_Players[client] then 
		self.m_Players[client]:delete()
		self.m_Players[client] = nil
	else 
		if self.m_Players[spectating] then 
			self.m_Players[spectating]:stopSpectate(client)
		end
	end
end

function BlackJackManager:Event_onPlayerInsurance() 
	if self.m_Players[client] then 
		self.m_Players[client]:insurance()
	end
end

function BlackJackManager:Event_onPlayerReset(bet) 
	if self.m_Players[client] then 
		self.m_Players[client]:reset(bet)
	end
end

function BlackJackManager:Event_onPlayerSpectate(spectator, player) 
	if self.m_Players[player] then 
		self.m_Players[player]:spectate(spectator)
	end
end


function BlackJackManager:start(player) 
	if not self.m_Players[player] then 
		self.m_Players[player] = BlackJack:new(player)
	end
end

