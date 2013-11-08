-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        server/classes/Jobs/Job.lua
-- *  PURPOSE:     Abstract job class
-- *
-- ****************************************************************************
Job = inherit(Object)
Job.Map = {}

function Job:constructor()
	table.insert(Job.Map, self)
end

Job.start = pure_virtual
