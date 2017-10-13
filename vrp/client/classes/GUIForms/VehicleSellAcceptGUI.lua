-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleSellAcceptGUI.lua
-- *  PURPOSE:     VehicleSellAcceptGUI class
-- *
-- ****************************************************************************

VehicleSellAcceptGUI = inherit(GUIForm)
inherit(Singleton, VehicleSellAcceptGUI)

function VehicleSellAcceptGUI:constructor( player, price, car )
	local width, height = ( screenWidth*0.35)/ASPECT_RATIO_MULTIPLIER, (screenHeight*0.35)/ASPECT_RATIO_MULTIPLIER
	GUIForm.constructor(self, (screenWidth*0.5 - width/2) /ASPECT_RATIO_MULTIPLIER , screenHeight*0.5, width, height)
	self.m_Player = player
	self.m_Price = price 
	self.m_Car = car
	self.m_Window = GUIWindow:new(0,0,width,height,_"Handelsvertrag - Handshake",true,true,self)
	self.m_LabelContract =	GUILabel:new(width*0.1,height*0.2,width*0.8, height*0.1,_"Vertragsangebot:", self.m_Window)
	self.m_LabelContract2 =	GUILabel:new(width*0.2,height*0.32,width*0.8, height*0.1,_"Fahrzeug: "..(car:getName()), self.m_Window)
	self.m_LabelContract3 =	GUILabel:new(width*0.2,height*0.44,width*0.8, height*0.1,_"Verkäufer: "..player.name, self.m_Window)
	self.m_LabelContract4 =	GUILabel:new(width*0.2,height*0.56,width*0.8, height*0.1,_"Verkaufspreis ($): "..price, self.m_Window)
	self.m_AcceptButton = GUIButton:new(width*0.3, height*0.8, width*0.4, height*0.1, "Weiter", self.m_Window)
	self.m_AcceptButton.onLeftClick = bind(self.AcceptButton_applyContract, self)
end

function VehicleSellAcceptGUI:destructor()
	GUIForm.destructor(self)
end

function VehicleSellAcceptGUI:AcceptButton_applyContract()
	triggerServerEvent("VehicleSell_tradeCar", localPlayer, self.m_Player, self.m_Price, self.m_Car )
	delete( VehicleSellAcceptGUI:getSingleton() )
end


