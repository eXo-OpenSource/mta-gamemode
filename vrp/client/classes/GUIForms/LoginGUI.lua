LoginGUI = inherit(GUIForm)
inherit(Singleton, LoginGUI)

function LoginGUI:constructor(savedName, savedPW)

	LoginGUI.startCameraDrive()
	showChat(false)
	setPlayerHudComponentVisible("radar",false)

	self.m_SavedName = savedName
	self.m_SavedPW = savedPW

	self.m_FadeTime = DEBUG_AUTOLOGIN and 50 or 250
	self.m_Elements = {}

	grid("reset", true)
	self.m_W = grid("x", 10)
	self.m_H = grid("y", 13) --height of register panel to switch content without recreating the form (as resizing stretches the cache area!)

	GUIForm.constructor(self, 0, 0, self.m_W , self.m_H, true)
	self.m_H = 0 -- to let the animation start from the center of the screen
	self:centerForm()

	if not DEBUG_AUTOLOGIN then --only play animations when it is necessary
		setTimer(function()
			self:switchViews(savedName and true)
		end, 500, 1)
	else
		self:switchViews(savedName and true)
	end


	self:bind("enter",
		function(self)
			if not self.m_Loaded or self.m_AnimInProgress then return end

			if self.m_LoginMode then
				if self.m_Elements.BtnLogin:isEnabled() then
					self.m_Elements.BtnLogin:onLeftClick()
				end
			else
				if self.m_Elements.BtnRegister:isVisible() then
					self.m_Elements.BtnRegister:onLeftClick()
				end
			end
		end
	)
end

function LoginGUI:virtual_destructor()
	LoginGUI.stopCameraDrive()
	Cursor:hide(true)
end

function LoginGUI:fadeElements(fadeIn)
	for i, v in pairs(self.m_Elements) do
		if fadeIn then
			Animation.FadeAlpha:new(v, self.m_FadeTime, 0, v:getAlpha() or 255)
		else
			Animation.FadeAlpha:new(v, self.m_FadeTime, v:getAlpha() or 255, 0)
		end
	end
end

