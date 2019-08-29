-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/PlayHouse.lua
-- *  PURPOSE:     PlayHouse class
-- *
-- ****************************************************************************

PlayHouse = inherit(Singleton)

PlayHouse.Items =
{
    ["Wochenkarte"] =  50000, 
	["Zweiwochenkarte"] =  90000,
	["Dreiwochenkarte"] =  135000,
	["Monatskarte"]  = 170000,
}

PlayHouse.StreamUrl = "files/audio/devils_harp.mp3"

addRemoteEvents{"PlayHouse:requestTimeWeather", "PlayHouse:buyItem", "PlayHouse:checkClubcard"}
function PlayHouse:constructor() 
   	self.m_BankAccountServer = BankServer.get("gameplay.playhouse")
    addEventHandler("PlayHouse:requestTimeWeather", root, bind(self.Event_requestTimeWeather, self))
    addEventHandler("PlayHouse:buyItem", root, bind(self.Event_buyItem, self))
    addEventHandler("PlayHouse:checkClubcard", root, bind(self.Event_checkClubCard, self))
    self.m_EnterCasino = InteriorEnterExit:new(Vector3(-1431.87, -952.25, 200.96), Vector3(467.85, 498.00, 1055.82), 0, 180, 12, 0, 0, 0)

    local antifall = createColCuboid(452.46, 476.06, 1045.81,  120, 60, 40)
    InstantTeleportArea:new(antifall, 12, 0, Vector3(467.85, 498.00, 1055.82))

    self.m_Skull = createObject(3524,  -1431.795, -950.54102, 202.319, 33.997, 0, 355.999)
    self.m_SkullSecond = createObject(3524,  -1431.4449, -950.11603, 201.619, 33.997, 0, 2.249)
    self.m_SkullThird = createObject(3524,  -1432.1949,  -950.11603, 201.66901, 34, 0, 352.25)

    self.m_MoveState = false
    self.m_EnterCasino:setLocked(true)
    self.m_Open = false 
    GlobalTimer:getSingleton():registerEvent(bind(self.open, self), "PlayHouseOpen", nil, 20, 00)
end

function PlayHouse:open() 
    for k, p in pairs(getElementsByType("player")) do 
        p:triggerEvent("PlayHouse:playOpen")
    end
    if self.m_Open then return end
    self.m_MoveState = not self.m_MoveState
    self.m_Open = true
    self.m_EnterCasino:setLocked(false)
    if self.m_MoveState then   
        self.m_SkullUp = math.random(2, 6) / 10
        moveObject(self.m_Skull, 2000, self.m_Skull.position.x, self.m_Skull.position.y, self.m_Skull.position.z+self.m_SkullUp, 10, 0, 0, math.random(1, 2) == 1 and "OutBack" or "OutQuad")
        self.m_SkullUp2 = math.random(2, 8) / 10
        moveObject(self.m_SkullSecond, 2000, self.m_SkullSecond.position.x, self.m_SkullSecond.position.y, self.m_SkullSecond.position.z+self.m_SkullUp2, 10, 0, 0, math.random(1, 2) == 1 and "OutBack" or "OutQuad")
        self.m_SkullUp3 = math.random(2, 8) / 10
        moveObject(self.m_SkullThird, 2000, self.m_SkullThird.position.x, self.m_SkullThird.position.y, self.m_SkullThird.position.z+self.m_SkullUp3, 10, 0, 0, math.random(1, 2) == 1 and "OutBack" or "OutQuad")
    end
    self.m_MoveTimer = setTimer(function()
        self.m_MoveState = not self.m_MoveState
        if self.m_MoveState then   
            self.m_SkullUp = math.random(2, 6) / 10
            moveObject(self.m_Skull, 2000, self.m_Skull.position.x, self.m_Skull.position.y, self.m_Skull.position.z+self.m_SkullUp, 10, 0, 0, math.random(1, 2) == 1 and "OutBack" or "OutQuad")
            self.m_SkullUp2 = math.random(2, 8) / 10
            moveObject(self.m_SkullSecond, 2000, self.m_SkullSecond.position.x, self.m_SkullSecond.position.y, self.m_SkullSecond.position.z+self.m_SkullUp2, 10, 0, 0, math.random(1, 2) == 1 and "OutBack" or "OutQuad")
            self.m_SkullUp3 = math.random(2, 8) / 10
            moveObject(self.m_SkullThird, 2000, self.m_SkullThird.position.x, self.m_SkullThird.position.y, self.m_SkullThird.position.z+self.m_SkullUp3, 10, 0, 0, math.random(1, 2) == 1 and "OutBack" or "OutQuad")
        else 
            moveObject(self.m_Skull, 2000, self.m_Skull.position.x, self.m_Skull.position.y, self.m_Skull.position.z-self.m_SkullUp, -10, 0, 0, math.random(1, 2) == 1 and "OutBack" or "OutQuad")
            moveObject(self.m_SkullSecond, 2000, self.m_SkullSecond.position.x, self.m_SkullSecond.position.y, self.m_SkullSecond.position.z-self.m_SkullUp2, -10, 0, 0, math.random(1, 2) == 1 and "OutBack" or "OutQuad")
            moveObject(self.m_SkullThird, 2000, self.m_SkullThird.position.x, self.m_SkullThird.position.y, self.m_SkullThird.position.z-self.m_SkullUp3, -10, 0, 0, math.random(1, 2) == 1 and "OutBack" or "OutQuad")
        end 
    end, 2000, 0)
