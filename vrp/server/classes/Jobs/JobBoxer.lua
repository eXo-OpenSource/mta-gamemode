-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobBoxer.lua
-- *  PURPOSE:     Boxer job class
-- *
-- ****************************************************************************

JobBoxer = inherit(Job)

function JobBoxer:constructor()
    Job.constructor(self)
    self.m_Pickup = Pickup(773.99, 5.475, 1000.78, 3, 1239, 1500)
    self.m_Pickup:setInterior(5)

    self.m_Marker = Marker(773.99, -0.6, 999.8, "cylinder", 1.0, 0, 0, 255, 255)
    self.m_Marker:setInterior(5)

    self:createTopList()
    self.m_PlayerLevelCache = {}
    self.m_BankAccountServer = BankServer.get("job.boxer")

    addEventHandler("onPickupHit", self.m_Pickup, 
        function(player)
            if player:getJob() == self then
                triggerClientEvent(player, "boxerJobFightList", player)
            else
                player:sendError("Du bist kein Boxer!")
            end
        end
    )

    addEventHandler("onMarkerHit", self.m_Marker,
        function(player)
            self:openTopList(player)
        end
    )

    PlayerManager:getSingleton():getWastedHook():register(
		function(player, killer, weapon)
			if self:isPlayerBoxing(player) == true then
				if ExecutionPed.Map[player] then delete(ExecutionPed.Map[player]) end
				if player:getExecutionPed() then delete(player:getExecutionPed()) end
                player:triggerEvent("abortDeathGUI", true)
                fadeCamera(player, false)
                setTimer(self.onDeath, 1750, 1, self, player)
				return true
			end
		end
	)

    addRemoteEvents{"boxerJobStartJob", "boxerJobEndJob", "boxerJobAbortJob"}
    addEventHandler("boxerJobStartJob", root, bind(self.startJob, self, typ))
    addEventHandler("boxerJobEndJob", root, bind(self.endJob, self))
    addEventHandler("boxerJobAbortJob", root, bind(self.abortJob, self))
end

function JobBoxer:destructor()
    if isElement(self.m_Pickup) then
        self.m_Pickup:destroy()
    end
    if isElement(self.m_Marker) then
        self.m_Marker:destroy()
    end
end

function JobBoxer:start(player)
    player:setData("Boxer.Income", 0)
end

function JobBoxer:checkRequirements(player)
	if not (player:getJobLevel() >= JOB_LEVEL_BOXER) then
		player:sendError(_("Für diesen Job benötigst du mindestens Joblevel %d", player, JOB_LEVEL_BOXER))
		return false
	end
	return true
end

function JobBoxer:startJob(typ, dimension)
    client:setPublicSync("JobBoxer:activeLevel", typ)
    client:sendInfo("Du bist nun im Ring,\ndrücke L um aufzugeben!")

    client.m_JobBoxerHealth = client:getHealth()
    client.m_JobBoxerArmor = client:getArmor()
    client:setHealth(100)
    client:setArmor(0)
    client:setPosition(758.42, 11.18, 1001.16)
    client:setRotation(0, 0, 270)
    client:setCameraTarget(client)
    client:setDimension(dimension)

    client.m_LastJobAction = getRealTime().timestamp

    setPedFightingStyle(client, 5)
end

function JobBoxer:endJob()
    local level = client:getPublicSync("JobBoxer:activeLevel")
    self.m_BankAccountServer:transferMoney({client, true}, JobBoxerMoney[level], "Boxer-Job", "Job", "Boxer")
    client:setData("Boxer.Income", client:getData("Boxer.Income") + JobBoxerMoney[level] )
    client:sendSuccess(("Du hast den Kampf gewonnen!\nDu erhälst dafür %s $!"):format(JobBoxerMoney[level]))

    sql:queryExec("INSERT INTO ??_boxerlevel (UserId, Boxerlevel) VALUES(?, 1) ON DUPLICATE KEY UPDATE Boxerlevel = Boxerlevel + 1", sql:getPrefix(), client:getId())
    local level = self:getPlayerLevel(client)[3]
    self.m_PlayerLevelCache[client:getName()][3] = level + 1
    self:updateCachedTopList(client)
    client:setPublicSync("JobBoxer:Level", client:getPublicSync("JobBoxer:Level")+1)

    client:setHealth(client.m_JobBoxerHealth)
    client:setArmor(client.m_JobBoxerArmor)
    client:setPosition(763.26, 5.48, 1000.71)
    client:setRotation(0, 0, 270)
    client:setCameraTarget(client)
    client:setDimension(0)

    client:setPublicSync("JobBoxer:activeLevel", false)
    setPedFightingStyle(client, 15)
end

function JobBoxer:abortJob()
    client:sendInfo("Du hast den Kampf aufgegeben!")

    client:setHealth(client.m_JobBoxerHealth)
    client:setArmor(client.m_JobBoxerArmor)
    client:setPosition(763.26, 5.48, 1000.71)
    client:setRotation(0, 0, 270)
    client:setCameraTarget(client)
    client:setDimension(0)

    client:setPublicSync("JobBoxer:activeLevel", false)
    setPedFightingStyle(client, 15)
