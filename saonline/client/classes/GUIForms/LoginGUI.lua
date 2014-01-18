LoginGUI = inherit(Singleton)
inherit(GUIForm, LoginGUI)

function LoginGUI:constructor()	
	local sw, sh = guiGetScreenSize()
	local bw, bh = math.floor(sw * 0.08), math.floor(sh * 0.04)
	self.usePasswordHash = false
	
	GUIForm.constructor(self, 0, 0, sw, sh)
	self.m_Background = GUIRectangle:new(0, 0, sw, sh, tocolor(2, 17, 39, 255), self)
	self.m_TopBar = GUIRectangle:new(bw, bh, sw-2*bw, sh*0.2, tocolor(0, 0, 0, 170), self)
	GUILabel:new(30, 40, sw, sh, "V Roleplay", 1, self.m_TopBar)
		:setFont(VRPFont(sh*0.05))
		
	self.m_HomeButton = VRPButton:new(0, sh*0.2-sh*0.05, (sw-2*bw)/3, sh*0.05, "Home", self.m_TopBar)
	self.m_HomeButton.onLeftClick = bind(LoginGUI.showHome, self)
	
	self.m_LoginButton = VRPButton:new((sw-2*bw)/3, sh*0.2-sh*0.05, (sw-2*bw)/3, sh*0.05, "Login", self.m_TopBar)
	self.m_LoginButton.onLeftClick = bind(LoginGUI.showLogin, self)
	
	self.m_RegisterButton = VRPButton:new((sw-2*bw)/3*2, sh*0.2-sh*0.05, (sw-2*bw)/3, sh*0.05, "Register", self.m_TopBar)
	self.m_RegisterButton.onLeftClick = bind(LoginGUI.showRegister, self)
	
	local tabw = (sw-2*bw)/3*2
	local tabh = sh-2*bh-sh*0.2-20
	
	self.m_SideBar 		= GUIRectangle:new(sw-bw-(sw-2*bw)/3, bh+sh*0.2+10, tabw/2, tabh, tocolor(0, 0, 0, 100), self)
	self.m_LoginTab 	= GUIRectangle:new(bw, bh+sh*0.2+10, tabw, tabh, tocolor(0, 0, 0, 170), self)
	self.m_HomeTab 		= GUIRectangle:new(bw, bh+sh*0.2+10, tabw, tabh, tocolor(0, 0, 0, 170), self)
	self.m_RegisterTab 	= GUIRectangle:new(bw, bh+sh*0.2+10, tabw, tabh, tocolor(0, 0, 0, 170), self)
	
	-- Side Bar
	GUILabel:new(0, 20, tabw/2, tabh, "News", 2.5, self.m_SideBar):setAlignX("center")
	
	-- Home Tab
	GUILabel:new(35, 35, tabw, tabh, "Willkommen auf V Roleplay!", 2.5, self.m_HomeTab)
	GUILabel:new(35, 80, tabw, tabh, [[
		   Hier sollte irgendwann mal ein toller Text stehen.
		   - Infos wie Homepageadresse, TS3 und Ingamesupportmöglichkeit
		   - Rechts News
		   - Irgendwer muss sich mal was ausdenken :D
		]], 1, self.m_HomeTab)
	
	-- Login Tab
	GUIRectangle:new(0, 35, tabw, 5, tocolor(255, 255, 255, 255), self.m_LoginTab)
	local lbl = GUILabel:new(0, 10, tabw, tabh, "Falls du schon einen Account besitzt,  kannst du dich hier mit deinen Accountdaten einloggen.", 1, self.m_LoginTab)
	lbl:setAlignX("center")
	
	GUILabel:new(tabw/6, 120, tabw/3, 35, "Username:", 1, self.m_LoginTab):setAlignY("center")
	GUILabel:new(tabw/6, 170, tabw/3, 35, "Passwort:", 1, self.m_LoginTab):setAlignY("center")
	self.m_LoginEditUsername = GUIEdit:new(tabw/6*2, 120, tabw/2, 35, self.m_LoginTab)
	self.m_LoginEditPassword = GUIEdit:new(tabw/6*2, 170, tabw/2, 35, self.m_LoginTab)
	self.m_LoginEditPassword:setMasked()
	
	self.m_SubmitLoginButton = GUIRectangle:new(tabw/4, tabh-80, tabw/2, 70, tocolor(0, 32, 63,	255), self.m_LoginTab)
	local btnlbl = GUILabel:new(tabw/4, tabh-80, tabw/2, 70, "Einloggen", 1, self.m_LoginTab)
	btnlbl:setAlignX("center")
	btnlbl:setAlignY("center")

	GUILabel:new(tabw/6, 220, tabw/3, 20, "Remember Login:", 1, self.m_LoginTab):setAlignY("center")
	self.m_SaveLoginCheckbox = GUICheckbox:new(tabw/6*2, 220, 20, 20, "", self.m_LoginTab)
	
	self.m_LoginErrorBox = GUIRectangle:new(tabw/6, 300, tabw/1.5, 70, tocolor(173, 14, 22, 255), self.m_LoginTab)
	self.m_LoginErrorText = GUILabel:new(0, 0, tabw/1.5, 70, "", 1, self.m_LoginErrorBox)
	self.m_LoginErrorText:setAlignX("center"):setAlignY("center")
	self.m_LoginErrorBox:hide()
	
	self.m_SubmitLoginButton.onLeftClick = bind(function(self)
		local pw = self.m_LoginEditPassword:getText()
		if self.usePasswordHash and self.usePasswordHash == pw then -- User has not changed the password
			triggerServerEvent("accountlogin", root, self.m_LoginEditUsername:getText(), "", pw)
		else
			triggerServerEvent("accountlogin", root, self.m_LoginEditUsername:getText(), pw)
		end
	end, self)

	-- Register Tab
	GUIRectangle:new(0, 35, tabw, 5, tocolor(255, 255, 255, 255), self.m_RegisterTab)
	GUILabel:new(0, 10, tabw, tabh, "Du kannst dir hier einen Account registrieren.", 1, self.m_RegisterTab)
		:setAlignX("center")
	
	GUILabel:new(tabw/6, 120, tabw/3, 35, "Username:", 1, self.m_RegisterTab)
		:setAlignY("center")
	GUILabel:new(tabw/6, 170, tabw/3, 35, "Passwort:", 1, self.m_RegisterTab)
		:setAlignY("center")
	
	self.m_RegisterEditUsername = GUIEdit:new(tabw/6*2, 120, tabw/2, 35, self.m_RegisterTab)
	self.m_RegisterEditPassword = GUIEdit:new(tabw/6*2, 170, tabw/2, 35, self.m_RegisterTab)
	self.m_RegisterEditPassword:setMasked()
	
	self.m_RegisterErrorBox = GUIRectangle:new(tabw/6, 300, tabw/1.5, 70, tocolor(173, 14, 22, 255), self.m_RegisterTab)
	self.m_RegisterErrorBox:hide()
	self.m_RegisterErrorText = GUILabel:new(0, 0, tabw/1.5, 70, "", 1, self.m_RegisterErrorBox)
		:setAlign("center", "center")
	
	self.m_SubmitRegisterButton = GUIRectangle:new(tabw/4, tabh-80, tabw/2, 70, tocolor(0, 32, 63,	255), self.m_RegisterTab)
	GUILabel:new(tabw/4, tabh-80, tabw/2, 70, "Registrieren", 1, self.m_RegisterTab)
		:setAlign("center", "center")
	
	self.m_SubmitRegisterButton.onLeftClick = bind(function(self)
		triggerServerEvent("accountregister", root, self.m_RegisterEditUsername:getText(), self.m_RegisterEditPassword:getText())
	end, self)
	
	
	self:bind("arrow_l", 
		function(self)
			if self.m_LoginTab:isVisible() then
				self:showHome()
			elseif self.m_RegisterTab:isVisible() then
				self:showLogin()
			end
		end
	)	
	
	self:bind("arrow_r", 
		function(self)
			if self.m_HomeTab:isVisible() then
				self:showLogin()
			elseif self.m_LoginTab:isVisible() then
				self:showRegister()
			end
		end
	)
