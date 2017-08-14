-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppSanNews.lua
-- *  PURPOSE:     San News app class
-- *
-- ****************************************************************************
AppSanNews = inherit(PhoneApp)

local ColorTable = {
	["Orange"] = Color.Orange,
	["Grün"] = Color.Green,
	["Hell-Blau"] = Color.AD_LightBlue,
	["Red"] = Color.Red,
}

function AppSanNews:constructor()
	PhoneApp.constructor(self, "SanNews", "IconSanNews.png")
end

function AppSanNews:onOpen(form)

	self.m_TabPanel = GUIPhoneTabPanel:new(0, 0, form.m_Width, form.m_Height, form)
	self.m_Tabs = {}
	self.m_Tabs["News"] = self.m_TabPanel:addTab(_"Nachrichten", FontAwesomeSymbols.Newspaper)
	local tab = self.m_Tabs["News"]
	self.m_NewsBrowser = GUIWebView:new(0, 0, tab.m_Width, tab.m_Height-10, ("https://exo-reallife.de/ingame/vRPphone/apps/sannews/index.php?player=%s&sessionID=%s"):format(localPlayer:getName(), localPlayer:getSessionId()), true, self.m_Tabs["News"])


	self.m_Tabs["Advertisment"] = self.m_TabPanel:addTab(_"Werbung", FontAwesomeSymbols.Advertisement)
	tab = self.m_Tabs["Advertisment"]
	GUILabel:new(tab.m_Width*0.02, tab.m_Height*0.01, tab.m_Width*0.98, tab.m_Height*0.12, "Werbung", self.m_Tabs["Advertisment"]):setMultiline(true)
	GUILabel:new(tab.m_Width*0.02, tab.m_Height*0.15, tab.m_Width*0.98, tab.m_Height*0.07, "Werbe-Text:", self.m_Tabs["Advertisment"]):setMultiline(true)
	self.m_EditBox = GUIEdit:new(tab.m_Width*0.02, tab.m_Height*0.22, tab.m_Width*0.96, tab.m_Height*0.07, self.m_Tabs["Advertisment"])
	self.m_EditBox.onChange = function () self:calcCosts() end

	GUILabel:new(tab.m_Width*0.02, tab.m_Height*0.32, tab.m_Width*0.48, tab.m_Height*0.07, "Farbe:", self.m_Tabs["Advertisment"])
	self.m_ColorChanger = GUIChanger:new(tab.m_Width*0.4, tab.m_Height*0.32, tab.m_Width*0.58, tab.m_Height*0.07, self.m_Tabs["Advertisment"])
	for key, name in pairs(AD_COLORS) do
		self.m_ColorChanger:addItem(name)
	end
	self.m_ColorChanger.onChange = function () self:calcCosts() end

	GUILabel:new(tab.m_Width*0.02, tab.m_Height*0.42, tab.m_Width*0.5, tab.m_Height*0.07, "Dauer:", self.m_Tabs["Advertisment"])
	self.m_DurationChanger = GUIChanger:new(tab.m_Width*0.4, tab.m_Height*0.42, tab.m_Width*0.58, tab.m_Height*0.07, self.m_Tabs["Advertisment"])
	for name, duration in pairs(AD_DURATIONS) do
		self.m_DurationChanger:addItem(name)
	end
	self.m_DurationChanger.onChange = function () self:calcCosts() end

	GUILabel:new(tab.m_Width*0.02, tab.m_Height*0.52, tab.m_Width*0.5, tab.m_Height*0.07, "Sender:", self.m_Tabs["Advertisment"])
	self.m_SenderNameChanger = GUIChanger:new(tab.m_Width*0.4, tab.m_Height*0.52, tab.m_Width*0.58, tab.m_Height*0.07, self.m_Tabs["Advertisment"])
	self.m_SenderNameChanger:addItem(localPlayer:getName())
	if localPlayer:getGroupName() and localPlayer:getGroupName() ~= "" then
		self.m_SenderNameChanger:addItem(localPlayer:getGroupName())
	end

	self.m_InfoRect = GUIRectangle:new(tab.m_Width*0.02, tab.m_Height*0.65, tab.m_Width*0.96, tab.m_Height*0.13, Color.Red, self.m_Tabs["Advertisment"])
	self.m_InfoLabel = GUILabel:new(tab.m_Width*0.02, tab.m_Height*0.65, tab.m_Width*0.96, tab.m_Height*0.07, "Kosten: 0$", self.m_Tabs["Advertisment"]):setFontSize(0.8):setAlignX("center")

	self.m_SubmitButton = VRPButton:new(tab.m_Width*0.02, tab.m_Height*0.85, tab.m_Width*0.96, tab.m_Height*0.09, _"Werbung schalten", true, self.m_Tabs["Advertisment"]):setBarColor(Color.Green)


	self.m_SubmitButton.onLeftClick =
		function()
			local senderName, senderIndex = self.m_SenderNameChanger:getIndex()
			triggerServerEvent("sanNewsAdvertisement", localPlayer, senderIndex, self.m_EditBox:getText(), self.m_ColorChanger:getIndex(), self.m_DurationChanger:getIndex())
		end
	self:calcCosts()

