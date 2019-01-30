-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/DrugFactories/Factories/WeedFactory.lua
-- *  PURPOSE:     Weed Factory class
-- *
-- ****************************************************************************
WeedFactory = inherit(DrugFactory)

function WeedFactory:constructor(id, type, owner, progress, managerPos, workingstations, workers, lastattack, x, y, z, rot, dim, int, intX, intY, intZ, intRot, color)
    self.WeedGrowStations = {}
    self:create(id, type, owner, progress, managerPos, workingstations, workers, lastattack, x, y, z, rot, dim, int, intX, intY, intZ, intRot, color)
end

function WeedFactory:destructor()
    self:destroyWeedGrowStations()
end

function WeedFactory:startWorking()
    local amount = self:getWorkingStationCount()
    if amount > #WEED_GROW_STATIONS then amount = #WEED_GROW_STATIONS end
    for i = 1, amount do
        self:createWeedGrowStation(WEED_GROW_STATIONS[i][1], WEED_GROW_STATIONS[i][2], WEED_GROW_STATIONS[i][3], WEED_GROW_STATIONS[i][4], self:getWorkerCount(), self.m_Interior, self.m_Dimension)
    end
end

function WeedFactory:destroyWeedGrowStations()
    for key, table in ipairs(self.WeedGrowStations) do
        for tablekey, object in ipairs(table) do
            object:destroy()
        end
    end
    self.WeedGrowStations = {}
end

function WeedFactory:createWeedGrowStation(x, y, z, rot, workers, interior, dimension)
    local index = #self.WeedGrowStations + 1
    self.WeedGrowStations[index] = {}
    local table_index = 1
    for key, table in ipairs(WEED_GROW_STATION_OFFSETS) do
        self.WeedGrowStations[index][table_index] = createObject(table.model, x+table.posX, y+table.posY, z+table.posZ, 0+table.rotX, 0+table.rotY, 0+table.rotZ)
        self.WeedGrowStations[index][table_index]:setDoubleSided(table.doublesided)
        self.WeedGrowStations[index][table_index]:setInterior(interior)
        self.WeedGrowStations[index][table_index]:setDimension(dimension)

        if type(table.scale) == "table" then
            self.WeedGrowStations[index][table_index]:setScale(unpack(table.scale))
        else
            self.WeedGrowStations[index][table_index]:setScale(table.scale)
        end
        if table_index > 1 then
            self.WeedGrowStations[index][table_index]:attach(self.WeedGrowStations[index][1], table.posX, table.posY, table.posZ, table.rotX, table.rotY, table.rotZ)
        end
        table_index = table_index + 1
    end
    if self.WeedGrowStations[index][1] then
        self.WeedGrowStations[index][1]:setRotation(0, 0, rot)
    end
    for key, table in ipairs(WEED_WORKERS) do
        if table[1] == index then
            if factory:getWorkerCount() <= key then
                local npcIndex = #self.WeedGrowStations[index] + 1
                local skinID = WEED_WORKER_SKINS[math.random(1, #WEED_WORKER_SKINS)]
                local random = math.random(1, #WEED_WORKER_ANIMATIONS)
                local block, animation = WEED_WORKER_ANIMATIONS[random][1], WEED_WORKER_ANIMATIONS[random][2]
                self.WeedGrowStations[index][npcIndex] = NPC:new(skinID, table[2], table[3], table[4], table[5])
                self.WeedGrowStations[index][npcIndex]:setInterior(interior)
                self.WeedGrowStations[index][npcIndex]:setDimension(dimension)
                self.WeedGrowStations[index][npcIndex]:setImmortal(true)
                self.WeedGrowStations[index][npcIndex]:setAnimation(block, animation, -1, true, false, false, false)
                self.WeedGrowStations[index][npcIndex]:setFrozen(true)
            end
        end
    end
end

function WeedFactory:getMaxWorkingStations()
    return #WEED_GROW_STATIONS
end

function WeedFactory:getMaxWorkers()
    return #WEED_WORKERS
end