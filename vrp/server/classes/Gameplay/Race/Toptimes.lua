-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Race/Toptimes.lua
-- *  PURPOSE:     Toptimes class
-- *
-- ****************************************************************************
Toptimes = inherit(Object)

function Toptimes:constructor(sMapname)
    assert(type(sMapname == "string"))
    local result = sql:queryFetchSingle("SELECT * FROM ??_toptimes WHERE Name = ?", sql:getPrefix(), sMapname)
    self.m_Mapname = sMapname

    if result then
        self.m_MapID = result.ID
        self.m_Toptimes = fromJSON(result.Times)

        self:updatePlayernames()
    else
        self.m_Toptimes = {}
        local _, _, insertID = sql:queryFetch("INSERT INTO ??_toptimes (Name, Times) VALUES (?, ?)", sql:getPrefix(), self.m_Mapname, toJSON(self.m_Toptimes))
        self.m_MapID = insertID
        return
    end
end

function Toptimes:destructor()
	sql:queryExec("UPDATE ??_toptimes SET Times = ? WHERE ID = ?", sql:getPrefix(), toJSON(self.m_Toptimes), self.m_MapID)
end

function Toptimes:save()
	sql:queryExec("UPDATE ??_toptimes SET Times = ? WHERE ID = ?", sql:getPrefix(), toJSON(self.m_Toptimes), self.m_MapID)
end

function Toptimes:updatePlayernames()
    for _, Toptime in pairs(self.m_Toptimes) do
        Toptime.name = Account.getNameFromId(Toptime.PlayerID)
    end
end

function Toptimes:addNewToptime(PlayerID, time)
    -- Update current time if exists
    for _, v in pairs(self.m_Toptimes) do
        if v.PlayerID == PlayerID then
            if v.time > time then
                v.time = time
                v.date = getRealTime().timestamp
                self:sortToptimes()
                return true
            end
            return false
        end
    end

    -- Anyways create one
    local newHuntertime = {}
    newHuntertime.PlayerID = PlayerID
    newHuntertime.time = time
    newHuntertime.name = Account.getNameFromId(PlayerID)
    newHuntertime.date = getRealTime().timestmap

    table.insert(self.m_Toptimes, newHuntertime)
    self:sortToptimes()
    return true
end

function Toptimes:getToptime()
	return self.m_Toptimes[1] and self.m_Toptimes[1].time or 0
end

function Toptimes:removeToptime(ID)
    if self.m_Toptimes[ID] then
        table.remove(self.m_Toptimes, ID)
        self:sortToptimes()
        return true
    end
    return false
end

function Toptimes:getToptimeFromPlayer(PlayerID)
    for i, v in pairs(self.m_Toptimes) do
        if v.PlayerID == PlayerID then
            return v, i
        end
    end

    return false
end

function Toptimes:getPlayerFromToptime(ID)
	if self.m_Toptimes[ID] then
		return self.m_Toptimes[ID].PlayerID
	end
	return false
end

function Toptimes:getMapID()
	return self.m_MapID
end

--[[function Toptimes:sendToptimes(Player)
    if Player then
        callClientFunction(Player, "setToptimeTable", self.m_Toptimes)
    end
    return false
end]]

function Toptimes:sortToptimes()
    -- Storage the old last toptime
    --local old12 = self.m_Toptimes[12]

    -- Sort table
    table.sort(self.m_Toptimes,
        function(a, b)
            return a.time < b.time
        end
    )

	self:save()
	--[[
    -- Storage the new last toptime
    local new12 = self.m_Toptimes[12]

    -- Update player toptimes
    if old12 ~= new12 then
        for _, Player in pairs(getElementsByType("player")) do
           if Player.m_ID == old12.PlayerID then
               if getPlayerGamemode(Player) == gGamemodeDM then
                   Player:setData("TopTimes", Player:getData("TopTimes") - 1)
                   Player:setData("TopTimeCounter", Player:getData("TopTimeCounter") - 1)
               elseif getPlayerGamemode(Player) == gGamemodeRA then
                   Player:setData("TopTimesRA", Player:getData("TopTimesRA") - 1)
               end
           end
        end
    end]]
end

function Toptimes.getPlayerToptimeCount(player, prefix)
    local toptimeCount = 0

    local result = sql:queryFetch("SELECT Name, Times FROM ??_toptimes ORDER BY ID ASC", sql:getPrefix())
    if result then
        for _, v in pairs(result) do
            if string.find(v.mapname, prefix) then
                local toptimeTable = fromJSON(v.toptimes)
                if toptimeTable and type(toptimeTable) == "table" then
                    for i = 1, 12 do
                        if toptimeTable[i] and toptimeTable[i].PlayerID == player.m_ID then
                            toptimeCount = toptimeCount + 1
                        end
                    end
                end
            end
        end
    end

    return toptimeCount
end
