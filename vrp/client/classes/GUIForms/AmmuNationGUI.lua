-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AmmuNationGUI.lua
-- *  PURPOSE:     Ammu nation GUI class
-- *
-- ****************************************************************************
AmmuNationGUI = inherit(GUIForm)
inherit(Singleton, AmmuNationGUI)

function AmmuNationGUI:constructor()
	self.m_Selection = 1
	self.m_CameraInstance = false

	GUIForm.constructor(self,screenWidth/2,screenHeight/2,400,200)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Ammu-Nation", true, true, self)
	self.m_Label = GUILabel:new(30, 45, 300, 300, _("Waffe: %s\nBenötigtes Level: %d",AmmuNationGUI.INFO[self.m_Selection].NAME, MIN_WEAPON_LEVELS[AmmuNationGUI.INFO[self.m_Selection].ID]), self.m_Window)
	self.m_Label:setFont(VRPFont(24))
	self.m_BuyMagazine = GUIButton:new(30, 90, self.m_Width-60, 35, _("Magazin kaufen ($%i)",AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Magazine.price), self.m_Window)
	self.m_BuyMagazine:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_BuyMagazine.onLeftClick = bind(self.buyMagazine,self)
	self.m_BuyWeapon = GUIButton:new(30, 135, self.m_Width-60, 35, _("Waffe kaufen ($%i)",AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Weapon), self.m_Window)
	self.m_BuyWeapon:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_BuyWeapon.onLeftClick = bind(self.buyWeapon,self)
	GUILabel:new(30, 175, 300, 20, "Leertaste - Schließen", self.m_Window)

	self.m_OnKeyFunc = bind(self.onKey, self)
	addEventHandler("onClientKey", root, self.m_OnKeyFunc)
end

function AmmuNationGUI:destructor()
	if self.m_CameraInstance then
		delete(self.m_CameraInstance)
	end
	setCameraTarget(localPlayer, localPlayer)
	removeEventHandler("onClientKey", root, self.m_OnKeyFunc)

	GUIForm.destructor(self)
end

function AmmuNationGUI:buyMagazine()
	triggerServerEvent("onPlayerMagazineBuy",localPlayer,AmmuNationGUI.INFO[self.m_Selection].ID)
end

function AmmuNationGUI:buyWeapon()
	triggerServerEvent("onPlayerWeaponBuy",localPlayer,AmmuNationGUI.INFO[self.m_Selection].ID)
end

function AmmuNationGUI:updateDimension(int)
	for key, value in pairs(AmmuNationGUI.INFO) do
		value.WEAPON:setDimension(localPlayer:getDimension())
		value.WEAPON:setInterior(7)
	end
end

