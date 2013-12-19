-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/StreetRaceEvent.lua
-- *  PURPOSE:     Streetrace event class
-- *
-- ****************************************************************************
StreetRaceEvent = inherit(Event)

function StreetRaceEvent:constructor()
	Event.constructor(self)
end

function StreetRaceEvent:start()
	-- Jusonex: A better place for the following might be the Event class --> we have to write something like "onStart" or - as bad alternative - we can call Event.start here
	if #self.m_Players == 0 then
		return false
	end

	-- Find random position
	local x, y, z = unpack(StreetRaceEvent.Destinations[math.random(1, #StreetRaceEvent.Destinations)])
	self.m_Blip = createBlip(x, y, z, 41)
	self.m_ColShape = createColSphere(x, y, z, 20)
	addEventHandler("onColShapeHit", self.m_ColShape, bind(self.colShapeHit, self))
	
	-- Start the GPS for each player
	for k, player in ipairs(self.m_Players) do
		player:startNavigationTo(x, y, z)
	end
	
	-- Tell player that we started the event
	self:sendMessage("Event started", 255, 255, 0)
end

function StreetRaceEvent:destructor()
	destroyElement(self.m_Blip)
	destroyElement(self.m_ColShape)
end

function StreetRaceEvent:colShapeHit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		-- Add player to the winner list
		self.m_Ranks[#self.m_Ranks+1] = hitElement
		
		-- Tell all players that someone reached the destination
		self:sendMessage("%s reached the destination as %d.", 255, 255, 0, getPlayerName(hitElement), #self.m_Ranks)
		
		-- Give him some money
		local moneyAmount = 100 * #self.m_Players / #self.m_Ranks
		givePlayerMoney(hitElement, moneyAmount)
		hitElement:sendMessage(_("[EVENT] You won %d$", hitElement), 0, 255, 0, moneyAmount)
		
		-- Quit the hitting player
		self:quit(hitElement)
		
		-- Stop the event is all players reached the destination
		if #self.m_Players == #self.m_Ranks then
			delete(self)
		end
	end
end

StreetRaceEvent.Destinations = {
	{0, 0, 4},
	{10, 4, 6}
}
