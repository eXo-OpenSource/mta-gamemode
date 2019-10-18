-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/MapEditor/MapEditor.lua
-- *  PURPOSE:     Map Editor class
-- *
-- ****************************************************************************

MapEditor = inherit(Singleton)
addRemoteEvents{"MapEditor:placeObject", "MapEditor:requestControlForObject", "MapEditor:requestMapInfos", "MapEditor:requestObjectInfos", "MapEditor:createNewMap", "MapEditor:setMapStatus",
    "MapEditor:startMapEditing", "MapEditor:removeObject", "MapEditor:removeWorldModel", "MapEditor:restoreWorldModel", "MapEditor:requestEditingPlayers", "MapEditor:forceCloseEditor",
    "MapEditor:changeSettings"}

function MapEditor:constructor()
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
    self.m_WorldModelRemoveBind = bind(self.removeWorldModel, self)
    self.m_WorldModelRestoreBind = bind(self.restoreWorldModel, self)
    self.m_EditingPlayersRequestBind = bind(self.sendEditingPlayersToClient, self)
    self.m_ForceCloseBind = bind(self.forceCloseEditor, self)
    self.m_SettingsChangeBind = bind(self.changeSettings, self)
    self.m_CommandBind = bind(self.startEditing, self)
    
    addEventHandler("MapEditor:placeObject", root, self.m_PlaceObjectBind)
    addEventHandler("MapEditor:requestControlForObject", root, self.m_ControlRequestBind)
    addEventHandler("MapEditor:requestMapInfos", root, self.m_MapRequestBind)
    addEventHandler("MapEditor:requestObjectInfos", root, self.m_ObjectRequestBind)
    addEventHandler("MapEditor:createNewMap", root, self.m_NewMapBind)
    addEventHandler("MapEditor:setMapStatus", root, self.m_MapStatusBind)
    addEventHandler("MapEditor:startMapEditing", root, self.m_StartEditingBind)
    addEventHandler("MapEditor:removeObject", root, self.m_ObjectRemoveBind)
    addEventHandler("MapEditor:removeWorldModel", root, self.m_WorldModelRemoveBind)
    addEventHandler("MapEditor:restoreWorldModel", root, self.m_WorldModelRestoreBind)
    addEventHandler("MapEditor:requestEditingPlayers", root, self.m_EditingPlayersRequestBind)
    addEventHandler("MapEditor:forceCloseEditor", root, self.m_ForceCloseBind)
    addEventHandler("MapEditor:changeSettings", root, self.m_SettingsChangeBind)

    addCommandHandler("mapeditor", self.m_CommandBind)
end

function MapEditor:startEditing(player)
    if player:getRank() < ADMIN_RANK_PERMISSION["openMapEditor"] then
        player:sendError(_("Du bist nicht berechtigt!", client))
        return
    end
    self:setPlayerInEditorMode(player, 1)
    Admin:getSingleton():sendShortMessage(_("%s hat den Map Editor geöffnet!", player, player:getName()))
end

function MapEditor:setPlayerInEditorMode(player, mapId, close)
    if not close then
        player.m_IsInEditorMode = true
        player.m_EditingMapId = mapId or 1
        player:triggerEvent("MapEditor:enableClient", true)
    else
        player.m_IsInEditorMode = nil
        player.m_EditingMapId = nil
        player:triggerEvent("MapEditor:enableClient", false)
    end
end

function MapEditor:getPlayerEditingMap(player)
    return player.m_EditingMapId or 1
end

function MapEditor:placeObject(x, y, z, rx, ry, rz, sx, sy, sz, interior, dimension, model, breakable, collision, doublesided)
    if not MapLoader:getSingleton():getMapStatus(self:getPlayerEditingMap(client)) then
        client:sendError(_("Die Map #%s ist deaktiviert!", client, self:getPlayerEditingMap(client)))
        return
    end

    local object = source
    local objectExisted = false
    if getElementType(object) ~= "object" then
        object = createObject(model, x, y, z, rx, ry, rz)
        objectExisted = false
    else
        objectExisted = true
    end

    object:setPosition(x, y, z)
    object:setRotation(rx, ry, rz)
    object:setScale(sx, sy, sz)
    object:setInterior(interior)
    object:setDimension(dimension)
    object:setModel(model)
    object:setData("breakable", breakable, true)
    if breakable then
        triggerClientEvent("applyBreakableState", object)
    end
    if collision ~= nil then
        object:setCollisionsEnabled(collision)
    end
    if doublesided ~= nil then
        object:setDoubleSided(doublesided)
    end

    
    if objectExisted then
        if MapLoader:getSingleton():updateObject(object) or not MapLoader:getSingleton():isMapSavingEnabled(object.m_MapId) then
            client:sendSuccess(_("Objekt gespeichert!", client))
        else
            client:sendError(_("Fehler beim Speichern des Objektes!", client))
        end
    else
        if MapLoader:getSingleton():addObjectToMap(object, self:getPlayerEditingMap(client), client) then
            client:sendSuccess(_("Objekt erstellt!", client))
        end
    end