function AmmuNationGUI:onKey(key, state)
	if key == "space" then
		delete(self)
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
		self.m_Selection = math.max(math.min(self.m_Selection, #AmmuNationGUI.INFO), 1)

		if AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Magazine then
			self.m_Label:setText(_("Waffe: %s\nBenötigtes Level: %d",AmmuNationGUI.INFO[self.m_Selection].NAME,MIN_WEAPON_LEVELS[AmmuNationGUI.INFO[self.m_Selection].ID]))
			self.m_BuyMagazine:setText(_("Magazin kaufen ($%i)",AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Magazine.price))
			self.m_BuyMagazine:setVisible(true)
			self.m_BuyWeapon:setText(_("Waffe kaufen ($%i)",AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Weapon))
		else
			self.m_Label:setText(_("%s\nBenötigtes Level: %d",AmmuNationGUI.INFO[self.m_Selection].NAME,MIN_WEAPON_LEVELS[AmmuNationGUI.INFO[self.m_Selection].ID]))
			self.m_BuyMagazine:setVisible(false)
			self.m_BuyWeapon:setText(_("%s kaufen ($%i)",AmmuNationGUI.INFO[self.m_Selection].NAME, AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Weapon))
		end
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

addEvent("openAmmuNationGUI", true)
addEventHandler("openAmmuNationGUI", root,
	function()
		local gui = AmmuNationGUI:getSingleton()
		gui:updateMatrix()
		gui:updateDimension()
	end
)

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
		NAME = "Desert Eagle",
		WEAPON = createObject(348,310,-142.39999389648,999.70001220703,0,23,305),
		MATRIX = {311.121979,-141.730835,1000.188477,238.921417,-199.475098,962.074463},
		ID = 24
	},
	[6] = {
		NAME = "Shotgun",
		WEAPON = createObject(349,317.29998779297,-131.5,1000.6,0,0,270),
		MATRIX = {315.967560,-131.796539,1000.857971,415.202942,-131.063644,988.537292},
		ID = 25
	},
	[7] = {
		NAME = "Rifle",
		WEAPON = createObject(357,317.29998779297,-133.5,1000.6,0,0,270),
		MATRIX = {315.967560,-133.8,1000.857971,415.202942,-131.063644,988.537292},
		ID = 33
	},

	[8] = {
		NAME = "Schlagring",
		WEAPON = createObject(331,313, -131.27, 1002,0,0,180),
		MATRIX = {313, -134.74839782715, 1002.470703125, 313, -133.81578063965, 1002.1194458008},
		ID = 1
	},

	[9] = {
		NAME = "Schutzweste",
		WEAPON = createObject(1242,308, -131.27, 1001.75,0,0,180),
		MATRIX = {308, -134.74839782715, 1002.470703125, 308, -133.81578063965, 1002.1194458008},
		ID = 0
	},
}
--[[AmmuNation = inherit(Singleton)

addRemoteEvents{"AmmuNationReciveDimension"}

local POSITION          = Vector3(0,0,3)
local WEAPON_POSITION   = Vector3(0,3,4)
local WEAPON_DIFF       = 50
local DIFF              = 1
local DEFAULTSECTION    = 1 -- Pistols
local DEFAULTWEAPON     = 1 -- RND
local DEFAULTCHANGETIME = 500 -- VALUES IN MS

-- DEBUG/TEST CATEGORIES

function table.wipe(t) t = {} end

AmmuNation.SECTION = {
    [1] =
    {
    NAME = "Halb- und Vollautomatische Gewehre";
    SUB =   {
            [1] = 31, -- M4
            [2] = 30, -- AK-47
            [3] = 33, -- Country Rifle
            [4] = 34, -- Sniper ( Scoped Version )
            };
    };
    [2] =
    {
    NAME = "Pistolen";
    SUB =   {
            [1] = 22, -- Pistol
            [2] = 23, -- Silenced Pistol
            [3] = 24, -- Desert Eagle
            };
    };

}

function AmmuNation:constructor()
    POSITION.z = POSITION.z - DIFF
    self.m_Marker = createMarker(POSITION.x,POSITION.y,POSITION.z,"cylinder",1.2,255,255,255,255)
    self.m_Section = DEFAULTSECTION
    self.m_Weapon = DEFAULTWEAPON
    self.m_WeaponElements = {}
    self.m_Progress = 0
    self.m_Changing = false
    self.m_IsShopping = false
    self.m_Coroutine = false

    addEventHandler("AmmuNationReciveDimension", root, bind(self.SetDimension,self))
    addEventHandler("onClientKey",               root, bind(self.OnClientKey, self))
    addEventHandler("onClientMarkerHit",         root, bind(self.OnMarkerHit, self))


    self:Setup()
end

function AmmuNation:OnMarkerHit(hitElement)
    if hitElement ~= localPlayer then return end
    self.m_IsShopping = true
    setElementFrozen(localPlayer,true)
end


function AmmuNation:SetDimension (dim)
    self.m_Marker:SetDimension(math.abs(dim))
end

function AmmuNation:OnDraw()
    self.m_Progress = self.m_Progress + 0.01

    if self.m_Changing then
        for key, value in ipairs(self.m_WeaponElements) do
            local typ = self.m_Movement == "l" and "-" or "+"
            local fixPos = WEAPON_POSITION.y+((self.m_Weapon-2)+(key-1)*WEAPON_DIFF)
            local pos = fixPos+(self.m_Progress*tonumber(typ..WEAPON_DIFF))
            local x,y,z = getElementPosition(value)
            setElementPosition(value,x,pos,z)
        end
    end

    if self.m_Progress >= 1 then
        removeEventHandler("onClientRender", root, bind(self.OnDraw,self))
        self.m_Changing = false
    end
end

function AmmuNation:Setup()
    -- ToDo
      for i = 1, #AmmuNation.SECTION[self.m_Section].SUB do
        self.m_WeaponElements[i] = createObject(353,WEAPON_POSITION.x,WEAPON_POSITION.y+WEAPON_DIFF*(i-1),WEAPON_POSITION.z)
      end
end

function AmmuNation:WipeAndChange(kind)
    if kind == "section" then
      table.foreach(self.m_WeaponElements,function(_,v) v:destroy() end)
      table.wipe(self.m_WeaponElements)
      for i = 1, #AmmuNation.SECTION[self.m_Section] do
        self.m_WeaponElements[i] = createObject(353,WEAPON_POSITION.x,WEAPON_POSITION.y+WEAPON_DIFF*(i-1),WEAPON_POSITION.z)
      end
    end

    if kind == "weapon" then
        self.m_Progress = 0
        addEventHandler("onClientRender", root, bind(self.OnDraw,self))
    end
end

function AmmuNation:OnClientKey(sKey)
    if self.m_Changing or not self.m_IsShopping then return end
    local key = sKey:lower()
    if key == "arrow_d" or key == "arrow_u" then
        local inc = key == "arrow_d" and -1 or 1
        self.m_Weapon = DEFAULTWEAPON
        self.m_Section = math.max(math.min(self.m_Section+inc,#AmmuNation.SECTION),1)
        self.m_Changing = true
        self:WipeAndChange("section")
    elseif key == "arrow_r" or key == "arrow_l" then
        local inc = key == "arrow_l" and -1 or 1
        self.m_Weapon = math.max(math.min(self.m_Weapon,#AmmuNation.SECTION[self.m_Section]),1)
        self.m_Changing = true
        self.m_Movement = split(key,"_")[2]
        self:WipeAndChange("weapon")
    elseif key == "space" then
    end
end]]
