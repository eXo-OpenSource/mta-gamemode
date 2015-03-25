-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/BankRobbery.lua
-- *  PURPOSE:     Bank robbery class
-- *
-- ****************************************************************************
BankRobbery = inherit(Object)
BankRobbery.Map = {}
local MIN_TIME_BETWEEN_ROBBS = 5000 --30*60*1000
local HOLD_TIME = 20*1000 --4*60*1000

function BankRobbery:constructor(position, rotation, interior, dimension)
	--self.m_Safe = createObject(2332, position.x, position.y, position.z, 0, 0, rotation)
	--setElementInterior(self.m_Safe, interior)
	--setElementDimension(self.m_Safe, dimension or 0)

	table.insert(BankRobbery.Map, self)

	self.m_LastRobbery = 0
	self.m_Timer = false
	self.m_BombArea = BombArea:new(position, bind(self.BombArea_Place, self), bind(self.BombArea_Explode, self), HOLD_TIME)
	self.m_ColShape = createColSphere(position, 25)
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

							player:triggerEvent("bankRobberyCountdownStop")
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

function BankRobbery:BombArea_Place(bombArea, player)
	if not player:getGroup() then
		player:sendError(_("Banken kannst du nur, wenn du Mitglied einer Gruppe bist, ausrauben", player))
		return false
	end

	if getTickCount() < self.m_LastRobbery+MIN_TIME_BETWEEN_ROBBS then
		player:sendError(_("Banken können nur einmal innerhalb von 30min ausgeraubt werden!", player))
		return false
	end

	if not DEBUG and JobPolice:getSingleton():countPlayers() < 5 then
		player:sendError(_("Um den Überfall starten zu können, müssen mindestens 5 Polizisten online sein!", player))
		return false
	end

	-- Update last tick
	self.m_LastRobbery = getTickCount()

	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		player:triggerEvent("bankRobberyCountdown", HOLD_TIME/1000)

		local group = player:getGroup()
		if group and group:isEvil() then
			player:reportCrime(Crime.BankRobbery)
		end
	end
	return true
end

function BankRobbery:BombArea_Explode(bombArea)
	-- Give all groups money who are within the colshape (amount depends on player count)
	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		local group = player:getGroup()
		if group and group:isEvil() then
			group:giveMoney(400)
			player:giveMoney(400)
		end
	end
end


function BankRobbery.initializeAll()
	BankRobbery:new(Vector3(827.3, 4227.6, 15.75), 0, 1)
end
