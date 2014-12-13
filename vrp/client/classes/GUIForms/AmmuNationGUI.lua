AmmuNationGUI = inherit(GUIForm)
inherit(Singleton, AmmuNationGUI)

AmmuNationGUI.MARKER = createMarker(308.29330,-141.14204,998.60156,"cylinder",1.2,255,0,0,125)

function AmmuNationGUI:constructor()
	

	self.m_Selection = 1
	self.m_Active = false
	self.m_CameraInstance = false
	
	GUIForm.constructor(self,150,200,400,200)
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Ammu-Nation", true, false, self)
	self.m_Label = GUILabel:new(30, 45, 300, 300, _("Waffe : %s\nBenoetigtes Level: %d",AmmuNationGUI.INFO[self.m_Selection].NAME,AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].MinLevel), self)
	self.m_Label:setFont(VRPFont(24))
	self.m_BuyMagazine = GUIButton:new(30, 90, self.m_Width-60, 35, _("Magazin kaufen ( $ %i )",AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Magazine.price), self)
	self.m_BuyMagazine:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)	
	self.m_BuyMagazine.onLeftClick = bind(self.buyMagazine,self)
	self.m_BuyWeapon = GUIButton:new(30, 135, self.m_Width-60, 35, _("Waffe kaufen ( $ %i )",AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Weapon), self)
	self.m_BuyWeapon:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_BuyWeapon.onLeftClick = bind(self.buyWeapon,self)
	self:close()
	
	-- if the player spawn in this interior

	self:setDimension()
	
	setElementInterior(AmmuNationGUI.MARKER,7)
	
	addEvent("AmmuNation:setDimension",true)
	addEventHandler("AmmuNation:setDimension",localPlayer,bind(self.setDimension,self))
	
	addEventHandler("onClientKey", root, bind(self.onKey,self))
	addEventHandler("onClientMarkerHit", AmmuNationGUI.MARKER, bind(self.onMarkerHit,self))
end

function AmmuNationGUI:buyMagazine()
	triggerServerEvent("onPlayerMagazineBuy",localPlayer,AmmuNationGUI.INFO[self.m_Selection].ID)
end

function AmmuNationGUI:buyWeapon()
	triggerServerEvent("onPlayerWeaponBuy",localPlayer,AmmuNationGUI.INFO[self.m_Selection].ID)
end

function AmmuNationGUI:onMarkerHit(hitElement,dim)
	if hitElement == localPlayer and dim then
		self.m_Active = true
		self:open()
		self:updateMatrix()
	end
end

function AmmuNationGUI:setDimension(int)
	
	for key, value in pairs(AmmuNationGUI.INFO) do
		setElementDimension(value.WEAPON,getElementDimension(localPlayer))
		setElementInterior(value.WEAPON,7)
	end
	
	setElementDimension(AmmuNationGUI.MARKER,getElementDimension(localPlayer))
	
end

function AmmuNationGUI:onKey(key,state)

	if not self.m_Active then
		return
	end
	
	if key == "space" then
		self.m_Active = false
		if self.m_CameraInstance then delete(self.m_CameraInstance) end		
		setCameraTarget(localPlayer,localPlayer)
		self:close(true)
		return
	end
	
	if state then
		if key == "arrow_l" then
			self.m_Selection = self.m_Selection - 1
		elseif key == "arrow_r" then
			self.m_Selection = self.m_Selection + 1
		else
			return
		end
		self.m_Selection = math.max(math.min(self.m_Selection,#AmmuNationGUI.INFO),1)
		self.m_Label:setText(_("Waffe : %s\nBenoetigtes Level: %d",AmmuNationGUI.INFO[self.m_Selection].NAME,AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].MinLevel))
		self.m_BuyMagazine:setText(_("Magazin kaufen ( $ %i )",AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Magazine.price))
		self.m_BuyWeapon:setText(_("Waffe kaufen ( $ %i )",AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Weapon))
		self:updateMatrix()
	end
end

function AmmuNationGUI:updateMatrix()
	self.m_CurrentMatrix = {getCameraMatrix(localPlayer)}
	local fadeMatrix = AmmuNationGUI.INFO[self.m_Selection].MATRIX

	if self.m_CameraInstance then
		delete(self.m_CameraInstance)
	end
	
	self.m_CameraInstance = cameraDrive:new(self.m_CurrentMatrix[1],self.m_CurrentMatrix[2],self.m_CurrentMatrix[3],
	self.m_CurrentMatrix[4],self.m_CurrentMatrix[5],self.m_CurrentMatrix[6],
	fadeMatrix[1],fadeMatrix[2],fadeMatrix[3],
	fadeMatrix[4],fadeMatrix[5],fadeMatrix[6],
	1500
	)	
end

function AmmuNationGUI:destructor()

end

AmmuNationGUI.INFO = {
	[1] = {
		NAME = "AK-47",
		WEAPON = createObject(355,308,-144.6,1001.2),
		MATRIX = {308.227966,-142.709167,1001.194458,301.387390,-242.401749,1005.015076},
		ID = 30
	},
	[2] = {
		NAME = "M4A1",
		WEAPON = createObject(356,308.299,-144.6,1000.7),
		MATRIX = {308.141602,-143.443695,1000.868408,311.496613,-242.906876,991.079712},
		ID = 31
	},		
	[3] = {
		NAME = "MP5",
		WEAPON = createObject(353,303.299,-144.6,1001.2),
		MATRIX = {303.581848,-143.040573,1001.265564,294.203888,-242.526535,1005.086182},
		ID = 29
	},	
	[4] = {
		NAME = "Pistol",
		WEAPON = createObject(346,309.20001220703,-142.30000305176,999.70001220703,0,24,358),
		MATRIX = {309.173553,-141.216537,1000.342041,322.899658,-225.678635,948.595093},
		ID = 22
	},	
	[5] = {
		NAME = "Pistol-S",
		WEAPON = createObject(347,310,-142.39999389648,999.70001220703,0,23,305),
		MATRIX = {311.121979,-141.730835,1000.188477,238.921417,-199.475098,962.074463},
		ID = 23
	},	
	[6] = {
		NAME = "Shotgun",
		WEAPON = createObject(349,317.29998779297,-131.5,1000.6,0,0,270),
		MATRIX = {315.967560,-131.796539,1000.857971,415.202942,-131.063644,988.537292},
		ID = 25
	},
}