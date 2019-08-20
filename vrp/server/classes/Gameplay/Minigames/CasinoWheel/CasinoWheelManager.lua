-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Minigames/CasinoWheelManager.lua
-- *  PURPOSE:     CasinoWheelManager
-- *
-- ****************************************************************************

CasinoWheelManager = inherit(Singleton)

addRemoteEvents{"CasinoWheel:requestMap", "CasinoWheel:onPlayerStop", "CasinoWheel:onPlayerSubmitBet", "CasinoWheel:onPlayerRedrawBet", "CasinoWheel:onPlayerClose"}

function CasinoWheelManager:constructor() 
	self.m_Map = {}
	self.m_Players = {}

	addEventHandler("CasinoWheel:requestMap", root, bind(self.Event_onPlayerRequestMap, self))
	addEventHandler("CasinoWheel:onPlayerStop", root, bind(self.Event_onPlayerStop, self))
	addEventHandler("CasinoWheel:onPlayerSubmitBet", root, bind(self.Event_onPlayerSubmitBet, self))
	addEventHandler("CasinoWheel:onPlayerRedrawBet", root, bind(self.Event_onPlayerRedrawBet, self))
	addEventHandler("CasinoWheel:onPlayerClose", root, bind(self.Event_onPlayerRedrawBet, self))
	PlayerManager:getSingleton():getQuitHook():register(bind(self.Event_PlayerQuit, self))
end

function CasinoWheelManager:Event_onPlayerRequestMap()
	client:triggerEvent("CasinoWheel:sendTableObjects", self.m_Map)
end

function CasinoWheelManager:Event_PlayerQuit(player) 
	if self.m_Players[player] then
		if self.m_Map[self.m_Players[player]] then
			self.m_Map[self.m_Players[player]]:stopPlayer(player)
		end
	end
end


function CasinoWheelManager:Event_onPlayerStop() 
	if self.m_Players[client] then
		if self.m_Map[self.m_Players[client]] then
			self.m_Map[self.m_Players[client]]:stopPlayer(client)
		end
	end
	self.m_Players[client] = nil
end

function CasinoWheelManager:Event_onPlayerSubmitBet(bets) 
	if self.m_Players[client] then
		if self.m_Map[self.m_Players[client]] then
			self.m_Map[self.m_Players[client]]:submitBet(client, bets)
		end
	end
end

function CasinoWheelManager:Event_onPlayerRedrawBet() 
	if self.m_Players[client] then
		if self.m_Map[self.m_Players[client]] then
			self.m_Map[self.m_Players[client]]:redrawBet(client)
		end
	end
end


function CasinoWheelManager:create(pos, rot)
	if pos and rot then
		local instance = CasinoWheel:new(pos, rot) 
		self.m_Map[instance:getObject()] = instance
			
		for k, p in ipairs(getElementsByType("player")) do 
			p:triggerEvent("CasinoWheel:sendTableObject", instance:getObject())
		end
		instance:getObject():setData("clickable", true, true)
		instance.m_Ped:setData("clickable", true, true)

    	addEventHandler("onElementClicked", instance:getObject(), function(button, state, player)
			if not player.m_LoggedIn then return end
			if self.m_Players[player] then return end
        	if Vector3(source:getPosition()-player:getPosition()):getLength() > 5 then return end
			if button == "left" and state == "up" then
				self.m_Players[player] = source
				self.m_Map[self.m_Players[player]].m_Players[player] = true
				player:triggerEvent("CasinoWheel:clickWheel", source)
			end
		end)
		addEventHandler("onElementClicked", instance.m_Ped, function(button, state, player)
			if not player.m_LoggedIn then return end
			if self.m_Players[player] then return end
        	if Vector3(source:getPosition()-player:getPosition()):getLength() > 5 then return end
			if button == "left" and state == "up" then
				self.m_Players[player] = source.m_Obj
				self.m_Map[self.m_Players[player]].m_Players[player] = true
				player:triggerEvent("CasinoWheel:clickWheel", source.m_Obj)
			end
		end)
		return instance
	end
end

function CasinoWheelManager:destructor() 

end