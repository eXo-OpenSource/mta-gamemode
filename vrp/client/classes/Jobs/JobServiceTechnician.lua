-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobServiceTechnician.lua
-- *  PURPOSE:     Service technician job class
-- *
-- ****************************************************************************
JobServiceTechnician = inherit(Job)

function JobServiceTechnician:constructor()
    Job.constructor(self, 900.80, -1447.34, 13.29, "ServiceTechnician.png", "files/images/Jobs/HeaderServiceTechnician.png", _"Service-Techniker", _"Dies ist der Service Techniker")

end

function JobServiceTechnician:start()

end
