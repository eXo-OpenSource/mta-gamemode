-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Minigames/PricePool/PricePoolManager.lua
-- *  PURPOSE:     PricePoolManager class
-- *
-- ****************************************************************************

PricePoolManager = inherit(Singleton)
PricePoolManager.Map = {}
addRemoteEvents{"buyPricePoolEntries"}

function PricePoolManager:constructor()
    self:load()
    addEventHandler("buyPricePoolEntries", root, bind(self.buyEntries, self))
end

function PricePoolManager:destructor()
    for key, pricepool in pairs(PricePoolManager.Map) do
        delete(pricepool)
    end
end

function PricePoolManager:load()
    local result = sql:queryFetch("SELECT * FROM ??_pricepools WHERE Active = 1", sql:getPrefix())
    for key, row in pairs(result) do
        local priceTable = {}
        for key, price in pairs(fromJSON(row.Prices)) do
            table.insert(priceTable, {price[1], price[2]})
        end

        local entries = sql:queryFetch("SELECT * FROM ??_pricepool_entries WHERE PoolId = ?", sql:getPrefix(), row.Id)
        local entryTable = {}
        for key, entryRow in pairs(entries) do
            entryTable[entryRow.UserId] = entryRow.Entries
        end

        PricePoolManager.Map[row.Id] = PricePool:new(row.Id, row.Name, row.EntryPrice, row.RaffleDate, priceTable)
        PricePoolManager.Map[row.Id]:addEntries(entryTable, true)
    end
end

function PricePoolManager:createPricePool(name, entryPrice, prices, raffleDate)
    local result, numrows, lastInsertID = sql:queryFetch("SELECT Name FROM ??_pricepools WHERE Name = ?", sql:getPrefix(), name)
    if numrows == 0 then
        sql:queryExec("INSERT INTO ??_pricepools (Name, EntryPrice, Prices, RaffleDate, Active) VALUES (?, ?, ?, ?, 1)", sql:getPrefix(), name, entryPrice, toJSON(prices), raffleDate)
        PricePoolManager.Map[sql:lastInsertId()] = PricePool:new(sql:lastInsertId(), name, entryPrice, raffleDate, prices)
        return PricePoolManager.Map[sql:lastInsertId()]
    end
    return false
end

function PricePoolManager:createPed(pricepool, id, position, rotation)
    if not pricepool and pricepool.createPed then
        return
    end
    
    pricepool:createPed(id, position, rotation)
end

function PricePoolManager:getPricePool(name, entryPrice, prices, raffleDate)
    for key, pricepool in pairs(PricePoolManager.Map) do
        if pricepool:getName() == name then
            return pricepool
        end
    end
    return self:createPricePool(name, entryPrice, prices, raffleDate)
end

function PricePoolManager:openEntryWindow(pricepool, player, active)
    local entries = pricepool:getEntriesByName()
    local entryPrice = pricepool:getEntryPrice()
    local date = getOpticalTimestamp(pricepool:getRaffleDate())
    local priceList = pricepool:getPriceList()

    player:triggerEvent("openPricePoolEntryWindow", pricepool:getId(), entries, entryPrice, priceList, date, active)
end

function PricePoolManager:buyEntries(pricepoolId, entries)
    local pricepool = PricePoolManager.Map[pricepoolId]
    if not pricepool then
        return
    end
    if pricepool:getDailyEntryBuyLimit() and pricepool:getDailyEntryBuyLimit() - pricepool:getTodaysEntryAmount(client:getId()) <= entries then
        client:sendError(_("Du kannst heute nur noch %d Lose kaufen!", client, pricepool:getDailyEntryBuyLimit() - pricepool:getTodaysEntryAmount(client:getId())))
        return
    end
    if client:getInventory():removeItem(pricepool:getEntryPrice(), entries) then
        pricepool:addEntry(client:getId(), entries)
        client:sendSuccess(_("Du hast dir erfolgreich %d Lose gekauft!", client, entries))
        for key, player in pairs(PlayerManager:getSingleton():getReadyPlayers()) do
            player:triggerEvent("updatePricePoolEntryWindow", pricepoolId, pricepool:getEntriesByName())
        end
    else
        client:sendError(_("Du hast nicht genug, um den Preis zu bezahlen!", client))
    end
end