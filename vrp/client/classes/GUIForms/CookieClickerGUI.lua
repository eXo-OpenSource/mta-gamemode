-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/CookieClickerGUI.lua
-- *  PURPOSE:     Cookie Clicker GUI class
-- *
-- ****************************************************************************
CookieClickerGUI = inherit(GUIForm)
inherit(Singleton, CookieClickerGUI)

addRemoteEvents{"CookieClicker:openGUI", "CookieClicker:sendCookieData", "CookieClicker:sendTopListData", "CookieClicker:forceCloseGUI"}

function CookieClickerGUI:constructor(rangeElement)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 16)
	self.m_Height = grid("y", 17)
	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true, false, rangeElement)

	self.m_Cookies = 0
	self.m_CookiesPerClick = 0

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Weihnachtsevent: User Clicker", true, true, self)

	self.m_CookieLabel = GUIGridLabel:new(8, 4, 6, 1, "Deine User:", self.m_Window):setFont(VRPFont(45))
	self.m_CookieCount = GUIGridLabel:new(13, 4, 5, 1, self.m_Cookies, self.m_Window):setFont(VRPFont(45))

	self.m_CookiePerClickLabel = GUIGridLabel:new(8, 6, 6, 1, "User pro Klick:", self.m_Window):setFont(VRPFont(45))
	self.m_CookiePerClickCount = GUIGridLabel:new(13, 6, 5, 1, self.m_CookiesPerClick, self.m_Window):setFont(VRPFont(45)) 

	self.m_Cookie = GUIImage:new(self.m_Width/2-288, self.m_Height/2-250, 256, 256, "files/images/Other/UserClicker.png", self.m_Window)    
	self.m_CookieHitBox = GUIButton:new(self.m_Width/2-288, self.m_Height/2-250, 256, 256, "", self.m_Window, tocolor(0,0,0,0), tocolor(0,0,0,0))
	self.m_CookieHitBox:setBackgroundColor(tocolor(0,0,0,0)):setBackgroundHoverColor(tocolor(0,0,0,0)):setAlpha(0):setBarEnabled(false)
	self.m_CookieHitBox.onHover = function() 
		Animation.Size:new(self.m_Cookie, 450, 276, 276, "OutBounce") 
		Animation.Move:new(self.m_Cookie, 100, self.m_Width/2-293.5, self.m_Height/2-255.5)
	end
	self.m_CookieHitBox.onUnhover = function() 
		Animation.Size:new(self.m_Cookie, 450, 256, 256, "OutBounce")
		Animation.Move:new(self.m_Cookie, 100, self.m_Width/2-288, self.m_Height/2-250)
	end
	self.m_CookieHitBox.onLeftClick = function() 
		Animation.Size:new(self.m_Cookie, 100, 255, 255)
		if timer then
			killTimer(timer)
		end
		local timer = setTimer(function() Animation.Size:new(self.m_Cookie, 100, 276, 276) end, 100, 1)
		if self:canPlayerCollectCookie() then
			self.m_Cookies = self.m_Cookies + self.m_CookiesPerClick
			self.m_CookieCount:setText(self.m_Cookies)
		end
	end

	self.m_UpgradeButton = {}
	self.m_UpgradeLabel = {}

	self.m_UpgradeButton[1] = GUIGridButton:new(1, 12, 5, 1, "", self.m_Window)
	self.m_UpgradeLabel[1] = GUIGridLabel:new(1, 11, 5, 1, "Keine Zensur (+ 1)", self.m_Window)
	self.m_UpgradeButton[2] = GUIGridButton:new(6, 12, 5, 1, "", self.m_Window)
	self.m_UpgradeLabel[2] = GUIGridLabel:new(6, 11, 5, 1, "Kein FUV-Einsatz (+ 4)", self.m_Window)
	self.m_UpgradeButton[3] = GUIGridButton:new(11, 12, 5, 1, "", self.m_Window)
	self.m_UpgradeLabel[3] = GUIGridLabel:new(11, 11, 5, 1, "Lagfreier Gangwar (+ 6)", self.m_Window)
  
	self.m_UpgradeButton[4] = GUIGridButton:new(1, 15, 5, 1, "", self.m_Window)
	self.m_UpgradeLabel[4] = GUIGridLabel:new(1, 14, 5, 1, "Backups (+ 8)", self.m_Window)
	self.m_UpgradeButton[5] = GUIGridButton:new(6, 15, 5, 1, "", self.m_Window)
	self.m_UpgradeLabel[5] = GUIGridLabel:new(6, 14, 5, 1, "Neues Inventar (+ 10)", self.m_Window)
	self.m_UpgradeButton[6] = GUIGridButton:new(11, 15, 5, 1, "", self.m_Window)
	self.m_UpgradeLabel[6] = GUIGridLabel:new(11, 14, 5, 1, "Updates (+ 12)", self.m_Window)

	for id, button in ipairs(self.m_UpgradeButton) do
		button.onLeftClick = bind(self.onUpgradeButtonClick, self, id)
	end

	self.m_SaveButton = GUIGridButton:new(11, 16, 5, 1, "Speichern", self.m_Window)
	self.m_SaveButton.onLeftClick = function() 
		triggerServerEvent("CookieClicker:saveCookies", localPlayer, self.m_Cookies) 
		SuccessBox:new(_"Gespeichert!")
	end

	triggerServerEvent("CookieClicker:requestData", localPlayer, "cookies")
	addEventHandler("CookieClicker:sendCookieData", localPlayer, bind(self.onCookieDataReceive, self))
