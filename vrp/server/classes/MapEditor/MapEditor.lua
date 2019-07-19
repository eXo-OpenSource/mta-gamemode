-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/MapEditor/MapEditor.lua
-- *  PURPOSE:     Map Editor class
-- *
-- ****************************************************************************

MapEditor = inherit(Singleton)
addRemoteEvents{"MapEditor:placeObject", "MapEditor:requestControlForObject"}

function MapEditor:constructor()
    self.m_Objects = {}
    --map loading
    MapLoader:getSingleton():loadAllFromDatabase()
    
    self.m_PlaceObjectBind = bind(self.placeObject, self)
    self.m_ControlRequestBind = bind(self.requestControlForObject, self)
    addEventHandler("MapEditor:placeObject", root, self.m_PlaceObjectBind)
    addEventHandler("MapEditor:requestControlForObject", root, self.m_ControlRequestBind)
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

function MapEditor:requestControlForObject(object, callbackType)
    if object.m_ObjectId then
        if not object.m_ControlledBy then
            if callbackType == "removeControl" then
                object.m_ControlledBy = nil
                return
            end
            
            object.m_ControlledBy = client
            client:triggerEvent("MapEditor:giveControlPermission", object, callbackType, true)
        else
            client:triggerEvent("MapEditor:giveControlPermission", object, callbackType, false)
        end
    end
end