function LoginGUI:switchViews(showLogin, deleteView, callback)
	if self.m_AnimInProgress then return false end
	self.m_AnimInProgress = true
	self:fadeElements()

	--animate the window using a dummy because otherwise the content would stretch
	self.m_AnimationDummy = DxRectangle:new(self.m_AbsoluteX, self.m_AbsoluteY, self.m_W, self.m_H, Color.Background):setDrawingEnabled(true)
	local newH = deleteView and 0 or showLogin and grid("y", 11) or grid("y", 13)
	Animation.Move:new(self.m_AnimationDummy, self.m_FadeTime + self.m_FadeTime * 1.2, self.m_AbsoluteX, screenHeight/2 - newH/2, "InOutQuad")

	--this stupid code is just because the window bgcolor is sometimes changed too early (resulting in a transparent window for 1 frame. suggestions are welcome!
	Animation.Size:new(self.m_AnimationDummy, 1, self.m_W, self.m_H, "InOutQuad").onFinish = function()
		if self.m_Window then  self.m_Window.m_BGColor = Color.Clear end
		Animation.Size:new(self.m_AnimationDummy, self.m_FadeTime + self.m_FadeTime * 1.2, self.m_W, newH, "InOutQuad")
	end


	setTimer(function()
		self:deleteElements()

		if not deleteView then
			if showLogin then
				self:loadLoginElements()
			else
				self:loadRegisterElements()
			end
			self:fadeElements(true)
		end
		self.m_Window.m_BGColor = Color.Clear

		setTimer(function()
			if not deleteView then
				if self.m_AnimationDummy then self.m_AnimationDummy:delete() end
				self.m_Window.m_BGColor = Color.Background
				self.m_AnimInProgress = false
			else
				self:delete()
				if callback then callback() end
			end
		end, self.m_FadeTime, 1)

	end, self.m_FadeTime*1.2, 1)
end

function LoginGUI:centerForm()
	self:setPosition(screenWidth/2 - self.m_W/2, screenHeight/2 - self.m_H/2)
end

function LoginGUI:deleteElements()
	for i, v in pairs(self.m_Elements) do
		v:delete()
	end
end

function LoginGUI:loadLoginElements()
	grid("reset", true)
	self.m_W = grid("x", 10)
	self.m_H = grid("y", 11)
	self:centerForm()
	self.m_LoginMode = true

	self.m_Window = GUIWindow:new(0, 0, self.m_W, self.m_H, _"", false, false, self)
	self.m_Elements.logo = GUIGridImage:new(1, 1, 9, 2, "files/images/LogoNoFont.png", self.m_Window):fitBySize(285, 123)

	self.m_Elements.window = self.m_Window

	self.m_Elements.lbl1 = GUIGridLabel:new(1, 3, 9, 2, _"Herzlich willkommen auf eXo Reallife, bitte logge dich mit deinen Accountdaten ein.", self.m_Window)
		:setAlignX("center")
	self.m_Elements.editName = GUIGridEdit:new(1, 5, 9, 1, self.m_Window)
		:setCaption(_"Username")
		:setIcon(FontAwesomeSymbols.Player)
		:setText(self.m_SavedName or "")
	self.m_Elements.editPW = GUIGridEdit:new(1, 6, 9, 1, self.m_Window)
		:setCaption(_"Passwort")
		:setText(self.m_SavedPW or "")
		:setMasked()
		:setIcon(FontAwesomeSymbols.Lock)
	self.m_Elements.lbl2 = GUIGridLabel:new(1, 7, 6, 1, _"Passwort speichern", self.m_Window)
	self.m_Elements.swSavePW = GUIGridSwitch:new(7, 7, 3, 1, self.m_Window):setState(self.m_SavedPW and self.m_SavedPW ~= "")

	self.m_Elements.BtnLogin = GUIGridButton:new(1, 8, 9, 1, "Einloggen", self.m_Window)
		:setBarEnabled(false)
	self.m_Elements.BtnLogin.onLeftClick = function()
		self.m_Elements.BtnLogin:setEnabled(false)
	end
	self.m_Elements.connectionLabel = GUIGridLabel:new(1, 9, 9, 1, "", self.m_Window)
		:setColor(Color.Red)
		:setAlignX("center")
	self.m_Elements.Label = GUIGridLabel:new(1, 10, 9, 1, _"(Kein Account? Registriere dich noch heute!)", self.m_Window)
		:setClickable(true)
		:setAlignX("center")
	self.m_Elements.Label.onLeftClick = function()
		self:switchViews(false)
	end
	self.m_Elements.Label:setAlignX("center")

	--logic
	self.m_Elements.BtnLogin.onLeftClick = bind(function(self)
		if self:checkExternalWebsitesActivated() then
			local name = self.m_Elements.editName:getText()
			local pw = self.m_Elements.editPW:getText()

			if self.m_SavedPW and self.m_SavedPW == pw then -- User has not changed the password
				triggerServerEvent("accountlogin", root, name, "", pw)
			else
				triggerServerEvent("accountlogin", root, name, pw, nil, self.m_Elements.swSavePW:isChecked())
			end

			-- Disable login button field to avoid several events
			self:setLoggingIn(true)
		end
	end, self)

	nextframe(function()
		if DEBUG_AUTOLOGIN then self.m_Elements.BtnLogin:onLeftClick() end
	end)

	self.m_Loaded = true
end

function LoginGUI:loadRegisterElements()
	grid("reset", true)
	self.m_W = grid("x", 10)
	self.m_H = grid("y", 13)
	self:centerForm()
	self.m_LoginMode = false

	self.m_Window = GUIWindow:new(0, 0, self.m_W, self.m_H, _"", false, false, self)
	self.m_Elements.logo = GUIGridImage:new(1, 1, 9, 2, "files/images/LogoNoFont.png", self.m_Window):fitBySize(285, 123)

	self.m_Elements.window = self.m_Window

	self.m_Elements.lbl1 = GUIGridLabel:new(1, 3, 9, 3, _"Bitte fülle das Formular aus um einen neuen Account zu erstellen. Pro PC und Internetanschluss ist nur ein Account zugelassen.", self.m_Window)
		:setAlignX("center")
	self.m_Elements.editName = GUIGridEdit:new(1, 6, 9, 1, self.m_Window)
		:setCaption(_"Username")
		:setIcon(FontAwesomeSymbols.Player)
	self.m_Elements.editPW = GUIGridEdit:new(1, 7, 9, 1, self.m_Window)
		:setCaption(_"Passwort")
		:setMasked()
		:setIcon(FontAwesomeSymbols.Lock)
	self.m_Elements.editPW2 = GUIGridEdit:new(1, 8, 9, 1, self.m_Window)
		:setCaption(_"Passwort wiederholen")
		:setMasked()
		:setIcon(FontAwesomeSymbols.Lock)
	self.m_Elements.editEmail = GUIGridEdit:new(1, 9, 9, 1, self.m_Window)
		:setCaption(_"Email-Adresse")
		:setIcon(FontAwesomeSymbols.Mail)

	self.m_Elements.checkAcceptRules = GUIGridCheckbox:new(1, 10, 7, 1, _"Ich akzeptiere die Serverregeln.", self.m_Window)
	self.m_Elements.cLblRules = GUIGridLabel:new(8, 10, 2, 1, _"(ansehen)", self.m_Window)
		:setClickable(true)
		:setAlignX("right")

	self.m_Elements.BtnRegister = GUIGridButton:new(1, 11, 9, 1, _"Registrieren", self.m_Window)
		:setBarEnabled(false)

	self.m_Elements.Label = GUIGridLabel:new(3, 12, 5, 1, _"(zurück zum Login)", self.m_Window)
		:setClickable(true)
		:setAlignX("center")

	self.m_Elements.Label.onLeftClick = function()
		self:switchViews(true)
	end

	self.m_Elements.ErrorLbl = GUIGridLabel:new(1, 6, 9, 4, _"error text gets loaded here", self.m_Window)
		:setAlignX("center")
		:setBackgroundColor(Color.Red)
		:setVisible(false)

	--logic
	self:checkRegister()

	self.m_Elements.BtnRegister.onLeftClick = bind(function(self)
		if self:checkExternalWebsitesActivated() then
			if self.m_Elements.editPW:getText() == self.m_Elements.editPW2:getText() then
				if self.m_Elements.checkAcceptRules:isChecked() then
					triggerServerEvent("accountregister", root, self.m_Elements.editName:getText(), self.m_Elements.editPW:getText(), self.m_Elements.editEmail:getText())
					self.m_Elements.BtnRegister:setEnabled(false)
				else
					triggerEvent("registerfailed",localPlayer, _"Du musst den Serveregeln zustimmen!")
				end
			else
				triggerEvent("registerfailed",localPlayer, _"Passwörter stimmen nicht überein!")
			end
		end
	end, self)

	self.m_Elements.cLblRules.onLeftClick = function()
		if self:checkExternalWebsitesActivated() then
			LoginRuleGUI:new()
			InfoBox:new(_"Da alle Regeln in einem Dokument stehen wirkt der Scrollbalken erscheckend klein - aber keine Sorge, wichtig für dich sind für den Anfang nur die Regeln von §1 - §5.\nMit gedrückter Shift-Taste kannst du im Dokument schneller scrollen.")
		end
	end

	self.m_Loaded = true
end

function LoginGUI:initClose(callback)
	self:switchViews(true, true, callback)
end

function LoginGUI:checkRegister()
	triggerServerEvent("checkRegisterAllowed", localPlayer)
end


function LoginGUI:showRegisterMultiaccountError(name)
	self.m_Elements.editName:setVisible(false)
	self.m_Elements.editPW:setVisible(false)
	self.m_Elements.editPW2:setVisible(false)
	self.m_Elements.editEmail:setVisible(false)
	self.m_Elements.BtnRegister:setVisible(false)
	self.m_Elements.checkAcceptRules:setVisible(false)
	self.m_Elements.cLblRules:setVisible(false)

	local text = _("Für deine Serial existiert bereits ein Account. Wenn du mit anderen Spielern im gleichen Netzwerk spielen möchtest, musst du einen Multiaccount-Antrag im Forum (forum.exo-reallife.de) verfassen.")
	if name then
		text = _("Deine Serial wurde zuletzt vom Spieler '%s' benutzt! Wenn du mit anderen Spielern im gleichen Netzwerk spielen möchtest, musst du einen Multiaccount-Antrag im Forum (forum.exo-reallife.de) verfassen.", name)
	end
	self.m_Elements.ErrorLbl:setVisible(true)
	self.m_Elements.ErrorLbl:setText(text)

end

function LoginGUI:checkExternalWebsitesActivated()
	if getBrowserSettings().RemoteEnabled == false then
		ErrorBox:new(_"Bitte aktiviere in den Einstellungen unter Webbrowser die Option Externe Webseiten aktivieren!")
		return false
	end
	return true
end

function LoginGUI:setLoggingIn(state)
	local button = self.m_LoginMode and self.m_Elements.BtnLogin or self.m_Elements.BtnRegister
	local label = self.m_Elements.Label

	if state then
		button:setEnabled(false)
		label:setClickable(false):setColor(Color.Accent)
		self.m_Dots = "."
		self.m_UpdateTimer = setTimer(bind(self.updateTexts, self), 250, 0)
	else
		button:setText(self.m_LoginMode and _"Einloggen" or _"Registrieren")
		button:setEnabled(true)
		label:setClickable(true)
		killTimer(self.m_UpdateTimer)
		if self.m_ShortMessage then delete(self.m_ShortMessage) end
		self.m_ShortMessage = nil
		self.m_QueuePosition = nil
		self.m_ConnectionAttempt = nil
	end
end

function LoginGUI:updateTexts()
	local button = self.m_LoginMode and self.m_Elements.BtnLogin or self.m_Elements.BtnRegister
	local buttonText = _(self.m_LoginMode and "Einloggen%s" or "Registrieren%s", self.m_Dots)
	local text = ""

	if #self.m_Dots >= 3 then
		self.m_Dots = ""
	else
		self.m_Dots = self.m_Dots.."."
	end

	if self.m_QueuePosition and self.m_QueuePosition > 1 then
		text = _("Position in Warteschlange: %d", self.m_QueuePosition)
	elseif self.m_ConnectionAttempt and self.m_ConnectionAttempt > 0 then
		text = _("Verbindung zum Forum fehlgeschlagen! (%d/%d)\nVersuche erneut%s", self.m_ConnectionAttempt-1, FORUM_MAX_CONNECTION_ATTEMPTS-1, self.m_Dots)
	end

	button:setText(buttonText)
	if self.m_ShortMessage and #text > 0 then
		self.m_ShortMessage:setText(text)
	elseif #text > 0 then
		self.m_ShortMessage = ShortMessage:new(text, nil, false, -1, false, false, false, false, true)
	elseif self.m_ShortMessage then
		delete(self.m_ShortMessage)
		self.m_ShortMessage = nil
	end
end

addEvent("receiveRegisterAllowed", true)
addEventHandler("receiveRegisterAllowed", root,
	function(state, name)
		if state == false then
			LoginGUI:getSingleton():showRegisterMultiaccountError(name)
		end
	end
)

addEvent("loginfailed", true)
addEventHandler("loginfailed", root,
	function(text)
		ErrorBox:new(text)
		LoginGUI:getSingleton():setLoggingIn(false)
	end
)
addEvent("registerfailed", true)
addEventHandler("registerfailed", root,
	function(text)
		ErrorBox:new(text)
		LoginGUI:getSingleton():setLoggingIn(false)
	end
)

addEvent("closeLogin", true)
addEventHandler("closeLogin", root,
	function()
		LoginGUI:getSingleton():initClose()
	end
)

addEvent("loginInformationUpdate", true)
addEventHandler("loginInformationUpdate", root, 
	function(queuePosition, connectionAttempt)
		if LoginGUI:isInstantiated() then
			if connectionAttempt == true then
				LoginGUI:getSingleton():setLoggingIn(false)
				ErrorBox:new(_"Verbindung zum Forum nicht möglich!")
				return
			end
			LoginGUI:getSingleton().m_QueuePosition = queuePosition
			LoginGUI:getSingleton().m_ConnectionAttempt = connectionAttempt
		end
	end
)

addEvent("loginsuccess", true)
addEventHandler("loginsuccess", root,
	function(pwhash)
		local lgi = LoginGUI:getSingleton()

		if lgi.m_Elements.swSavePW:isChecked() and pwhash then
			core:set("Login", "username", lgi.m_Elements.editName:getText())
			core:set("Login", "password", pwhash)
		else
			core:set("Login", "password", "")
		end

		core:afterLogin()
		lgi:setLoggingIn(false)
		lgi:initClose()
	end
)

function LoginGUI.startCameraDrive()
	local positions = { -- from, to - use /cammat
		{1513.67, -1730.51, 30.08, 1513.17, -1731.26, 29.63, 1448.87, -1729.30, 29.87, 1449.27, -1730.09, 29.40}, --Usertreff
		{1207.93, -1396.98, 36.71, 1207.22, -1396.39, 36.32, 1209.52, -1270.38, 26.66, 1208.81, -1271.06, 26.50}, --Rescue Base
		{1823.10, -1886.26, 34.70, 1822.36, -1886.72, 34.21, 1809.02, -1943.21, 18.81, 1808.39, -1942.46, 18.99}, --EPT
		{334.18, -2145.09, 32.20, 334.43, -2144.12, 32.16, 329.64, -1845.51, 12.24, 330.36, -1844.82, 12.33}, --Pier
		{-202.24, -346.63, 41.28, -202.20, -345.66, 41.03, -326.57, -18.33, 49.76, -325.65, -18.07, 49.46}, --Farm
		{694.92, 752.66, 3.76, 694.45, 753.47, 3.43, 745.98, 904.85, 6.73, 745.20, 904.41, 6.29}, --Gravel
		{1380.20, -2352.63, 62.20, 1380.91, -2351.94, 62.08, 1579.13, -2166.62, 42.35, 1580.00, -2167.12, 42.34}, --Airport
		{2335.97, -1555.61, 45.53, 2336.34, -1554.68, 45.48, 2331.10, -1392.08, 69.67, 2330.62, -1391.23, 69.42}, --Ballas
	}
	local rand = math.random(1,#positions)
	local p = positions[rand]
	if EVENT_HALLOWEEN then p = {956.14, -1133.92, 37.22, 884.34, -1066.16, 21.27, 824.06, -1105.73, 30.81, 915.61, -1065.58, 28.06} end --grave yard ls

	local timeMS = getDistanceBetweenPoints3D(p[1], p[2], p[3], p[7], p[8], p[9])*1000

	localPlayer.m_LoginDriveObject = cameraDrive:new(p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10], p[11], p[12], timeMS, "Linear" )
	localPlayer.m_LoginDriveObject:setFOV(100)

	localPlayer.m_LoginCamTimer = setTimer(LoginGUI.startCameraDrive, timeMS, 1)
	localPlayer:setDimension(0)

	for i,player in pairs(getElementsByType("player")) do
		setPlayerNametagShowing(player, false)
	end

	RadialShader:getSingleton():setEnabled(true)
	--localPlayer.m_LoginShader =  LoginShader:new()
end

function LoginGUI.stopCameraDrive()
	if localPlayer.m_LoginDriveObject then
		delete(localPlayer.m_LoginDriveObject)
		showChat(true)
	end
	if localPlayer.m_LoginCamTimer and isTimer(localPlayer.m_LoginCamTimer) then
		killTimer(localPlayer.m_LoginCamTimer)
	end
	if localPlayer.m_LoginShader then
		delete(localPlayer.m_LoginShader)
		localPlayer.m_LoginShader = nil
	end
	setCameraTarget(localPlayer)
	triggerServerEvent("onClientRequestTime", localPlayer)
end




LoginRuleGUI = inherit(GUIForm)
inherit(Singleton, LoginRuleGUI)

function LoginRuleGUI:constructor()
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 16) 	-- width of the window
	self.m_Height = grid("y", 12) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Regelwerk", true, true, self)

	self.m_Browser = GUIGridWebView:new(1, 1, 15, 11, "https://forum.exo-reallife.de/index.php?thread/22539-serverregeln/", true, self.m_Window)
end

function LoginRuleGUI:destructor()
	GUIForm.destructor(self)
end

