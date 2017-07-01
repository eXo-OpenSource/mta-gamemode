LoginGUI = inherit(GUIForm)
inherit(Singleton, LoginGUI)

function LoginGUI:constructor()
	LoginGUI.startCameraDrive()
	showChat(false)
	setPlayerHudComponentVisible("radar",false)
	local sw, sh = guiGetScreenSize()
	self.usePasswordHash = false

	GUIForm.constructor(self, sw*0.2, sh*0.2, sw*0.6, sh*0.6)
	self.m_LoginButton 		= VRPButton:new(0, 0, sw*0.6/2, sh*0.6*0.1, "Login", false, self):setColor(tocolor(5, 10, 10))
	self.m_RegisterButton 	= VRPButton:new(sw*0.6/2, 0, sw*0.6/2, sh*0.6*0.1, "Registrieren", false, self):setColor(tocolor(5, 10, 10))
--	self.m_GuestButton 		= VRPButton:new(sw*0.6/3*2, 0, sw*0.6/3, sh*0.6*0.1, "Als Gast spielen", false, self)

	self.m_NewsTab 			= GUIRectangle:new(sw*0.6*0.75, sh*0.6*0.1, sw*0.6*0.25, sh*0.6-sh*0.6*0.01,  tocolor(10, 20, 20, 190), self)
	self.m_NewsTabBar		= GUIRectangle:new(sw*0.6*0.75, sh*0.6*0.1, sw*0.6*0.010, sh*0.6-sh*0.6*0.01, tocolor(50, 70, 70, 128), self)
							  GUILabel:new(sw*0.01, sh*0.01, self.m_Width/0.02, self.m_Height*0.2, "News:", self.m_NewsTab):setFont(VRPFont(sh*0.06)):setColor(Color.LightBlue)
	self.m_NewsText = GUILabel:new(sw*0.01, sh*0.065,
		self.m_Width/0.02, self.m_Height*0.6,
		[[
eXo 1.2 - 16.06.2017

einige Neuerungen:
- Spawnauswahl
- automat. Firmen-
  Fahrzeugverkauf
- neue Objektplatzierung
- endlich wieder Magnet-Helis
- ...und noch viel mehr!

Einen ausführlichen Change-
log findet ihr natürlich unter
forum.exo-reallife.de!

		]], self.m_NewsTab):setFont(VRPFont(sh*0.03))

	self.m_LoginTab 		= GUIRectangle:new(0, sh*0.6*0.1, sw*0.6*0.75, sh*0.6-sh*0.6*0.01, tocolor(10, 30, 30, 190), self)
	self.m_LoginEditUser	= GUIEdit:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.46, sw*0.6*0.75*0.50, sh*0.6*0.05, self.m_LoginTab)
	self.m_LoginTextUser	= GUILabel:new(sw*0.6*0.75*0.67, (sh*0.6-sh*0.6*0.01)*0.46, sw*0.1, sh*0.03, "Benutzername", self.m_LoginTab) -- 1.75
	self.m_LoginEditPass	= GUIEdit:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.54, sw*0.6*0.75*0.50, sh*0.6*0.05, self.m_LoginTab)
	self.m_LoginTextPass	= GUILabel:new(sw*0.6*0.75*0.67, (sh*0.6-sh*0.6*0.01)*0.54, sw*0.1, sh*0.03, "Passwort", self.m_LoginTab) -- 1.75
	self.m_LoginCheckbox	= GUICheckbox:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.62, sw*0.6*0.025, sw*0.6*0.025, "Passwort merken", self.m_LoginTab)
	self.m_LoginErrorBox = GUIRectangle:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.66, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.075, tocolor(255, 0, 0, 128), self.m_LoginTab)
	self.m_LoginErrorBox:hide()
	self.m_LoginErrorText = GUILabel:new(0, 0, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.061, "Fehler: Irgendwas stimmt nicht!", self.m_LoginErrorBox):setAlign("center", "center")

	self.m_LoginLoginButton	= VRPButton:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.75, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.1, "Einloggen", true, self.m_LoginTab)
	self.m_LoginLogo = GUIImage:new(sw*0.6*0.75*0.05, sh*0.06, sh*0.175, sh*0.084, "files/images/Logo.png", self.m_LoginTab)

	self.m_LoginEditPass:setMasked("*")
	self.m_LoginInfoText = GUILabel:new(sw*0.6*0.75*0.05+sh*0.175, sh*0.025,
		sw*0.6*0.75-sw*0.6*0.75*0.05-1.25*sh*0.175, sh, [[Willkommen auf eXo-Reallife!

	Wenn du bereits registriert bist, kannst du dich hier einloggen. Solltest du noch keinen Account besitzen, so kannst du dich im "Registrieren"-Tab registrieren.
	]], self.m_LoginTab):setFont(VRPFont(sh*0.03))

	self.m_RegisterTab 		= GUIRectangle:new(0, sh*0.6*0.1, sw*0.6*0.75, sh*0.6-sh*0.6*0.01, tocolor(10, 30, 30, 190), self)
	self.m_RegisterTab:setVisible(false)

	self.m_RegisterEditUser	= GUIEdit:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.35, sw*0.6*0.75*0.50, sh*0.6*0.05, self.m_RegisterTab)
	self.m_RegisterTextUser	= GUILabel:new(sw*0.6*0.75*0.67, (sh*0.6-sh*0.6*0.01)*0.35, sw*0.1, sh*0.03, "Benutzername", self.m_RegisterTab) -- 1.75
	self.m_RegisterEditPass	= GUIEdit:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.43, sw*0.6*0.75*0.50, sh*0.6*0.05, self.m_RegisterTab)
	self.m_RegisterTextPass	= GUILabel:new(sw*0.6*0.75*0.67, (sh*0.6-sh*0.6*0.01)*0.43, sw*0.1, sh*0.03, "Passwort", self.m_RegisterTab) -- 1.75
	self.m_RegisterEditPass2 = GUIEdit:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.51, sw*0.6*0.75*0.50, sh*0.6*0.05, self.m_RegisterTab)
	self.m_RegisterTextPass2 = GUILabel:new(sw*0.6*0.75*0.67, (sh*0.6-sh*0.6*0.01)*0.51, sw*0.1, sh*0.03, "Erneut Passwort", self.m_RegisterTab) -- 1.75
	self.m_RegisterEditMail	= GUIEdit:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.59, sw*0.6*0.75*0.50, sh*0.6*0.05, self.m_RegisterTab)
	self.m_RegisterTextMail	= GUILabel:new(sw*0.6*0.75*0.67, (sh*0.6-sh*0.6*0.01)*0.59, sw*0.1, sh*0.03, "E-Mail", self.m_RegisterTab) -- 1.75

	self.m_RegisterErrorBox = GUIRectangle:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.65, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.075, tocolor(255, 0, 0, 128), self.m_RegisterTab)
	self.m_RegisterErrorBox:hide()
	self.m_RegisterErrorText = GUILabel:new(0, 0, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.075, "Fehler: Irgendwas stimmt nicht!", self.m_RegisterErrorBox):setAlign("center", "center")


	self.m_RegisterRegisterButton	= VRPButton:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.75, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.1, "Registrieren", true, self.m_RegisterTab)
	self.m_RegisterLogo = GUIImage:new(sw*0.6*0.75*0.05, sh*0.06, sh*0.175, sh*0.084, "files/images/Logo.png", self.m_RegisterTab)

	self.m_RegisterEditPass:setMasked("*")
	self.m_RegisterEditPass2:setMasked("*")
	self.m_RegisterInfoText = GUILabel:new(sw*0.6*0.75*0.05+sh*0.175, sh*0.04,

	sw*0.6*0.75-sw*0.6*0.75*0.05-1.25*sh*0.175, sh, [[Willkommen auf eXo-Reallife!

	Bitte fülle die folgenden Informationen aus um dich zu registrieren!
	]], self.m_RegisterTab):setFont(VRPFont(sh*0.035))
	--[[
	self.m_GuestTab 		= GUIRectangle:new(0, sh*0.6*0.1, sw*0.6*0.75, sh*0.6-sh*0.6*0.01, tocolor(0, 0, 0, 128), self)
	self.m_GuestTab:setVisible(false)

	self.m_GuestErrorBox = GUIRectangle:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.65, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.075, tocolor(255, 0, 0, 128), self.m_GuestTab)
	self.m_GuestErrorBox:hide()
	self.m_GuestErrorText = GUILabel:new(0, 0, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.075, "Fehler: Irgendwas stimmt nicht!", self.m_GuestErrorBox):setAlign("center", "center")

	self.m_GuestGuestButton	= VRPButton:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.75, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.1, "Als Gast spielen", true, self.m_GuestTab)
	self.m_GuestLogo = GUIImage:new(sw*0.6*0.75*0.05, sh*0.025, sh*0.175, sh*0.175, "files/images/Logo.png", self.m_GuestTab)

	self.m_GuestInfoText = GUILabel:new(sw*0.6*0.75*0.05+sh*0.175, sh*0.04,
	--]]
	self.m_LoginButton:dark(true)
	self.m_RegisterButton:dark(true)
	--self.m_GuestButton:dark(true)

	self.m_LoginButton.onLeftClick = bind(self.showLogin, self)
	self.m_RegisterButton.onLeftClick = bind(self.checkRegister, self)
	--self.m_GuestButton.onLeftClick = bind(self.showGuest, self)

	self.m_LoginLoginButton.onLeftClick = bind(function(self)
		local pw = self.m_LoginEditPass:getText()
		if self.usePasswordHash and self.usePasswordHash == pw then -- User has not changed the password
			triggerServerEvent("accountlogin", root, self.m_LoginEditUser:getText(), "", pw)
		else
			triggerServerEvent("accountlogin", root, self.m_LoginEditUser:getText(), pw)
		end

		-- Disable login button field to avoid several events
		self.m_LoginLoginButton:setEnabled(false)
	end, self)

	self.m_RegisterRegisterButton.onLeftClick = bind(function(self)
		if self.m_RegisterEditPass:getText() == self.m_RegisterEditPass2:getText() then
			triggerServerEvent("accountregister", root, self.m_RegisterEditUser:getText(), self.m_RegisterEditPass:getText(), self.m_RegisterEditMail:getText())
		else triggerEvent("registerfailed",localPlayer,"Passwörter stimmen nicht überein!")
		end
	end, self)


	--self.m_GuestGuestButton.onLeftClick = bind(function(self)
	--	triggerServerEvent("accountguest", root)
	--end, self)

	self:bind("arrow_l",
		function(self)
			if self.m_RegisterTab:isVisible() then
				self:showLogin()
			elseif self.m_LoginTab:isVisible() then
				self:checkRegister()
		--	elseif self.m_GuestTab:isVisible() then
		--		self:showRegister()
			end
		end
	)

	self:bind("arrow_r",
		function(self)
			if self.m_LoginTab:isVisible() then
				self:checkRegister()
			elseif self.m_RegisterTab:isVisible() then
		--		self:showGuest()
				self:showLogin()
			end
		end
	)

	self:bind("enter",
		function(self)
			if self.m_LoginTab:isVisible() then
				if self.m_LoginLoginButton:isEnabled() then
					self.m_LoginLoginButton:onLeftClick()
				end
			elseif self.m_RegisterTab:isVisible() then
				if self.m_RegisterRegisterButton:isVisible() then
					self.m_RegisterRegisterButton:onLeftClick()
				end
			--else
			--	self.m_GuestGuestButton:onLeftClick()
			end
		end
	)

	self:showLogin()
	nextframe(function()
		if DEBUG_AUTOLOGIN then self.m_LoginLoginButton:onLeftClick() end
	end)
	

	-- Show some help
	HelpBar:getSingleton():addText(HelpTextTitles.General.LoginRegister, HelpTexts.General.LoginRegister, false)
