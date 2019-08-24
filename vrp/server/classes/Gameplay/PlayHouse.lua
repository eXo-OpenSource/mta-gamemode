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
    ["Clubkarte"] = 50000,
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
end

function PlayHouse:Event_checkClubCard() 
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

function PlayHouse:Event_buyItem(item) 
    if PlayHouse.Items[item] then 
        local price = PlayHouse.Items[item]
        if price then 
            if price <= client:getMoney() then 
                if item == "Clubkarte" and client:getInventory():getItemAmount("Clubkarte") and client:getInventory():getItemAmount("Clubkarte") > 0 then 
                    return  client:sendError(_("Du besitzt bereits eine Clubkarte!", client))
                end
                if client:getInventory():giveItem(item, 1) then 
                    if not client:transferMoney(self.m_BankAccountServer, price, "Item-Kauf (Spielhaus)", "Gameplay", "PlayHouse") then
                        client:getInventory():removeItem(item, 1)
                        client:sendError(_("Etwas ist fehlgeschlagen!", client))
                    else 
                        if item == "Clubkarte" then 
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

