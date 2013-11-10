-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        server/classes/Jobs/Job.lua
-- *  PURPOSE:     Abstract job class
-- *
-- ****************************************************************************
Job = inherit(Object)

function Job:constructor()
	
end

function Job:getId()
	return self.m_Id
end

function Job:setId(Id)
	self.m_Id = Id
end

Job.start = pure_virtual
