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
    self.m_MapRemovals = {} -- containts removed world objects !sorted by Map!
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
        self.m_MapInfos[mRow.Id] = {mRow.Name, Account.getNameFromId(mRow.Creator), mRow.Activated, mRow.SaveObjects}
        if mRow.Activated == 1 then
            self:loadFromDatabase(mRow.Id)
        end
    end
end

function MapLoader:loadFromDatabase(id)
    if not self.m_Maps[id] then
        self.m_MapInfos[id][3] = 1
        self.m_Maps[id] = {}
        self.m_MapRemovals[id] = {}

        local objects = sql:queryFetch("SELECT * FROM ??_map_editor_objects WHERE MapId = ?", sql:getPrefix(), id)
        for key, oRow in pairs(objects) do
            if oRow.Type == 1 then
                local index = #self.m_Maps[id]+1

                self.m_Maps[id][index] = createObject(oRow.Model, oRow.PosX, oRow.PosY, oRow.PosZ, oRow.RotX, oRow.RotY, oRow.RotZ)
                self.m_Maps[id][index]:setScale(oRow.ScaleX, oRow.ScaleY, oRow.ScaleZ)
                self.m_Maps[id][index]:setInterior(oRow.Interior)
                self.m_Maps[id][index]:setDimension(oRow.Dimension)
                self.m_Maps[id][index]:setCollisionsEnabled(toboolean(oRow.Collision))
                self.m_Maps[id][index]:setDoubleSided(toboolean(oRow.Doublesided))
                self.m_Maps[id][index].m_Creator = oRow.Creator
                self.m_Maps[id][index].m_ObjectId = oRow.Id
                self.m_Maps[id][index].m_MapId = id
                self.m_Maps[id][index].m_Index = index
                self.m_Maps[id][index]:setData("MapEditor:object", true, true)
                self.m_Maps[id][index]:setData("MapEditor:id", oRow.Id, true)
                self.m_Maps[id][index]:setData("MapEditor:mapId", id, true)
                self.m_Maps[id][index]:setData("breakable", toboolean(oRow.Breakable), toboolean(oRow.Breakable))

                self:addRef(self.m_Maps[id][index])
            elseif oRow.Type == 0 then
                local index = #self.m_MapRemovals[id]+1

                self.m_MapRemovals[id][index] = {insertId=oRow.Id, worldModelId=oRow.Model, wX=oRow.PosX, wY=oRow.PosY, wZ=oRow.PosZ, wrX=oRow.RotX, wrY=oRow.RotY, wrZ=oRow.RotZ, interior=oRow.Interior, radius=oRow.Radius, creator=oRow.Creator}
                removeWorldModel(oRow.Model, oRow.Radius, oRow.PosX, oRow.PosY, oRow.PosZ, oRow.Interior)
            end
        end
        triggerClientEvent("applyBreakableState", resourceRoot)
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
        local breakable = object:getData("breakable")
        local collision = object:getCollisionsEnabled()
        local doublesided = object:isDoubleSided()
        local creatorId = creator:getId() or 0
        local result, numrows, insertId = false, false, false

        if self:isMapSavingEnabled(mapId) then
            result, numrows, insertId = sql:queryFetch("INSERT INTO ??_map_editor_objects (Type, Model, PosX, PosY, PosZ, RotX, RotY, RotZ, ScaleX, ScaleY, ScaleZ, Interior, Dimension, Breakable, Collision, Doublesided, MapId, Creator) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
                sql:getPrefix(), 1, model, math.round(x, 4), math.round(y, 4), math.round(z, 4), math.round(rx, 4), math.round(ry, 4), math.round(rz, 4), math.round(sx, 6), math.round(sy, 6), math.round(sz, 6), interior, dimension, fromboolean(breakable), fromboolean(collision), fromboolean(doublesided), mapId, creatorId)
        end

        local index = #self.m_Maps[mapId]+1

        self.m_Maps[mapId][index] = object
        self.m_Maps[mapId][index].m_Creator = creatorId
        self.m_Maps[mapId][index].m_ObjectId = insertId
        self.m_Maps[mapId][index].m_MapId = mapId
        self.m_Maps[mapId][index].m_Index = index
        self.m_Maps[mapId][index]:setData("MapEditor:object", true, true)
        self.m_Maps[mapId][index]:setData("MapEditor:id", insertId, true)
        self.m_Maps[mapId][index]:setData("MapEditor:mapId", mapId, true)

        self:addRef(self.m_Maps[mapId][index])

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
        local breakable = object:getData("breakable")
        local collision = object:getCollisionsEnabled()
        local doublesided = object:isDoubleSided()
        local creatorId = client:getId() or 0
        local objectId = object.m_ObjectId

        if self:isMapSavingEnabled(object.m_MapId) then
            local result = sql:queryExec("UPDATE ??_map_editor_objects SET Model = ?, PosX = ?, PosY = ?, PosZ = ?, RotX = ?, RotY = ?, RotZ = ?, ScaleX = ?, ScaleY = ?, ScaleZ = ?, Interior = ?, Dimension = ?, Breakable = ?, Collision = ?, Doublesided = ?, Creator = ? WHERE Id = ?", 
                sql:getPrefix(), model, math.round(x, 4), math.round(y, 4), math.round(z, 4), math.round(rx, 4), math.round(ry, 4), math.round(rz, 4), math.round(sx, 6), math.round(sy, 6), math.round(sz, 6), interior, dimension, fromboolean(breakable), fromboolean(collision), fromboolean(doublesided), creatorId, objectId)
            
            return result
        end
    end
