-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/DrugFactories/Factories/CocaineFactory.lua
-- *  PURPOSE:     Cocaine Factory class
-- *
-- ****************************************************************************
CocaineFactory = inherit(DrugFactory)

function CocaineFactory:constructor(id, type, owner, progress, managerPos, workingstations, workers, lastattack, x, y, z, rot, dim, int, intX, intY, intZ, intRot, color)
    self.CocaineStations = {}
    self:create(id, type, owner, progress, managerPos, workingstations, workers, lastattack, x, y, z, rot, dim, int, intX, intY, intZ, intRot, color)
end

function CocaineFactory:destructor()
    self:destroyCocaineStations()
end

function CocaineFactory:startWorking()
    local amount = self:getWorkingStationCount()
    if amount > #COCAINE_STATIONS then amount = #COCAINE_STATIONS end
    for i = 1, amount do
        self:createCocaineStation(COCAINE_STATIONS[i][1], COCAINE_STATIONS[i][2], COCAINE_STATIONS[i][3], COCAINE_STATIONS[i][4], self:getWorkerCount(), self.m_Interior, self.m_Dimension)
    end
end

function CocaineFactory:destroyCocaineStations()
    for key, table in ipairs(self.CocaineStations) do
        for tablekey, object in ipairs(table) do
            object:destroy()
        end
    end
    self.CocaineStations = {}
end

function CocaineFactory:createCocaineStation(x, y, z, rotate, workers, interior, dimension)
    local index = #self.CocaineStations + 1
    local skinID = math.random(144, 146)
    self.CocaineStations[index] = {}
    self.CocaineStations[index][1] = createObject(934, x, y, z, 0, 0, 270)
    self.CocaineStations[index][1]:setInterior(interior)
    self.CocaineStations[index][1]:setDimension(dimension)
    if rotate == true then
        self.CocaineStations[index][2] = createObject(941, x, y-1.56, z-0.85)
        if index <= workers then
            self.CocaineStations[index][3] = NPC:new(skinID, x, y-2.56, z-0.5, 0)
        end
    else
        self.CocaineStations[index][2] = createObject(941, x, y+1.56, z-0.85)
        if index <= workers then
            self.CocaineStations[index][3] = NPC:new(skinID, x, y+2.56, z-0.5, 180)
        end
    end
    self.CocaineStations[index][2]:setInterior(interior)
    self.CocaineStations[index][2]:setDimension(dimension)

    if isElement(self.CocaineStations[index][3]) then
        self.CocaineStations[index][3]:setInterior(interior)
        self.CocaineStations[index][3]:setDimension(dimension)
        self.CocaineStations[index][3]:setImmortal(true)
        self.CocaineStations[index][3]:setAnimation("FOOD", "SHP_Tray_Pose", -1, true, false, false, false)
        self.CocaineStations[index][3]:setFrozen(true)
    end
end

function CocaineFactory:getMaxWorkingStations()
    return #COCAINE_STATIONS
end

function CocaineFactory:getMaxWorkers()
    return #COCAINE_STATIONS
end