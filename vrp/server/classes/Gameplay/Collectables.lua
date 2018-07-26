-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Collectables.lua
-- *  PURPOSE:     Collectables server-side class
-- *
-- ****************************************************************************
Collectables = inherit(Singleton)

addEvent("requestCollectables", true)
addEvent("checkCollectableHit", true)

Collectables.COLLECT_COUNT = 40

function Collectables:constructor()
    addEventHandler("requestCollectables", root, bind(self.sendCollectables,self))
    addEventHandler("checkCollectableHit", root, bind(self.checkCollectable,self))
    self.m_Collectables = {}
	self.m_CollectablesIds = {}

    local result = sql:queryFetch("SELECT * FROM ??_collectables", sql:getPrefix())

    for k, v in ipairs(result) do
        self.m_Collectables[v.Id] = {v.PosX, v.PosY, v.PosZ}
        table.insert(self.m_CollectablesIds, v.Id)
    end
end

function Collectables:checkCollectable(collectableID)
    if not client then return end
    local x, y, z = getElementPosition(client)
	local px, py, pz = unpack(self.m_Collectables[collectableID])

    if getDistanceBetweenPoints3D(x, y, z, px, py, pz) >= 10 then
        print(("WARNING: %s is maybe cheatin' @ collectables"):format(getPlayerName(client)))
    else
		local collectables = client:getCollectables()

		if (table.find(collectables.collectable, collectableID)) then
			table.removevalue(collectables.collectable, collectableID)
			table.insert(collectables.collected, collectableID)
			client:setCollectables(collectables)

			client:sendShortMessage(_("Du hast ein eXo-Logo gefunden!\nDafür erhälst du %s eXo-Points!", client, 200))
			client:givePoints(200)
			sql:queryExec("UPDATE ??_collectables SET CollectCount = CollectCount + 1 WHERE Id = ?", sql:getPrefix(), collectableID)
		else
			print(("WARNING: %s is maybe cheatin, already collected?' @ collectables"):format(getPlayerName(client)))
		end
    end
end

function Collectables:generateForPlayer(player)
    local collectables = table.deepcopy(self.m_CollectablesIds)
    local collectablesForPlayer = {
		collectable = {},
		collected = {}
	}

    for i = 1, Collectables.COLLECT_COUNT do
        local item = math.random(1, table.size(collectables))
        table.insert(collectablesForPlayer.collectable, item)
        table.remove(collectables, item)
	end

	player:setCollectables(collectablesForPlayer)
	return collectablesForPlayer
end

function Collectables:sendCollectables()
    if not client then return end

    if not client:getCollectables() or table.size(client:getCollectables()) ~= 2 then
        self:generateForPlayer(client)
	end

	local collectable = {}

	for k, v in ipairs(client:getCollectables().collectable) do
		collectable[v] = self.m_Collectables[v]
	end

    triggerClientEvent(client, "reciveCollectables", client, collectable)
end
