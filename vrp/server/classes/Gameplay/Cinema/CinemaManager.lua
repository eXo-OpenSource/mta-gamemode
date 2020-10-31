-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Cinema/CinemaManager.lua
-- *  PURPOSE:     cinemaManager class
-- *
-- ****************************************************************************

CinemaManager = inherit(Singleton)

function CinemaManager:constructor()
    self.m_Lobbys = {}
    self.m_LobbysReturnToClient = {}
    self.m_FreeDimension = 1337
    
    self.m_InteriorEnterExit = InteriorEnterExit:new(Vector3(1290.91, -1160.42, 24), Vector3(-2158.64, 642.54, 1052.37), 180, 0, 1, 0)
    self.m_CreateLobbyMarker = Marker(-2161.24, 640.62, 1051.5, "cylinder", 1, 255, 255, 255)
    self.m_CreateLobbyMarker:setInterior(1)

    self.m_Blip = Blip:new("Cinema.png", 1290.91, -1160.42, root, 400)
    self.m_Blip:setOptionalColor({170, 0, 0})
    self.m_Blip:setDisplayText("Kino", BLIP_CATEGORY.Leisure)

    self.m_Ped = createPed(171, Vector3(-2161.22, 638.71, 1052.41))
    self.m_Ped:setInterior(1)

    addRemoteEvents{"Cinema_triggerCreateLobby", "Cinema_getLobbyDetails", "Cinema_validatePassword", 
    "Cinema_addPlayerToLobby", "Cinema_addVideoToQueue", "Cinema_removeVideoFromQueue", "Cinema_updateCurrentlyPlaying", 
    "Cinema_syncVideoForPlayers", "Cinema_syncVideoRemove", "Cinema_requestCurrentQueue", "Cinema_AdminRemoveLobby"}

    self.m_OnEnterMarkerHit = bind(self.onEnterMarkerHit, self)
    addEventHandler("onMarkerHit", self.m_CreateLobbyMarker, self.m_OnEnterMarkerHit)
   
    self.m_CreateLobbyInstance = bind(self.createLobbyInstance, self)
    addEventHandler("Cinema_triggerCreateLobby", getRootElement(), self.m_CreateLobbyInstance)

    self.m_GetLobbyDetails = bind(self.getLobbyDetails, self)
    addEventHandler("Cinema_getLobbyDetails", getRootElement(), self.m_GetLobbyDetails)

    self.m_ValidatePassword = bind(self.validatePassword, self)
    addEventHandler("Cinema_validatePassword", getRootElement(), self.m_ValidatePassword)

    self.m_AddPlayerToLobby = bind(self.addPlayerToLobby, self)
    addEventHandler("Cinema_addPlayerToLobby", getRootElement(), self.m_AddPlayerToLobby)

    self.m_AddVideoToQueue = bind(self.addVideoToQueue, self)
    addEventHandler("Cinema_addVideoToQueue", getRootElement(), self.m_AddVideoToQueue)

    self.m_RemoveVideoFromQueue = bind(self.removeVideoFromQueue, self)
    addEventHandler("Cinema_removeVideoFromQueue", getRootElement(), self.m_RemoveVideoFromQueue)

    self.m_UpdateCurrentlyPlaying = bind(self.updateCurrentlyPlaying, self)
    addEventHandler("Cinema_updateCurrentlyPlaying", getRootElement(), self.m_UpdateCurrentlyPlaying)

    self.m_SyncVideoForPlayers = bind(self.syncVideoForPlayers, self)
    addEventHandler("Cinema_syncVideoForPlayers", getRootElement(), self.m_SyncVideoForPlayers)

    self.m_SyncRemoveVideo = bind(self.syncRemoveVideo, self)
    addEventHandler("Cinema_syncVideoRemove", getRootElement(), self.m_SyncRemoveVideo)

    self.m_RequestCurrentQueue = bind(self.requestCurrentQueue, self)
    addEventHandler("Cinema_requestCurrentQueue", getRootElement(), self.m_RequestCurrentQueue)

    self.m_AdminRemoveLobby = bind(self.adminRemoveLobby, self)
    addEventHandler("Cinema_AdminRemoveLobby", getRootElement(), self.m_AdminRemoveLobby)

    PlayerManager:getSingleton():getWastedHook():register(
        function(player)
            if player.CinemaLobby then
                player.CinemaLobby:deleteLobbyOnQuitOrDeath(player)
            end
        end)

    PlayerManager:getSingleton():getQuitHook():register(
        function(player)
            if player.CinemaLobby then
                player.CinemaLobby:deleteLobbyOnQuitOrDeath(player)
            end
        end)

    PlayerManager:getSingleton():getAFKHook():register(
        function(player)
            if player.CinemaLobby then
                player.CinemaLobby:deleteLobbyOnQuitOrDeath(player)
            end
        end)  
end   

