-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/BankRobbery.lua
-- *  PURPOSE:     Bank robbery class
-- *
-- ****************************************************************************
BankRobbery = inherit(Object)
BankRobbery.Map = {}

function BankRobbery:constructor(position, rotation, interior, dimension)
	self.m_Safe = createObject(2332, position.X, position.Y, position.Z, 0, 0, rotation)
	setElementInterior(self.m_Safe, interior)
	setElementDimension(self.m_Safe, dimension or 0)
	
	setObjectScale(self.m_Safe, 6)
	-- Todo: Create a dummy wall to create a 'fake collider'
	table.insert(BankRobbery.Map, self)
	
	self.m_ColShape = createColSphere(position.X, position.Y, position.Z, 25) -- Should we really take the upper floors into account? A ColRectangle might be better here
end

function BankRobbery:installBomb()
	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		player:triggerEvent("bankRobberyCountdown", 4--[[*60]])
		
		local group = player:getGroup()
		if group and group:isEvil() then
			player:reportCrime(Crime.BankRobbery)
		end
	end
	
	setTimer(
		function()
			local x, y, z = getElementPosition(self.m_Safe)
			createExplosion(x, y, z, 11) -- Type: Small
			setElementModel(self.m_Safe, 1829)
		
			-- Give all groups money who are within the colshape (amount depends on player count)
			for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
				local group = player:getGroup()
				if group and group:isEvil() then
					group:giveMoney(400)
				end
			end
		end,
		4*--[[60*]]1000,
		1
	)
end

function BankRobbery.getRobableBankAtElement(element)
	for k, bankRobbery in ipairs(BankRobbery.Map) do
		if isElementWithinColShape(element, bankRobbery.m_ColShape) then
			return bankRobbery
		end
	end
	return false
end

function BankRobbery.initializeAll()
	BankRobbery:new(Vector(359.8, 160.7, 1009.9), 130, 3)
	
	-- Test
	addCommandHandler("sprengen",
		function(player)
			if not player:getGroup() then
				player:sendError(_("Banken kannst du nur, wenn du Mitglied einer Gruppe bist, ausrauben", player))
				return
			end
		
			local bankRobbery = BankRobbery.getRobableBankAtElement(player)
			if not bankRobbery then
				player:sendError(_("Du bist nicht in der Nähe einer ausraubbaren Bank", player))
				return
			end
			
			local x, y, z = getElementPosition(bankRobbery.m_Safe)
			if getDistanceBetweenPoints3D(x, y, z, getElementPosition(player)) > 5 then
				player:sendError(_("Du befindest dich nicht nah genug am Tresor", player))
				return
			end
			
			if not player:getGroup():isEvil() then
				player:sendError(_("Als Gruppe mit einem positiven Karma kannst du keine Banküberfälle starten", player))
				return
			end
			
			-- Todo: Play install animation
			bankRobbery:installBomb()
		end
	)
end
