-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/Managers/ItemSellContractManager.lua
-- *  PURPOSE:     ItemSellContract Manager class
-- *
-- ****************************************************************************

ItemSellContractManager = inherit(Singleton)
addRemoteEvents{"onReceiveSellContractSignature", "onSellContractTradeAbort"}

function ItemSellContractManager:constructor()
    self.m_PendingTrades = {}

    addEventHandler("onReceiveSellContractSignature", root, bind(self.receiveSign, self))
    addEventHandler("onSellContractTradeAbort", root, bind(self.abortTrade, self))
end

function ItemSellContractManager:addVehicleTrade(player, vehicle)
    if self:isPlayerTrading(player) then
        player:sendError(_("Du bist bereits am handeln!", player))
        return
    end

    local product = vehicle:getName()
    local productIdLabel = "Fahrgestellnummer"
    local productId = vehicle:getId()
    local informationLabel = "Kilometerstand"
    local information = vehicle:getMileage() and vehicle:getMileage()/1000 or 0

    self.m_PendingTrades[player] = {
        tradeType = "vehicle",
        tradeElement = vehicle,
        product = product,
        productIdLabel = productIdLabel,
        productId = productId,
        informationLabel = informationLabel,
        information = information
    }

    player:triggerEvent("openSellContractGUI", player, false, product, productIdLabel, productId, informationLabel, information, false, false)
end

function ItemSellContractManager:receiveSign(seller, signType, sign, purchaser, price)
    if self.m_PendingTrades[seller] then
        if signType == "seller" then
            local trade = self.m_PendingTrades[seller]

            trade.purchaser = purchaser
            trade.price = price

            local product = trade.product
            local productIdLabel = trade.productIdLabel
            local productId = trade.productId
            local informationLabel = trade.informationLabel
            local information = trade.information

            if self:isPlayerTrading(purchaser) then
                seller:sendError(_("Der Spieler ist bereits am handeln!", seller))
                return
            end
            if #purchaser:getVehicles() >= math.floor(MAX_VEHICLES_PER_LEVEL*purchaser:getVehicleLevel()) then
                seller:sendError(_("Der Spieler kann nicht noch mehr Fahrzeuge besitzen!", seller))
                return
            end

            purchaser:triggerEvent("openSellContractGUI", seller, purchaser, product, productIdLabel, productId, informationLabel, information, price, sign)
        elseif signType == "purchaser" then
            self:confirmTrade(seller)
            seller:triggerEvent("onPurchaseConfirmationReceive", sign)
        end
    end
end

function ItemSellContractManager:confirmTrade(seller)
    if self.m_PendingTrades[seller] then
        if self.m_PendingTrades[seller].tradeType == "vehicle" then
            if seller.vehicle and seller.vehicle:getId() == self.m_PendingTrades[seller].productId then
                local purchaser = self.m_PendingTrades[seller].purchaser
                local vehicle = self.m_PendingTrades[seller].tradeElement
                if purchaser:transferBankMoney(seller, price, "Fahrzeug-Handel", "Gameplay", "VehicleTrade") then
                    VehicleManager:getSingleton():removeRef(vehicle, false)
                    vehicle:setOwner(purchaser)
                    vehicle:setData("OwnerName", purchaser.name, true)
                    VehicleManager:getSingleton():addRef(vehicle, false)
                    vehicle.m_Keys = {}
                    VehicleManager:getSingleton():syncVehicleInfo(seller)
                    VehicleManager:getSingleton():syncVehicleInfo(purchaser)
                    seller:getInventory():removeItem("Handelsvertrag", 1)
                    StatisticsLogger:getSingleton():addVehicleTradeLog(vehicle, seller, purchaser, price, "player")
                    purchaser:sendInfo(_("Der Handel wurde abgeschlossen!", purchaser))
                    seller:sendInfo(_("Der Handel wurde abgeschlossen!", seller))
                else
                    purchaser:sendError(_("Du hast nicht genug Geld auf der Bank!", purchaser))
                    seller:sendInfo(_("Der Käufer hat nicht genug Geld auf der Bank!", seller))
                end
            end
        end
    end
end

function ItemSellContractManager:abortTrade(seller)
    if self.m_PendingTrades[seller] then
        local purchaser = self.m_PendingTrades[seller].purchaser

        seller:triggerEvent("closeSellContractGUI")
        if purchaser then
            purchaser:triggerEvent("closeSellContractGUI")
        end
        self.m_PendingTrades[seller] = nil
    end
end

function ItemSellContractManager:isPlayerTrading(player)
    for seller, trade in pairs(self.m_PendingTrades) do
        if seller == player then
            return true
        elseif trade.purchaser and trade.purchaser == player then
            return true
        end
    end
    return false
end