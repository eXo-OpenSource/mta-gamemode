CharacterSelectionGUI = inherit(Singleton)
inherit(DxElement, CharacterSelectionGUI)

function CharacterSelectionGUI:constructor(accountinfo, charinfo)
	local font = dxCreateFont("files/fonts/gtafont.ttf", 120)
	local sw, sh = guiGetScreenSize()
	DxElement.constructor(self, 0, 0, sw, sh, false, false)
	self.m_Background = GUIRectangle:new(0, 0, sw, sh, tocolor(2, 17, 39, 255), self)
	self.m_TopBar = GUIRectangle:new(150, 50, sw-300, 250, tocolor(0, 0, 0, 170), self)
	local servername = GUILabel:new(30, 40, sw, sh, "GTA:SA Online", 1, self.m_TopBar)
	servername:setFont(font)
	servername:setFontSize(0.4)
	
	
	self.m_RegisterTab 	= GUIRectangle:new(150, 310, (sw-300)/3*2, sh-360, tocolor(0, 0, 0, 170), self)
	local tabw = (sw-300)/(MAX_CHARACTERS+1)
	local tabh = sh-360
	
	self.m_Character = {}
	
	for i = 1, accountinfo.MaxCharacters do
		self.m_Character[i] = {}
		local cc = self.m_Character[i]
		
		cc.button = GUIRectangle:new(tabw*(i-1), 200, tabw, 50, tocolor(255, 255, 255), self.m_TopBar)
		cc.button.onLeftClick = bind(CharacterSelectionGUI.openCharacter, self, i)

		cc.buttonText = GUILabel:new(0, 0, tabw, 50, "Verfügbar", 0.2, cc.button)
		cc.buttonText:setFont(font)
		cc.buttonText:setColor(tocolor(0, 0, 0, 255))
		cc.buttonText:setAlignX("center")
		cc.buttonText:setAlignY("center")
	end
	
	for i = accountinfo.MaxCharacters+1, MAX_CHARACTERS do
		self.m_Character[i] = {}
		local cc = self.m_Character[i]
		
		cc.button = GUIRectangle:new(tabw*(i-1), 200, tabw, 50, tocolor(255, 255, 255), self.m_TopBar)
		cc.button.onLeftClick = bind(CharacterSelectionGUI.openCharacter, self, i)
		
		cc.buttonText = GUILabel:new(0, 0, tabw, 50, "Gesperrt", 0.2, cc.button)
		cc.buttonText:setFont(font)
		cc.buttonText:setColor(tocolor(0, 0, 0, 255))
		cc.buttonText:setAlignX("center")
		cc.buttonText:setAlignY("center")
	end
	
	self.m_ActiveCharacter = false
	self:openCharacter(1)
end

function CharacterSelectionGUI:openCharacter(i)
	if i == self.m_ActiveCharacter then return end
	
	local sw, sh = guiGetScreenSize()
	local tabw = (sw-300)/(MAX_CHARACTERS+1)
	
	outputDebugString(i)
	local cc = self.m_Character[i]
	cc.button.m_Width  = tabw*2
	cc.buttonText.m_Width  = tabw*2
	
	if self.m_ActiveCharacter then
		local cold = self.m_Character[self.m_ActiveCharacter]
		cold.button.m_Width  = tabw
		cold.buttonText.m_Width  = tabw
		for index = self.m_ActiveCharacter, MAX_CHARACTERS do
			local cafter = self.m_Character[index]
			cafter.button:setPosition(tabw*(index-1), nil)
		end
	end
	for index = i+1, MAX_CHARACTERS do
		local cafter = self.m_Character[index]
		cafter.button:setPosition(tabw*index, nil)
	end
	
	self.m_ActiveCharacter = i
	self:anyChange()
end

addEvent("loginsuccess", true)
addEventHandler("loginsuccess", root, 
	function(accountinfo, charinfo)
		LoginGUI:getSingleton():delete()
		CharacterSelectionGUI:new(accountinfo, charinfo)
	end
)