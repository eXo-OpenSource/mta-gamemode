-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/vehicles/extensions/tuning/TuningTemplate.lua
-- *  PURPOSE:     Tuning-Template for Performance-Handling
-- *
-- ****************************************************************************
TuningTemplateManager = inherit( Singleton )

addRemoteEvents{"requestHandlingTemplates", "applyHandlingTemplate", "saveHandlingTemplate", "deleteHandlingTemplate"}
function TuningTemplateManager:constructor( )
    self.m_Templates = {}
    self:collect()
    addEventHandler("requestHandlingTemplates", root, bind(self.Event_onRequestTemplates, self))
    addEventHandler("applyHandlingTemplate", root, bind(self.Event_onApplyTemplate, self))
    addEventHandler("saveHandlingTemplate", root, bind(self.Event_onSaveTemplate, self))
    addEventHandler("deleteHandlingTemplate", root, bind(self.Event_onDeleteTemplate, self))
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

function TuningTemplateManager:overwriteTemplate(name, data, model, creator)
    if self.m_Templates[model] then 
        if self.m_Templates[model][name] then 
            local timeStamp = getRealTime().timestamp
            local id = self.m_Templates[model][name]:getId()
            sql:queryExec("UPDATE ??_vehicle_performance_templates SET Data = ?, Creator = ?, Date = ? WHERE Id = ?", sql:getPrefix(), toJSON(data), creator, timeStamp, id)
            self.m_Templates[model][name] = nil
            self.m_Templates[model][name] = TuningTemplate:new(name, model, data, creator, time or timeStamp, id)
        end
    end
end

function TuningTemplateManager:removeTemplate(name, model)
    if self.m_Templates[model] then 
        if self.m_Templates[model][name] then 
            if self.m_Templates[model][name]:getId() > 0 then
                sql:queryExec("DELETE FROM ??_vehicle_performance_templates WHERE Id=?", sql:getPrefix(), self.m_Templates[model][name]:getId())
                self.m_Templates[model][name]:delete()
                self.m_Templates[model][name] = nil
                return true
            end
        end
    end
    return false
end

function TuningTemplateManager:applyTemplate( name, vehicle)
    if name and vehicle then 
        if self.m_Templates[vehicle:getModel()] then 
            if self.m_Templates[vehicle:getModel()][name] then 
                self.m_Templates[vehicle:getModel()][name]:applyTemplate(vehicle) 
                return true
            end
        end
    end
    return false
end

function TuningTemplateManager:Event_onApplyTemplate(name, model)
    if self.m_Templates[model] then 
        if self.m_Templates[model][name] then
            local vehicle = client:getOccupiedVehicle() or client:getContactElement()
            if vehicle and isElement(vehicle) and getElementType(vehicle) == "vehicle" then 
                if self.m_Templates[model][name]:getVehicle() == model then 
                    if self:applyTemplate(name, vehicle) then 
                        playSoundFrontEnd(client, 46)
                        client:sendInfo(_("Vorlage wurde angewendet!", client))
                    else 
                        client:sendError(_("Vorlage nicht kompatibel mit diesem Fahrzeug!", client))
                    end
                else 
                    client:sendError(_("Vorlage nicht kompatibel mit diesem Fahrzeug!", client))
                end
            end
        else 
            client:sendError(_("Vorlage nicht kompatibel mit diesem Fahrzeug!", client))
        end
    else 
        client:sendError(_("Vorlage nicht kompatibel mit diesem Fahrzeug!", client))
    end
end

function TuningTemplateManager:Event_onSaveTemplate(name, model, vehicle, forceSave)
    vehicle = client:getOccupiedVehicle() or client:getContactElement()
    if vehicle and isElement(vehicle) and getElementType(vehicle) == "vehicle" then
        if forceSave then 
            if vehicle:getModel() == model then 
                self:overwriteTemplate(name, vehicle:getHandling(), vehicle:getModel(), client:getId())
                client:sendInfo(_("Vorlage (%s) wurde überschrieben!", client, name))
                client:triggerEvent("onReceiveHandlingTemplates", self.m_Templates)
                return
            else 
                client:sendError(_("Vorlage (%s) ist nicht kompatibel mit diesem Modell!", client, name))
                return
            end
        end
        self:addTemplate(name, data, vehicle:getModel(), client:getId())
        client:sendInfo(_("Vorlage (%s) wurde erstellt!", client, name))
        client:triggerEvent("onReceiveHandlingTemplates", self.m_Templates)
    end
end

function TuningTemplateManager:Event_onDeleteTemplate(name, model)
    if self:removeTemplate(name, model) then
        client:sendInfo(_("Vorlage (%s) wurde gelöscht!", client, name))
        client:triggerEvent("onReceiveHandlingTemplates", self.m_Templates)
        return
    end
    client:sendError(_("Vorlage (%s) konnte nicht gelöscht werden!", client, name))
end


function TuningTemplateManager:Event_onRequestTemplates( )
    client:triggerEvent("onReceiveHandlingTemplates", self.m_Templates)
end

function TuningTemplateManager:destructor() 

end