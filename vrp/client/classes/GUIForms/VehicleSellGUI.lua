-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleShopGUI.lua
-- *  PURPOSE:     VehicleShopGUI class
-- *
-- ****************************************************************************

VehicleSellGUI = inherit(GUIForm)
inherit(Singleton, VehicleSellGUI)

function VehicleSellGUI:constructor( ts, veh )
	local veh = getPedOccupiedVehicle(localPlayer)
	local width, height =  (screenWidth*0.4)/ASPECT_RATIO_MULTIPLIER, screenHeight*0.4
	local model = veh:getName()
	local date = ts[1].."/"..(ts[2]+1).."/"..ts[3]+1900
	self.m_Veh = veh
	GUIForm.constructor(self, (screenWidth*0.5 - width/2) /ASPECT_RATIO_MULTIPLIER , (screenHeight*0.5-height/2)/ASPECT_RATIO_MULTIPLIER, width, height)
	self.m_Window = GUIWindow:new(0,0,width,height,_"Handelsvertrag - Autoverkauf",true,true,self)
	self.m_LabelContract =	GUILabel:new(width*0.2,height*0.2,width*0.8, height*0.1,_"Vertragsfahrzeug: "..model, self.m_Window)
	self.m_LabelContract2 =	GUILabel:new(width*0.2,height*0.32,width*0.8, height*0.1,_"Vertragsdatum: "..date, self.m_Window)
	self.m_LabelContract3 =	GUILabel:new(width*0.2,height*0.44,width*0.3, height*0.1,_"Verkauf an: ", self.m_Window)
	self.m_Edit = GUIEdit:new(width*0.55, height*0.44, width*0.3, height*0.07, self.m_Window )
	self.m_LabelContract4 =	GUILabel:new(width*0.2,height*0.56,width*0.3, height*0.1,_"Verkaufspreis ($): ", self.m_Window)
	self.m_Edit2 = GUIEdit:new(width*0.55, height*0.56, width*0.3, height*0.07, self.m_Window )
	self.m_AcceptButton = GUIButton:new(width*0.3, height*0.8, width*0.4, height*0.1, "Weiter", self.m_Window)
	self.m_AcceptButton.onLeftClick = bind(self.AcceptButton_applyContract, self)
end

function VehicleSellGUI:destructor()
	GUIForm.destructor(self)
end

function VehicleSellGUI:AcceptButton_applyContract()
	local name = self.m_Edit:getDrawnText()
	local price = self.m_Edit2:getDrawnText()
	if name and price then
		if #name > 0 then
			if #price > 0 then
				if tonumber( price ) then
					local player = getPlayerFromName( name ) 
					if player then
						local px,py = getElementPosition( localPlayer )
						local mx,my = getElementPosition( player )
						local distance = getDistanceBetweenPoints2D( px, py, mx, my)
						if distance <= 10 then 
							triggerServerEvent("VehicleSell_requestSell", localPlayer, name, price, self.m_Veh)
						else ErrorBox:new(_"Käufer zu weit entfernt!")
						end
					else ErrorBox:new(_"Käufer nicht gefunden!")
					end
				else ErrorBox:new(_"Bitte gebe einen gültigen Preis an!")
				end
			else ErrorBox:new(_"Bitte gebe einen gültigen Preis an!")
			end
		else ErrorBox:new(_"Bitte gebe einen gültigen Spieler an!")
		end
	else ErrorBox:new(_"Bitte fülle die Felder aus!")
	end
end


