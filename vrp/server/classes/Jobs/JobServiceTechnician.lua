-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobServiceTechnician.lua
-- *  PURPOSE:     Service technician job class
-- *
-- ****************************************************************************
JobServiceTechnician = inherit(Job)

function JobServiceTechnician:constructor()
    self.m_Tasks = {JobServiceTechnicianTaskQuestion}

    AutomaticVehicleSpawner:new(413, 904.37, -1454.68, 13.5, 7, 0, 270, nil, self)
end

function JobServiceTechnician:start(player)
    local taskClass = self.m_Tasks[math.random(1, #self.m_Tasks)]
    local task = taskClass:new(player)
    player.ServiceTechnician_Task = task
end

function JobServiceTechnician:stop(player)
    player.ServiceTechnician_Task:delete()
end
