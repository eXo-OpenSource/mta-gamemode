LoginGUI = inherit(Singleton)
inherit(DxElement, LoginGUI)

function LoginGUI:constructor()	
	local font = dxCreateFont("files/fonts/gtafont.ttf", 120)
	local sw, sh = guiGetScreenSize()
	local bw, bh = math.floor(sw * 0.08), math.floor(sh * 0.04)
	
	DxElement.constructor(self, 0, 0, sw, sh, false, false)
	self.m_Background = GUIRectangle:new(0, 0, sw, sh, tocolor(2, 17, 39, 255), self)
	self.m_TopBar = GUIRectangle:new(bw, bh, sw-2*bw, sh*0.2, tocolor(0, 0, 0, 170), self)
	local servername = GUILabel:new(30, 40, sw, sh, "V Roleplay", 0.5, self.m_TopBar)
	servername:setFont(font)
	servername:setFontSize(0.25)
	
	self.m_HomeButton = GUIRectangle:new(0, sh*0.2-sh*0.05, (sw-2*bw)/3, sh*0.05, tocolor(255, 255, 255), self.m_TopBar)
	self.m_HomeButton2 = GUIRectangle:new(0, sh*0.2-sh*0.05, (sw-2*bw)/3, 5, tocolor(19, 64, 121), self.m_TopBar)
	self.m_HomeButton.onLeftClick = bind(LoginGUI.showHome, self)
	
	self.m_HomeButtonText =  GUILabel:new(0, 0, (sw-2*bw)/3, sh*0.05, "Home", 0.2, self.m_HomeButton)
	self.m_HomeButtonText:setFont(font)
	self.m_HomeButtonText:setColor(tocolor(0, 0, 0, 255))
	self.m_HomeButtonText:setAlignX("center")
	self.m_HomeButtonText:setAlignY("center")

	self.m_LoginButton = GUIRectangle:new((sw-2*bw)/3, sh*0.2-sh*0.05, (sw-2*bw)/3, sh*0.05, tocolor(255, 255, 255), self.m_TopBar)
	self.m_LoginButton2 = GUIRectangle:new((sw-2*bw)/3,  sh*0.2-sh*0.05, (sw-2*bw)/3, 4, tocolor(19, 64, 121), self.m_TopBar)
	self.m_LoginButton.onLeftClick = bind(LoginGUI.showLogin, self)
	
	self.m_LoginButtonText = GUILabel:new(0, 0, (sw-2*bw)/3, sh*0.05, "Login", 0.2, self.m_LoginButton)
	self.m_LoginButtonText:setFont(font)
	self.m_LoginButtonText:setColor(tocolor(0, 0, 0, 255))
	self.m_LoginButtonText:setAlignY("center")
	self.m_LoginButtonText:setAlignX("center")
	
	self.m_RegisterButton = GUIRectangle:new((sw-2*bw)/3*2, sh*0.2-sh*0.05, (sw-2*bw)/3, sh*0.05, tocolor(255, 255, 255), self.m_TopBar)
	self.m_RegisterButton2 = GUIRectangle:new((sw-2*bw)/3*2, sh*0.2-sh*0.05, (sw-2*bw)/3, 4, tocolor(19, 64, 121), self.m_TopBar)
	self.m_RegisterButton.onLeftClick = bind(LoginGUI.showRegister, self)
	
	self.m_RegisterButtonText = GUILabel:new(0, 0, (sw-2*bw)/3, sh*0.05, "Registrieren", 0.2, self.m_RegisterButton)
	self.m_RegisterButtonText:setFont(font)
	self.m_RegisterButtonText:setColor(tocolor(0, 0, 0, 255))
	self.m_RegisterButtonText:setAlignX("center")
	self.m_RegisterButtonText:setAlignY("center")
		
	local tabw = (sw-2*bw)/3*2
	local tabh = sh-2*bh-sh*0.2-20
	
	self.m_SideBar 		= GUIRectangle:new(sw-bw-(sw-2*bw)/3, bh+sh*0.2+10, tabw/2, tabh, tocolor(0, 0, 0, 100), self)
	self.m_LoginTab 	= GUIRectangle:new(bw, bh+sh*0.2+10, tabw, tabh, tocolor(0, 0, 0, 170), self)
	self.m_HomeTab 		= GUIRectangle:new(bw, bh+sh*0.2+10, tabw, tabh, tocolor(0, 0, 0, 170), self)
	self.m_RegisterTab 	= GUIRectangle:new(bw, bh+sh*0.2+10, tabw, tabh, tocolor(0, 0, 0, 170), self)
	
	-- Login Tab
	GUIRectangle:new(0, 35, tabw, 5, tocolor(255, 255, 255, 255), self.m_LoginTab)
	local lbl = GUILabel:new(0, 10, tabw, tabh, "Falls du schon einen Account besitzt,  kannst du dich hier mit deinen Accountdaten einloggen.", 1, self.m_LoginTab)
	lbl:setAlignX("center")
	
	GUILabel:new(tabw/6, 120, tabw/3, 35, "Username:", 1, self.m_LoginTab):setAlignY("center")
	GUILabel:new(tabw/6, 170, tabw/3, 35, "Passwort:", 1, self.m_LoginTab):setAlignY("center")
	self.m_LoginEditUsername = GUIEdit:new(tabw/6*2, 120, tabw/2, 35, self.m_LoginTab)
	self.m_LoginEditPassword = GUIEdit:new(tabw/6*2, 170, tabw/2, 35, self.m_LoginTab)
	
	self.m_SubmitLoginButton = GUIRectangle:new(tabw/4, tabh-80, tabw/2, 70, tocolor(0, 32, 63,	255), self.m_LoginTab)
	local btnlbl = GUILabel:new(tabw/4, tabh-80, tabw/2, 70, "Einloggen", 1, self.m_LoginTab)
	btnlbl:setAlignX("center")
	btnlbl:setAlignY("center")

	GUILabel:new(tabw/6, 220, tabw/3, 20, "Remember Login:", 1, self.m_LoginTab):setAlignY("center")
	self.m_SaveLoginCheckbox = GUICheckbox:new(tabw/6*2, 220, 20, 20, "", self.m_LoginTab)
	
	self.m_LoginErrorBox = GUIRectangle:new(tabw/6, 300, tabw/1.5, 70, tocolor(173, 14, 22, 255), self.m_LoginTab)
	local btnlbl = GUILabel:new(0, 0, tabw/1.5, 70, "Fehler: Ungültiger Nutzername / Passwort!", 1, self.m_LoginErrorBox)
	btnlbl:setAlignX("center")
	btnlbl:setAlignY("center")
	
	self.m_SubmitLoginButton.onLeftClick = bind(function(self)
		triggerServerEvent("accountlogin", root, self.m_LoginEditUsername:getText(), self.m_LoginEditPassword:getText())
	end, self)

	-- Register Tab
	GUIRectangle:new(0, 35, tabw, 5, tocolor(255, 255, 255, 255), self.m_RegisterTab)
	local lbl = GUILabel:new(0, 10, tabw, tabh, "Du kannst dir hier einen Account registreieren.", 1, self.m_RegisterTab)
	lbl:setAlignX("center")
	
	GUILabel:new(tabw/6, 120, tabw/3, 35, "Username:", 1, self.m_RegisterTab):setAlignY("center")
	GUILabel:new(tabw/6, 170, tabw/3, 35, "Passwort:", 1, self.m_RegisterTab):setAlignY("center")
	self.m_RegisterEditUsername = GUIEdit:new(tabw/6*2, 120, tabw/2, 35, self.m_RegisterTab)
	self.m_RegisterEditPassword = GUIEdit:new(tabw/6*2, 170, tabw/2, 35, self.m_RegisterTab)
	
	self.m_SubmitRegisterButton = GUIRectangle:new(tabw/4, tabh-80, tabw/2, 70, tocolor(0, 32, 63,	255), self.m_RegisterTab)
	local btnlbl = GUILabel:new(tabw/4, tabh-80, tabw/2, 70, "Registrieren", 1, self.m_RegisterTab)
	btnlbl:setAlignX("center")
	btnlbl:setAlignY("center")
	
	self.m_SubmitRegisterButton.onLeftClick = bind(function(self)
		triggerServerEvent("accountregister", root, self.m_RegisterEditUsername:getText(), self.m_RegisterEditPassword:getText())
	end, self)
