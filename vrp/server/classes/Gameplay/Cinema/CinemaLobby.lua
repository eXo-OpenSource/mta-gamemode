-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Cinema/CinemaLobby.lua
-- *  PURPOSE:     creates cinema instance
-- *
-- ****************************************************************************

CinemaLobby = inherit(Object)

function CinemaLobby:constructor(lobbyHost, settingVideoAddHostOnly, settingManageVideoHostOnly, freeDimension)
    self.m_LobbyHost = lobbyHost
    self.m_Players = {}
    self.m_Queue = {}
    self.m_CurrentlyPlaying = {}
    self.m_SettingVideoAddHostOnly = settingVideoAddHostOnly
    self.m_SettingManageVideoHostOnly = settingManageVideoHostOnly
      
    self.m_Position  = Vector3(420.40, -210, 1023.53)
    self.m_Dimension = freeDimension
    self.m_Interior  = 17

    self.m_LeaveMarker = Marker(421, -209, 1022.6, "cylinder", 1, 255, 255, 255)
    self.m_LeaveMarker:setDimension(self.m_Dimension)
    self.m_LeaveMarker:setInterior(self.m_Interior)

    self.m_DeleteLobby = bind(self.deleteLobby, self)
    addEventHandler("onMarkerHit", self.m_LeaveMarker, self.m_DeleteLobby)

    self:addPlayer(self.m_LobbyHost)
end

function CinemaLobby:addPlayer(player) 
    table.insert(self.m_Players, player)  

    player:setPosition(self.m_Position)
    player:setDimension(self.m_Dimension)
    player:setInterior(self.m_Interior)

    player.CinemaLobby = self

    if #self.m_CurrentlyPlaying > 0 then
        URL = self.m_CurrentlyPlaying[1]
        time = (getTickCount() - self.m_CurrentlyPlaying[2]) / 1000
        currentlyPlaying = {URL, time}
    else
        currentlyPlaying = {}
    end

    player:triggerEvent("Cinema_createLobbyInstance", self.m_LobbyHost, self.m_SettingVideoAddHostOnly, self.m_SettingManageVideoHostOnly, currentlyPlaying)
end    

function CinemaLobby:addToQueue(URL, playerName)
        self.m_Queue[URL] = {}
        self.m_Queue[URL].URL = URL
        self.m_Queue[URL].playerName = playerName    

    triggerClientEvent(self.m_Players, "Cinema_queueSync", resourceRoot, self.m_Queue)
end   

function CinemaLobby:removeFromQueue(URL)
    self.m_Queue[URL] = nil

    triggerClientEvent(self.m_Players, "Cinema_queueSync", resourceRoot, self.m_Queue)
end    

function CinemaLobby:updateCurrentlyPlaying(URL)
    self.m_CurrentlyPlaying = URL and {URL, getTickCount()} or {}
    triggerClientEvent(self.m_Players, "Cinema_updateCurrentlyPlaying", resourceRoot, self.m_CurrentlyPlaying)
end   

function CinemaLobby:getCurrentQueue(player)
    player:triggerEvent("Cinema_queueSync", self.m_Queue)
end    

function CinemaLobby:syncVideo(URL)
    triggerClientEvent(self.m_Players, "Cinema_syncVideo", resourceRoot, URL)
end

function CinemaLobby:syncRemoveVideo()
    triggerClientEvent(self.m_Players, "Cinema_syncRemoveVideo", resourceRoot)
end   

function CinemaLobby:playerRemoveFromLobby(player)
    player:setPosition(math.random(-2171, -2167), 641, 1052.38)
    player:setDimension(0)
    player:setInterior(1)
    player:triggerEvent("Cinema_deleteLobby")
    player.CinemaLobby = nil

    if player.sittingOn then
        Chair:getSingleton():removePlayer(player.sittingOn, player)
        player.sittingOn = nil
        player:setFrozen(false)
    end
    
    CinemaManager:getSingleton():log(player, self.m_LobbyHost, "leave lobby")
end

function CinemaLobby:deleteLobby(hitElement, matchingDimension)
    if hitElement == self.m_LobbyHost and matchingDimension then 
        CinemaManager:getSingleton():deleteLobby(self.m_LobbyHost)
    elseif matchingDimension then
        for i, player in pairs(self.m_Players) do
            if player == hitElement then
                self:playerRemoveFromLobby(player)
                self.m_Players[i] = nil
            end
        end
    end          
end    

function CinemaLobby:deleteLobbyOnQuitOrDeath(player)
    if player == self.m_LobbyHost then 
        CinemaManager:getSingleton():deleteLobby(self.m_LobbyHost)
    else 
        for i, plr in pairs(self.m_Players) do
            if plr == player then
                self:playerRemoveFromLobby(player)
                self.m_Players[i] = nil
            end
        end
    end        
end    

function CinemaLobby:destructor()
    for i, player in pairs(self.m_Players) do
        self:playerRemoveFromLobby(player)
    end   

    self.m_LeaveMarker:destroy()
end   