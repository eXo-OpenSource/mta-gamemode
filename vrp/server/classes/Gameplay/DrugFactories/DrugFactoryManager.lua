-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/DrugFactories/DrugFactoryManager.lua
-- *  PURPOSE:     Drug Factory Manager class
-- *
-- ****************************************************************************
DrugFactoryManager = inherit(Singleton)
DrugFactoryManager.Map = {}

addRemoteEvents{"requestDrugFactoryData", "requestFactoryRecruitWorker", "requestFactoryBuildWorkingStation", "onFactoryRecruitWorker", "onFactoryBuildWorkingStation"}

function DrugFactoryManager:constructor()
    self.m_FactoryTypes = {
        [1] = {CocaineFactory, "Kokain", 2, 2750.60, -1312.00, 1174.19, 90},
        [2] = {WeedFactory, "Weed", 1, 2132.84, -2297.11, 960.42, 0},
        [3] = {DrugFactory, "Heroin", 0, 0, 0, 0, 0}
    }
    self.m_FactoryColors = {
        [1] = {255, 255, 255},
        [2] = {0, 200, 50},
        [3] = {0, 0, 0}
    }
    self:loadFactories()
    FactoryWarManager:new()
    self.m_GlobalTimerId = GlobalTimer:getSingleton():registerEvent(bind(self.onFactoryPayday, self), "Fabrik-Payday",false,false,0)

    addEventHandler("requestDrugFactoryData", root, bind(self.sendDataToClient, self))

    addEventHandler("requestFactoryRecruitWorker", root, bind(self.requestFactoryRecruitWorker, self))
    addEventHandler("requestFactoryBuildWorkingStation", root, bind(self.requestFactoryBuildWorkingStation, self))
    addEventHandler("onFactoryRecruitWorker", root, bind(self.onFactoryRecruitWorker, self))
    addEventHandler("onFactoryBuildWorkingStation", root, bind(self.onFactoryBuildWorkingStation, self))
end

function DrugFactoryManager:destructor()
    FactoryWarManager:delete()
    for key, factory in ipairs(DrugFactoryManager.Map) do
        factory:delete()
    end
end

function DrugFactoryManager:loadFactories()
	local result = sql:queryFetch("SELECT * FROM ??_drug_factories", sql:getPrefix())
    for k, row in ipairs(result) do
        if self.m_FactoryTypes[row.type] then
            DrugFactoryManager.Map[row.id] = self.m_FactoryTypes[row.type][1]:new(row.id, row.type, row.owner, row.progress, {x=tonumber(row.managerX), y=tonumber(row.managerY), z=tonumber(row.managerZ), rot=tonumber(row.managerRot)}, row.workingstations, row.lastattack, row.workers, tonumber(row.x), tonumber(row.y), tonumber(row.z), tonumber(row.rot), row.dimension, self.m_FactoryTypes[row.type][3], self.m_FactoryTypes[row.type][4], self.m_FactoryTypes[row.type][5], self.m_FactoryTypes[row.type][6], self.m_FactoryTypes[row.type][7], self.m_FactoryColors[row.type])
        end
	end
end

function DrugFactoryManager:saveFactories()
    for key, factory in ipairs(DrugFactoryManager.Map) do
        sql:queryFetch("UPDATE ??_drug_factories SET owner = ?, lastattack = ?, workingstations = ?, workers = ?", sql:getPrefix(), factory:getOwner(), factory:getLastAttack(), factory:getWorkingStationCount(), factory:getWorkerCount())
    end
end

