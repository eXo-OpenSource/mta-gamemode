-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/ChristmasTruckManager.lua
-- *  PURPOSE:     christmas truck manager class
-- *
-- ****************************************************************************
ChristmasTruckManager = inherit(Singleton)
ChristmasTruckManager.MinPlayers = 3
ChristmasTruckManager.Price = 15000
ChristmasTruckManager.MaxPresents = 32
ChristmasTruckManager.MoneyBonusPerPresent = 50
ChristmasTruckManager.SugarcaneBonusIfFull = 5
ChristmasTruckManager.ExpireTime = 24*60*60

function ChristmasTruckManager:constructor()
    self.m_FactionPresents = {}
    self.m_ChristmasTrees = { -- factionId, object
        [1] = createObject(6972, 2764.90, -2383.23, 12.6625),
        [2] = createObject(6972, 2765.54, -2508.25, 12.6625),
        [3] = createObject(6972, 2744.84, -2421.651, 12.6625),
        [5] = createObject(6972, 683.15, -1255.801, 12.5837),
        [7] = createObject(6972, 2492.44, -1668.54, 12.36312),
        [8] = createObject(6972, 2225.167, -1431.90, 22.9),
        [10] = createObject(6972, 2782.35, -2019.28, 12.55),
    }
    for id, object in pairs(self.m_ChristmasTrees) do
        if FactionManager:getSingleton():getFromId(id) then
            object.FactionId = id
            object:setDoubleSided(true)
            object:setData("clickable", true, true)
            addEventHandler("onElementClicked", object, bind(self.onTreeClick, self))
        end
    end
    
    local result = sql:queryFetch("SELECT Id, ChristmasPresents FROM ??_factions WHERE active = 1", sql:getPrefix())
    for i, data in pairs(result) do
        self.m_FactionPresents[data["Id"]] = fromJSON(data["ChristmasPresents"])
    end

    self.m_BankAccount = BankServer.get("action.trucks")
    self.m_Marker = createMarker(-1568.19, 2702.68, 54.84, "cylinder", 1, 255, 255, 255 )
    self.m_ColShape = createColSphere(-1568.19, 2702.68, 54.84, 2)

    self:checkPresents()
    setTimer(bind(self.checkPresents, self), 5*60*1000, 0)

    addEventHandler("onColShapeHit", self.m_ColShape, bind(self.onStartMarkerHit, self))
end

function ChristmasTruckManager:destructor()
    for factionId, data in pairs(self.m_FactionPresents) do 
        sql:queryExec("UPDATE ??_factions SET ChristmasPresents = ? WHERE Id = ?", sql:getPrefix(), toJSON(data) or toJSON({}), factionId)
    end
end

function ChristmasTruckManager:onTreeClick(button, state, player)
    if button == "left" and state == "down" then
        if getDistanceBetweenPoints3D(source.position, player.position) < 5 then
            if player:getPlayerAttachedObject() and player:getPlayerAttachedObject():getData("ChristmasTruck:Present") then
                if player:getFaction() and player:getFaction():getId() == source.FactionId then
                    if self.m_Current then
                        self.m_Current:onPresentDeliver(player, source)
                    else
                        --TODO maybe do something better?!?
                        local box = player:getPlayerAttachedObject()
                        player:detachPlayerObject(box)
                        box.Present:destroy()
                        box:destroy()
                    end
                else
                    player:sendError(_("Sei artig und bringe die Geschenke zum Weihnachtsbaum deiner Fraktion!", player))
                end
            else
                if player:getFaction() and player:getFaction():getId() == source.FactionId then
                    local temp = {}
                    for i, timestamp in pairs(self:getFactionPresents(player:getFaction())) do
                        temp[i] = timestamp + ChristmasTruckManager.ExpireTime
                    end
                    player:triggerEvent("ChristmasTruckTreeGUI:open", source ,temp)
                end
            end
        end
    end
end

