-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/TrainingGUI.lua
-- *  PURPOSE:     Training Lobby GUI
-- *
-- ****************************************************************************
TrainingGUI = inherit(GUIForm)
inherit(Singleton, TrainingGUI)

addRemoteEvents{"deathmatchOpenLobbyGUI", "deathmatchReceiveLobbys"}

function TrainingGUI:constructor( id )
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Training", true, true, self)
	self.m_ID = id
	GUILabel:new(self.m_Width*0.02, 35, self.m_Width*0.96, self.m_Height*0.05, "Warnung: Alle deine Waffen werden beim betreten des Trainings gelöscht!", self.m_Window):setColor(Color.Red)


	self.m_JoinButton = GUIButton:new(self.m_Width-self.m_Width*0.32, self.m_Height-self.m_Height*0.09, self.m_Width*0.3, self.m_Height*0.07, _"Betreten", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)
	self.m_JoinButton.onLeftClick = bind(self.tryJoinLobby, self)

	self.m_PlayerLabel = GUILabel:new(self.m_Width*0.02, self.m_Height-self.m_Height*0.17, self.m_Width*0.65, self.m_Height*0.06, "", self.m_Window)
	self.m_WeaponLabel = GUILabel:new(self.m_Width*0.02, self.m_Height-self.m_Height*0.09, self.m_Width*0.65, self.m_Height*0.06, "", self.m_Window)

	triggerServerEvent("deathmatchRequestLobbys", root)

	addEventHandler("deathmatchReceiveLobbys", root, bind(self.receiveLobbys, self))
end

function TrainingGUI:destructor()
	GUIForm.destructor(self)
end

function TrainingGUI:onShow()
	triggerServerEvent("deathmatchRequestLobbys", root)
end

function DeathmatchLobbyGUI:onHide()
end