end

function LoginGUI:showHome()
	self.m_RegisterButton.m_Color = tocolor(0, 0, 0, 0)
	self.m_LoginButton.m_Color = tocolor(0, 0, 0, 0)
	self.m_HomeButton.m_Color =	tocolor(255, 255, 255, 255)
	self.m_RegisterButtonText.m_Color = tocolor(255, 255, 255, 255)
	self.m_LoginButtonText.m_Color = tocolor(255, 255, 255, 255)
	self.m_HomeButtonText.m_Color = tocolor(0, 0, 0, 255)
	
	self.m_RegisterButton2:hide()
	self.m_LoginButton2:hide()
	self.m_HomeButton2:show()
	
	self.m_LoginTab:hide()
	self.m_RegisterTab:hide()
	self.m_HomeTab:show()
	self:anyChange()
end

function LoginGUI:showLogin()
	self.m_LoginButton.m_Color = tocolor(255, 255, 255, 255)
	self.m_RegisterButton.m_Color = tocolor(0, 0, 0, 0)
	self.m_HomeButton.m_Color = tocolor(0, 0, 0, 0)
	self.m_RegisterButtonText.m_Color = tocolor(255, 255, 255, 255)
	self.m_LoginButtonText.m_Color = tocolor(0, 0, 0, 255)
	self.m_HomeButtonText.m_Color = tocolor(255, 255, 255, 255)
	
	self.m_RegisterButton2:hide()
	self.m_LoginButton2:show()
	self.m_HomeButton2:hide()
	
	self.m_LoginTab:show()
	self.m_RegisterTab:hide()
	self.m_HomeTab:hide()
	self:anyChange()
end

function LoginGUI:showRegister()
	self.m_RegisterButton.m_Color = tocolor(255, 255, 255, 255)
	self.m_LoginButton.m_Color = tocolor(0, 0, 0, 0)
	self.m_HomeButton.m_Color = tocolor(0, 0, 0, 0)
	self.m_RegisterButtonText.m_Color = tocolor(0, 0, 0, 255)
	self.m_LoginButtonText.m_Color = tocolor(255, 255, 255, 255)
	self.m_HomeButtonText.m_Color = tocolor(255, 255, 255, 255)
	
	self.m_RegisterButton2:show()
	self.m_LoginButton2:hide()
	self.m_HomeButton2:hide()
	
	self.m_LoginTab:hide()
	self.m_RegisterTab:show()
	self.m_HomeTab:hide()
	self:anyChange()
end



lgi = LoginGUI:new()
lgi:showHome()