end

function LoginGUI:destructor()
	--[[
	local music = DownloadGUI:getSingleton().m_Music
	setTimer(function(music)
		if isElement(music) then
			music:setVolume(music:getVolume()-0.05)
		end
	end, 100, 6, music)

	setTimer(function()
		delete(DownloadGUI:getSingleton())
	end, 2000, 1)
	--]]

	Cursor:hide(true)
	GUIForm.destructor(self)
	LoginGUI.stopCameraDrive()
end

function LoginGUI:showLogin()
	self.m_LoginButton:light()
	self.m_LoginButton:setColor(tocolor(0,0, 0))
	self.m_RegisterButton:dark()
	self.m_RegisterButton:setColor(tocolor(10, 15, 15))
--	self.m_GuestButton:dark()

	self.m_LoginTab:setVisible(true)
--	self.m_GuestTab:setVisible(false)
	self.m_RegisterTab:setVisible(false)
end

function LoginGUI:checkRegister()
	self:showRegister()
	triggerServerEvent("checkRegisterAllowed", localPlayer)
end

function LoginGUI:showRegister()
	self.m_RegisterButton:light()
	self.m_RegisterButton:setColor(tocolor(0,0, 0))
	self.m_LoginButton:dark()
	self.m_LoginButton:setColor(tocolor(10, 15, 15))
	--	self.m_GuestButton:dark()
	self.m_LoginTab:setVisible(false)
	--	self.m_GuestTab:setVisible(false)
	self.m_RegisterTab:setVisible(true)
