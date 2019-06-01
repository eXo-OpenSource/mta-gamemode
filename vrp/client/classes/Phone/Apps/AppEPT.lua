-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppEPT.lua
-- *  PURPOSE:     EPT App class
-- *
-- ****************************************************************************
AppEPT = inherit(PhoneApp)

function AppEPT:constructor()
	PhoneApp.constructor(self, "Taxi und Bus", "IconEPT.png")

	addRemoteEvents{"receivingEPTList" }
	addEventHandler("receivingEPTList", root, bind(AppEPT.receivingEPTList, self))
end

function AppEPT:onOpen(form)
	self.m_TabPanel = GUIPhoneTabPanel:new(0, 0, form.m_Width, form.m_Height, form)
	self.m_Tabs = {}
	self.m_Tabs["Info"] = self.m_TabPanel:addTab(_"Information", FontAwesomeSymbols.Info)
	self.m_HeaderInfo = GUILabel:new(10, 10, form.m_Width-20, 50, _"Public Transport", self.m_Tabs["Info"]) -- 3
	self.m_LabelInfo = GUILabel:new(10, 60, form.m_Width-20, 30, _"Herzlich Willkommen bei eXo Public Transport!\nIn dieser App sehen Sie alle aktiven Taxis und unseren aktuellen Busfahrplan. Möch-\nten Sie unseren Limousinen-\nservice in Anspruch nehmen oder uns für Events mieten? Zögern Sie nicht und rufen Sie uns an - Ihr Weg ist unser Ziel!", self.m_Tabs["Info"])
	self.m_CallEPT = GUIButton:new(50, form.m_Height-90, form.m_Width - 60, 30, "EPT anrufen!", self.m_Tabs["Info"]):setBackgroundColor(Color.Green)
	self.m_CallEPT.onLeftClick = bind(self.CallEPT, self)

	self.m_Tabs["Taxi"] = self.m_TabPanel:addTab(_"Taxi", FontAwesomeSymbols.Taxi)
	self.m_HeaderTaxi = GUILabel:new(10, 10, form.m_Width-20, 50, _"Taxiservice", self.m_Tabs["Taxi"])
	self.m_EPTList = GUIGridList:new(10, 60, form.m_Width-20, form.m_Height-160, self.m_Tabs["Taxi"])
	self.m_EPTList:addColumn(_"Spieler", .6)
	self.m_EPTList:addColumn(_"Dauer", .4)

	self.m_CallEPT = GUIButton:new(10, form.m_Height-90, form.m_Width - 20, 30, "EPT anrufen!", self.m_Tabs["Taxi"]):setBackgroundColor(Color.Green)
	self.m_CallEPT.onLeftClick = bind(self.CallEPT, self)


	self.m_Tabs["Bus"] = self.m_TabPanel:addTab(_"Fahrplan", FontAwesomeSymbols.Table)
	self.m_HeaderBus = GUILabel:new(10, 10, form.m_Width-20, 50, _"Busfahrplan", self.m_Tabs["Bus"])
	self.m_BusRoute = BusRoutePlan:new(10, 100, form.m_Width-20, form.m_Height-160, 100, self.m_Tabs["Bus"])
	self.m_BusRoute:setBackgroundDisabled(true)
	self.m_BusRoute:setCompactView(true)
	self.m_BusRoute:setLine(1)

	local width = form.m_Width-20
	self.m_Line1Btn = GUIButton:new(10, 60, width/2-5, 30, _"Linie 1", self.m_Tabs["Bus"])
		:setBackgroundColor(tocolor(unpack(EPTBusData.lineData.lineDisplayData[1].color)))
	self.m_Line1Btn.onLeftClick = function()
		self.m_BusRoute:setLine(1)
	end
	self.m_Line2Btn = GUIButton:new(10 + width/2 + 5, 60, width/2-5, 30, _"Linie 2", self.m_Tabs["Bus"])
		:setBackgroundColor(tocolor(unpack(EPTBusData.lineData.lineDisplayData[2].color)))
	self.m_Line2Btn.onLeftClick = function()
		self.m_BusRoute:setLine(2)
	end
	triggerServerEvent("requestEPTList", localPlayer)
end

function AppEPT:CallEPT()
	Phone:getSingleton():openAppByClass(AppCall)
	Phone:getSingleton():getAppByClass(AppCall):openInCall("company", "EPT", CALL_RESULT_CALLING, false)
	triggerServerEvent("callStartSpecial", root, 389)

	self:close()
end

-- ca. 40sec für 700 (Taxi bei 80km/h)
-- = 0,05 sec für 1 // Nutze 0,06
function AppEPT:receivingEPTList(instructors)
	self.m_EPTList:clear()
	for _, player in pairs(instructors) do
		local estimatedTime = getDistanceBetweenPoints3D(localPlayer.position, player.position)*0.06
		self.m_EPTList:addItem(player:getName(), ("ca. %s%s"):format(estimatedTime > 60 and math.round(estimatedTime/60, 1) or math.round(estimatedTime), estimatedTime > 60 and "m" or "s"))
	end
end
