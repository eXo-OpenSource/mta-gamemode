-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/MapEditor/MapEditor.lua
-- *  PURPOSE:     Map Editor class
-- *
-- ****************************************************************************

MapEditor = inherit(Singleton)
addRemoteEvents{"MapEditor:placeObject", "MapEditor:requestControlForObject", "MapEditor:requestMapInfos", "MapEditor:requestObjectInfos", "MapEditor:createNewMap", "MapEditor:setMapStatus",
    "MapEditor:startMapEditing", "MapEditor:removeObject"}

function MapEditor:constructor()
    self.m_Objects = {}
    --map loading
    MapLoader:getSingleton():loadAllFromDatabase()
    
    self.m_PlaceObjectBind = bind(self.placeObject, self)
    self.m_ControlRequestBind = bind(self.requestControlForObject, self)
    self.m_MapRequestBind = bind(self.sendMapInfosToClient, self)
    self.m_ObjectRequestBind = bind(self.sendObjectInfosToClient, self)
    self.m_NewMapBind = bind(self.createNewMap, self)
    self.m_MapStatusBind = bind(self.setMapStatus, self)
    self.m_StartEditingBind = bind(self.startMapEditing, self)
    self.m_ObjectRemoveBind = bind(self.removeObject, self)
    
    addEventHandler("MapEditor:placeObject", root, self.m_PlaceObjectBind)
    addEventHandler("MapEditor:requestControlForObject", root, self.m_ControlRequestBind)
    addEventHandler("MapEditor:requestMapInfos", root, self.m_MapRequestBind)
    addEventHandler("MapEditor:requestObjectInfos", root, self.m_ObjectRequestBind)
    addEventHandler("MapEditor:createNewMap", root, self.m_NewMapBind)
    addEventHandler("MapEditor:setMapStatus", root, self.m_MapStatusBind)
    addEventHandler("MapEditor:startMapEditing", root, self.m_StartEditingBind)
    addEventHandler("MapEditor:removeObject", root, self.m_ObjectRemoveBind)
end

function MapEditor:setPlayerInEditorMode(player, mapId)
    player.m_IsInEditorMode = true
    player.m_EditingMapId = mapId or -1
    player:triggerEvent("MapEditor:enableClient", true)
end

function MapEditor:getPlayerEditingMap(player)
    return player.m_EditingMapId
end

function MapEditor:placeObject(x, y, z, rx, ry, rz, sx, sy, sz, interior, dimension, model)
    local object = source
    local saveObject = false
    local objectExisted = false
    if getElementType(object) ~= "object" then
        object = createObject(model, x, y, z, rx, ry, rz)
        objectExisted = false
        if self:getPlayerEditingMap(client) ~= -1 then
            saveObject = true
        end
    else
        if self:getPlayerEditingMap(client) ~= -1 then
            objectExisted = true
            saveObject = true
        end
    end

    object:setPosition(x, y, z)
    object:setRotation(rx, ry, rz)
    object:setScale(sx, sy, sz)
    object:setInterior(interior)
    object:setDimension(dimension)
    object:setModel(model)

    if saveObject then
        if objectExisted then
            MapLoader:getSingleton():updateObject(object)
        else
            MapLoader:getSingleton():addObjectToMap(object, self:getPlayerEditingMap(client), client) 
        end
    end
end

function MapEditor:removeObject()
    local object = source
    if object and isElement(object) then
        if object.m_MapId then
            MapLoader:getSingleton():removeObject(object)
            return
        end
        object:destroy()
    end
end

function MapEditor:requestControlForObject(object, callbackType)
    if object.m_ObjectId then

        if callbackType == "removeControl" then
            object.m_ControlledBy = nil
            return
        end

        if object.m_ControlledBy then
            if isElement(object.m_ControlledBy) then
                client:sendError(_("Das Objekt wird gerade von %s kontrolliert!", client, object.m_ControlledBy:getName()))
                return
            end
        end

        if self:getPlayerEditingMap(client) == object.m_MapId then
            object.m_ControlledBy = client
            client:triggerEvent("MapEditor:giveControlPermission", object, callbackType, true)
            return
        end

    end
end

function MapEditor:sendMapInfosToClient()
    local mapTable = MapLoader:getSingleton():getMapInfos()
    client:triggerEvent("MapEditorMapGUI:sendInfos", mapTable)
end

function MapEditor:sendObjectInfosToClient(id)
    local maps = MapLoader:getSingleton():getMaps()
    if maps[id] then
        local transportTable = {}
        for key, object in ipairs(maps[id]) do
            transportTable[key] = {object, Account.getNameFromId(object.m_Creator)}
        end
        triggerLatentClientEvent(client, "MapEditorMapGUI:sendObjectsToClient", 50000, false, client, transportTable)
    end
end

function MapEditor:createNewMap(name)
    if client:getRank() < RANK.Administrator then
        client:sendError("Du bist nicht berechtigt!")
        return
    end
    MapLoader:getSingleton():createNewMap(name, client)
    self:sendMapInfosToClient()
end

function MapEditor:startMapEditing(player, id)
    if client then
        self:setPlayerInEditorMode(player, id)
        Admin:getSingleton():sendShortMessage(("%s editiert nun die Map #%s"):format(player:getName(), id))
    end
end

function MapEditor:setMapStatus(id)
    if MapLoader:getSingleton():getMapStatus(id) then
        if MapLoader:getSingleton():deactivateMap(id) then
            Admin:getSingleton():sendShortMessage(("%s hat die Map #%s deaktiviert!"):format(client:getName(), id))
        end
    else
        if MapLoader:getSingleton():loadFromDatabase(id) then
            local result = sql:queryExec("UPDATE ??_map_editor_maps SET Activated = 1 WHERE Id = ?", sql:getPrefix(), id)
            Admin:getSingleton():sendShortMessage(("%s hat die Map #%s aktiviert!"):format(client:getName(), id))
        end
    end
    self:sendMapInfosToClient()
end