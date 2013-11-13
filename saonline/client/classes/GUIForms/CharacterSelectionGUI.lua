CharacterSelectionGUI = inherit(Singleton)
inherit(GUIForm, CharacterSelectionGUI)

function CharacterSelectionGUI:constructor(accountinfo, charinfo)
	local font = dxCreateFont("files/fonts/gtafont.ttf", 120)
	local smallfont = dxCreateFont("files/fonts/gtafont.ttf", 12)
	local sw, sh = guiGetScreenSize()
	local bw, bh = math.floor(sw * 0.08), math.floor(sh * 0.04)
	
	GUIForm.constructor(self, 0, 0, sw, sh)
	self.m_Background = GUIRectangle:new(0, 0, sw, sh, tocolor(2, 17, 39, 255), self)
	self.m_TopBar = GUIRectangle:new(bw, bh, sw-2*bw, sh*0.2, tocolor(0, 0, 0, 170), self)
	GUILabel:new(30, 40, sw, sh, "V Roleplay", 1, self.m_TopBar)
		:setFont(VRPFont(sh*0.05))
	
	local asize = sw * 0.05
	self.m_Avatar = GUIImage:new(sw-2*bw-asize-10, 10, asize, asize, "files/images/avatar_default.png", self.m_TopBar)
	GUILabel:new(sw-2*bw-asize-25-dxGetTextWidth(accountinfo.Username, 1, smallfont), 10 + asize/3*0, dxGetTextWidth(accountinfo.Username, 1, smallfont), 25, accountinfo.Username, 1, self.m_TopBar):setFont(smallfont)	
	GUILabel:new(sw-2*bw-asize-25-dxGetTextWidth(RANK[accountinfo.Rank], 1, smallfont), 10 + asize/3*1, dxGetTextWidth(RANK[accountinfo.Rank], 1, smallfont), 25, RANK[accountinfo.Rank], 1, self.m_TopBar):setFont(smallfont)
	
	local text = ("BANK $%d   CASH $%d"):format(accountinfo.Money, accountinfo.Bank)
	GUILabel:new(sw-2*bw-asize-25-dxGetTextWidth(text, 1, smallfont), 10 + asize/3*2, dxGetTextWidth(text, 1, smallfont), 25, text, 1, self.m_TopBar):setFont(smallfont)
	
	
	local tabw = (sw-2*bw)/(MAX_CHARACTERS+1)
	local tabh = sh-200-2*bh
	
	self.m_Character = {}
	
	for i = 1, MAX_CHARACTERS do
		local text = "Available"
		if accountinfo.MaxCharacters < i then
			text = "Locked"
		end
		
		self.m_Character[i] = {}
		local cc = self.m_Character[i]
		cc.button = VRPButton:new(tabw*(i-1), sh*0.2-sh*0.05, tabw, sh*0.05, text, self.m_TopBar):dark()
		cc.button.onLeftClick = bind(CharacterSelectionGUI.openCharacter, self, i)
		
		cc.tab = GUIRectangle:new(bw+tabw*(i-1), bh+sh*0.2+10, tabw-5, tabh, tocolor(0, 0, 0, 170), self)
		GUILabel:new(5, 20, tabw-5, tabh-20, tostring(i), 1, cc.tab)
			:setFont(VRPFont(tabh*0.42))
		
		cc.info = GUIRectangle:new(bw+tabw*i, bh+sh*0.2+10, tabw-5, tabh-tabh*0.08, tocolor(0, 0, 0, 170), self)
		local titlebar = GUIRectangle:new(0, 0, tabw-5, tabh*0.05, tocolor(4, 78, 153, 255), cc.info)
		GUILabel:new(0, 0, tabw-5, tabh*0.05, accountinfo.Username, 1, titlebar)
			:setFont(VRPFont(tabh*0.035))
			:setAlign("center", "center")
		
		local wsize = math.floor(tabh*0.2)
		GUIImage:new((tabw-5-wsize)/2, tabh*0.08, wsize, wsize, "files/images/world.png", cc.info)
		local cfore, cback = tocolor(4, 78, 153, 255), tocolor(12, 25, 42, 255)
		
		GUILabel:new(10, tabh*0.31, tabw-25, 100, "Driving", 1, cc.info):setFont(VRPFont(tabh*0.035))
		GUIBar:new(15, tabh*0.36, tabw-30, tabh*0.025, cfore, cback, 0.5, cc.info)

		GUILabel:new(10, tabh*0.40, tabw-25, 100, "Shooting", 1, cc.info):setFont(VRPFont(tabh*0.035))
		GUIBar:new(15, tabh*0.45, tabw-30, tabh*0.025, cfore, cback, 0.5, cc.info)

		GUILabel:new(10, tabh*0.49, tabw-25, 100, "Flying", 1, cc.info):setFont(VRPFont(tabh*0.035))
		GUIBar:new(15, tabh*0.54, tabw-30, tabh*0.025, cfore, cback, 0.5, cc.info)

		GUILabel:new(10, tabh*0.58, tabw-25, 100, "Sneaking", 1, cc.info):setFont(VRPFont(tabh*0.035))
		GUIBar:new(15, tabh*0.63, tabw-30, tabh*0.025, cfore, cback, 0.5, cc.info)

		GUILabel:new(10, tabh*0.67, tabw-25, 100, "Endurance", 1, cc.info):setFont(VRPFont(tabh*0.035))
		GUIBar:new(15, tabh*0.72, tabw-30, tabh*0.025, cfore, cback, 0.5, cc.info)
		
		GUILabel:new(10, tabh*0.80, tabw-25, 100, "Device Access", 1, cc.info):setFont(VRPFont(tabh*0.035))
		
		cc.info:hide()
	end
	
	self.m_ActiveCharacter = false
	self:openCharacter(1)
end

function CharacterSelectionGUI:openCharacter(i)
	if i == self.m_ActiveCharacter then return end
	
	local sw, sh = guiGetScreenSize()
	local bw, bh = math.floor(sw * 0.08), math.floor(sh * 0.04)
	local tabw = (sw-2*bw)/(MAX_CHARACTERS+1)
	
	local cc = self.m_Character[i]
	cc.button:setSize(tabw*2)
	cc.button:light()
	cc.tab:show()
	cc.info:show()
	
	if self.m_ActiveCharacter then
		local cold = self.m_Character[self.m_ActiveCharacter]
		cold.button:dark()
		cold.button:setSize(tabw)
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