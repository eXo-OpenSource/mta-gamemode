-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/vehicles/extensions/tuning/TuningTemplate.lua
-- *  PURPOSE:     Tuning-Template for Performance-Handling
-- *
-- ****************************************************************************
TuningTemplate = inherit( Object )

function TuningTemplate:constructor( name, model, data, creator, time, id)
    self.m_Name = name
    self.m_Model = model
    self.m_Tunings = data
    self.m_Creator = creator
    self.m_CreatorName = Account.getNameFromId(creator)
    self.m_Time = time
    self.m_Id = id
end

function TuningTemplate:applyTemplate(vehicle)
    if not vehicle.m_Tunings then 
        vehicle.m_Tunings = VehicleTuning:new(vehicle)
    end
    for property, value in pairs(self.m_Tunings) do
        vehicle.m_Tunings:setTuningProperty(property, value)
    end
    vehicle.m_Tunings.m_TuningTemplate = self.m_Name
    vehicle.m_Tunings:saveTuningKits()
    vehicle:setTemplate(self.m_Id)
    vehicle:updateTemplate()
end

function TuningTemplate:getId()
    return self.m_Id
end

function TuningTemplate:getVehicle()
    return self.m_Model
end

function TuningTemplate:getName()
    return self.m_Name
end

function TuningTemplate:destructor() 

end