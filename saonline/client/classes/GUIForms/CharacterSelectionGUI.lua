CharacterSelectionGUI = inherit(Singleton)
inherit(DxElement, CharacterSelectionGUI)

function CharacterSelectionGUI:constructor(accountinfo, charinfo)
	local font = dxCreateFont("files/fonts/gtafont.ttf", 120)
	local sw, sh = guiGetScreenSize()
	local bw, bh = math.floor(sw / 12), math.floor(sh / 15)
	
	DxElement.constructor(self, 0, 0, sw, sh, false, false)
	self.m_Background = GUIRectangle:new(0, 0, sw, sh, tocolor(2, 17, 39, 255), self)
	self.m_TopBar = GUIRectangle:new(bw, bh, sw-2*bw, 200, tocolor(0, 0, 0, 170), self)
	local servername = GUILabel:new(30, 40, sw, sh, "GTA:SA Online", 1, self.m_TopBar)
	servername:setFont(font)
	servername:setFontSize(0.4)
	
	local asize = sw / 12
	self.m_Avatar = GUIRectangle:new(sw-2*bw-asize-10, 10, asize, asize, tocolor(255, 0, 0, 255), self.m_TopBar)
	
	local tabw = (sw-2*bw)/(MAX_CHARACTERS+1)
	local tabh = sh-200-2*bh
	
	self.m_Character = {}
	
	for i = 1, MAX_CHARACTERS do
		local text = "Verfügbar"
		if accountinfo.MaxCharacters < i then
			text = "Gesperrt"
		end
		
		self.m_Character[i] = {}
		local cc = self.m_Character[i]
		
		cc.button = GUIRectangle:new(tabw*(i-1), 150, tabw, 50, tocolor(0, 0, 0, 0), self.m_TopBar)
		cc.button.onLeftClick = bind(CharacterSelectionGUI.openCharacter, self, i)
		
		cc.buttonBar = GUIRectangle:new(0, 0, tabw, 5, tocolor(19, 64, 121), cc.button)
		cc.buttonBar:hide()

		cc.buttonText = GUILabel:new(0, 0, tabw, 50, text, 0.2, cc.button)
		cc.buttonText:setFont(font)
		cc.buttonText:setColor(tocolor(255, 255, 255, 255))
		cc.buttonText:setAlignX("center")
		cc.buttonText:setAlignY("center")
		
		cc.tab = GUIRectangle:new(bw+tabw*(i-1), 20+bh+200, tabw-5, tabh, tocolor(0, 0, 0, 170), self)
		local lbl = GUILabel:new(5, 20, tabw-5, tabh-20, tostring(i), 1, cc.tab)
		lbl:setFont(font)
		lbl:setFontSize(1)
		cc.info = GUIRectangle:new(bw+tabw*i, 20+bh+200, tabw-5, tabh, tocolor(0, 0, 0, 170), self)
		cc.info:hide()
	end
	
	self.m_ActiveCharacter = false
	self:openCharacter(1)
end

function CharacterSelectionGUI:openCharacter(i)
	if i == self.m_ActiveCharacter then return end
	
	local sw, sh = guiGetScreenSize()
	local bw, bh = math.floor(sw / 12), math.floor(sh / 15)
	local tabw = (sw-2*bw)/(MAX_CHARACTERS+1)
	
	local cc = self.m_Character[i]
	cc.button.m_Width  = tabw*2
	cc.buttonBar.m_Width  = tabw*2
	cc.buttonText.m_Width  = tabw*2
	cc.buttonBar:show()
	cc.button.m_Color = tocolor(255, 255, 255, 255)
	cc.buttonText.m_Color = tocolor(0, 0, 0, 255)
	cc.tab:show()
	cc.info:show()
	
	if self.m_ActiveCharacter then
		local cold = self.m_Character[self.m_ActiveCharacter]
		cold.button.m_Width  = tabw
		cold.buttonBar.m_Width  = tabw
		cold.buttonText.m_Width  = tabw
		cold.button.m_Color = tocolor(0, 0, 0, 0)
		cold.buttonText.m_Color = tocolor(255, 255, 255, 255)
		cold.buttonBar:hide()
		cold.info:hide()
		
		for index = self.m_ActiveCharacter, MAX_CHARACTERS do
			local cafter = self.m_Character[index]
			cafter.button:setPosition(tabw*(index-1), nil)
			cafter.tab:setPosition(bw+tabw*(index-1), nil)
		end
	end
	
	for index = i+1, MAX_CHARACTERS do
		local cafter = self.m_Character[index]
		cafter.button:setPosition(tabw*index, nil)
		cafter.tab:setPosition(bw+tabw*index, nil)
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