end

function LoginGUI:showRegisterMultiaccountError(name)
	if self.m_RegisterMultiaccountBox then return end

	self.m_RegisterEditUser:setVisible(false)
	self.m_RegisterTextUser:setVisible(false)
	self.m_RegisterEditMail:setVisible(false)
	self.m_RegisterTextMail:setVisible(false)
	self.m_RegisterEditPass:setVisible(false)
	self.m_RegisterEditPass2:setVisible(false)
	self.m_RegisterTextPass:setVisible(false)
	self.m_RegisterTextPass2:setVisible(false)


	self.m_RegisterRegisterButton:setVisible(false)
	local width, height = screenWidth*0.6*0.75*0.7, (screenHeight*0.6-screenHeight*0.6*0.01)*0.2

	self.m_RegisterInfoText:setText(
	[[Willkommen auf eXo-Reallife!

	Es ist ein Fehler aufgetreten!
	]]
	)

	local text = _("Für deine Serial existiert bereits ein Account.\nJeder Spieler darf nur einen Account besitzen! Bitte melde dich bei einem Team-Mitglied!")
	if name then
		text = _("Deine Serial wurde zuletzt vom Spieler '%s' benutzt! \n Jeder Spieler darf nur einen Account besitzen! Bitte melde dich bei einem Team-Mitglied!", name)
	end

	self.m_RegisterMultiaccountBox = GUIRectangle:new(screenWidth*0.6*0.75*0.15, (screenHeight*0.6-screenHeight*0.6*0.01)*0.5, width, height, tocolor(255, 0, 0, 128), self.m_RegisterTab)
	self.m_RegisterMultiaccountText = GUILabel:new(0, 0, width, height, text, self.m_RegisterMultiaccountBox):setAlign("center", "center"):setMultiline(true):setFont(VRPFont(25))

