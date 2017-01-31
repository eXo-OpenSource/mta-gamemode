-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/KartGUI.lua
-- *  PURPOSE:     KartGUI class
-- *
-- ****************************************************************************
KartGUI = inherit(GUIForm)
inherit(Singleton, KartGUI)

addRemoteEvents{"showKartGUI", "receiveKartDatas"}

local lapPrice = 50
local lapPackDiscount = 4

function KartGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-270, screenHeight/2-230, 540, 460)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUILabel:new(self.m_Width-28, 0, 28, 28, "[x]", self):setFont(VRPFont(35))
	self.m_CloseButton.onLeftClick = function() self:delete() end

	local tabTimeRace = self.m_TabPanel:addTab(_("Zeitrennen"))
	local tabToptimes = self.m_TabPanel:addTab(_("Toptimes"))

	-- Zeitrennen
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.4, self.m_Height*0.1, _"eXo Kart Racing", tabTimeRace)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.11, self.m_Width*0.25, self.m_Height*0.06, _"Aktuelle Map:", tabTimeRace)
	self.m_MapNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.11, self.m_Width*0.4, self.m_Height*0.06, "", tabTimeRace)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.17, self.m_Width*0.25, self.m_Height*0.06, _"Autor:", tabTimeRace)
	self.m_AuthorLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.17, self.m_Width*0.4, self.m_Height*0.06, "", tabTimeRace)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.25, self.m_Width*0.8, self.m_Height*0.07, _"Runden", tabTimeRace)
	self.m_LapChange = GUIChanger:new(self.m_Width*0.02, self.m_Height*0.32, self.m_Width*0.35, self.m_Height*0.07, tabTimeRace)
	self.m_LapChange:addItem("5")
	self.m_LapChange:addItem("10")
	self.m_LapChange:addItem("15")
	self.m_LapChange:addItem("20")
	self.m_LapChange:addItem("30")
	self.m_LapChange:addItem("50")
	self.m_LapChange.onChange =
		function(text, index)
			local selectedLaps = tonumber(text)
			local discount = lapPackDiscount*(index-1)
			local price = selectedLaps*lapPrice
			price = price - (price/100*discount)

			self.m_PriceLabel:setText(("%d$"):format(price))

			if discount > 0 then
				self.m_DiscountLabel:setText(("(-%s%%)"):format(discount)):setColor(Color.Green)
			else
				self.m_DiscountLabel:setText(""):setColor(Color.White)
			end

			if self.m_Toptimes and self.m_Toptimes[1] then
				self.m_CalcedTimeLabel:setText(("ca. %s"):format(timeMsToTimeText(self.m_Toptimes[1].time*selectedLaps)))
			end
		end

	self.m_ButtonStart = GUIButton:new(self.m_Width*0.65, self.m_Height*0.32, self.m_Width*0.3, self.m_Height*0.07, _"Start", tabTimeRace):setBackgroundColor(Color.Orange)
	self.m_ButtonStart.onLeftClick =
		function()
			triggerServerEvent("startKartTimeRace", localPlayer, self.m_LapChange:getIndex())
		end

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.42, self.m_Width*0.25, self.m_Height*0.06, _"Preis:", tabTimeRace)
	self.m_PriceLabel = GUILabel:new(self.m_Width*0.25, self.m_Height*0.42, self.m_Width*0.25, self.m_Height*0.06,"", tabTimeRace)
	self.m_DiscountLabel = GUILabel:new(self.m_Width*0.34, self.m_Height*0.42, self.m_Width*0.25, self.m_Height*0.06,"", tabTimeRace)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.5, self.m_Width*0.25, self.m_Height*0.06, _"Benötigte Zeit:", tabTimeRace)
	self.m_CalcedTimeLabel = GUILabel:new(self.m_Width*0.25, self.m_Height*0.5, self.m_Width*0.25, self.m_Height*0.06,"", tabTimeRace)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.57, self.m_Width*0.98, self.m_Height*0.06, _"ACHTUNG: Du bekommst kein Geld erstattet, wenn du nicht alle runden fährst!", tabTimeRace):setColor(Color.Red)

	-- Toptimes
	self.m_GridList = GUIGridList:new(10, 10, self.m_Width-20, self.m_Height-30, tabToptimes)
	self.m_GridList:addColumn("Rank", .1)
	self.m_GridList:addColumn("Zeit", .4)
	self.m_GridList:addColumn("Spieler", .5)

	self.m_fnReceiveToptimes = bind(KartGUI.receiveToptimes, self)
	addEventHandler("receiveKartDatas", root, self.m_fnReceiveToptimes)
	triggerServerEvent("requestKartDatas", localPlayer)
end

function KartGUI:virtual_destructor()
	removeEventHandler("receiveKartDatas", root, self.m_fnReceiveToptimes)
end

function KartGUI:receiveToptimes(mapname, mapauthor, toptimes)
	self.m_Toptimes = toptimes

	self.m_MapNameLabel:setText(mapname)
	self.m_AuthorLabel:setText(mapauthor)

	self.m_LapChange.onChange(self.m_LapChange:getIndex())

	self.m_GridList:clear()
	for k, v in ipairs(self.m_Toptimes) do
		self.m_GridList:addItem(("%d."):format(k), timeMsToTimeText(v.time), v.name)
	end
end

addEventHandler("showKartGUI", root,
	function(show)
		if show then
			KartGUI:new()
		else
			delete(KartGUI:getSingleton())
		end
	end
)
