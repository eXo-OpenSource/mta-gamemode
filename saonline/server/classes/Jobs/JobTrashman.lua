-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        server/classes/Jobs/JobTrashman.lua
-- *  PURPOSE:     Trashman job
-- *
-- ****************************************************************************
JobTrashman = inherit(Job)
local MONEY_PER_CAN = 5

function JobTrashman:constructor()
	Job.constructor(self)
	
	addEvent("trashcanCollect", true)
	addEventHandler("trashcanCollect", root, bind(self.Event_trashcanCollect, self))
end

function JobTrashman:start(player)
	local vehicle = createVehicle(408, 2118, -2080, 14.1, 0, 0, 135)
	warpPedIntoVehicle(player, vehicle)
end

function JobTrashman:Event_trashcanCollect(containerNum)
	if not containerNum then return end
	if containerNum > 2 or containerNum < 1 then
		-- Possible cheat attempt | Todo: Add to anticheat
		return
	end
	
	-- Todo: Prevent the player from calling this event too often per specified interval -> Anticheat
	-- Note: It's bad to create the huge amount of trashcans on the server - but...we should do it probably?
	givePlayerMoney(client, containerNum * MONEY_PER_CAN)
end
