-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Cinema/CinemaLobby.lua
-- *  PURPOSE:     cinema lobby instance
-- *
-- ****************************************************************************

CinemaLobby = inherit(Singleton)

addRemoteEvents{"Cinema_playVideo", "Cinema_queueSync", "Cinema_updateCurrentlyPlaying", "Cinema_syncVideo", "Cinema_syncRemoveVideo"}

function CinemaLobby:constructor(lobbyHost, settingVideoAddHostOnly, settingManageVideoHostOnly, currentlyPlaying)
    self.m_Queue = {}
    self.m_LobbyHost = lobbyHost
    self.m_SettingVideoAddHostOnly = settingVideoAddHostOnly
    self.m_SettingManageVideoHostOnly = settingManageVideoHostOnly
    self.m_CurrentlyPlaying = currentlyPlaying

    Browser.requestDomains({"noembed.com"})

    self:createBrowser()

    triggerServerEvent("Cinema_requestCurrentQueue", resourceRoot, self.m_LobbyHost)

    self.m_SyncVideoOnEnter = bind(self.syncVideoOnEnter, self)
    addEventHandler("onClientBrowserCreated", self.m_Browser, self.m_SyncVideoOnEnter)
   
    self.m_PlayVideo = bind(self.playVideo, self)
    addEventHandler("Cinema_playVideo", getRootElement(), self.m_PlayVideo)

    self.m_QueueSync = bind(self.queueSync, self)
    addEventHandler("Cinema_queueSync", getRootElement(), self.m_QueueSync)

    self.m_UpdateCurrentlyPlaying = bind(self.updateCurrentlyPlaying, self)
    addEventHandler("Cinema_updateCurrentlyPlaying", getRootElement(), self.m_UpdateCurrentlyPlaying)

    self.m_SyncVideo = bind(self.syncVideo, self)
    addEventHandler("Cinema_syncVideo", getRootElement(), self.m_SyncVideo)

    self.m_SyncRemoveVideo = bind(self.defaultScreen, self)
    addEventHandler("Cinema_syncRemoveVideo", getRootElement(), self.m_SyncRemoveVideo)

    local key = core:get("KeyBindings", "KeyCinemaVideoGUI", KeyBinds:getSingleton().m_Keys["general"]["KeyCinemaVideoGUI"]["defaultKey"])
    InfoBox:new(("Drücke '%s' für die Videoverwaltung!"):format(key:upper()))
end

function CinemaLobby:openVideoGUI()
    CinemaManager:getSingleton():videoGUI()
    self:queueUpdate()   
 end 

function CinemaLobby:createBrowser()
    self.m_Width, self.m_Height = guiGetScreenSize()

    self.m_Browser = Browser(self.m_Width, self.m_Height, false)

    self.m_RenderBrowser = bind(self.renderBrowser, self)
    addEventHandler("onClientPreRender", getRootElement(), self.m_RenderBrowser)
end    

function CinemaLobby:renderBrowser()
    self.m_PosX = 403.6
    self.m_PosY = -214 
    self.m_PosZ = 1025.48
    self.m_Size = 8.73
    
    dxDrawMaterialLine3D(self.m_PosX, self.m_PosY, self.m_PosZ, self.m_PosX, self.m_PosY, self.m_PosZ-4.91, self.m_Browser, self.m_Size, tocolor(255,255,255,255), false, self.m_PosX+1, self.m_PosY, self.m_Size)  
end 

function CinemaLobby:defaultScreen()
    self.m_Browser:loadURL("https://cp.exo-reallife.de/images/logo.png")
end   

function CinemaLobby:queueAdd(URL)
    if self.m_LobbyHost == localPlayer or not(self.m_SettingVideoAddHostOnly) then 
        if not(self.m_Queue[URL]) then  
            triggerServerEvent("Cinema_addVideoToQueue", resourceRoot, self.m_LobbyHost, URL)
        else
            ErrorBox:new(_"Das Video ist bereits in der Videoliste!")
        end
    else
        ErrorBox:new(_"Dazu hast du keine Berechtigung!")
    end    
end    