end

function MapLoader:removeObject(object)
    if object.m_ObjectId then
        local result = sql:queryExec("DELETE FROM ??_map_editor_objects WHERE Id = ?", sql:getPrefix(), object.m_ObjectId)
        if self.m_Maps[object.m_MapId][object.m_Index] then
            local mapId = object.m_MapId
            local index = object.m_Index
            
            self:removeRef(self.m_Maps[mapId][index])

            self.m_Maps[mapId][index]:destroy()
            table.remove(self.m_Maps[mapId], index)
            for key, obj in ipairs(self.m_Maps[mapId]) do
                obj.m_Index = key
            end

            return true
        end
    end
end

function MapLoader:removeWorldModel(worldModelId, wX, wY, wZ, wrX, wrY, wrZ, radius, worldLODModelId, interior, mapId, creator)
    if removeWorldModel(worldModelId, radius, wX, wY, wZ, interior) then
        local index = #self.m_MapRemovals[mapId]+1
        local result, numrows, insertId = sql:queryFetch("INSERT INTO ??_map_editor_objects (Type, Model, PosX, PosY, PosZ, RotX, RotY, RotZ, Interior, MapId, Radius, Creator) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
            sql:getPrefix(), 0, worldModelId, wX, wY, wZ, wrX, wrY, wrZ, interior, mapId, radius, creator)

        self.m_MapRemovals[mapId][index] = {insertId=insertId, worldModelId=worldModelId, wX=wX, wY=wY, wZ=wZ, wrX=wrX, wrY=wrY, wrZ=wrZ, interior=interior, radius=radius, creator=creator}
    else 
        return false
    end
    if worldLODModelId and worldLODModelId ~= 0 then
        if removeWorldModel(worldLODModelId, radius, wX, wY, wZ, interior) then
            local index = #self.m_MapRemovals[mapId]+1
            local result, numrows, insertId = sql:queryFetch("INSERT INTO ??_map_editor_objects (Type, Model, PosX, PosY, PosZ, RotX, RotY, RotZ, Interior, MapId, Radius, Creator) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                sql:getPrefix(), 0, worldLODModelId, wX, wY, wZ, wrX, wrY, wrZ, interior, mapId, radius, creator)

            self.m_MapRemovals[mapId][index] = {insertId=insertId, worldModelId=worldModelId, wX=wX, wY=wY, wZ=wZ, wrX=wrX, wrY=wrY, wrZ=wrZ, interior=interior, radius=radius, creator=creator}
            return 2
        end
    end
    return 1
end

function MapLoader:restoreWorldModel(mapId, index)
    local insertId = self.m_MapRemovals[mapId][index].insertId
    local worldModelId = self.m_MapRemovals[mapId][index].worldModelId
    local wX = self.m_MapRemovals[mapId][index].wX
    local wY = self.m_MapRemovals[mapId][index].wY
    local wZ = self.m_MapRemovals[mapId][index].wZ
    local interior = self.m_MapRemovals[mapId][index].interior

    if restoreWorldModel(worldModelId, 0.1, wX, wY, wZ, interior) then
        self.m_MapRemovals[mapId][index] = nil
        local result = sql:queryExec("DELETE FROM ??_map_editor_objects WHERE Id = ?", sql:getPrefix(), insertId)
        return true
    end
end

function MapLoader:addRef(object)
    self.m_Objects[#self.m_Objects+1] = object
end

function MapLoader:removeRef(object)
    for key, value in ipairs(self.m_Objects) do
        if object == value then
            table.remove(self.m_Objects, key)
        end
    end
end

function MapLoader:createNewMap(name, creator)
    if not name:match("^[a-zA-Z0-9_.%[%]]*$") then
        return "invalid name"
    end
    for i = 1, #self.m_MapInfos do
        if self.m_MapInfos[i][1] == name then
            return "already exists"
        end
    end

    local result, numrows, insertId = sql:queryFetch("INSERT INTO ??_map_editor_maps (Name, Creator, SaveObjects, Activated) VALUES(?, ?, ?, ?)", sql:getPrefix(), name, creator:getId(), 1, 1)
    if result then
        self.m_MapInfos[insertId] = {name, creator:getName(), 1, 1}
        self.m_Maps[insertId] = {}
        self.m_MapRemovals[insertId] = {}
        return true
    end
end

function MapLoader:deactivateMap(id)
    if self.m_MapInfos[id] then
        local result = sql:queryExec("UPDATE ??_map_editor_maps SET Activated = 0 WHERE Id = ?", sql:getPrefix(), id)
        self.m_MapInfos[id][3] = 0
        if self.m_Maps[id] then
            for key, object in ipairs(self.m_Maps[id]) do
                object:destroy()

                self:removeRef(object)

            end
        end
        self.m_Maps[id] = nil
        if self.m_MapRemovals[id] then
            for index, tbl in pairs(self.m_MapRemovals[id]) do
                local worldModelId = self.m_MapRemovals[id][index].worldModelId
                local wX = self.m_MapRemovals[id][index].wX
                local wY = self.m_MapRemovals[id][index].wY
                local wZ = self.m_MapRemovals[id][index].wZ
                local interior = self.m_MapRemovals[id][index].interior
                restoreWorldModel(worldModelId, 0.1, wX, wY, wZ, interior)
            end
        end

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

function MapLoader:isMapSavingEnabled(id)
    return self.m_MapInfos[id] and toboolean(self.m_MapInfos[id][4])
end

function MapLoader:getMapRemovals()
    return self.m_MapRemovals
end