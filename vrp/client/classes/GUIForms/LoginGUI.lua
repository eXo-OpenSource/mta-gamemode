LoginGUI = inherit(GUIForm)
inherit(Singleton, LoginGUI)

function LoginGUI:constructor()	
	local sw, sh = guiGetScreenSize()
	self.usePasswordHash = false

	GUIForm.constructor(self, sw*0.2, sh*0.2, sw*0.6, sh*0.6)
	self.m_LoginButton 		= VRPButton:new(0, 0, sw*0.6/3, sh*0.6*0.1, "Login", false, self)
	self.m_RegisterButton 	= VRPButton:new(sw*0.6/3, 0, sw*0.6/3, sh*0.6*0.1, "Registrieren", false, self)
	self.m_GuestButton 		= VRPButton:new(sw*0.6/3*2, 0, sw*0.6/3, sh*0.6*0.1, "Als Gast spielen", false, self)
	
	self.m_NewsTab 			= GUIRectangle:new(sw*0.6*0.75, sh*0.6*0.1, sw*0.6*0.25, sh*0.6-sh*0.6*0.01, tocolor(0, 0, 0, 128), self)
	self.m_NewsTabBar		= GUIRectangle:new(sw*0.6*0.75, sh*0.6*0.1, sw*0.6*0.010, sh*0.6-sh*0.6*0.01, tocolor(230, 230, 230, 200), self)
	
	self.m_LoginTab 		= GUIRectangle:new(0, sh*0.6*0.1, sw*0.6*0.75, sh*0.6-sh*0.6*0.01, tocolor(0, 0, 0, 128), self)
	self.m_LoginEditUser	= GUIEdit:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.41, sw*0.6*0.75*0.30, sh*0.6*0.05, self.m_LoginTab)
	self.m_LoginTextUser	= GUILabel:new(sw*0.6*0.75*0.47, (sh*0.6-sh*0.6*0.01)*0.41, sw*0.1, sh*0.03, "Benutzername", self.m_LoginTab) -- 1.75
	self.m_LoginEditPass	= GUIEdit:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.49, sw*0.6*0.75*0.30, sh*0.6*0.05, self.m_LoginTab)
	self.m_LoginTextPass	= GUILabel:new(sw*0.6*0.75*0.47, (sh*0.6-sh*0.6*0.01)*0.49, sw*0.1, sh*0.03, "Passwort", self.m_LoginTab) -- 1.75
	self.m_LoginCheckbox	= GUICheckbox:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.575, sw*0.6*0.025, sw*0.6*0.025, "Passwort merken", self.m_LoginTab)
	self.m_LoginErrorBox = GUIRectangle:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.65, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.075, tocolor(255, 0, 0, 128), self.m_LoginTab)
	self.m_LoginErrorBox:hide()
	self.m_LoginErrorText = GUILabel:new(0, 0, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.075, "Fehler: Irgendwas stimmt nicht!", self.m_LoginErrorBox):setAlign("center", "center")
	
	self.m_LoginLoginButton	= VRPButton:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.75, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.1, "Einloggen", true, self.m_LoginTab)
	self.m_LoginLogo = GUIImage:new(sw*0.6*0.75*0.05, sh*0.025, sh*0.175, sh*0.175, "files/images/Logo.png", self.m_LoginTab)
	
	self.m_LoginEditPass:setMasked("*")
	self.m_LoginInfoText = GUILabel:new(sw*0.6*0.75*0.05+sh*0.175, sh*0.04, 
	
	sw*0.6*0.75-sw*0.6*0.75*0.05-1.25*sh*0.175, sh, [[Willkommen auf V-Roleplay!
	
	Wenn du bereits registriert bist, kannst du dich hier einloggen. Solltest du noch keinen Account besitzen so kannst du dich im "Registrieren"-Tab registrieren. Du kannst den Server auch ersteinmal als Gast ausprobieren!	
	]], self.m_LoginTab):setFont(VRPFont(sh*0.035))
	
	self.m_RegisterTab 		= GUIRectangle:new(0, sh*0.6*0.1, sw*0.6*0.75, sh*0.6-sh*0.6*0.01, tocolor(0, 0, 0, 128), self)
	self.m_RegisterTab:setVisible(false)
	
	self.m_RegisterEditUser	= GUIEdit:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.41, sw*0.6*0.75*0.30, sh*0.6*0.05, self.m_RegisterTab)
	self.m_RegisterTextUser	= GUILabel:new(sw*0.6*0.75*0.47, (sh*0.6-sh*0.6*0.01)*0.41, sw*0.1, sh*0.03, "Benutzername", self.m_RegisterTab) -- 1.75
	self.m_RegisterEditPass	= GUIEdit:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.49, sw*0.6*0.75*0.30, sh*0.6*0.05, self.m_RegisterTab)
	self.m_RegisterTextPass	= GUILabel:new(sw*0.6*0.75*0.47, (sh*0.6-sh*0.6*0.01)*0.49, sw*0.1, sh*0.03, "Passwort", self.m_RegisterTab) -- 1.75

	self.m_RegisterEditMail	= GUIEdit:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.57, sw*0.6*0.75*0.30, sh*0.6*0.05, self.m_RegisterTab)
	self.m_RegisterTextMail	= GUILabel:new(sw*0.6*0.75*0.47, (sh*0.6-sh*0.6*0.01)*0.57, sw*0.1, sh*0.03, "E-Mail", self.m_RegisterTab) -- 1.75

	self.m_RegisterErrorBox = GUIRectangle:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.65, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.075, tocolor(255, 0, 0, 128), self.m_RegisterTab)
	self.m_RegisterErrorBox:hide()
	self.m_RegisterErrorText = GUILabel:new(0, 0, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.075, "Fehler: Irgendwas stimmt nicht!", self.m_RegisterErrorBox):setAlign("center", "center")
	
	
	self.m_RegisterRegisterButton	= VRPButton:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.75, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.1, "Registrieren", true, self.m_RegisterTab)
	self.m_RegisterLogo = GUIImage:new(sw*0.6*0.75*0.05, sh*0.025, sh*0.175, sh*0.175, "files/images/Logo.png", self.m_RegisterTab)
	
	self.m_RegisterEditPass:setMasked("*")
	self.m_RegisterInfoText = GUILabel:new(sw*0.6*0.75*0.05+sh*0.175, sh*0.04, 
	
	sw*0.6*0.75-sw*0.6*0.75*0.05-1.25*sh*0.175, sh, [[Willkommen auf V-Roleplay!
	
	Bitte fülle die folgenden Informationen aus um dich zu registrieren!	
	]], self.m_RegisterTab):setFont(VRPFont(sh*0.035))
	
	self.m_GuestTab 		= GUIRectangle:new(0, sh*0.6*0.1, sw*0.6*0.75, sh*0.6-sh*0.6*0.01, tocolor(0, 0, 0, 128), self)
	self.m_GuestTab:setVisible(false)
	
	self.m_GuestErrorBox = GUIRectangle:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.65, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.075, tocolor(255, 0, 0, 128), self.m_GuestTab)
	self.m_GuestErrorBox:hide()
	self.m_GuestErrorText = GUILabel:new(0, 0, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.075, "Fehler: Irgendwas stimmt nicht!", self.m_GuestErrorBox):setAlign("center", "center")
	
	self.m_GuestGuestButton	= VRPButton:new(sw*0.6*0.75*0.15, (sh*0.6-sh*0.6*0.01)*0.75, sw*0.6*0.75*0.7, (sh*0.6-sh*0.6*0.01)*0.1, "Als Gast spielen", true, self.m_GuestTab)
	self.m_GuestLogo = GUIImage:new(sw*0.6*0.75*0.05, sh*0.025, sh*0.175, sh*0.175, "files/images/Logo.png", self.m_GuestTab)
	
	self.m_GuestInfoText = GUILabel:new(sw*0.6*0.75*0.05+sh*0.175, sh*0.04, 
	
	sw*0.6*0.75-sw*0.6*0.75*0.05-1.25*sh*0.175, sh, [[Willkommen auf V-Roleplay!
	
	Bevor du dich registrierst, kannst du den Server natürlich auch ersteinmal als Gast unverbindlich testen. Du kannst dich während du testest jederzeit registrieren, ohne deinen bisherigen Fortschritt zu verlieren!	
	]], self.m_GuestTab):setFont(VRPFont(sh*0.035))

	self.m_LoginButton:dark(true)
	self.m_RegisterButton:dark(true)
	self.m_GuestButton:dark(true)
	
	self.m_LoginButton.onLeftClick = bind(self.showLogin, self)
	self.m_RegisterButton.onLeftClick = bind(self.showRegister, self)
	self.m_GuestButton.onLeftClick = bind(self.showGuest, self)

	self.m_LoginLoginButton.onLeftClick = bind(function(self)
		local pw = self.m_LoginEditPass:getText()
		if self.usePasswordHash and self.usePasswordHash == pw then -- User has not changed the password
			triggerServerEvent("accountlogin", root, self.m_LoginEditUser:getText(), "", pw)
		else
			triggerServerEvent("accountlogin", root, self.m_LoginEditUser:getText(), pw)
		end
	end, self)	
	
	self.m_RegisterRegisterButton.onLeftClick = bind(function(self)
		triggerServerEvent("accountregister", root, self.m_RegisterEditUser:getText(), self.m_RegisterEditPass:getText(), self.m_RegisterEditMail:getText())
	end, self)	
	
	
	self.m_GuestGuestButton.onLeftClick = bind(function(self)
		triggerServerEvent("accountguest", root)
	end, self)
	
	self:bind("arrow_l", 
		function(self)
			if self.m_RegisterTab:isVisible() then
				self:showLogin()
			elseif self.m_GuestTab:isVisible() then
				self:showRegister()
			end
		end
	)	
	
	self:bind("arrow_r", 
		function(self)
			if self.m_LoginTab:isVisible() then
				self:showRegister()
			elseif self.m_RegisterTab:isVisible() then
				self:showGuest()
			end
		end
	)	
	
	self:bind("enter", 
		function(self)
			if self.m_LoginTab:isVisible() then
				self.m_LoginLoginButton:onLeftClick()
			elseif self.m_RegisterTab:isVisible() then
				self.m_RegisterRegisterButton:onLeftClick()
			else
				self.m_GuestGuestButton:onLeftClick()
			end
		end
	)
	
	self:showLogin()