end

addEvent("receiveRegisterAllowed", true)
addEventHandler("receiveRegisterAllowed", root,
	function(state, name)
		if state == false then
			LoginGUI:getSingleton():showRegisterMultiaccountError(name)
		end
	end
)

function LoginGUI:showGuest()
	self.m_RegisterButton:dark()
	self.m_LoginButton:dark()
--	self.m_GuestButton:light()

	self.m_LoginTab:setVisible(false)
--	self.m_GuestTab:setVisible(true)
	self.m_RegisterTab:setVisible(false)
end

function LoginGUI:fadeIn(quick)
--[[	if quick then
		self.m_LoginButton:setAlpha(255)
	else
		self.m_LoginButton:fadeIn(750)
		self.m_RegisterButton:fadeIn(750)
		self.m_GuestButton:fadeIn(750)

		-- replace 750 with a high number to outline a bug
		Animation.FadeAlpha:new(self.m_LoginTab, 500, 0, 128)
	end
]]
	GUIForm.fadeIn(self, 750)
end

function LoginGUI:fadeOut(quick)
	if quick then
		self.m_LoginButton:setAlpha(0)
	else

	end
end

addEvent("loginfailed", true)
addEventHandler("loginfailed", root,
	function(text)
		LoginGUI:getSingleton().m_LoginErrorBox:show()
		LoginGUI:getSingleton().m_LoginErrorText:setText(text)
		LoginGUI:getSingleton().m_LoginLoginButton:setEnabled(true)
	end
)
addEvent("registerfailed", true)
addEventHandler("registerfailed", root,
	function(text)
		LoginGUI:getSingleton().m_RegisterErrorBox:show()
		LoginGUI:getSingleton().m_RegisterErrorText:setText(text)
	end
)

