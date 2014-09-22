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
	--self.m_Safe = createObject(2332, position.X, position.Y, position.Z, 0, 0, rotation)
	--setElementInterior(self.m_Safe, interior)
	--setElementDimension(self.m_Safe, dimension or 0)
	
	table.insert(BankRobbery.Map, self)
	
	self.m_Timer = false
	self.m_ColShape = createColSphere(position.X, position.Y, position.Z, 25)
	setElementInterior(self.m_ColShape, interior)
	
	addEventHandler("onColShapeLeave", self.m_ColShape,
		function(element, matchingDimension)
			if getElementType(element) == "player" and matchingDimension then
				-- Stop the countdown if all evil people were eliminated
				if self:countEvilPeople() == 0 then
					if self:countPolicePeople() > 0 then
						-- Give some money to the good people for defending the bank successfully
						for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
							if player:getJob() == JobPolice:getSingleton() then
								player:giveMoney(700)
							end
						end
					end
					if self.m_Timer and isTimer(self.m_Timer) then
						killTimer(self.m_Timer)
					end
				end
			end
		end
	)
end

function BankRobbery:installBomb()
	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		player:triggerEvent("bankRobberyCountdown", 4*60)
		
		local group = player:getGroup()
		if group and group:isEvil() then
			player:reportCrime(Crime.BankRobbery)
		end
	end
	
	self.m_Timer = setTimer(
		function()
			local x, y, z = getElementPosition(self.m_Safe)
			createExplosion(x, y, z, 11) -- Type: Small
			--setElementModel(self.m_Safe, 1829)
		
			-- Give all groups money who are within the colshape (amount depends on player count)
			for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
				local group = player:getGroup()
				if group and group:isEvil() then
					group:giveMoney(400)
				end
			end
		end,
		4*60*1000,
		1
	)
end

function BankRobbery:countEvilPeople()
	local amount = 0
	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		if player:getGroup() and player:getGroup():isEvil() then
			amount = amount + 1
		end
	end
	return amount
end

function BankRobbery:countPolicePeople()
	local amount = 0
	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		if player:getJob() == JobPolice:getSingleton() then
			amount = amount + 1
		end
	end
	return amount
end

function BankRobbery.getRobableBankAtElement(element)
	for k, bankRobbery in ipairs(BankRobbery.Map) do
		if isElementWithinColShape(element, bankRobbery.m_ColShape) then
			return bankRobbery
		end
	end
	return false
end

function BankRobbery.onBombPlace(player)
	local bankRobbery = BankRobbery.getRobableBankAtElement(player)
	if not bankRobbery then
		--player:sendError(_("Du bist nicht in der Nähe einer ausraubbaren Bank", player))
		return false
	end
	
	if not player:getGroup() then
		player:sendError(_("Banken kannst du nur, wenn du Mitglied einer Gruppe bist, ausrauben", player))
		return true
	end
	
	if not player:getGroup():isEvil() then
		player:sendError(_("Als Gruppe mit einem positiven Karma kannst du keine Banküberfälle starten", player))
		return true
	end
	
	local x, y, z = getElementPosition(bankRobbery.m_ColShape)
	if getDistanceBetweenPoints3D(x, y, z, getElementPosition(player)) > 5 then
		player:sendError(_("Du befindest dich nicht nah genug am Tresor", player))
		return true
	end
	
	bankRobbery:installBomb()
	return true
end

function BankRobbery.initializeAll()
	BankRobbery:new(Vector(827.3, 4227.6, 15.75), 0, 1)
end