end

function LoginGUI:showLogin()
	self.m_LoginButton:light()
	self.m_RegisterButton:dark()
	self.m_GuestButton:dark()
	
	self.m_LoginTab:setVisible(true)
	self.m_GuestTab:setVisible(false)
	self.m_RegisterTab:setVisible(false)
end

function LoginGUI:showRegister()
	self.m_RegisterButton:light()
	self.m_LoginButton:dark()
	self.m_GuestButton:dark()
	
	self.m_LoginTab:setVisible(false)
	self.m_GuestTab:setVisible(false)
	self.m_RegisterTab:setVisible(true)
end

function LoginGUI:showGuest()
	self.m_RegisterButton:dark()
	self.m_LoginButton:dark()
	self.m_GuestButton:light()
	
	self.m_LoginTab:setVisible(false)
	self.m_GuestTab:setVisible(true)
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
	end
)
addEvent("registerfailed", true)
addEventHandler("registerfailed", root, 
	function(text)
		LoginGUI:getSingleton().m_RegisterErrorBox:show()
		LoginGUI:getSingleton().m_RegisterErrorText:setText(text)
	end
)


addEvent("loginsuccess", true)
addEventHandler("loginsuccess", root, 
	function(pwhash, tutorialstage)
		local lgi = LoginGUI:getSingleton()
	
		if lgi.m_LoginCheckbox:isChecked() and pwhash then
			core:set("login", "username", lgi.m_LoginEditUser:getText())
			core:set("login", "password", pwhash)
		end
		lgi:delete()
		
		-- Maybe start tutorial
		if tutorialstage == 0 then
			-- Play Intro
			CutscenePlayer:getSingleton():playCutscene("Intro",
				function()
					setElementPosition(localPlayer, 0, 0, 5)
					
					-- Temp fix?
					triggerServerEvent("introFinished", root)
					HUDRadar:getSingleton():show()
				end
			)
		elseif tutorialstage == 1 then
			-- Create Character
		elseif tutorialstage == 2 then
			-- Play Tutorial Mission
		else
			-- If the tutorial is done the server will do the job of spawning etc.
			HUDRadar:getSingleton():show()
		end

		
	end
)
