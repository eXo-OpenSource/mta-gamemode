-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/TemporaryAdminEvent.lua
-- *  PURPOSE:     temp class to create event on friday
-- *
-- ****************************************************************************


function table.valueToIndex(tab)
	local temp = {}
	for k, v in pairs(tab) do
		temp[v] = true
	end
	return temp
end

TemporaryAdminEvent = inherit(Singleton)
TemporaryAdminEvent.ms_MarkerPositions = {
    {-2664.0000000, 1768.6000000, 15.0000000, "checkpoint", 30, 199, 188, 55, 50}, --0
    {359.8999900, 250.8999900, 1.0000000, "checkpoint", 200, 199, 188, 55, 50}, --1
    {376.7999900, -722.9000200, 19.8000000, "checkpoint", 15, 0, 0, 255, 50}, --2
    {334.3999900, -1190.1000000, 76.3000000, "checkpoint", 20, 0, 0, 255, 50}, --3
    {105.9000000, -1490.7000000, 13.0000000, "checkpoint", 20, 0, 0, 255, 50}, --4
    {288.1000100, -1485.3000000, 30.6000000, "checkpoint", 20, 0, 0, 255, 50}, --5
    {387.0000000, -1522.2000000, 32.3000000, "checkpoint", 25, 199, 188, 55, 50}, --6
    {623.4000200, -1575.8000000, 15.5000000, "checkpoint", 20, 0, 0, 255, 50}, --7
    {820.7999900, -1439.6000000, 13.5000000, "checkpoint", 9, 0, 0, 255, 50}, --8
    {1070.6000000, -1495.0000000, 13.6000000, "checkpoint", 10, 0, 0, 255, 50}, --9
    {1331.2000000, -1853.4000000, 13.4000000, "checkpoint", 20, 0, 0, 255, 50}, --10
    {1461.7000000, -1734.7000000, 13.4000000, "checkpoint", 15, 199, 188, 55, 50}, --11
}

function TemporaryAdminEvent:constructor()
    self.m_Markers = {}
    self.m_Blips = {}
    self.m_PlayersFinished = {}
    for i, v in ipairs(TemporaryAdminEvent.ms_MarkerPositions) do
        local m = createMarker(unpack(v))
        m.m_Tempevent_index = i
        addEventHandler("onMarkerHit", m, bind(self.onEventMarkerHit, self))
        self.m_Markers[i] = m
    end
    return self
end

function TemporaryAdminEvent:destructor()
	for _, v in pairs(self.m_Players) do
		v.currentBlip:delete()
	end

	for _, v in pairs(self.m_Markers) do
		v:destroy()
	end
end

function TemporaryAdminEvent:startEvent()
    if not self.m_Started then
        self.m_Started = true
        self.m_Players = table.valueToIndex(AdminEventManager:getSingleton().m_CurrentEvent.m_Players)
        for i, v in pairs(self.m_Players) do
            iprint(i, v)
            self.m_Players[i] = {}
            self.m_Players[i].currentMarker = 1
            self.m_Players[i].currentBlip = Blip:new("Waypoint.png", TemporaryAdminEvent.ms_MarkerPositions[1][1], TemporaryAdminEvent.ms_MarkerPositions[1][2], i, 9999)
            i:sendInfo(_("Der Triathlon beginnt! Bitte folge den Markierungen auf der Map.", i))
        end
    end
end


function TemporaryAdminEvent:onEventMarkerHit(hitElement, dim)
    local i = source.m_Tempevent_index
    if hitElement.type == "player" and dim and i then
        if self.m_Players and self.m_Players[hitElement] then
            if self.m_Players[hitElement].currentMarker >= i then
                if TemporaryAdminEvent.ms_MarkerPositions[i+1] then
                    hitElement:sendInfo(_("Du hast Wegpunkt %s/%s durchquert, auf zum nächsten!", hitElement, i, #self.m_Markers))
                    self.m_Players[hitElement].currentMarker = self.m_Players[hitElement].currentMarker + 1
                    self.m_Players[hitElement].currentBlip:delete()
                    self.m_Players[hitElement].currentBlip = Blip:new("Waypoint.png", TemporaryAdminEvent.ms_MarkerPositions[i+1][1], TemporaryAdminEvent.ms_MarkerPositions[i+1][2], hitElement, 9999)
                else
                    if not hitElement.m_TriathlonFinished then
                        hitElement:sendInfo(_("Du hast den Triathlon geschafft!", hitElement))
                        hitElement.m_TriathlonFinished = true
                        table.insert(self.m_PlayersFinished, hitElement)
                        self.m_Players[hitElement].currentBlip:delete()
                    end
                end
            else
                hitElement:sendError(_("Dies ist Wegpunkt #%s, du bist aber erst bei Wegpunkt #%s.", hitElement, i, self.m_Players[hitElement].currentMarker))
            end
        end
    end
end

-- dirty

addCommandHandler("tempevent_create",
    function(player)
        if player:getRank() >= 6 then
            if AdminEventManager:getSingleton().m_CurrentEvent then
				TemporaryAdminEvent:new()
				player:sendShortMessage(_("Eventmarker erstellt. gestartet wird mit /tempevent_startevent", player))
            else
                player:sendShortMessage(_("Bitte erst das Admin-Event starten.", player))
            end
        end
    end
)

addCommandHandler("tempevent_start",
    function(player)
        if player:getRank() >= 6 then
            if TemporaryAdminEvent:isInstantiated() then
				TemporaryAdminEvent:getSingleton():startEvent()
            else
                player:sendShortMessage(_("Bitte erst das Temp-Event erstellen (/tempevent_createevent).", player))
            end
        end
    end
)

addCommandHandler("tempevent_stop",
    function(player)
        if player:getRank() >= 6 then
            if TemporaryAdminEvent:isInstantiated() and TemporaryAdminEvent:getSingleton().m_Started then
				delete(TemporaryAdminEvent:getSingleton())
            else
                player:sendShortMessage(_("Das Event ist nicht gestartet.", player))
            end
        end
    end
)

addCommandHandler("tempevent_listplayers",
    function(player)
        if player:getRank() >= 1 then
			if TemporaryAdminEvent:isInstantiated() and TemporaryAdminEvent:getSingleton().m_Started then
                outputConsole("Liste der Spieler im Ziel:", player)
                for i, v in ipairs(TemporaryAdminEvent:getSingleton().m_PlayersFinished) do
                    outputConsole(("%02d - %s"):format(i, v:getName()), player)
                end
                outputConsole("Ende der Liste.", player)
            else
                player:sendShortMessage(_("Das Event ist nicht gestartet.", player))
            end
        end
    end
)
