-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/GasStationGUI.lua
-- *  PURPOSE:     Gas station GUI
-- *
-- ****************************************************************************
GasStationGUI = inherit(GUIForm)
inherit(Singleton, GasStationGUI)

function GasStationGUI:constructor()
	GUIForm.constructor(self, (screenWidth/2-screenWidth*0.4*0.5)/ASPECT_RATIO_MULTIPLIER, screenHeight*0.1, screenWidth*0.4/ASPECT_RATIO_MULTIPLIER, screenHeight*0.15)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Tankstelle", true, false, self)
	GUILabel:new(self.m_Width*0.05, self.m_Height*0.35, self.m_Width*0.9, self.m_Height*0.3, _"Drücke und halte Leertaste, um zu tanken\n(Preis für 1l: 1$)", self.m_Window):setAlignX("center")
	self:setVisible(false)


	self.m_FillTimer = false

	addEvent("gasStationGUIOpen", true)
	addEventHandler("gasStationGUIOpen", root,
		function(shopId)
			self:setVisible(true)

			if not self.m_FillTimer then
				self.m_FillTimer = setTimer(
					function()
						if getKeyState("space") then
							triggerServerEvent("gasStationFill", root, shopId)
						end
					end,
					1000,
					0
				)
			end
		end
	)
	addEvent("gasStationGUIClose", true)
	addEventHandler("gasStationGUIClose", root,
		function()
			self:setVisible(false)

			if self.m_FillTimer then
				killTimer(self.m_FillTimer)
				self.m_FillTimer = false
			end
		end
	)
end