end

function CookieClickerGUI:virtual_destructor(noSave)
	if not noSave then
		triggerServerEvent("CookieClicker:saveCookies", localPlayer, self.m_Cookies)
	end
	AntiClickSpam:getSingleton():setBlock(8)
end

function CookieClickerGUI:onUpgradeButtonClick(id)
	triggerServerEvent("CookieClicker:saveCookies", localPlayer, self.m_Cookies)
	triggerServerEvent("CookieClicker:onUpgradeBuy", localPlayer, id)
end

function CookieClickerGUI:onCookieDataReceive(cookies, upgrades, info)
	local userPerClick = 1
	for upgrade, count in pairs(upgrades) do
		userPerClick = userPerClick + (info[tonumber(upgrade)].AddedClicks * count)
	end
	self.m_CookiesPerClick = userPerClick
	self.m_CookiePerClickCount:setText(userPerClick)

	self.m_Cookies = cookies
	self.m_CookieCount:setText(cookies)
	
	for id, button in ipairs(self.m_UpgradeButton) do
		local upgradePrice
		if upgrades[id] == 0 then
		   upgradePrice = info[id].price 
		else
			upgradePrice =  math.floor(info[id].Price + ((upgrades[tostring(id)] + 1 * 0.1) * info[id].Price) * 1.1)
		end

		button:setText(convertNumber(upgradePrice).. " User")
	end
end

function CookieClickerGUI:canPlayerCollectCookie()
	local cX, cY = getCursorPosition()
	local currentTick = getTickCount()
	if not self.m_CursorPositions then
		self.m_CursorPositions = {cX, cY}
		self.m_CursorPositionsCount = 0
	end
	if not self.m_CurrentTick then
		self.m_CurrentTick = currentTick
		self.m_ClickCount = 0
	end

	if cX == self.m_CursorPositions[1] and cY == self.m_CursorPositions[2] then
		if self.m_CursorPositionsCount >= 15 then
			ErrorBox:new(_"Bewege deine Maus!")
			return false
		else
			self.m_CursorPositionsCount = self.m_CursorPositionsCount + 1
		end
	else
		self.m_CursorPositions = {cX, cY}
		self.m_CursorPositionsCount = 0
	end

	if self.m_CurrentTick + 1000 >= currentTick then
		if self.m_ClickCount >= 20 then
			-- TODO Add sanction if to many clicks per second
			ErrorBox:new(_"Du klickst zu schnell!")
			return false
		else
			self.m_ClickCount = self.m_ClickCount + 1
		end
	else
		self.m_CurrentTick = currentTick
		self.m_ClickCount = 0
	end
	return true
end

CookieClickerButtonGUI = inherit(GUIButtonMenu)
inherit(Singleton, CookieClickerButtonGUI)

function CookieClickerButtonGUI:constructor(rangeElement)
	GUIButtonMenu.constructor(self, "Weihnachtsevent: User Clicker", false, false, false, false, rangeElement)

	self:addItem("User Clicker spielen", Color.Accent, function()
		if not CookieClickerGUI:isInstantiated() then
			delete(self)
			CookieClickerGUI:new(rangeElement)
			AntiClickSpam:getSingleton():setBlock(15)
		end
	end)
end

addEventHandler("CookieClicker:openGUI", localPlayer, function(rangeElement)
	if not CookieClickerButtonGUI:isInstantiated() and not CookieClickerGUI:isInstantiated() then
		CookieClickerButtonGUI:new(rangeElement)
	end
end)

addEventHandler("CookieClicker:forceCloseGUI", localPlayer, function(save)
	if CookieClickerGUI:isInstantiated() then
		CookieClickerGUI:getSingleton():delete(save)
	end
end)