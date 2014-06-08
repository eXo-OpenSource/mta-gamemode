-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GangArea.lua
-- *  PURPOSE:     Gang area (turfing) class
-- *
-- ****************************************************************************
GangArea = inherit(Object)

function GangArea:constructor(x, y, width, height)
	self.m_ColShape = createColRectangle(x, y-height, width, height) -- y-height := use north west corner instead of south west
	self.m_RadarArea = RadarArea:new(x, y, width, height, tocolor(0, 255, 0, 200))
	self.m_OwnerGroup = false
	
	self.m_TurfingPlayers = {}
	self.m_TurfingGroup = false
	self.m_TurfingTimer = nil
	self.m_TurfingProgress = 100
	
	addEventHandler("onColShapeHit", self.m_ColShape, bind(self.Area_Enter, self))
	addEventHandler("onColShapeLeave", self.m_ColShape, bind(self.Area_Leave, self))
end

function GangArea:destructor()
	destroyElement(self.m_ColShape)
	destroyElement(self.m_RadarArea)
end

function GangArea:Area_Enter(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		if not self.m_OwnerGroup then
			return
		end
	
		local group = hitElement:getGroup()
		if not group then
			return
		end
		
		-- Check if it is not the same group and it is an evil group (= gang)
		if group == self.m_OwnerGroup or group:isEvil() then
			return
		end
		
		-- Start turfing only if at least 2 players of the owner group are online
		local onlinePlayers = self.m_OwnerGroup:getOnlinePlayers()
		if #onlinePlayers < 2 then
			return
		end
		
		table.insert(self.m_TurfingPlayers, hitElement)
		self.m_TurfingGroup = group
		
		-- Is it the first player?
		if not self.m_TurfingTimer then
			self.m_TurfingTimer = setTimer(bind(self.updateTurfing, self), 4000, 0)
			
			-- Tell the client that we're turfing now
			for k, player in pairs(onlinePlayers) do
				player:triggerEvent("gangTurfStart", self.m_TurfingGroup:getName())
			end
			hitElement:triggerEvent("gangTurfStart", self.m_TurfingGroup:getName())
		end
	end
end

function GangArea:Area_Leave(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		local idx = table.find(self.m_TurfingPlayers, hitElement)
		if not idx then
			return
		end
		
		table.remove(self.m_TurfingPlayers, idx)
		hitElement:triggerEvent("gangTurfStop", self.m_TurfingGroup:getName())
		
		if #self.m_TurfingPlayers == 0 then
			-- Stop attacking mode
			self.m_TurfingGroup = false
			
			killTimer(self.m_TurfingTimer)
			self.m_TurfingTimer = nil
			
			for k, player in pairs(self.m_OwnerGroup:getOnlinePlayers()) do
				player:triggerEvent("gangTurfStop", self.m_TurfingGroup:getName())
			end
		end
	end
end

function GangArea:updateTurfing()
	-- Using a timer interval of 4 seconds results in a overall turfing time of 400 seconds (4000ms * 100)
	self.m_TurfingProgress = self.m_TurfingProgress - 1
	
	if self.m_TurfingProgress <= 0 then
		-- it looks like the gang area has a new owner :)
		self.m_OwnerGroup = self.m_TurfingGroup
	end
end

function GangArea:sendMessage(message, ...)
	for k, player in pairs(self.m_OwnerGroup:getOnlinePlayers()) do
		player:sendMessage(_(message, player, ...))
	end
	
	if self.m_TurfingPlayers then
		for k, player in pairs(self.m_TurfingPlayers) do
			player:sendMessage(_(message, player, ...))
		end
	end
end
