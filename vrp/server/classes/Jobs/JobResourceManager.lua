-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobResourceManager.lua
-- *  PURPOSE:     Job-Resource Manager
-- *
-- ****************************************************************************

JobResourceManager = inherit(Singleton)

function JobResourceManager:constructor() 
	JobResourceEvaluate:getSingleton():startAsyncEvaluate()
end

function JobResourceManager:destructor()

end