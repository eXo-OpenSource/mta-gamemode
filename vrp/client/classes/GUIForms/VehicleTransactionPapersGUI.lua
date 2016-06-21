-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleShopGUI.lua
-- *  PURPOSE:     VehicleShopGUI class
-- *
-- ****************************************************************************

VehicleTransactionPapersGUI = inherit(GUIForm)
inherit(Singleton, VehicleTransactionPapersGUI)

function VehicleTransactionPapersGUI:constructor( )
	local veh = getPedOccupiedVehicle(localPlayer)
	local width, height =  (screenWidth*0.4)/ASPECT_RATIO_MULTIPLIER, screenHeight*0.4
	self.m_Veh = veh
	GUIForm.constructor(self, (screenWidth*0.5 - width/2) /ASPECT_RATIO_MULTIPLIER , (screenHeight*0.5-height/2)/ASPECT_RATIO_MULTIPLIER, width, height)
	self.m_Window = GUIWindow:new(0,0,width,height,_"Transaktionspapiere - Auto",true,true,self)
	self.m_ItemImage = GUIImage:new(width*0.3, height*0.3, width*0.4, height*0.4, "files/images/Inventory/items/Items/Contract.png", self.m_Window)
	self.m_AcceptButton = GUIButton:new(width*0.3, height*0.8, width*0.4, height*0.1, "Kaufen [ $300 ]", self.m_Window)
	self.m_AcceptButton.onLeftClick = bind(self.AcceptButton_buyPapers, self)
end

function VehicleTransactionPapersGUI:destructor()
	GUIForm.destructor(self)
end

function VehicleTransactionPapersGUI:AcceptButton_buyPapers()
	triggerServerEvent("VehicleTransaction_OnBuyPapers",localPlayer)
	delete( VehicleTransactionPapersGUI:getSingleton() )
end


