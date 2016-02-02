-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/BankRobbery.lua
-- *  PURPOSE:     Bank robbery class
-- *
-- ****************************************************************************
BankRobbery = inherit(Object)
BankRobbery.Map = {}
local MIN_TIME_BETWEEN_ROBBS = 5*60*1000 --30*60*1000
local HOLD_TIME = 60*1000 --4*60*1000

function BankRobbery:constructor(position, rotation, interior, dimension)
	self.m_SafeDoor = createObject(2634, 828.70001, 4227.6001, 15.9, 0, 0, 90)
	self.m_SafeDoor:setInterior(1)

	table.insert(BankRobbery.Map, self)

	self.m_LastRobbery = 0
	self.m_Timer = false
	self.m_BombArea = BombArea:new(position, bind(self.BombArea_Place, self), bind(self.BombArea_Explode, self), HOLD_TIME)
	self.m_ColShape = createColSphere(position, 25)
	self.m_ColShape:setInterior(interior)

	addEventHandler("onColShapeLeave", self.m_ColShape,
		function(element, matchingDimension)
			if getElementType(element) == "player" and matchingDimension then
				-- Stop the countdown if all evil people were eliminated
				if self:countEvilPeople() == 0 then
					if self:countPolicePeople() > 0 then
						-- Give some money to the good people for defending the bank successfully
						for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
							if player:getFaction() and player:getFaction():isStateFaction() then
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
		if player:getFaction() and player:getFaction():isEvilFaction() then
			amount = amount + 1
		end
	end
	return amount
end

function BankRobbery:countPolicePeople()
	local amount = 0
	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		if player:getFaction() and player:getFaction():isStateFaction() then
			amount = amount + 1
		end
	end
	return amount
end

function BankRobbery:BombArea_Place(bombArea, player)
	if not player:getFaction() then
		player:sendError(_("Banken kannst du nur, wenn du Mitglied einer bösen Fraktion bist, ausrauben", player))
		return false
	end

	if getTickCount() < self.m_LastRobbery+MIN_TIME_BETWEEN_ROBBS then
		player:sendError(_("Banken können nur einmal innerhalb von 30min ausgeraubt werden!", player))
		return false
	end

	if not DEBUG and FactionState:getSingleton():countPlayers() < 5 then
		player:sendError(_("Um den Überfall starten zu können, müssen mindestens 5 Polizisten online sein!", player))
		return false
	end

	-- Update last tick
	self.m_LastRobbery = getTickCount()

	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		player:triggerEvent("bankRobberyCountdown", HOLD_TIME/1000)

		local faction = player:getFaction()
		if faction and faction:isEvilFaction() then
			player:reportCrime(Crime.BankRobbery)
		end
	end
	return true
end

function BankRobbery:BombArea_Explode(bombArea)
	-- Give all evil faction money who are within the colshape (amount depends on player count)
	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		if player:getFaction() and player:getFaction():isEvilFaction() then
			faction:giveMoney(400)
			player:giveMoney(400)
		end
	end

	-- Destroy door
	self.m_SafeDoor:destroy()

	-- Clear visibility after some time
	setTimer(function()
		if not isElement(self.m_SafeDoor) then
			self.m_SafeDoor = createObject(2634, 828.70001, 4227.6001, 15.9, 0, 0, 90)
			self.m_SafeDoor:setInterior(1)
		end
	end, MIN_TIME_BETWEEN_ROBBS, 1)
end


function BankRobbery.initializeAll()
	BankRobbery:new(Vector3(827.3, 4227.6, 15.75), 0, 1)
end