end

function MapEditor:removeObject()
    local object = source
    if object and isElement(object) then
        if object.m_MapId then
            if self:getPlayerEditingMap(client) == object.m_MapId then
                if object.m_ControlledBy == client then
                    if MapLoader:getSingleton():removeObject(object) then
                        client:sendSuccess("Objekt entfernt!")
                    end
                else
                    client:sendError(_("Das Objekt wird gerade von %s kontrolliert!", client, object.m_ControlledBy:getName()))
                end
            else
                client:sendError(_("Das Objekt gehört zu Map #%s!", client, object.m_MapId))
            end
        end
    end
end

function MapEditor:removeWorldModel(worldModelId, wX, wY, wZ, wrX, wrY, wrZ, radius, worldLODModelId)
    local interior = client:getInterior()
    local mapId = self:getPlayerEditingMap(client)
    local creator = client:getId()
    local result = MapLoader:getSingleton():removeWorldModel(worldModelId, wX, wY, wZ, wrX, wrY, wrZ, radius, worldLODModelId, interior, mapId, creator)
    if result == 1 then
        client:sendSuccess(_("Das World-Object wurde gelöscht!", client))
    elseif result == 2 then
        client:sendSuccess(_("Das World-Object wurde mitsamt dem low LOD Object gelöscht!", client))
    else
        client:sendError(_("Das World-Object konnte nicht gelöscht werden!", client))
    end
end

function MapEditor:restoreWorldModel(mapId, index)
    if MapLoader:getSingleton():restoreWorldModel(mapId, index) then
        client:sendSuccess(_("Das World-Object wurde wiederhergestellt!", client))
    else
        client:sendError(_("Das World-Object konnte nicht wiederhergestellt werden!", client))
    end
end 

function MapEditor:requestControlForObject(callbackType, currentObject)
    local object = source
    if object.m_MapId then

        if currentObject then
            currentObject.m_ControlledBy = nil
        end

        if callbackType == "removeControl" then
            object.m_ControlledBy = nil
            return
        end

        if object.m_ControlledBy then
            if isElement(object.m_ControlledBy) and object.m_ControlledBy ~= client then
                client:sendError(_("Das Objekt wird gerade von %s kontrolliert!", client, object.m_ControlledBy:getName()))
                return
            end
        end

        if self:getPlayerEditingMap(client) == object.m_MapId then
            object.m_ControlledBy = client
            client:triggerEvent("MapEditor:giveControlPermission", object, callbackType, true)
            return
        else
            client:sendError(_("Dieses Objekt gehört zu Map #%s!", client, object.m_MapId))
        end

    end
end

function MapEditor:sendMapInfosToClient(player)
    if player then
        client = player
    end
    local mapTable = MapLoader:getSingleton():getMapInfos()
    client:triggerEvent("MapEditorMapGUI:sendInfos", mapTable)
end

function MapEditor:sendObjectInfosToClient(id)
    local maps = MapLoader:getSingleton():getMaps()
    local mapremovals = MapLoader:getSingleton():getMapRemovals()
    if maps[id] then
        local transportTableObjects = {}
        local transportTableRemovals = {}
        for key, object in ipairs(maps[id]) do
            transportTableObjects[key] = {object, Account.getNameFromId(object.m_Creator)}
        end
        for key, removal in ipairs(mapremovals[id]) do
            transportTableRemovals[key] = {insertId=removal.insertId, worldModelId=removal.worldModelId, wX=removal.wX, wY=removal.wY, wZ=removal.wZ, wrX=removal.wrX, wrY=removal.wrY, wrZ=removal.wrZ, interior=removal.interior, radius=removal.radius, creator=removal.creator}
            transportTableRemovals[key].creator = Account.getNameFromId(transportTableRemovals[key].creator)
        end
        triggerLatentClientEvent(client, "MapEditorMapGUI:sendObjectsToClient", 50000, false, client, transportTableObjects, transportTableRemovals)
    end