end

function LoginGUI:showHome(quick)
	self.m_RegisterButton:dark(quick)
	self.m_LoginButton:dark(quick)
	self.m_HomeButton:light(quick)
	
	self.m_LoginTab:hide()
	self.m_RegisterTab:hide()
	self.m_HomeTab:show()
	self:anyChange()
end

function LoginGUI:showLogin()
	self.m_LoginButton:light()
	self.m_RegisterButton:dark()
	self.m_HomeButton:dark()
		
	self.m_LoginTab:show()
	self.m_RegisterTab:hide()
	self.m_HomeTab:hide()
	self:anyChange()
	
	self:bind("enter",
		function(self)
			self.m_SubmitLoginButton.onLeftClick(self)
		end
	)
end

function LoginGUI:showRegister()
	self.m_RegisterButton:light()
	self.m_LoginButton:dark()
	self.m_HomeButton:dark()
	
	self.m_LoginTab:hide()
	self.m_RegisterTab:show()
	self.m_HomeTab:hide()
	
	self:bind("enter",
		function(self)
			self.m_SubmitRegisterButton.onLeftClick(self)
		end
	)
	
	self:anyChange()
end

addEvent("ingamenews", true)
addEventHandler("ingamenews", root,	
	function(news)
		local newsyoff = 65
		local sw, sh = guiGetScreenSize()
		local bw, bh = math.floor(sw * 0.08), math.floor(sh * 0.04)
		local tabw = (sw-2*bw)/3*2
		local tabh = sh-2*bh-sh*0.2-20
		local self = LoginGUI:getSingleton()
		for k, v in ipairs(news) do
			GUILabel:new(0, newsyoff, tabw/2, tabh, v.title, 1.75, self.m_SideBar):setAlignX("center")
			GUILabel:new(tabw/2-80, newsyoff+2, tabw/2, tabh, v.date, 1, self.m_SideBar)
			GUILabel:new(15, newsyoff+30, tabw/2-30, tabh, v.text, 1, self.m_SideBar)
			
			local lines = math.ceil(dxGetTextWidth(v.text) / (tabw/2-30)) + 1
			
			newsyoff = newsyoff+ 30 + dxGetFontHeight ( 1, "default") *1.75 * lines * 1.2
		end
	
	end
)


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
	
		if lgi.m_SaveLoginCheckbox:isChecked() and pwhash then
			if fileExists("logininfo.vrp") then
				fileDelete("logininfo.vrp")
			end
			local fh = fileCreate("logininfo.vrp")
			fileWrite(fh, pwhash)
			fileWrite(fh, lgi.m_LoginEditUsername:getText())
			fileClose(fh)
		end
		lgi:delete()
		
		outputDebug(tutorialstage)
		-- Maybe start tutorial
		if tutorialstage == 0 then
			-- Play Intro
			CutscenePlayer:getSingleton():playCutscene("Intro",
				function()
					setCameraTarget(localPlayer)
					setElementPosition(localPlayer, 0, 0, 5)
					setElementFrozen(localPlayer, false)
					
					-- Temp fix?
					triggerServerEvent("introFinished", root)
					HUDRadar:new()
				end
			)
		elseif tutorialstage == 1 then
			-- Create Character
		elseif tutorialstage == 2 then
			-- Play Tutorial Mission
		else
			-- If the tutorial is done the server will do the job of spawning etc.
		end

		
	end
)

lgi = LoginGUI:new()
lgi:showHome(true)

if fileExists("logininfo.vrp") then
	local fh = fileOpen("logininfo.vrp")
	local len = fileGetSize(fh)
	if len > 64 then
		local pwhash = fileRead(fh, 64)
		local username = fileRead(fh, len-64)
		lgi.m_LoginEditUsername:setText(username)
		lgi.m_LoginEditPassword:setText(pwhash)
		lgi.usePasswordHash = pwhash;
		lgi.m_SaveLoginCheckbox:setChecked(true)
		lgi:anyChange()
		fileClose(fh)
	else
		-- Invalid
		fileClose(fh)
		fileDelete("logininfo.vrp")
	end
end