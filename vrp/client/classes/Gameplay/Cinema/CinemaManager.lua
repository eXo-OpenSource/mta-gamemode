-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Cinema/CinemaManager.lua
-- *  PURPOSE:     CinemaManager class
-- *
-- ****************************************************************************

CinemaManager = inherit(Singleton)

function CinemaManager:constructor()
    self.m_Lobbys = {}
    self.m_MarkerPosition = Vector3(-2161.24, 640.62, 1051.5)

    addRemoteEvents{"Cinema_onEnterMarkerHit", "Cinema_triggerLobbyUpdate", "Cinema_returnLobbyDetails", "Cinema_getPasswordValidationResponse", "Cinema_createLobbyInstance", "Cinema_deleteLobby"}
   
    self.m_OnEnterMarkerHit = bind(self.lobbyGUI, self)
    addEventHandler("Cinema_onEnterMarkerHit", getRootElement(), self.m_OnEnterMarkerHit)
    
    self.m_TriggerLobbyUpdate = bind(self.updateLobbyGUI, self)
    addEventHandler("Cinema_triggerLobbyUpdate", getRootElement(), self.m_TriggerLobbyUpdate)

    self.m_ReturnLobbyDetails = bind(self.returnLobbyDetails, self)
    addEventHandler("Cinema_returnLobbyDetails", getRootElement(), self.m_ReturnLobbyDetails)

    self.m_GetPasswordValidationResponse = bind(self.getPasswordValidationResponse, self)
    addEventHandler("Cinema_getPasswordValidationResponse", getRootElement(), self.m_GetPasswordValidationResponse)

    self.m_CreateLobbyInstance = bind(self.createLobbyInstance, self)
    addEventHandler("Cinema_createLobbyInstance", getRootElement(), self.m_CreateLobbyInstance)

    self.m_DeleteLobby = bind(self.deleteLobby, self)
    addEventHandler("Cinema_deleteLobby", getRootElement(), self.m_DeleteLobby)

    self.m_CurtainTXD = engineLoadTXD("files/models/objects/CinemaCurtain.txd")
    engineImportTXD(self.m_CurtainTXD, 2559)

    self.m_EntraceTXD = engineLoadTXD("files/models/objects/CinemaEntrance.txd")
    engineImportTXD(self.m_EntraceTXD, 14534)
end   

function CinemaManager:lobbyGUI(marker)
    self:closeGUI()
    self.m_CinemaGUI = CinemaLobbyGUI:new(self.m_MarkerPosition)
    self:requestLobbyDetails()
end 

function CinemaManager:createLobbyGUI()
    self:closeGUI()
    self.m_CinemaGUI = CinemaCreateLobbyGUI:new(self.m_MarkerPosition)
end   

function CinemaManager:PasswordGUI(lobbyHost)
    self:closeGUI()
    self.m_CinemaGUI = CinemaPasswordGUI:new(lobbyHost, self.m_MarkerPosition)
end

function CinemaManager:videoGUI()
    self:closeGUI()
    self.m_CinemaGUI = CinemaVideoGUI:new()
end    

function CinemaManager:closeGUI()
    if self.m_CinemaGUI then
        delete(self.m_CinemaGUI:getSingleton())
        self.m_CinemaGUI = nil
    end
end    

function CinemaManager:requestLobbyDetails()
    triggerServerEvent("Cinema_getLobbyDetails", resourceRoot)
end    

function CinemaManager:returnLobbyDetails(lobbys)
    self.m_Lobbys = lobbys
    self:updateLobbyGUI()
end    

function CinemaManager:validatePassword(enteredPassword, lobbyHost)
    triggerServerEvent("Cinema_validatePassword", resourceRoot, enteredPassword, lobbyHost)
end

function CinemaManager:getPasswordValidationResponse(validation, lobbyHost)
    if validation then
        self:addPlayerToLobby(lobbyHost)
        self:closeGUI()
    else
        ErrorBox:new(_"Falsches Passwort!")    
    end
end  

function CinemaManager:updateLobbyGUI()
    for player, info in pairs(self.m_Lobbys) do
        CinemaLobbyGUI:getSingleton():addItemToList(player, info)
    end
end

function CinemaManager:createLobby(lobbyName, lobbyPassword, settingVideoAddHostOnly, settingManageVideoHostOnly)
    triggerServerEvent("Cinema_triggerCreateLobby", resourceRoot, lobbyName, lobbyPassword, settingVideoAddHostOnly, settingManageVideoHostOnly)
end    

function CinemaManager:addPlayerToLobby(lobbyHost)
    triggerServerEvent("Cinema_addPlayerToLobby", resourceRoot, lobbyHost)
end   

function CinemaManager:createLobbyInstance(lobbyHost, settingVideoAddHostOnly, settingManageVideoHostOnly, currentlyPlaying)
    self.m_LobbyInstance = CinemaLobby:new(lobbyHost, settingVideoAddHostOnly, settingManageVideoHostOnly, currentlyPlaying)
end  

function CinemaManager:deleteLobby()
    delete(self.m_LobbyInstance:getSingleton())
    self:closeGUI()
    self.m_LobbyInstance = nil
end