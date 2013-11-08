LoginGUI = inherit(Singleton)
LoginGUI = inherit(DxElement)

function LoginGUI:constructor()	
	local font = dxCreateFont("files/fonts/gtafont.ttf", 120)
	local sw, sh = guiGetScreenSize()
	DxElement.constructor(self, 0, 0, sw, sh, false, false)
	self.m_Background = GUIRectangle:new(0, 0, sw, sh, tocolor(2, 17, 39, 255), self)
	self.m_TopBar = GUIRectangle:new(150, 50, sw-300, 200, tocolor(0, 0, 0, 170), self)
	local servername = GUILabel:new(30, 40, sw, sh, "GTA:SA Online", 1, self.m_TopBar)
	servername:setFont(font)
	servername:setFontSize(0.4)
	
	self.m_HomeButton = GUIButton:new(0, 200, (sw-300)/3, 50, "Home", self.m_TopBar)
	self.m_HomeButton:setFont(font)
	self.m_HomeButton:setFontSize(0.25)
	self.m_HomeButton.m_BackgroundColor = tocolor(255, 255, 255)
	self.m_HomeButton.onLeftClick = bind(LoginGUI.showHome, self)
	
	self.m_LoginButton = GUIButton:new((sw-300)/3, 200, (sw-300)/3, 50, "Login", self.m_TopBar)
	self.m_LoginButton:setFont(font)
	self.m_LoginButton:setFontSize(0.25)
	self.m_LoginButton.m_BackgroundColor = tocolor(255, 255, 255)
	self.m_LoginButton.onLeftClick = bind(LoginGUI.showLogin, self)
	
	self.m_RegisterButton = GUIButton:new((sw-300)/3*2, 200, (sw-300)/3, 50, "Register", self.m_TopBar)
	self.m_RegisterButton:setFont(font)
	self.m_RegisterButton:setFontSize(0.25)
	self.m_RegisterButton.m_BackgroundColor = tocolor(255, 255, 255)
	self.m_RegisterButton.onLeftClick = bind(LoginGUI.showRegister, self)
end

function LoginGUI:showHome()
	self.m_RegisterButton.m_BackgroundColor = tocolor(0, 0, 0, 0)
	self.m_LoginButton.m_BackgroundColor = tocolor(0, 0, 0, 0)
	self.m_HomeButton.m_BackgroundColor = tocolor(255, 255, 255)
end

function LoginGUI:showLogin()
	self.m_RegisterButton.m_BackgroundColor = tocolor(0, 0, 0, 0)
	self.m_LoginButton.m_BackgroundColor = tocolor(255, 255, 255)
	self.m_HomeButton.m_BackgroundColor = tocolor(0, 0, 0, 0)
end

function LoginGUI:showRegister()
	self.m_RegisterButton.m_BackgroundColor = tocolor(255, 255, 255)
	self.m_LoginButton.m_BackgroundColor = tocolor(0, 0, 0, 0)
	self.m_HomeButton.m_BackgroundColor = tocolor(0, 0, 0, 0)
end

function f()
	lgi:showHome()
	setTimer(	
	function() 
		lgi:showLogin()
		setTimer(	
		function() 
			lgi:showRegister()
			setTimer(f, 1000, 1) 
		end, 1000, 1)
	end,
	1000, 1)
end			

addCommandHandler("logingui",
	function()
		lgi = LoginGUI:new()
		f()
	end
)