end

function JobBoxer:leaveJobBuilding(player)
    if player:getData("Boxer.Income") and player:getData("Boxer.Income") > 1 then
        local income = player:getData("Boxer.Income")
        player:setData("Boxer.Income", 0)
        local duration = getRealTime().timestamp - player.m_LastJobAction
        StatisticsLogger:getSingleton():addJobLog(player, "jobBoxer", duration, income)
    end
end

function JobBoxer:isPlayerBoxing(player)
    if player:getPublicSync("JobBoxer:activeLevel") then
        return true
    else
        return false
    end
end

function JobBoxer:onDeath(player)
    local skin = player:getModel()
    local interior = player:getInterior()
    spawnPlayer(player, 763.26, 5.48, 1000.71, 270, skin, interior, 0)
    player:setAlpha(255)
    setCameraTarget(player, player)
    fadeCamera(player, true)
end

function JobBoxer:createTopList()
    self.m_BoxerLevelTable = {}
    local int = 0

    local result = sql:queryFetch("SELECT UserId, Boxerlevel FROM ??_boxerlevel ORDER BY Boxerlevel DESC LIMIT 10", sql:getPrefix())
    for _, row in ipairs(result) do
        int = int + 1
        self.m_BoxerLevelTable[int] = {Account.getNameFromId(row["UserId"]), row["Boxerlevel"]}
    end
end

function JobBoxer:getPlayerLevel(player)
    if self.m_PlayerLevelCache[player:getName()] then 
        if getTickCount() - self.m_PlayerLevelCache[player:getName()][4] < 600000 then
            return self.m_PlayerLevelCache[player:getName()]
        end
    else
        local result = sql:queryFetch("SELECT (SELECT COUNT(*) FROM ??_boxerlevel WHERE Boxerlevel >= ?) AS Position, Boxerlevel FROM ??_boxerlevel WHERE UserId=?", sql:getPrefix(), player:getPublicSync("JobBoxer:Level"), sql:getPrefix(), player:getId())
        self.m_PlayerLevelCache[player:getName()] = {0, player:getName(), 0, getTickCount()}
        for _, row in ipairs(result) do
            self.m_PlayerLevelCache[player:getName()] = {row["Position"] or 0, player:getName(), row["Boxerlevel"] or 0, getTickCount()}
        end
        return self.m_PlayerLevelCache[player:getName()]
    end
end

function JobBoxer:openTopList(player)
    local playerTable = self:getPlayerLevel(player)
    triggerClientEvent(player, "boxerJobTopList", player, self.m_BoxerLevelTable, playerTable)
    player:sendShortMessage("Deine eigene Statistik aktualisiert sich alle 10 Minuten.")
end

function JobBoxer:updateCachedTopList(player)
    local bNameFound = false
    local bTableIndex = false
    local bUpperIndex = false
    for i = 1, 10 do
        if self.m_BoxerLevelTable[i] then
            if self.m_BoxerLevelTable[i][1] == player:getName() then
                bNameFound = true
                bTableIndex = i
                bUpperIndex = bTableIndex-1
            end
        end
    end
    if bNameFound == true then
        self.m_BoxerLevelTable[bTableIndex][2] = self:getPlayerLevel(player)[3]
        for i = 10, 1, -1 do 
            if self.m_BoxerLevelTable[bTableIndex] then
                if self.m_BoxerLevelTable[i] then
                    if self.m_BoxerLevelTable[bTableIndex][2] > self.m_BoxerLevelTable[i][2] then
                        bUpperIndex = i
                    end
                end
            end
        end
        if self.m_BoxerLevelTable[bTableIndex] then
            if self.m_BoxerLevelTable[bUpperIndex] then
                if self.m_BoxerLevelTable[bTableIndex][2] > self.m_BoxerLevelTable[bUpperIndex][2] then
                    local temp = self.m_BoxerLevelTable[bUpperIndex]
                    self.m_BoxerLevelTable[bUpperIndex] = self.m_BoxerLevelTable[bTableIndex]
                    self.m_BoxerLevelTable[bTableIndex] = temp
                end
            end
        end
    else
        local bUpperIndex = 10
        for i = 10, 1, -1 do 
            if self.m_BoxerLevelTable[i] then
                if self:getPlayerLevel(player)[3] > self.m_BoxerLevelTable[i][2] then
                    bUpperIndex = i
                end
            end
        end
        if not self.m_BoxerLevelTable[1] then
            self.m_BoxerLevelTable[1] = {player:getName(), self:getPlayerLevel(player)[3]}
            return
        end
        if self:getPlayerLevel(player)[3] > self.m_BoxerLevelTable[bUpperIndex][2] then
            if not self.m_BoxerLevelTable[10] then
                for i = 10, 1, -1 do
                    if not self.m_BoxerLevelTable[i] then
                        self.m_BoxerLevelTable[i] = {player:getName(), self:getPlayerLevel(player)[3]}
                    end
                end
            end
        end
    end
end