-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/vehicles/extensions/tuning/TuningTemplate.lua
-- *  PURPOSE:     Tuning-Template for Performance-Handling
-- *
-- ****************************************************************************
TuningTemplateManager = inherit( Singleton )

addRemoteEvents{"requestHandlingTemplates"}
function TuningTemplateManager:constructor( )
    self.m_Templates = {}
    self:collect()
    addEventHandler("requestHandlingTemplates", root, bind(self.Event_onRequestTemplates, self))
end

function TuningTemplateManager:collect()
    local templateResults =  sql:queryFetch("SELECT * FROM ??_vehicle_performance_templates", sql:getPrefix())
    if templateResults then 
        for id, row in ipairs(templateResults) do 
            if not self.m_Templates[row.Model] then self.m_Templates[row.Model] = {} end
            self:addTemplate( row.Name, fromJSON(row.Data), row.Model, row.Creator, row.Date, row.Id )
        end
    end
end

function TuningTemplateManager:addTemplate( name, data, model, creator, time, id)
    local timeStamp = getRealTime().timestamp
    if not self.m_Templates[model] then 
        self.m_Templates[model] = { }
    end
    if not id or id == 0 then
        sql:queryExec("INSERT INTO ??_vehicle_performance_templates (Name, Model, Data, Creator, Date) VALUES(?, ?, ?, ?, ?)", sql:getPrefix(), name, model, toJSON(data), creator, timeStamp)
        id = sql:lastInsertId()
    end
    if id and id > 0 then
        self.m_Templates[model][name] = TuningTemplate:new(name, model, data, creator, time or timeStamp, id)
    end
end

function TuningTemplateManager:removeTemplate(name, model)
    if self.m_Templates[model] then 
        if self.m_Templates[model][name] then 
            if self.m_Templates[model][name]:getId() > 0 then
                sql:queryExec("DELETE FROM ??_vehicle_performance_templates WHERE Id=?", sql:getPrefix(), self.m_Templates[model][name]:getId())
                self.m_Templates[model][name]:delete()
            end
        end
    end
end

function TuningTemplateManager:applyTemplate( name, vehicle)
    if name and vehicle then 
        if self.m_Templates[vehicle:getModel()] then 
            if self.m_Templates[vehicle:getModel()][name] then 
                self.m_Templates[vehicle:getModel()][name]:applyTemplate(vehicle) 
            end
        end
    end
end

function TuningTemplateManager:Event_onRequestTemplates( )
    client:triggerEvent("onReceiveHandlingTemplates", self.m_Templates)
end

function TuningTemplateManager:destructor() 

end