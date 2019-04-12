-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/DrugFactories/Factories/HeroinFactory.lua
-- *  PURPOSE:     Heroin Factory class
-- *
-- ****************************************************************************
HeroinFactory = inherit(DrugFactory)

function HeroinFactory:constructor(id, type, owner, progress, managerPos, workingstations, workers, lastattack, x, y, z, rot, dim, int, intX, intY, intZ, intRot, color)
    self.HeroinStations = {}
    self:create(id, type, owner, progress, managerPos, workingstations, workers, lastattack, x, y, z, rot, dim, int, intX, intY, intZ, intRot, color)

    self.m_ClickBind = bind(self.onVentClick, self)
    self:createVentEntries()
end

function HeroinFactory:destructor()

end

function HeroinFactory:startWorking()
    local amount = self:getWorkingStationCount()
    if amount > #HEROIN_GROW_STATIONS then amount = #HEROIN_GROW_STATIONS end
    for i = 1, amount do
        self:createHeroinStation(HEROIN_GROW_STATIONS[i][1], HEROIN_GROW_STATIONS[i][2], HEROIN_GROW_STATIONS[i][3], HEROIN_GROW_STATIONS[i][4], HEROIN_GROW_STATIONS[i][5], self.m_Interior, self.m_Dimension)
    end
end

function HeroinFactory:destroyHeroinStations()
    for key, table in ipairs(self.HeroinStations) do
        for tablekey, object in ipairs(table) do
            object:destroy()
        end
    end
    self.HeroinStations = {}
end

function HeroinFactory:createHeroinStation(x, y, z, rotation, rotate, interior, dimension)
    local index = #self.HeroinStations + 1
    self.HeroinStations[index] = {}
    local table_index = 1
    for key, table in ipairs(HEROIN_GROW_STATION_OFFSETS) do
        self.HeroinStations[index][table_index] = createObject(table.model, x+table.posX, y+table.posY, z+table.posZ)
        self.HeroinStations[index][table_index]:setScale(table.scale)
        table_index = table_index + 1
    end

    if rotate == true then
        lockerX = 0.53
    else
        lockerX = -5.47
    end
    self.HeroinStations[index][table_index] = createObject(3389, x+lockerX, y+2.03, z-0.11, 0, 0, 90)

    for i = 1, #self.HeroinStations[index] do
        self.HeroinStations[index][i]:setInterior(interior)
        self.HeroinStations[index][i]:setDimension(dimension)
        if i > 1 then
            if i == #self.HeroinStations[index] then
                rotZ = 90
            else
                rotZ = 0
            end
            local table = HEROIN_GROW_STATION_OFFSETS[i]
            if table then
                self.HeroinStations[index][i]:attach(self.HeroinStations[index][1], table.posX, table.posY, table.posZ)
            else
                self.HeroinStations[index][i]:attach(self.HeroinStations[index][1], lockerX, 2.03, -0.11, 0, 0, 90)
            end
        end
    end

    self.HeroinStations[index][1]:setRotation(0, 0, rotation)
    if index <= self.m_Workers then
        local npcIndex = #self.HeroinStations[index]+1
        self.HeroinStations[index][npcIndex] = NPC:new(math.random(28,30), unpack(HEROIN_WORKERS[index]))
        self.HeroinStations[index][npcIndex]:setInterior(interior)
        self.HeroinStations[index][npcIndex]:setDimension(dimension)
        self.HeroinStations[index][npcIndex]:setImmortal(true)
        self.HeroinStations[index][npcIndex]:setAnimation("FOOD", "SHP_Tray_Pose", -1, true, false, false, false)
        self.HeroinStations[index][npcIndex]:setFrozen(true)
    end
end

function HeroinFactory:getMaxWorkingStations()
    return #HEROIN_GROW_STATIONS
end

function HeroinFactory:getMaxWorkers()
    return #HEROIN_GROW_STATIONS
end

function HeroinFactory:canBuyWorkers()
    return #HEROIN_GROW_STATIONS
end

function HeroinFactory:createVentEntries()
    self.m_VentEntryWest = createObject(2986, 2653.480, -1450.8, 41.3, 0, 91, 0)
    self.m_VentEntryWest:setData("clickable", true, true)
    self.m_VentEntryWest:setData("Offset:x", -0.75)
    self.m_VentEntryWest:setData("Offset:y", 0.1)
    self.m_VentEntryWest:setData("Offset:z", 0.5)

    self.m_VentOutWest = createObject(2986, 2680.3, -1554.775, 2919.39, 0, 90, 270)
    self.m_VentOutWest:setData("clickable", true, true)
    self.m_VentOutWest:setData("Offset:x", -0.1)
    self.m_VentOutWest:setData("Offset:y", 1)
    self.m_VentOutWest:setData("Offset:z", 0.5)
    self.m_VentOutWest:setInterior(self.m_Interior)
    self.m_VentOutWest:setDimension(self.m_Dimension)

    self.m_VentEntryEast = createObject(2986, 2667.089, -1450.8, 41.3, 0, 91, 180)
    self.m_VentEntryEast:setData("Offset:x", 0.75)
    self.m_VentEntryEast:setData("Offset:y", 0.1)
    self.m_VentEntryEast:setData("Offset:z", 0.5)
    self.m_VentEntryEast:setData("clickable", true, true)

    self.m_VentOutEast = createObject(2986, 2658.3, -1554.775, 2919.39, 0, 90, 270)
    self.m_VentOutEast:setData("clickable", true, true)
    self.m_VentOutEast:setData("Offset:x", -0.1)
    self.m_VentOutEast:setData("Offset:y", 1)
    self.m_VentOutEast:setData("Offset:z", 0.5)
    self.m_VentOutEast:setInterior(self.m_Interior)
    self.m_VentOutEast:setDimension(self.m_Dimension)

    self.m_VentEntryWest:setData("counterpart", self.m_VentOutWest)
    self.m_VentOutWest:setData("counterpart", self.m_VentEntryWest)

    self.m_VentEntryEast:setData("counterpart", self.m_VentOutEast)
    self.m_VentOutEast:setData("counterpart", self.m_VentEntryEast)

    addEventHandler("onElementClicked", self.m_VentEntryWest, self.m_ClickBind)
    addEventHandler("onElementClicked", self.m_VentOutWest, self.m_ClickBind)
    addEventHandler("onElementClicked", self.m_VentEntryEast, self.m_ClickBind)
    addEventHandler("onElementClicked", self.m_VentOutEast, self.m_ClickBind)
end

function HeroinFactory:onVentClick(mouseButton, buttonState, player)
    if mouseButton == "left" and buttonState == "down" then
        local x, y, z = getElementPosition(player)
        if getDistanceBetweenPoints3D(x, y, z, getElementPosition(source)) < 2 then
            local counterpart = source:getData("counterpart")
            local offsetX = counterpart:getData("Offset:x") or 0
            local offsetY = counterpart:getData("Offset:y") or 0
            local offsetZ = counterpart:getData("Offset:z") or 0
            local cx, cy, cz = getElementPosition(counterpart)

            player:setInterior(counterpart:getInterior())
            player:setDimension(counterpart:getDimension())
            player:setPosition(cx+offsetX, cy+offsetY, cz+offsetZ)
        else
            player:sendError("Du bist zu weit von dem Lüftungsschaft entfernt!")
        end
    end
end