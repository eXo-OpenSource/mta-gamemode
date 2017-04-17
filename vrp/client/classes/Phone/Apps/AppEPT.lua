-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppEPT.lua
-- *  PURPOSE:     EPT App class
-- *
-- ****************************************************************************
AppEPT = inherit(PhoneApp)

function AppEPT:constructor()
	PhoneApp.constructor(self, "Taxi", "IconEPT.png")

	addRemoteEvents{"receivingEPTList" }
	addEventHandler("receivingEPTList", root, bind(AppEPT.receivingEPTList, self))
end

function AppEPT:onOpen(form)
	self.m_EPTList = GUIGridList:new(10, 10, form.m_Width-20, form.m_Height-60, form)
	self.m_EPTList:addColumn(_"Spieler", .6)
	self.m_EPTList:addColumn(_"Dauer", .4)

	self.m_CallEPT = GUIButton:new(10, form.m_Height-40, form.m_Width - 20, 30, "EPT anrufen!", form):setBackgroundColor(Color.Orange)
	self.m_CallEPT.onLeftClick = bind(self.CallEPT, self)

	triggerServerEvent("requestEPTList", localPlayer)
end

function AppEPT:CallEPT()
	Phone:getSingleton():openAppByClass(AppCall)
	CallResultActivity:new(Phone:getSingleton():getAppByClass(AppCall), "company", "EPT", CALL_RESULT_CALLING, false)
	triggerServerEvent("callStartSpecial", root, 404)

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
