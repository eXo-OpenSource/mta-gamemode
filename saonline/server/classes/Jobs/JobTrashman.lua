-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobTrashman.lua
-- *  PURPOSE:     Trashman job
-- *
-- ****************************************************************************
JobTrashman = inherit(Job)
local MONEY_PER_CAN = 5

function JobTrashman:constructor()
	Job.constructor(self)
	
	self.m_DumpArea = createColRectangle(2096.9, -2081.6, 9.8, 10.5) -- 2096.9, -2071.1, 9.8, -10.5
	addEventHandler("onColShapeHit", self.m_DumpArea, bind(JobTrashman.dumpCans, self))
	
	addEvent("trashcanCollect", true)
	addEventHandler("trashcanCollect", root, bind(self.Event_trashcanCollect, self))
end

function JobTrashman:start(player)
	local vehicle = createVehicle(408, 2118, -2080, 14.1, 0, 0, 135)
	warpPedIntoVehicle(player, vehicle)
	
	client:setData("Trashman:Cans", 0)
end

function JobTrashman:checkRequirements(player)
	if not (player:getXP() > 50 and self:getKarma() >= 0) then
		player:sendMessage(_("Für diesen Job benötigst du mindestens 50 Erfahrungspunkte und ein positives Karma", player), 255, 0, 0)
		return false
	end
	return true
end

function JobTrashman:Event_trashcanCollect(containerNum)
	if not containerNum then return end
	if containerNum > 2 or containerNum < 1 then
		-- Possible cheat attempt | Todo: Add to anticheat
		return
	end
	
	-- Prevent the player from calling this event too often per specified interval -> Anticheat
	-- Note: It's bad to create the huge amount of trashcans on the server - but...we should do it probably?
	local lastTime = client:getData("Trashman:LastCan") or -math.huge
	if getTickCount() - lastTime < 2500 then
		-- Todo: Report possible cheat attempt
		outputChatBox("Possible cheat attempt!")
		return
	end
	client:setData("Trashman:LastCan", getTickCount())
	
	-- Increment the can counter now
	client:setData("Trashman:Cans", client:getData("Trashman:Cans") + containerNum)
end

function JobTrashman:dumpCans(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension and hitElement:getJob() == self then
		local numCans = hitElement:getData("Trashman:Cans")
		local moneyAmount = numCans * MONEY_PER_CAN
		
		hitElement:giveMoney(moneyAmount)
		hitElement:giveXP(numCans * 0.01)
		hitElement:giveKarma(numCans * 0.01)
		
		hitElement:sendMessage(_("You got %d$", hitElement), 0, 255, 0, moneyAmount)
		
		hitElement:setData("Trashman:Cans", 0)
		hitElement:triggerEvent("trashcanReset")
	end
end
