-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/MapEditor/MapLoader.lua
-- *  PURPOSE:     Map Editor Map Loader class
-- *
-- ****************************************************************************

MapLoader = inherit(Singleton)

function MapLoader:constructor()
    self.m_Maps = {} -- contains objects !sorted by Map!
    self.m_MapInfos = {}
    self.m_Objects = {} -- containts !all! objects
end

function MapLoader:destructor()
    for id, map in ipairs(self.m_Maps) do

        for key, object in ipairs(map) do
            object:destroy()
            
        end
    end
end

function MapLoader:loadAllFromDatabase()
    local maps = sql:queryFetch("SELECT * FROM ??_map_editor_maps", sql:getPrefix())
    for key, mRow in pairs(maps) do
        self.m_MapInfos[mRow.Id] = {mRow.Name, mRow.Creator, mRow.Activated}
        if mRow.Activated == 1 then
            self:loadFromDatabase(mRow.Id)
        end
    end
end

function MapLoader:loadFromDatabase(id)
    if not self.m_Maps[id] then
        self.m_MapInfos[id][3] = 1
        self.m_Maps[id] = {}

        local objects = sql:queryFetch("SELECT * FROM ??_map_editor_objects WHERE MapId = ?", sql:getPrefix(), id)
        for key, oRow in pairs(objects) do
            local index = #self.m_Maps[id]+1
            local globalIndex = #self.m_Objects+1

            self.m_Maps[id][index] = createObject(oRow.Model, oRow.PosX, oRow.PosY, oRow.PosZ, oRow.RotX, oRow.RotY, oRow.RotZ)
            self.m_Maps[id][index]:setScale(oRow.ScaleX, oRow.ScaleY, oRow.ScaleZ)
            self.m_Maps[id][index]:setInterior(oRow.Interior)
            self.m_Maps[id][index]:setDimension(oRow.Dimension)
            self.m_Maps[id][index].m_Creator = oRow.Creator
            self.m_Maps[id][index].m_ObjectId = oRow.Id
            self.m_Maps[id][index].m_MapId = id
            self.m_Maps[id][index]:setData("MapEditor:object", true, true)
            self.m_Maps[id][index]:setData("MapEditor:id", oRow.Id, true)
            self.m_Maps[id][index]:setData("clickable", true, true)

            self.m_Objects[globalIndex] = self.m_Maps[id][index]
        end

        return true
    end
    
    return false
end

function MapLoader:addObjectToMap(object, mapId, creator)
    if self.m_Maps[mapId] then
        local model = object:getModel()
        local x, y, z = getElementPosition(object)
        local rx, ry, rz = getElementRotation(object)
        local sx, sy, sz = getObjectScale(object)
        local interior = object:getInterior()
        local dimension = object:getDimension()
        local creatorId = creator:getId() or 0

        local result, numrows, insertId = sql:queryFetch("INSERT INTO ??_map_editor_objects (Model, PosX, PosY, PosZ, RotX, RotY, RotZ, ScaleX, ScaleY, ScaleZ, Interior, Dimension, MapId, Creator) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
            sql:getPrefix(), model, math.round(x, 4), math.round(y, 4), math.round(z, 4), math.round(rx, 4), math.round(ry, 4), math.round(rz, 4), math.round(sx, 6), math.round(sy, 6), math.round(sz, 6), interior, dimension, mapId, creatorId)
        
        local index = #self.m_Maps[mapId]+1
        self.m_Maps[mapId][index] = object
        self.m_Maps[mapId][index].m_Creator = creatorId
        self.m_Maps[mapId][index].m_ObjectId = insertId
        self.m_Maps[mapId][index].m_MapId = mapId
        self.m_Maps[mapId][index].m_Index = index
        self.m_Maps[mapId][index]:setData("MapEditor:object", true, true)
        self.m_Maps[mapId][index]:setData("MapEditor:id", insertId, true)
        self.m_Maps[mapId][index]:setData("clickable", true, true)

        return true
    end
end

function MapLoader:updateObject(object)
    if object.m_MapId then
        local model = object:getModel()
        local x, y, z = getElementPosition(object)
        local rx, ry, rz = getElementRotation(object)
        local sx, sy, sz = getObjectScale(object)
        local interior = object:getInterior()
        local dimension = object:getDimension()
        local creatorId = client:getId() or 0
        local objectId = object.m_ObjectId

        local result = sql:queryExec("UPDATE ??_map_editor_objects SET Model = ?, PosX = ?, PosY = ?, PosZ = ?, RotX = ?, RotY = ?, RotZ = ?, ScaleX = ?, ScaleY = ?, ScaleZ = ?, Interior = ?, Dimension = ?, Creator = ? WHERE Id = ?", 
            sql:getPrefix(), model, math.round(x, 4), math.round(y, 4), math.round(z, 4), math.round(rx, 4), math.round(ry, 4), math.round(rz, 4), math.round(sx, 6), math.round(sy, 6), math.round(sz, 6), interior, dimension, creatorId, objectId)

        return result
    end
end

function MapLoader:removeObject(object)
    if object.m_ObjectId then
        local result = sql:queryExec("DELETE FROM ??_map_editor_objects WHERE Id = ?", sql:getPrefix(), object.m_ObjectId)
        if self.m_Maps[object.m_MapId][object.m_Index] then

            for key, value in ipairs(self.m_Objects) do
                if self.m_Maps[object.m_MapId][object.m_Index] == value then
                    table.remove(self.m_Objects, key)
                end
            end

            self.m_Maps[object.m_MapId][object.m_Index]:destroy()
            self.m_Maps[object.m_MapId][object.m_Index] = nil

        end
    end
end

function MapLoader:createNewMap(name, creator)
    if not name:match("^[a-zA-Z0-9_.%[%]]*$") then
        creator:sendError(_("Du darfst in dem Map Namen nur alphanumerische Zeichen verwenden!", creator))
        return
    end
    for i = 1, #self.m_MapInfos do
        if self.m_MapInfos[i][1] == name then
            creator:sendError(_("Es existiert bereits eine Map mit dem Namen \"%s\"!", creator, name))
            return
        end
    end

    local result = sql:queryExec("INSERT INTO ??_map_editor_maps (Name, Creator, Activated) VALUES(?, ?, ?)", sql:getPrefix(), name, creator:getId(), 1)
    if result then
        creator:sendSuccess(_("Map mit dem Namen \"%s\" erstellt!", creator, name))
    end
end

function MapLoader:deactivateMap(id)
    if self.m_MapInfos[id] then
        local result = sql:queryExec("UPDATE ??_map_editor_maps SET Activated = 0 WHERE Id = ?", sql:getPrefix(), id)
        self.m_MapInfos[id][3] = 0
        if self.m_Maps[id] then
            for key, object in ipairs(self.m_Maps[id]) do
                object:destroy()

                for k, v in ipairs(self.m_Objects) do
                    if self.m_Maps[id][key] == v then
                        table.remove(self.m_Objects, k)
                    end
                end

            end
        end
        self.m_Maps[id] = nil
        return true
    end
end

function MapLoader:getMapInfos()
    return self.m_MapInfos
end

function MapLoader:getMaps()
    return self.m_Maps
end

function MapLoader:getMapStatus(id)
    return self.m_Maps[id] and true or false
end