function CinemaManager:onEnterMarkerHit(hitElement, matchingDimension)
    if hitElement:getType() == "player" and matchingDimension then
        hitElement:triggerEvent("Cinema_onEnterMarkerHit", self.m_CreateLobbyMarker)
    end   
end   

function CinemaManager:getLobbyDetails()
    client:triggerEvent("Cinema_returnLobbyDetails", self.m_LobbysReturnToClient)
end    

function CinemaManager:validatePassword(enteredPassword, lobbyHost)
    if self.m_Lobbys[lobbyHost] and self.m_Lobbys[lobbyHost].lobbyPassword == enteredPassword then
        client:triggerEvent("Cinema_getPasswordValidationResponse", true, lobbyHost)
    else
        client:triggerEvent("Cinema_getPasswordValidationResponse", false)
    end    
end

function CinemaManager:createLobbyInstance(lobbyName, lobbyPassword, settingVideoAddHostOnly, settingManageVideoHostOnly)
   local lobbyHost = client
   
    self.m_Lobbys[lobbyHost] = {}
    self.m_Lobbys[lobbyHost].lobbyName                  = lobbyName    
    self.m_Lobbys[lobbyHost].lobbyPassword              = lobbyPassword
    self.m_Lobbys[lobbyHost].settingVideoAddHostOnly    = settingVideoAddHostOnly
    self.m_Lobbys[lobbyHost].settingManageVideoHostOnly = settingManageVideoHostOnly

    self.m_LobbysReturnToClient[lobbyHost] = {}
    self.m_LobbysReturnToClient[lobbyHost].lobbyName     = lobbyName    
    self.m_LobbysReturnToClient[lobbyHost].lobbyPassword = #lobbyPassword > 0
    
    self.m_Lobbys[lobbyHost].lobbyInstance = CinemaLobby:new(lobbyHost, settingVideoAddHostOnly, settingManageVideoHostOnly, self.m_FreeDimension) 
    self.m_FreeDimension = self.m_FreeDimension + 1
    self:log(lobbyHost, lobbyHost, "create lobby")
end    

function CinemaManager:addPlayerToLobby(lobbyHost)
    if self.m_Lobbys[lobbyHost] then
        self.m_Lobbys[lobbyHost].lobbyInstance:addPlayer(client)
        self:log(client, lobbyHost, "join lobby")
    end
end    

function CinemaManager:deleteLobby(lobbyHost)
    if self.m_Lobbys[lobbyHost] then
        self:log(lobbyHost, lobbyHost, "delete lobby")
        delete(self.m_Lobbys[lobbyHost].lobbyInstance)
        self.m_Lobbys[lobbyHost] = nil
        self.m_LobbysReturnToClient[lobbyHost] = nil
    end
end

function CinemaManager:addVideoToQueue(lobbyHost, URL)
    if self.m_Lobbys[lobbyHost] then
        self.m_Lobbys[lobbyHost].lobbyInstance:addToQueue(URL, client:getName())
        self:log(client, lobbyHost, "add video", URL)
    end
end    

function CinemaManager:removeVideoFromQueue(lobbyHost, URL)
    if self.m_Lobbys[lobbyHost] then
        self.m_Lobbys[lobbyHost].lobbyInstance:removeFromQueue(URL)
        self:log(client, lobbyHost, "remove video", URL)
    end
end    

function CinemaManager:updateCurrentlyPlaying(lobbyHost, URL)
    if self.m_Lobbys[lobbyHost] then
        self.m_Lobbys[lobbyHost].lobbyInstance:updateCurrentlyPlaying(URL)
    end
end      

function CinemaManager:requestCurrentQueue(lobbyHost)
    if self.m_Lobbys[lobbyHost] then
        self.m_Lobbys[lobbyHost].lobbyInstance:getCurrentQueue(client)
    end
end    

function CinemaManager:syncVideoForPlayers(lobbyHost, URL)
    if self.m_Lobbys[lobbyHost] then
        self.m_Lobbys[lobbyHost].lobbyInstance:syncVideo(URL)
        self:log(client, lobbyHost, "play video", URL)
    end
end    

function CinemaManager:syncRemoveVideo(lobbyHost)
    if self.m_Lobbys[lobbyHost] then
        self.m_Lobbys[lobbyHost].lobbyInstance:syncRemoveVideo()
    end
end   

function CinemaManager:adminRemoveLobby(lobbyHost)
    if client:getRank() >= ADMIN_RANK_PERMISSION["cinemaRemoveLobby"] and self.m_Lobbys[lobbyHost] then
        self:log(client, lobbyHost, "delete lobby")
        delete(self.m_Lobbys[lobbyHost].lobbyInstance)
        self.m_Lobbys[lobbyHost] = nil
        self.m_LobbysReturnToClient[lobbyHost] = nil
    end
end

function CinemaManager:log(player, host, action, videoId)
    local lobbyName = self.m_Lobbys[host].lobbyName
    local videoId = videoId or ""
    StatisticsLogger:getSingleton():addCinemaLog(player, host, lobbyName, action, videoId:sub(33, 43))
end