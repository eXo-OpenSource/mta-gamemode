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
        ["Fallschirm"] = {20, 5000, 46},
        ["DefuseKit"] = {20, 5000},
    },
    ["Explosiv"] = 
    {
        ["RPG-7"] = {5, 300000, 35}, 
        ["Granate"] = {10, 80000, 16},
        ["SLAM"] = {2, 40000}
    }
}

ArmsDealer.ProhibitedRank = 
{
    ["RPG-7"] = 3, 
    ["Granate"] = 3, 
    ["SLAM"] = 3,
    ["Scharfschützengewehr"] =  3 
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
    if not ActionsCheck:getSingleton():isActionAllowed(client) then return end
    if client and client.getFaction and client:getFaction() then 
        if cart and not self.m_InAir then
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
                                table.insert(self.m_Order[faction], {"Equipment", product, ArmsDealer.Data[category][product][1], ArmsDealer.Data[category][product][2], ArmsDealer.Data[category][product][3] })
                            end
                        end
                    end
                end
                self:processCart( self.m_Order[faction], faction)
            else 
                client:sendError("Deine Fraktion hat bereits heute bestellt!")
            end
        else 
            client:sendError("Es läuft zurzeit bereits ein Airdrop!")
        end
    end
end

function ArmsDealer:processCart( order, faction )
    local endPoint = factionAirDropPoint[faction:getId()]
    local etaTime
    if endPoint then
        etaTime = self:setupPlane(endPoint, 400000, faction, order)
    end

    local text = "Jackal Weapon Delivery\n"
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
    text = ("%s= Total-Preis:%s\n\nETA: %s"):format(text, self.m_TotalPrice, getOpticalTimestamp(etaTime+getRealTime().timestamp, true))
    faction:sendShortMessage(text, -1)
    faction:transferMoney(self.m_BankAccountServer, self.m_TotalPrice, "Lieferung", "Action", "Blackmarket")
    self.m_Blip =  Blip:new("Marker.png", endPoint.x, endPoint.y, {faction = {faction:getId()}}, 9999, BLIP_COLOR_CONSTANTS.Red)
    self.m_Blip:attach(self.m_Plane)

    self.m_DropBlip = Blip:new("SniperGame.png", endPoint.x, endPoint.y,  {factionType = {"State", "Evil"}}, 9999, BLIP_COLOR_CONSTANTS.Blue)
    self.m_DropIndicator = createObject(354, endPoint.x, endPoint.y, endPoint.z)
    PlayerManager:getSingleton():breakingNews("Ein nicht identifiziertes Flugzeug ist in den Flugraum von San Andreas eingedrungen!")
    self.m_InAir = true
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
    local endPoint = factionAirDropPoint[faction:getId()]
    if endPoint then 
        local length = 30 / #order 
        for i, data in ipairs(order) do 
            setTimer(function() 
                if self.m_Plane then 
                    local pos = self.m_Plane:getPosition()
                    ArmsPackage:new(data, Vector3(pos.x-4, pos.y, pos.z), Vector3(pos.x-4, pos.y, endPoint.z-0.35))
                end
            end, acceleration*(length*i), 1)
        end
    end
end

function ArmsDealer:setupPlane(pos, time, faction, order)
    self:sendOperatorMessage(faction, "In der Luft!")
    ActionsCheck:getSingleton():setAction("Waffendrop")
    local acceleration = time/6000
    local startPoint = Vector3(-3000, pos.y, 100)
    local distanceToDrop = math.abs(-3000 - pos.x)
    local distanceAfterDrop = 6000 - distanceToDrop
    local endPoint = Vector3(3000, pos.y, 100)
    self.m_Plane =  TemporaryVehicle.create(592, -3000, pos.y, 100)
    self.m_Plane:disableRespawn(true)
    self.m_Plane:setColor(0,0,0,0,0,0)
    self.m_Plane:setCollisionsEnabled(false)
    setVehicleLandingGearDown(self.m_Plane, false)
    self.m_MoveObject = createObject(1337, -3000, pos.y, 100)
    self.m_MoveObject:setCollisionsEnabled(false)
    self.m_MoveObject:setAlpha(0)
    self.m_Plane:attach(self.m_MoveObject, Vector3(0, 0, 0), Vector3(0, 0, 270))
    self.m_MoveObject:move(acceleration*distanceToDrop, pos.x, pos.y, 100)
    faction:setCountDown((acceleration*distanceToDrop)/1000, "Airdrop")
    setTimer(function() self:sendOperatorMessage(faction, "Abwurf in T-10!") end, (distanceToDrop*acceleration)-10000, 1)
    setTimer(function() 
        self.m_MoveObject:move(distanceAfterDrop*acceleration, 3000, pos.y, 100) 
        self:sendOperatorMessage(faction, "Abwurf!")
        self:startAirDrop(faction, order, acceleration)
        setTimer(function() self:clear() end, distanceAfterDrop*acceleration, 1)
    end, acceleration*distanceToDrop, 1)
    return (acceleration*distanceToDrop)/1000
end

function ArmsDealer:sendOperatorMessage(faction, text)
    if faction and text then 
        local players = faction:getOnlinePlayers()
        for index, player in pairs(players) do 
            playSoundFrontEnd(player, 47)
            setTimer(playSoundFrontEnd, 1000, 1, player, 48)
        end
        faction:sendMessage(("%s %s"):format("[**OPERATOR**]", text), 19, 32, 104)
    end
end


function ArmsDealer:clear()
    if self.m_Blip then 
        self.m_Blip:delete()
        self.m_Blip = nil
    end
    if self.m_Plane and isElement(self.m_Plane) then 
        self.m_Plane:destroy()
        self.m_Plane = nil
    end
    if self.m_MoveObject and isElement(self.m_MoveObject) then 
        self.m_MoveObject:destroy()
        self.m_MoveObject = nil
    end
    if self.m_DropBlip then 
        self.m_DropBlip:delete()
        self.m_DropBlip = nil 
    end
    if self.m_DropIndicator and isElement(self.m_DropIndicator) then 
        self.m_DropIndicator:destroy()
        self.m_DropIndicator = nil
    end
    self.m_InAir = false
    ActionsCheck:getSingleton():endAction()
end

function ArmsDealer:destructor()

end