end

function AppSanNews:calcCosts()
	local length = string.len(self.m_EditBox:getText())
	local selectedDuration = self.m_DurationChanger:getIndex()
	local durationExtra = (AD_DURATIONS[selectedDuration] - 20) * 2

	local colorMultiplicator = 1
	local selectedColor = self.m_ColorChanger:getIndex()
	if selectedColor ~= "Schwarz" then
		colorMultiplicator = 2
	end

	self.m_ColorChanger:setBackgroundColor(ColorTable[selectedColor])

	if self.m_EditBox:getText():find("\\") then
		self.m_InfoLabel:setText(_"Invalid Text!")
		self.m_InfoRect:setColor(Color.Red)
		self.m_SubmitButton:setEnabled(false)
		return
	end
	if length < 5 then
		self.m_InfoLabel:setText(_"Dein Werbetext ist zu kurz! Mindestens 5 Zeichen!")
		self.m_InfoRect:setColor(Color.Red)
		self.m_SubmitButton:setEnabled(false)
	elseif length > 50 then
		self.m_InfoLabel:setText(_"Dein Werbetext ist zu lang! Maximal 50 Zeichen!")
		self.m_InfoRect:setColor(Color.Red)
		self.m_SubmitButton:setEnabled(false)
	else
		local costs = (length*AD_COST_PER_CHAR + AD_COST + durationExtra) * colorMultiplicator
		self.m_InfoLabel:setText(_("Zeichenanzahl: %d Kosten: %d$", length, costs))
		self.m_InfoRect:setColor(Color.Green)
		self.m_SubmitButton:setEnabled(true)
	end
end



local currentAd
addEvent("showAd", true)
addEventHandler("showAd", root, function(sender, text, color, duration)
	local callSender =
	function()
		if Phone:getSingleton():isOn()then
			Phone:getSingleton():onShow()
			Phone:getSingleton():closeAllApps()
			Phone:getSingleton():openAppByClass(AppCall)

			if sender.referenz == "player" then
				local player = getPlayerFromName(sender.name)

				if not player then
					ErrorBox:new(_"Dieser Spieler ist nicht mehr online!")
					return
				end

				if player == localPlayer then
					ErrorBox:new(_"Du kannst dich nicht selbst anrufen!")
					return
				end

				Phone:getSingleton():getAppByClass(AppCall):openInCall("player", player, CALL_RESULT_CALLING, false)
				triggerServerEvent("callStart", root, player, false)
			elseif sender.referenz == "group" then
				Phone:getSingleton():getAppByClass(AppCall):openInCall("group", sender.name, CALL_RESULT_CALLING, false)
				triggerServerEvent("callStartSpecial", root, sender.number)
			end
		else
			WarningBox:new("Dein Handy ist ausgeschaltet!")
		end
	end

	currentAd = ShortMessage:new(("%s"):format(text), ("Werbung von %s"):format(sender.name), ColorTable[color], AD_DURATIONS[duration]*1000, callSender)
end)

addEventHandler("closeAd", root, function()
	if currentAd then
		delete(currentAd)
	end
end)
