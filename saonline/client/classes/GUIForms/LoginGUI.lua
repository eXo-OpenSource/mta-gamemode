LoginGUI = inherit(Singleton)
inherit(DxElement, LoginGUI)

function LoginGUI:constructor()	
	local font = dxCreateFont("files/fonts/gtafont.ttf", 120)
	local sw, sh = guiGetScreenSize()
	DxElement.constructor(self, 0, 0, sw, sh, false, false)
	self.m_Background = GUIRectangle:new(0, 0, sw, sh, tocolor(2, 17, 39, 255), self)
	self.m_TopBar = GUIRectangle:new(150, 50, sw-300, 250, tocolor(0, 0, 0, 170), self)
	local servername = GUILabel:new(30, 40, sw, sh, "GTA:SA Online", 1, self.m_TopBar)
	servername:setFont(font)
	servername:setFontSize(0.4)
	
	self.m_HomeButton = GUIRectangle:new(0, 200, (sw-300)/3, 50, tocolor(255, 255, 255), self.m_TopBar)
	self.m_HomeButton2 = GUIRectangle:new(0, 200, (sw-300)/3, 4, tocolor(19, 64, 121), self.m_TopBar)
	self.m_HomeButton.onLeftClick = bind(LoginGUI.showHome, self)
	
	self.m_HomeButtonText = GUILabel:new(0, 0, (sw-300)/3, 50, "Home", 0.2, self.m_HomeButton)
	self.m_HomeButtonText:setFont(font)
	self.m_HomeButtonText:setColor(tocolor(0, 0, 0, 255))
	self.m_HomeButtonText:setAlignX("center")
	self.m_HomeButtonText:setAlignY("center")

	self.m_LoginButton = GUIRectangle:new((sw-300)/3, 200, (sw-300)/3, 50, tocolor(255, 255, 255), self.m_TopBar)
	self.m_LoginButton2 = GUIRectangle:new((sw-300)/3, 200, (sw-300)/3, 4, tocolor(19, 64, 121), self.m_TopBar)
	self.m_LoginButton.onLeftClick = bind(LoginGUI.showLogin, self)
	
	self.m_LoginButtonText = GUILabel:new((sw-300)/3, 200, (sw-300)/3, 50, "Login", 0.2, self.m_TopBar)
	self.m_LoginButtonText:setFont(font)
	self.m_LoginButtonText:setColor(tocolor(0, 0, 0, 255))
	self.m_LoginButtonText:setAlignY("center")
	self.m_LoginButtonText:setAlignX("center")
	
	self.m_RegisterButton = GUIRectangle:new((sw-300)/3*2, 200, (sw-300)/3, 50, tocolor(255, 255, 255), self.m_TopBar)
	self.m_RegisterButton2 = GUIRectangle:new((sw-300)/3*2, 200, (sw-300)/3, 4, tocolor(19, 64, 121), self.m_TopBar)
	self.m_RegisterButton.onLeftClick = bind(LoginGUI.showRegister, self)
	
	self.m_RegisterButtonText = GUILabel:new((sw-300)/3*2, 200, (sw-300)/3, 50, "Register", 0.2, self.m_TopBar)
	self.m_RegisterButtonText:setFont(font)
	self.m_RegisterButtonText:setColor(tocolor(0, 0, 0, 255))
	self.m_RegisterButtonText:setAlignX("center")
	self.m_RegisterButtonText:setAlignY("center")
	
	self.m_SideBar 		= GUIRectangle:new(sw-150-(sw-300)/3, 310, (sw-300)/3, sh-360, tocolor(0, 0, 0, 100), self)
	self.m_LoginTab 	= GUIRectangle:new(150, 310, (sw-300)/3*2, sh-360, tocolor(0, 0, 0, 170), self)
	self.m_HomeTab 		= GUIRectangle:new(150, 310, (sw-300)/3*2, sh-360, tocolor(0, 0, 0, 170), self)
	self.m_RegisterTab 	= GUIRectangle:new(150, 310, (sw-300)/3*2, sh-360, tocolor(0, 0, 0, 170), self)
	
	local tabw = (sw-300)/3*2
	local tabh = sh-360
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
	
	self.m_SubmitLoginButton.onLeftClick = bind(function(self)
		triggerServerEvent("accountlogin", root, self.m_RegisterEditUsername:getText(), self.m_RegisterEditPassword:getText())
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
addCommandHandler("remk", function() lgi:hide() lgi:show() end)