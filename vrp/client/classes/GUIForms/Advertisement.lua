-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/Advertisement.lua
-- *  PURPOSE:     AdvertisementBox class
-- *
-- ****************************************************************************

AdvertisementBox = inherit(GUIForm)
inherit(Singleton, AdvertisementBox)

addRemoteEvents{"showAd", "closeAd", "closeAdvertisementBox"}

function AdvertisementBox:constructor()
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.24/2, screenWidth*0.4, screenHeight*0.24)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Werbung schalten", true, true, self)
	self.m_Window:addBackButton(function () SelfGUI:getSingleton():show() end)

	GUILabel:new(self.m_Width*0.01, self.m_Height*0.17, self.m_Width*0.98, self.m_Height*0.15, "Bitte gib deinen gewünschten Werbe-Text ein:", self.m_Window)
	self.m_EditBox = GUIEdit:new(self.m_Width*0.01, self.m_Height*0.32, self.m_Width*0.98, self.m_Height*0.15, self.m_Window)
	self.m_EditBox.onChange = function () self:calcCosts() end

	GUILabel:new(self.m_Width*0.01, self.m_Height*0.5, self.m_Width*0.2, self.m_Height*0.15, "Farbe:", self.m_Window)
	self.m_ColorChanger = GUIChanger:new(self.m_Width*0.15, self.m_Height*0.5, self.m_Width*0.3, self.m_Height*0.15, self.m_Window)
	for key, name in pairs(AD_COLORS) do
		self.m_ColorChanger:addItem(name)
	end
	self.m_ColorChanger.onChange = function () self:calcCosts() end

	GUILabel:new(self.m_Width*0.5, self.m_Height*0.5, self.m_Width*0.20, self.m_Height*0.15, "Dauer:", self.m_Window)
	self.m_DurationChanger = GUIChanger:new(self.m_Width*0.62, self.m_Height*0.5, self.m_Width*0.35, self.m_Height*0.15, self.m_Window)
	for name, duration in pairs(AD_DURATIONS) do
		self.m_DurationChanger:addItem(name)
	end
	self.m_DurationChanger.onChange = function () self:calcCosts() end

	GUILabel:new(self.m_Width*0.01, self.m_Height*0.65, self.m_Width*0.2, self.m_Height*0.15, "Sender:", self.m_Window)
	self.m_SenderNameChanger = GUIChanger:new(self.m_Width*0.15, self.m_Height*0.65, self.m_Width*0.3, self.m_Height*0.15, self.m_Window)
	self.m_SenderNameChanger:addItem(localPlayer:getName())
	if localPlayer:getGroupName() and localPlayer:getGroupName() ~= "" then
		self.m_SenderNameChanger:addItem(localPlayer:getGroupName())
	end

	self.m_InfoLabel = GUILabel:new(self.m_Width*0.01, self.m_Height*0.8, self.m_Width*0.75, self.m_Height*0.15, "Kosten: 0$", self.m_Window):setFontSize(0.8)

	self.m_SubmitButton = VRPButton:new(self.m_Width*0.64, self.m_Height*0.8, self.m_Width*0.35, self.m_Height*0.15, _"Werbung schalten", true, self.m_Window):setBarColor(Color.Green)


	self.m_SubmitButton.onLeftClick =
		function()
			local senderName, senderIndex = self.m_SenderNameChanger:getIndex()
			triggerServerEvent("sanNewsAdvertisement", localPlayer, senderIndex, self.m_EditBox:getText(), self.m_ColorChanger:getIndex(), self.m_DurationChanger:getIndex())
		end
	self:calcCosts()
end

function AdvertisementBox:calcCosts()
	local length = string.len(self.m_EditBox:getText())
	local selectedDuration = self.m_DurationChanger:getIndex()
	local durationExtra = (AD_DURATIONS[selectedDuration] - 20) * 2

	local colorMultiplicator = 1
	local selectedColor = self.m_ColorChanger:getIndex()
	if selectedColor ~= "Schwarz" then
		colorMultiplicator = 2
	end

	if self.m_EditBox:getText():find("\\") then
		self.m_InfoLabel:setText(_"Invalid Text!")
		self.m_InfoLabel:setColor(Color.Red)
		self.m_SubmitButton:setEnabled(false)
		return
	end
	if length < 5 then
		self.m_InfoLabel:setText(_"Dein Werbetext ist zu kurz! Mindestens 5 Zeichen!")
		self.m_InfoLabel:setColor(Color.Red)
		self.m_SubmitButton:setEnabled(false)
	elseif length > 50 then
		self.m_InfoLabel:setText(_"Dein Werbetext ist zu lang! Maximal 50 Zeichen!")
		self.m_InfoLabel:setColor(Color.Red)
		self.m_SubmitButton:setEnabled(false)
	else
		local costs = (length*AD_COST_PER_CHAR + AD_COST + durationExtra) * colorMultiplicator
		self.m_InfoLabel:setText(_("Zeichenanzahl: %d Kosten: %d$", length, costs))
		self.m_InfoLabel:setColor(Color.Green)
		self.m_SubmitButton:setEnabled(true)
	end
end

local ColorTable = {
	["Orange"] = Color.Orange,
	["Grün"] = Color.Green,
	["Hell-Blau"] = {0, 125, 125},
	["Red"] = Color.Red,
}

local currentAd

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

				CallResultActivity:new(Phone:getSingleton():getAppByClass(AppCall), "player", player, CALL_RESULT_CALLING, false)
				triggerServerEvent("callStart", root, player)
			elseif sender.referenz == "group" then
				CallResultActivity:new(Phone:getSingleton():getAppByClass(AppCall), "group", sender.name, CALL_RESULT_CALLING, false)
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

addEventHandler("closeAdvertisementBox", root,
	function()
		delete(AdvertisementBox:getSingleton())
	end
)
--[[
Advertisement = inherit(GUIForm)
inherit(Singleton, Advertisement)

function Advertisement:constructor(player, text, color, duration)
	if core:get("Ad", "Chat", 0) == 0 then
		GUIForm.constructor(self, 0, screenHeight-30, screenWidth, 30, false, true)
		self.m_Rectangle = GUIRectangle:new(0, 0, self.m_Width, self.m_Height, ColorTable[color], self)
		self.m_Rectangle:setAlpha(220)

		self.m_Duration = AD_DURATIONS[duration]*1000
		self.m_Label = GUILabel:new(10, 0, self.m_Width-10, self.m_Height-2, _("Werbung von %s: %s", player:getName(), text), self):setFont(VRPFont(32)):setFontSize(1)
		self:setVisible(false)
		self:FadeIn()
	else
		local r,g,b = fromcolor(ColorTable[color])
		if color == "Schwarz" then r,g,b = 180,180,180 end
		outputChatBox(_("Werbung von %s:", player:getName()), r, g, b)
		outputChatBox(text, r, g, b)
	end
end

function Advertisement:FadeIn()
	GUIForm.fadeIn(self, 750)
	setTimer(bind(self.fadeOut, self), self.m_Duration, 1)
end

function Advertisement:FadeOut()
	GUIForm.fadeOut(self, 750)
	setTimer(function() delete(self) end, 750, 1)
end
--]]
