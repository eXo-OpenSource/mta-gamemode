-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/Deathmatch/DMMatch.lua
-- *  PURPOSE:     Deathmatch match class
-- *
-- ****************************************************************************
DeathmatchMatch = inherit(Deathmatch)

function DeathmatchMatch:constructor (...)
    local args = {...}
    outputDebug("Creating a new Match #"..args[1].."...")

    self.m_ID = args[1]
    self.m_Data = {
        Type = args[3];
        Status = 1;
        Map = args[6];
        Weapon = args[5];
        Passworded = args[4][1];
        Password = args[4][2];
    }
    self.m_Players = {args[2]}
    self.m_Host = args[2]
end

function DeathmatchMatch:destructor ()
    outputDebug("Deleting Match #"..self.m_ID.."...")
end

function DeathmatchMatch:deleteMatch ()
    Deathmatch:getSingleton():deleteMatch(self.m_ID)
end

function DeathmatchMatch:getMatchData ()
    return {
        id = self.m_ID;
        type = self.m_Data["Type"];
        status = self.m_Data["Status"];
        map = self.m_Data["Map"];
        weapon = self.m_Data["Weapon"];
        passworded = self.m_Data["Passworded"];
        players = self.m_Players;
        host = self.m_Host;
    }
end

function DeathmatchMatch:setStatus (status)
    if Deathmatch.Status[status] then
        self.m_Data["Status"] = status
    end

    Deathmatch:getSingleton():syncData()
end

function DeathmatchMatch:addPlayer (player)
    player:setMatchID(self.m_ID)
    table.insert(self.m_Players, player)

    -- at the end -> sync it
    Deathmatch:getSingleton():syncData()
end

function DeathmatchMatch:removePlayer (player)
    player:setMatchID(0)
    table.removevalue(self.m_Players, player)


    -- at the end -> sync it
    Deathmatch:getSingleton():syncData()
end

-- DEBUG
addCommandHandler("testf", function ()
    local instance = Deathmatch:getSingleton():newMatch(getPlayerFromName("StiviK"), math.random(3), {false, ""}, 1, 3)
    addCommandHandler("testf2", function ()
        instance:setStatus(math.random(3))
    end)
end)

addCommandHandler("testb", function ()
    Deathmatch:getSingleton():getMatchFromID(1):deleteMatch()
end)