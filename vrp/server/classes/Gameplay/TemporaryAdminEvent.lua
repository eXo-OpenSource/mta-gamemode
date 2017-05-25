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

TemporaryAdminEvent = inherit(Object)
TemporaryAdminEvent.ms_MarkerPositions = {
    {1913, -2358, 13.5, "checkpoint", 30, 0, 0, 200},
    {1913, -2398, 13.5, "checkpoint", 30, 0, 200, 0},
    {1913, -2428, 13.5, "checkpoint", 30, 200, 0, 0},
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
            if self.m_Players[hitElement].currentMarker == i then
                if TemporaryAdminEvent.ms_MarkerPositions[i+1] then
                    hitElement:sendInfo(_("Du hast Wegpunkt %s/%s durchquert, auf zum nächsten!", hitElement, i, #self.m_Markers))
                    self.m_Players[hitElement].currentMarker = self.m_Players[hitElement].currentMarker + 1
                    self.m_Players[hitElement].currentBlip:delete()
                    self.m_Players[hitElement].currentBlip = Blip:new("Waypoint.png", TemporaryAdminEvent.ms_MarkerPositions[i][1], TemporaryAdminEvent.ms_MarkerPositions[i][2], hitElement, 9999)
                else
                    hitElement:sendInfo(_("Du hast den Triathlon geschafft!", hitElement))
                    table.insert(self.m_PlayersFinished, hitElement)
                    self.m_Players[hitElement].currentBlip:delete()
                end
            else
                hitElement:sendError(_("Dies ist Wegpunkt #%s, du bist aber erst bei Wegpunkt #%s.", hitElement, i, self.m_Players[hitElement].currentMarker))
            end
        end
    end
end


function TemporaryAdminEvent:stopEvent()
    if self.m_Started then
        self.m_Started = false
        for i, v in pairs(self.m_Markers) do
            v:destroy()
        end
    end
end



-- dirty

local curEvent
addCommandHandler("tempevent_createevent",
    function(player)
        if player:getRank() >= 6 then
            if AdminEventManager:getSingleton().m_CurrentEvent then
                if not curEvent then
                    curEvent = TemporaryAdminEvent:new()
                    player:sendShortMessage(_("Eventmarker erstellt. gestartet wird mit /tempevent_startevent", player))
                end
            else
                player:sendShortMessage(_("Bitte erst das Admin-Event starten.", player))
            end
        end
    end
)

addCommandHandler("tempevent_startevent",
    function(player)
        if player:getRank() >= 6 then
            if curEvent then
                curEvent:startEvent()
            else
                player:sendShortMessage(_("Bitte erst das Temp-Event erstellen (/tempevent_createevent).", player))
            end
        end
    end
)

addCommandHandler("tempevent_stopevent",
    function(player)
        if player:getRank() >= 6 then
            if curEvent and curEvent.m_Started then
                curEvent:stopEvent()
                curEvent:delete()
            else
                player:sendShortMessage(_("Das Event ist nicht gestartet.", player))
            end
        end
    end
)

addCommandHandler("tempevent_listplayers",
    function(player)
        if player:getRank() >= 1 then
            if curEvent and curEvent.m_Started then
                outputConsole("Liste der Spieler im Ziel:", player)
                for i, v in ipairs(curEvent.m_PlayersFinished) do
                    outputConsole(("%02d - %s"):format(i, v:getName()), player)
                end
                outputConsole("Ende der Liste.", player)
            else
                player:sendShortMessage(_("Das Event ist nicht gestartet.", player))
            end
        end
    end
)