addEvent("closeLogin", true)
addEventHandler("closeLogin", root,
	function(text)
		delete(LoginGUI:getSingleton())
	end
)


addEvent("loginsuccess", true)
addEventHandler("loginsuccess", root,
	function(pwhash, tutorialstage)
		local lgi = LoginGUI:getSingleton()
		lgi.m_LoginLoginButton:setEnabled(true)

		if lgi.m_LoginCheckbox:isChecked() and pwhash then
			core:set("Login", "username", lgi.m_LoginEditUser:getText())
			core:set("Login", "password", pwhash)
		end
		lgi:delete()

		core:afterLogin(tutorialstage)

		-- Maybe start tutorial
		if tutorialstage == 0 then
			-- Play Intro
			--CutscenePlayer:getSingleton():playCutscene("Intro",
			--	function()
					setElementPosition(localPlayer, 0, 0, 5)

					-- Temp fix?
					triggerServerEvent("introFinished", root)
			--	end
			--)
		elseif tutorialstage == 1 then
			-- Create Character
		elseif tutorialstage == 2 then
			-- Play Tutorial Mission
		else
			-- If the tutorial is done the server will do the job of spawning etc.
			--HUDRadar:getSingleton():show()
			--HUDUI:getSingleton():show()
		end
	end
)


function LoginGUI.startCameraDrive()
	setTime(0,0)
	local rand = math.random(1,2)
	if rand == 1 then
		localPlayer.m_LoginDriveObject = cameraDrive:new(1773.43, -1139.05, 185.85, 1545.51, -1346.14, 180.48, 1621.89, -1516.79, 175.44, 1545.51, -1346.14, 180.48, 200*1000, "Linear" )
	else
		localPlayer.m_LoginDriveObject = cameraDrive:new(1620.98, -1539.92, 53.34, 1477.86, -1757.46, 13.55,1401.78, -1735.55, 49.53,1477.86, -1757.46, 13.55, 200*1000, "Linear" )
		--else -- currently disabled
		--localPlayer.m_LoginDriveObject = cameraDrive:new(414.43, -1841.55, 56.27, 418.78, -1634.52, 56.27,987.92, -1917.45, 56.27,978.85, -1787.63, 56.27, 120*1000, "Linear" )
	end
	localPlayer.m_LoginShader =  LoginShader:new()
end

function LoginGUI.stopCameraDrive()
	if localPlayer.m_LoginDriveObject then
		delete(localPlayer.m_LoginDriveObject)
		showChat(true)
	end
	if localPlayer.m_LoginShader then
		delete(localPlayer.m_LoginShader)
		localPlayer.m_LoginShader = nil
	end
	triggerServerEvent("onClientRequestTime", localPlayer)
end