end

function PlayHouse:close() 
    self.m_Open = false
    self.m_EnterCasino:setEntryLocked()
    if self.m_MoveTimer and isTimer(self.m_MoveTimer) then 
        killTimer(self.m_MoveTimer)
    end
    if self.m_Skull then destroyElement(self.m_Skull) end 
    if self.m_SkullSecond then destroyElement(self.m_SkullSecond) end
    if self.m_SkullThird then destroyElement(self.m_SkullThird) end
    self.m_Skull = createObject(3524,  -1431.795, -950.54102, 202.319, 33.997, 0, 355.999)
    self.m_SkullSecond = createObject(3524,  -1431.4449, -950.11603, 201.619, 33.997, 0, 2.249)
    self.m_SkullThird = createObject(3524,  -1432.1949,  -950.11603, 201.66901, 34, 0, 352.25)
end

function PlayHouse:Event_checkClubCard() 
    local itemPlace = client:getInventory():getItemPlacesByName("Clubkarte")
    if itemPlace then 
        if itemPlace[1] then 
            if itemPlace[1][1] then 
                local value =  client:getInventory():getItemValueByBag(itemPlace[1][2], itemPlace[1][1])
                if value and tonumber(value) then 
                    if tonumber(value) <= getRealTime().timestamp then 
                        client:getInventory():removeAllItem("Clubkarte")
                        client:sendShortMessage(_("Deine Spielhaus-Clubkarte ist abgelaufen und wurde entfernt!", client))
                    end
                end
            end
        end
    end
    if client:getInventory():getItemAmount("Clubkarte") == 1 then 
        client:setData("PlayHouse:clubcard", true, true)
    else   
        client:setData("PlayHouse:clubcard", false, true)
    end
    client:triggerEvent("PlayHouse:sendStream", PlayHouse.StreamUrl)
end

function PlayHouse:sendStream(url) 
    PlayHouse.StreamUrl = url 
    for k, p in pairs(getElementsByType("player")) do 
        if p:getInterior() == 12 then 
            p:triggerEvent("PlayHouse:sendStream", url)
        end
    end
end

function PlayHouse:Event_buyItem(item, price, cardDuration) 
    if PlayHouse.Items[item] then 
        local price = PlayHouse.Items[item]
        if price then 
            if price <= client:getMoney() then 
                if item:find("karte") and client:getInventory():getItemAmount("Clubkarte") and client:getInventory():getItemAmount("Clubkarte") > 0 then 
                    return  client:sendError(_("Du besitzt bereits eine Clubkarte!", client))
                end
                if client:getInventory():giveItem(item:find("karte") and "Clubkarte" or item, 1, (cardDuration and tonumber(cardDuration) and getRealTime().timestamp + cardDuration) or nil) then 
                    if not client:transferMoney(self.m_BankAccountServer, price, "Item-Kauf (Spielhaus)", "Gameplay", "PlayHouse") then
                        client:getInventory():removeAllItem("Clubkarte")
                        client:sendError(_("Etwas ist fehlgeschlagen!", client))
                    else 
                        if item:find("karte")  then 
                            client:setData("PlayHouse:clubcard", true, true)
                        end
                    end
                else 
                    client:sendError(_("Du hast zu wenig Platz!", client))
                end
            else 
                client:sendError(_("Du hast zu wenig Geld!", client))
            end 
        end
    end
end

function PlayHouse:destructor() 

end

function PlayHouse:Event_requestTimeWeather() 
    local weather = getWeather() 
    local hour, time  = getTime()
    client:triggerEvent("PlayHouse:resetWeatherTime", hour, time, weather)
end

