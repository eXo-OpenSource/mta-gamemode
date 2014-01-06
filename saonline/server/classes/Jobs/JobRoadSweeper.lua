-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobRoadSweeper.lua
-- *  PURPOSE:     Road sweeper job class
-- *
-- ****************************************************************************
JobRoadSweeper = inherit(Job)

function JobRoadSweeper:constructor()
	Job.constructor(self)
	
	VehicleSpawner:new(205.7, -1442.8, 12.3, {"Sweeper"}, 315, function(player) return player:getJob() == self end)
	
	addEvent("sweeperGarbageCollect", true)
	addEventHandler("sweeperGarbageCollect", root, bind(self.Event_sweeperGarbageCollect, self))
end

function JobRoadSweeper:start(player)
	
end

function JobRoadSweeper:Event_sweeperGarbageCollect()
	if client:getJob() ~= self then
		return
	end

	-- Prevent the player from calling this event too often per specified interval -> Anticheat
	-- Note: It's bad to create the huge amount of trashcans on the server - but...we should do it probably?
	local lastTime = client:getData("Sweeper:Last") or -math.huge
	if getTickCount() - lastTime < 400 then
		-- Todo: Report possible cheat attempt
		outputChatBox("Possible cheat attempt!")
		return
	end
	client:setData("Sweeper:Last", getTickCount())
	
	client:giveMoney(3)
	client:giveXP(0.02)
end
