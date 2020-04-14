-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/Easter/Easter.lua
-- *  PURPOSE:     Easter class
-- *
-- ****************************************************************************

Easter = inherit(Singleton)
Easter.startDay = 95
Easter.today = getRealTime().yearday
Easter.RabbitObjects = { -- true = createObject ; false = removeWorldModel
    [4] = {
        {isNew=true, id=6959, x=2772.6, y=-1383.54, z=9.2, xr=0, yr=270, zr=0}
    },
    [8] = {
        {isNew=false, id=10671, radius=8.4, x=-2454.252, y=-125.72504, z=27.12412},
        {isNew=true, id=10671, x=-2454.5, y=-123.059, z=27.5, xr=0, yr=0, zr=0}
    },
    [9] = {
        {isNew=false, id=1497, radius=3.5, x=965.89465, y=2161.281, z=10.96091},
        {isNew=true, id=1491, x=966.07898, y=2162.1599, z=9.8, xr=0, yr=0, zr=270},
        {isNew=true, id=1491, x=966.09961, y=2159.1348, z=9.8, xr=0, yr=0, zr=90}
    }
}
addRemoteEvents{"Easter:requestHidingRabbits", "Easter:onHidingRabbitFound"}

function Easter:constructor()
    self.m_Objects = {}
    for day, data in pairs(Easter.RabbitObjects) do
        if getRealTime().yearday - Easter.startDay >= day then
            for index, object in pairs(data) do
                if object.isNew then
                    self.m_Objects[#self.m_Objects+1] = createObject(object.id, object.x, object.y, object.z, object.xr, object.yr, object.zr)
                else
                    removeWorldModel(object.id, object.radius, object.x, object.y, object.z)
                end
            end
        end
    end
    addEventHandler("Easter:requestHidingRabbits", root, bind(self.requestHidingRabbits, self))
    addEventHandler("Easter:onHidingRabbitFound", root, bind(self.onHidingRabbitFound, self))
end

function Easter:destructor()
    for day, data in pairs(Easter.RabbitObjects) do
        for index, object in pairs(data) do
            if object.isNew == false then
                restoreWorldModel(object.id, object.radius, object.x, object.y, object.z)
            end
        end
    end
end

function Easter:requestHidingRabbits()
    local rabbit = 0
    local result = sql:queryFetchSingle("SELECT RabbitsFound FROM ??_easter_rabbit_data WHERE UserId = ?", sql:getPrefix(), client:getId())
	if result then
        rabbit = result.RabbitsFound
    end
    if Easter.today - Easter.startDay >= rabbit then
        client:triggerEvent("Easter:loadHidingRabbit", rabbit)
    end
end

function Easter:onHidingRabbitFound(rabbit)
    if rabbit == 1 then
        sql:queryExec("INSERT INTO ??_easter_rabbit_data (UserId, RabbitsFound) VALUES (?, ?)", sql:getPrefix(), client:getId(), 1)
    else
        sql:queryExec("UPDATE ??_easter_rabbit_data SET RabbitsFound = ? WHERE UserId = ?", sql:getPrefix(), rabbit, client:getId())
    end
    client:getInventory():giveItem("Osterei", 10)
    client:sendSuccess("Du hast ein Helferchen des Osterhasen gefunden! Du hast 10 Ostereier erhalten!")
end