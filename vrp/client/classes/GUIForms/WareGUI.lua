-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/WareGUI.lua
-- *  PURPOSE:     Training Lobby GUI
-- *
-- ****************************************************************************
WareGUI = inherit(GUIForm)
inherit(Singleton, WareGUI)

addRemoteEvents{"Ware:wareOpenGUI"}

function WareGUI:constructor( id )
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Mini-Ware", true, true, self)
	self.m_ID = id
	GUILabel:new(self.m_Width*0.02, 35, self.m_Width*0.96, self.m_Height*0.05, "Warnung: Alle deine Waffen werden beim betreten des Ware-Modes gelöscht!", self.m_Window):setColor(Color.Red)
	
	
	self.m_JoinButton = VRPButton:new(self.m_Width-self.m_Width*0.32, self.m_Height-self.m_Height*0.09, self.m_Width*0.3, self.m_Height*0.07, _"Betreten", true, self.m_Window):setBarColor(Color.Green)
	self.m_JoinButton.onLeftClick = bind(self.tryJoinLobby, self)

	triggerServerEvent("deathmatchRequestLobbys", root)

	addEventHandler("deathmatchReceiveLobbys", root, bind(self.receiveLobbys, self))
end

function WareGUI:destructor()
	GUIForm.destructor(self)
end

function WareGUI:onHide()
end

addEventHandler("Ware:wareOpenGUI", root, function()
	WareGUI:new()
end)