end

function MapEditor:createNewMap(name)
    if client:getRank() < ADMIN_RANK_PERMISSION["createNewMap"] then
        client:sendError(_("Du bist nicht berechtigt!", client))
        return
    end
    
    local result = MapLoader:getSingleton():createNewMap(name, client)
    if result == "invalid name" then 
        client:sendError(_("Du darfst in dem Map Namen nur alphanumerische Zeichen verwenden!", client))
    elseif result == "already exists" then
        client:sendError(_("Es existiert bereits eine Map mit dem Namen \"%s\"!", client, name))
    elseif result == true then
        client:sendSuccess(_("Map mit dem Namen \"%s\" erstellt!", client, name))
        self:sendMapInfosToClient(client)
    end
end

function MapEditor:startMapEditing(player, id)
    if client then
        self:setPlayerInEditorMode(player, id)
        Admin:getSingleton():sendShortMessage(_("%s editiert nun die Map #%s", player, player:getName(), id))
        if client ~= localPlayer then
            player:sendShortMessage(_("%s hat dich zum Mappen eingeladen!", client, client:getName()), "Map Editor: Einladung")
        end
    end
end

function MapEditor:setMapStatus(id, player)
    if not client then
        client = player
    end
    if client:getRank() < ADMIN_RANK_PERMISSION["setMapStatus"] then
        client:sendError("Du bist nicht berechtigt!")
        return
    end

    if MapLoader:getSingleton():getMapStatus(id) then
        if MapLoader:getSingleton():deactivateMap(id) then
            Admin:getSingleton():sendShortMessage(_("%s hat die Map #%s deaktiviert!", client, client:getName(), id))
        else
            client:sendError(_("Du kannst diese Map nicht deaktivieren!", client))
        end
    else
        if MapLoader:getSingleton():loadFromDatabase(id) then
            local result = sql:queryExec("UPDATE ??_map_editor_maps SET Activated = 1 WHERE Id = ?", sql:getPrefix(), id)
            Admin:getSingleton():sendShortMessage(_("%s hat die Map #%s aktiviert!", client, client:getName(), id))
        end
    end
    self:sendMapInfosToClient(client)
end

function MapEditor:sendEditingPlayersToClient()
    local maps = MapLoader:getSingleton():getMapInfos()
    local players = {}
    for key, player in ipairs(getElementsByType("player")) do
        if player.m_IsInEditorMode then
            players[#players+1] = {player:getName(), self:getPlayerEditingMap(player)}
        end
    end
    client:triggerEvent("MapEditorEditingPlayersGUI:sendInfosToClient", maps, players)
end

function MapEditor:forceCloseEditor(name)
    if not name then
        self:setPlayerInEditorMode(client, false, true)
        Admin:getSingleton():sendShortMessage(_("%s hat den Map Editor geschlossen!", client, client:getName()))
        return
    end

    local player = getPlayerFromName(name)
    if player then
        self:setPlayerInEditorMode(player, false, true)
        Admin:getSingleton():sendShortMessage(_("%s hat den Map Editor von %s geschlossen!", client, client:getName(), name))
    end
end

function MapEditor:changeSettings(settingsTable)
    local id = settingsTable[1]
    local name = settingsTable[2]
    local activate = settingsTable[3]
    local saveObjects = settingsTable[4]
    local deactivatable = settingsTable[5]

    if name ~= false then
        local result = MapLoader:getSingleton():setMapName(id, name)
        if result == "invalid name" then 
            client:sendError(_("Du darfst in dem Map Namen nur alphanumerische Zeichen verwenden!", client))
        elseif result == "already exists" then
            client:sendError(_("Es existiert bereits eine Map mit dem Namen \"%s\"!", client, name))
        end
    end

    MapLoader:getSingleton():setMapObjectSavingEnabled(id, saveObjects)
    MapLoader:getSingleton():setMapDeactivatable(id, deactivatable)

    if MapLoader:getSingleton():getMapStatus(id) ~= activate then
        self:setMapStatus(id, client)
    end

    client:sendSuccess("Einstellungen gespeichert!")
end