function ChristmasTruckManager:onStartMarkerHit(hitElement, matchingDimension)
    if hitElement:getType() == "player" and matchingDimension then
		local faction = hitElement:getFaction()
		if faction then
			if (faction:isEvilFaction() or faction:isStateFaction()) then
                if hitElement:isFactionDuty() then	
                    if ActionsCheck:getSingleton():isActionAllowed(hitElement) then
                        QuestionBox:new(hitElement, "Möchtest du einen Weihnachtstruck starten?", 
                        function()
                            self:startChristmasTruck(hitElement)
                        end, function() end, source, 10)
                    end
                else
                    hitElement:sendError(_("Du bist nicht im Dienst!", hitElement))
                end
			else
				hitElement:sendError(_("Den Weihnachtstruck können nur Mitglieder einer Fraktion starten!", hitElement))
			end
		else
			hitElement:sendError(_("Den Weihnachtstruck können nur Fraktions-Mitglieder starten!", hitElement))
		end
	end
end

function ChristmasTruckManager:startChristmasTruck(player)
	if ActionsCheck:getSingleton():isActionAllowed(player) then
		local faction = player:getFaction()

		if faction:isEvilFaction() then
			if player:isFactionDuty() then
				if FactionState:getSingleton():countPlayers() < ChristmasTruckManager.MinPlayers and not DEBUG then
					player:sendError(_("Es müssen mindestens 3 Staatsfraktionisten online sein!", player))
					return
				end
			else
				player:sendError(_("Du trägst nicht deine Fraktionsfarben!",player))
				return
			end
		elseif faction:isStateFaction() then
			if player:isFactionDuty() then
				if FactionEvil:getSingleton():countPlayers() < ChristmasTruckManager.MinPlayers and not DEBUG then
					player:sendError(_("Es müssen mindestens 3 Spieler böser Fraktionen online sein!", player))
					return
                end
			else
				player:sendError(_("Du bist nicht im Dienst!",player))
				return
			end
		else
			player:sendError(_("Ungültige Fraktion!",player))
            return
		end

        if self:getPresentsCount(faction) >= ChristmasTruckManager.MaxPresents then
            player:sendError("Sei nicht so gierig!\nDer Weihnachtsbaum deiner Fraktion ist voll!")
            return
        end

		if faction then
            if ActionsCheck:getSingleton():isActionAllowed(player) then
                if faction:transferMoney(self.m_BankAccount, ChristmasTruckManager.Price, "Weihnachts-Truck", "Action", "ChristmasTruck") then
                    ActionsCheck:getSingleton():setAction("Weihnachtstruck")
                    if self.m_Current then delete(self.m_Current) end
                    self.m_Current = ChristmasTruck:new(player)
                    PlayerManager:getSingleton():breakingNews("Ein Truck mit Geschenken ist unterwegs")
                    Discord:getSingleton():outputBreakingNews("Ein Weihnachtstruck wurde gestartet")
                    FactionState:getSingleton():sendWarning("Ein Weihnachtstruck wurde gestartet", "Neuer Einsatz", true, ChristmasTruck.spawnPos)
                    FactionEvil:getSingleton():sendWarning("Ein Weihnachtstruck wurde gestartet", "Neue Aktion", true, ChristmasTruck.spawnPos)
                    StatisticsLogger:getSingleton():addActionLog("Weihnachtstruck", "start", player, player:getFaction(), "faction")
                end
            end
		else
			player:sendError(_("Du bist in keiner Fraktion!",player))
		end
	end
end

function ChristmasTruckManager:checkPresents()
    for i, faction in pairs(FactionManager:getSingleton():getAllFactions()) do
        if self.m_FactionPresents[faction:getId()] then
            for index, timestamp in pairs(self.m_FactionPresents[faction:getId()]) do
                if timestamp <= getRealTime().timestamp - ChristmasTruckManager.ExpireTime then
                    self.m_FactionPresents[faction:getId()][index] = nil
                    faction:sendShortMessage("Die Zeit eines Geschenks ist abgelaufen!\nDas Geschenk wurde entfernt!")
                end
            end
        end
    end
end

function ChristmasTruckManager:getPresentsCount(faction)
    local factionId
    if type(faction) == "number" then 
        factionId = faction
    else
        factionId = faction:getId()
    end

    return table.size(self.m_FactionPresents[factionId])
end

function ChristmasTruckManager:getFactionPresents(faction)
    local factionId
    if type(faction) == "number" then 
        factionId = faction
    else
        factionId = faction:getId()
    end

    return self.m_FactionPresents[factionId]
end