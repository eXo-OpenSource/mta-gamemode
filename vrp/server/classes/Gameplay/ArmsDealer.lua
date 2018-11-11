-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/ArmsDealer.lua
-- *  PURPOSE:     Arms Dealer class
-- *
-- ****************************************************************************
ArmsDealer = inherit(Singleton)

ArmsDealer.Data = 
{
    ["Waffen"] = AmmuNationInfo,
    ["Spezial"] = 
    {
        ["Gasmaske"] = {50, 50000},
        ["Gasgranate"] = {6, 50000, 17},
        ["Rauchgranate"] = {3, 100000},
        ["Scharfschützengewehr"] = {5, 60000, 34},
        ["Fallschirm"] = {20, 5000, 46}
    },
    ["Explosiv"] = 
    {
        ["RPG-7"] = {5, 300000, 35},
        ["Granate"] = {10, 80000, 16},
        ["SLAM"] = {2, 40000}
    }
}
addRemoteEvents{"requestArmsDealerInfo", "checkoutArmsDealerCart"}
function ArmsDealer:constructor()
    self.m_Order = {}
    self.m_BankAccountServer = BankServer.get("gameplay.blackmarket")
    addEventHandler("requestArmsDealerInfo", root, bind(self.sendInfo, self))
    addEventHandler("checkoutArmsDealerCart", root, bind(self.checkoutCart, self))
end

function ArmsDealer:getItemData(item)
    for category, data in pairs(ArmsDealer.Data) do 
        for product, subdata in pairs(data) do 
            if product == item then 
                return subdata
            end
        end
    end
    return false
end


function ArmsDealer:checkoutCart(cart)
    if client and client.getFaction and client:getFaction() then 
        if cart then
            local faction = client:getFaction()
            if not self.m_Order[faction] then
                self.m_Order[faction] = {}
                local depot = faction.m_Depot
                local orderCount = 0
                local price, maxAmount, currentAmount, pricePerPiece
                local validWeapons, maxWeapons, weaponDepot = faction.m_ValidWeapons, faction.m_WeaponDepotInfo, depot:getWeaponTable()
                for category, data in pairs(cart) do 
                    for product, subdata in pairs(data) do 
                        if category == "Waffen" then
                            if not self:isMagazin(product) then
                                maxAmount = maxWeapons[product]["Waffe"]
                                currentAmount = weaponDepot[product]["Waffe"]
                                pricePerPiece = maxWeapons[product]["WaffenPreis"]
                                if (maxAmount - currentAmount) > 0 then
                                    table.insert(self.m_Order[faction], {"Waffe", WEAPON_NAMES[product], (maxAmount-currentAmount), (maxAmount-currentAmount)*pricePerPiece, product})
                                end
                            else 
                                product = self:getMagazineId(product)
                                product = tonumber(product) -- hence doing tonumber(self:getMagazineId(...)) is trying to tonumber both gsub-return values
                                maxAmount = maxWeapons[product]["Magazine"]
                                currentAmount = weaponDepot[product]["Munition"]
                                pricePerPiece = maxWeapons[product]["MagazinPreis"]
                                if (maxAmount - currentAmount) > 0 then
                                    table.insert(self.m_Order[faction], {"Munition", WEAPON_NAMES[product], (maxAmount-currentAmount), (maxAmount-currentAmount)*pricePerPiece, product})
                                end
                            end
                        else 
                            if ArmsDealer.Data[category] and ArmsDealer.Data[category][product] then
                                table.insert(self.m_Order[faction], {"Equipment", product, ArmsDealer.Data[category][product][1], ArmsDealer.Data[category][product][2] })
                            end
                        end
                    end
                end
                self.m_Arrival = (120 + (#self.m_Order[faction] * 5))
                self:processCart( self.m_Order[faction], faction)
            end
        end
    end
end

function ArmsDealer:processCart( order, faction )
    local text = "BESTELLUNG\n\n"
    local categoryDisplay = {}

    for i, data in ipairs(order) do -- group the order into categories for display-purposes
        if not categoryDisplay[data[2]] then categoryDisplay[data[2]] = {} end
        table.insert(categoryDisplay[data[2]], data)
    end

    self.m_TotalPrice = 0
    for category, data in pairs(categoryDisplay) do 
        text = ("%s» %s\n"):format(text, category) 
        for i, subdata in ipairs(data) do 
            text = ("%s%s [ Stück: %s  - Preis: $%s  ]\n"):format(text, subdata[1], subdata[3], subdata[4])
            self.m_TotalPrice = self.m_TotalPrice + subdata[4]
        end
        text = ("%s\n"):format(text) -- add double breakline after each category
    end
    text = ("%s= Total-Preis:%s\n\nETA: %s"):format(text, self.m_TotalPrice, getOpticalTimestamp(self.m_Arrival+getRealTime().timestamp))
    faction:sendShortMessage(text, -1)
    self.m_BankAccountServer:transferMoney({"faction", faction:getId(), true}, self.m_TotalPrice, "Lieferung", "Action", "Blackmarket", {silent = true})
    local endPoint = factionWTDestination[faction:getId()]
    if endPoint then
        self:setupPlane(endPoint, 200000, faction, order)
    end
    self.m_Order[faction] = false
end

function ArmsDealer:isMagazin(product)
    if type(product) == "number" then
        return false 
    else
        return product:find("%-%[Magazin]")
    end
end

function ArmsDealer:getMagazineId(product)
    return product:gsub("%-%[Magazin]", "")
end

function ArmsDealer:sendInfo()
    if client.getFaction and client:getFaction() and client:getFaction():isEvilFaction() then
        local faction = client:getFaction()
        local depot = faction.m_Depot
        client:triggerEvent("updateArmsDealerInfo", ArmsDealer.Data, faction.m_ValidWeapons, faction.m_WeaponDepotInfo, depot:getWeaponTable() )
    end
end

function ArmsDealer:startAirDrop(faction, order, acceleration)
    local endPoint = factionWTDestination[faction:getId()]
    if endPoint then 
        local length = 30 / #order 
        for i, data in ipairs(order) do 
            setTimer(function() 
                ArmsPackage:new(data, Vector3(endPoint.x+(i*length), endPoint.y, endPoint.z+100), Vector3(endPoint.x +(i*length), endPoint.y, endPoint.z-0.3))
            end, acceleration*(length*i), 1)
        end
    end
end

function ArmsDealer:setupPlane(pos, time, faction, order)
    local acceleration = time/6000
    local startPoint = Vector3(-3000, pos.y, 100)
    local distanceToDrop = math.abs(-3000 - pos.x)
    local distanceAfterDrop = 6000 - distanceToDrop
    local endPoint = Vector3(3000, pos.y, 100)
    self.m_Plane =  TemporaryVehicle.create(592, -3000, pos.y, 100)
    self.m_Plane:setColor(0,0,0,0,0,0)
    setVehicleLandingGearDown(self.m_Plane, false)
    self.m_MoveObject = createObject(1337, -3000, pos.y, 100)
    self.m_MoveObject:setCollisionsEnabled(false)
    self.m_MoveObject:setAlpha(0)
    self.m_Plane:attach(self.m_MoveObject, Vector3(0, 0, 0), Vector3(0, 0, 270))
    self.m_MoveObject:move(acceleration*distanceToDrop, pos.x, pos.y, 100)
    setTimer(function() 
        self.m_MoveObject:move(distanceAfterDrop*acceleration, 3000, pos.y, 100) 
        self:startAirDrop(faction, order, acceleration)
    end, acceleration*distanceToDrop, 1)

end

function ArmsDealer:destructor()

end