function DrugFactoryManager:onFactoryPayday()
    for key, factory in ipairs(DrugFactoryManager.Map) do
        local factoryOwners = FactionManager:getSingleton():getFromId(factory:getOwner())
        if factoryOwners then
            if #factoryOwners:getOnlinePlayers(true) > 2 or DEBUG then
                local workers = factory:getWorkerCount()
                local workingstations = factory:getWorkingStationCount()
                local maxWorkers = factory:getMaxWorkers()
                local maxWorkingstations = factory:getMaxWorkingStations()
                local amount = math.floor(((workers*100/maxWorkers/2) + (workingstations*100/maxWorkingstations/2))/100*(factory.m_Type == 1 and DRUGFACTORY_MAX_PAYDAY_COCAINE or factory.m_Type == 2 and DRUGFACTORY_MAX_PAYDAY_WEED))
                local item = factory.m_Type == 1 and "Kokain" or factory.m_Type == 2 and "Weed"
                if amount > 0 then
                    factoryResult = factoryOwners:getDepot():addItem(false, item, amount, true)
                else
                    factoryResult = true
                end
                if factoryResult == true then
                    factoryOwners:sendMessage("Fabrik Payday: #FFFFFFEure Fraktion erhält: "..amount.." Gramm "..factory:getType(), 0, 200, 0, true)
                else
                    factoryOwners:sendMessage("Fabrik Payday: #FFFFFFEure Fraktion hat nicht genug Platz für "..amount.." Gramm "..factory:getType().." im Depot!", 200, 0, 0, true)
                end
            else
                factoryOwners:sendMessage("Fabrik Payday: Es sind nicht genügend Spieler online für den Fabrik Payday!", 200, 0, 0, true)
            end
        end
    end
end

function DrugFactoryManager:sendDataToClient(player)
    local table = {}
    for key, factory in ipairs(DrugFactoryManager.Map) do
        table[key] = {
            ["ID"] = key,
            ["Type"] = factory:getType(),
            ["Owner"] = FactionManager:getSingleton():getFromId(factory:getOwner()):getName(),
            ["Progress"] = factory:getProgress(),
            ["LastAttack"] = getOpticalTimestamp(factory:getLastAttack()),
            ["Position"] = getZoneName(factory.m_Blip:getPosition()),
            ["WorkingStations"] = factory:getWorkingStationCount(),
            ["Workers"] = factory:getWorkerCount(),
            ["maxWorkers"] = factory:getMaxWorkers(),
            ["maxWorkingStations"] = factory:getMaxWorkingStations()
        }
    end
    player:triggerEvent("onFactoryDataReceive", table)
end

function DrugFactoryManager:requestFactoryRecruitWorker(id)
    if DrugFactoryManager.Map[id] and DrugFactoryManager.Map[id]:getOwner() == client:getFaction():getId() then
        if client:getFaction():getPlayerRank(client) > 4 then
            QuestionBox:new(client, client, "Willst du Arbeiter für die Fabrik anwerben?", "onFactoryRecruitWorker", false, client, id)
        else
            client:sendError("Dazu bist nicht berechtigt!")
        end
    else
        client:sendError("Die Fabrik gehört nicht deiner Fraktion!")
    end
end

function DrugFactoryManager:requestFactoryBuildWorkingStation(id)
    if DrugFactoryManager.Map[id] and DrugFactoryManager.Map[id]:getOwner() == client:getFaction():getId() then
        if client:getFaction():getPlayerRank(client) > 4 then
            QuestionBox:new(client, client, "Willst du Verarbeitungsstellen für die Fabrik bauen?", "onFactoryBuildWorkingStation", false, client, id)
        else
            client:sendError("Dazu bist nicht berechtigt!")
        end
    else
        client:sendError("Die Fabrik gehört nicht deiner Fraktion!")
    end
end

function DrugFactoryManager:onFactoryRecruitWorker(player, id)
    local factory = DrugFactoryManager.Map[id]
    if factory:canBuyWorkers() > factory:getWorkerCount() then
        if factory:getWorkerCount() < factory:getMaxWorkers() then
            factory:setWorkerCount(factory:getWorkerCount() + 1)
            player:sendInfo("Arbeiter angeworben!")
        else
            player:sendError("Die Fabrik hat bereits die maximale Anzahl an Arbeitern!")
        end
    else
        player:sendError("Die Fabrik hat nicht genug Arbeitsplätze!")
    end
end

function DrugFactoryManager:onFactoryBuildWorkingStation(player, id)
    local factory = DrugFactoryManager.Map[id]
    if factory:getWorkingStationCount() < factory:getMaxWorkingStations() then
        factory:setWorkingStationCount(factory:getWorkingStationCount() + 1)
        player:sendInfo("Verarbeitungsstelle gebaut!")
    else
        player:sendError("Die Fabrik hat bereits die maximale Anzahl an Verarbeitungsstellen!")
    end
end