function CinemaLobby:queueSync(queue)
    self.m_Queue = queue

    if CinemaVideoGUI:isInstantiated() then
        CinemaManager:getSingleton():videoGUI()
        self:queueUpdate()
    end
end    

function CinemaLobby:queueUpdate()
        for URL, v in pairs(self.m_Queue) do
            requestTitle = fetchRemote(("https://noembed.com/embed?url=%s"):format(URL), 
            function(responseData) 
                responseData = fromJSON(responseData)
                if not(responseData) then
                    CinemaVideoGUI:getSingleton():addItemToList(URL, self.m_Queue[URL].playerName, URL)
                else
                    if responseData.title and #responseData.title > 50 then
                        title = responseData.title:sub(0, 50)
                        title = ("%s [...]"):format(title)
                        CinemaVideoGUI:getSingleton():addItemToList(title, self.m_Queue[URL].playerName, URL)
                    else
                        CinemaVideoGUI:getSingleton():addItemToList(responseData.title, self.m_Queue[URL].playerName, URL)
                    end
                end
            end)
        end
end    

function CinemaLobby:playVideo(URL)
    if self.m_LobbyHost == localPlayer or not(self.m_SettingManageVideoHostOnly) then     
        triggerServerEvent("Cinema_syncVideoForPlayers", resourceRoot, self.m_LobbyHost, URL)
        triggerServerEvent("Cinema_updateCurrentlyPlaying", resourceRoot, self.m_LobbyHost, URL)
    else
        ErrorBox:new(_"Dazu hast du keine Berechtigung!")
    end    
end   

function CinemaLobby:syncVideo(URL)
    local URL = ("https://www.youtube.com/embed/%s?autoplay=1&controls=0&showinfo=0"):format(self:getVideoIdFromURL(URL))
    self.m_Browser:loadURL(URL)
end   

function CinemaLobby:removeVideo(URL)
    if self.m_LobbyHost == localPlayer or not(self.m_SettingManageVideoHostOnly) then  
        if #self.m_CurrentlyPlaying > 0 then 
            if self.m_CurrentlyPlaying[1] == URL then
                triggerServerEvent("Cinema_syncVideoRemove", resourceRoot, self.m_LobbyHost)
                triggerServerEvent("Cinema_updateCurrentlyPlaying", resourceRoot, self.m_LobbyHost)
            end
        end    
        triggerServerEvent("Cinema_removeVideoFromQueue", resourceRoot, self.m_LobbyHost, URL)
    else
        ErrorBox:new(_"Dazu hast du keine Berechtigung!")
    end    
end      

function CinemaLobby:updateCurrentlyPlaying(currentlyPlaying)
    self.m_CurrentlyPlaying = currentlyPlaying  
end   

function CinemaLobby:syncVideoOnEnter()
    if #self.m_CurrentlyPlaying > 0 then 
        videoId = self:getVideoIdFromURL(self.m_CurrentlyPlaying[1]) 
        time = math.ceil(self.m_CurrentlyPlaying[2])
        URL = ("https://www.youtube.com/embed/%s?autoplay=1&controls=0&showinfo=0&start=%s"):format(videoId, time)
        self.m_Browser:loadURL(URL)
    else
        self:defaultScreen()
    end    
end   

function CinemaLobby:getVideoIdFromURL(URL)
    if URL then
        return URL:sub(33, 43)
    end
end

function CinemaLobby:destructor()
    removeEventHandler("Cinema_playVideo", getRootElement(), self.m_PlayVideo)
    removeEventHandler("Cinema_queueSync", getRootElement(), self.m_QueueSync)
    removeEventHandler("onClientPreRender", getRootElement(), self.m_RenderBrowser)
    removeEventHandler("Cinema_updateCurrentlyPlaying", getRootElement(), self.m_UpdateCurrentlyPlaying)
    removeEventHandler("Cinema_syncVideo", getRootElement(), self.m_SyncVideo)
    removeEventHandler("Cinema_syncRemoveVideo", getRootElement(), self.m_SyncRemoveVideo)

    self.m_Browser:destroy()
end