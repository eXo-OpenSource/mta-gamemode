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
		-- Don't start turfing if another group is already in turfing mode
		if self.m_TurfingGroup then
			return
		end
	
		local group = hitElement:getGroup()
		if not group then
			return
		end
		
		-- Check if it is not the same group and it is an evil group (= gang)
		if group == self.m_OwnerGroup or not group:isEvil() then
			return
		end
		
		table.insert(self.m_TurfingPlayers, hitElement)
		self:startTurfing(group)
		hitElement:triggerEvent("gangTurfStart", self.m_TurfingGroup:getName())
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
			if self.m_OwnerGroup then
				for k, player in pairs(self.m_OwnerGroup:getOnlinePlayers()) do
					player:triggerEvent("gangTurfStop", self.m_TurfingGroup:getName())
				end
			end
			
			-- Is there any other opponent group?
			for k, opponent in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
				local group = opponent:getGroup()
				if group and group ~= self.m_TurfingGroup and group ~= self.m_OwnerGroup then
					self:startTurfing(group)
					opponent:triggerEvent("gangTurfStart", self.m_TurfingGroup:getName())
					break
				end
			end
			
			-- Stop attacking mode
			self.m_TurfingGroup = false
			self.m_TurfingProgress = 100
			
			killTimer(self.m_TurfingTimer)
			self.m_TurfingTimer = nil
		end
	end
end

function GangArea:updateTurfing()
	-- Using a timer interval of 4 seconds results in a overall turfing time of 400 seconds (4000ms * 100)
	self.m_TurfingProgress = self.m_TurfingProgress - 1
	
	-- Tripple speed if the area has no owner group
	if not self.m_OwnerGroup then
		self.m_TurfingProgress = self.m_TurfingProgress - 2
	end
	
	if self.m_TurfingProgress <= 0 then
		-- it looks like the gang area has a new owner :)
		self.m_OwnerGroup = self.m_TurfingGroup
		self.m_TurfingProgress = 100
	end
end

function GangArea:startTurfing(group)
	if self.m_TurfingTimer then
		return
	end

	self.m_TurfingGroup = group
	self.m_TurfingTimer = setTimer(bind(self.updateTurfing, self), 4000, 0)
	
	-- Tell the client that we're turfing now
	if self.m_OwnerGroup then
		local onlinePlayers = self.m_OwnerGroup:getOnlinePlayers()
		for k, player in pairs(onlinePlayers) do
			player:triggerEvent("gangTurfStart", self.m_TurfingGroup:getName())
		end
	end
end

function GangArea:sendMessage(message, ...)
	if self.m_OwnerGroup then
		for k, player in pairs(self.m_OwnerGroup:getOnlinePlayers()) do
			player:sendMessage(_(message, player, ...))
		end
	end
	
	for k, player in pairs(self.m_TurfingPlayers) do
		player:sendMessage(_(message, player, ...))
	end
end
