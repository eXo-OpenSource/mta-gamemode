-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobServiceTechnicianTask.lua
-- *  PURPOSE:     Super service technician task class
-- *
-- ****************************************************************************
JobServiceTechnicianTask = inherit(Object)

function JobServiceTechnicianTask:virtual_constructor(player)
    local position = self:getRandomCoordinates()
    self.m_Marker = createMarker(position, "cylinder", 2, 255, 255, 0, 200, player)
    self.m_Blip = Blip:new("Waypoint.png", position.x, position.y, player)

    addEventHandler("onMarkerHit", self.m_Marker, function(hitElement, matchingDimension)
        if player == hitElement and matchingDimension then
            local vehicle = hitElement:getOccupiedVehicle()
            if vehicle then
                vehicle:setFrozen(true)
                self:start(hitElement)
            end
        end
    end
    )
end

function JobServiceTechnicianTask:destructor()
    self.m_Marker:destroy()
    self.m_Blip:delete()
end

function JobServiceTechnicianTask:getRandomCoordinates()
    return Vector3(self.ms_Coordinates[math.random(1, #self.ms_Coordinates)])
end

JobServiceTechnicianTask.start = pure_virtual

JobServiceTechnicianTask.ms_Coordinates = {
    {929.06, -1499.16, 13.60},
    {970.35, -1481.99, 13.60},
    --[[{x, y, z},
    {x, y, z},
    {x, y, z},
    {x, y, z},
    {x, y, z}]]
}
