-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobRoadSweeper.lua
-- *  PURPOSE:     Road sweeper job class
-- *
-- ****************************************************************************
JobRoadSweeper = inherit(Job)

function JobRoadSweeper:constructor()
	Job.constructor(self, 2659, -1427, 30, "files/images/Blips/Roadsweeper.png", "files/images/Jobs/HeaderTrashman.png", LOREM_IPSUM)
	
	self.m_Rubbish = {}
end

function JobRoadSweeper:start(player)
	for k, v in ipairs(JobRoadSweeper.Rubbish) do
		local x, y, z = unpack(v)
		local object = createObject(math.random(2670, 2677), x, y, z)
		table.insert(self.m_Rubbish, object)
	end
end

JobRoadSweeper.Rubbish = {
	{2461.5, -1656, 12.4},
	{2441.5, -1656, 12.4},
	{2431.5, -1656, 12.4},
	{2421.5, -1656, 12.4},
	{2411.5, -1656, 12.4},
	{2401.5, -1656, 12.4},
}
