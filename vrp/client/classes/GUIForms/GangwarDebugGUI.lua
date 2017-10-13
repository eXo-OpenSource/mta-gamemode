-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/GangwarDebugGUI.lua
-- *  PURPOSE:     Gangwar Debug GUI class
-- *
-- ****************************************************************************
GangwarDebugGUI = inherit(GUIForm)

function GangwarDebugGUI:constructor(gui)
	GUIForm.constructor(self, screenWidth/2-600/2, screenHeight/2-410/2, 600, 410)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Gangwar-Menü", true, true, self)

	if gui then
		self.m_Window:addBackButton(function () delete(self) gui:getSingleton():show() end)
	end
	self.m_GangwarAreas = {}
	self.m_GangAreasGrid = GUIGridList:new(10, 55, 200, 300, self.m_Window)
	self.m_GangAreasGrid:addColumn(_"Gebiete", 1)
	
			
	triggerServerEvent("gangwarGetAreas", localPlayer)	
	addRemoteEvents{"gangwarLoadArea", "gangwarRefresh"}
	addEventHandler("gangwarLoadArea", root, bind(self.Event_gangwarLoadArea, self))
	addEventHandler("gangwarRefresh", root, bind(self.Event_refresh, self))
end

function GangwarDebugGUI:Event_refresh() 
	if self.m_GangwarChart then delete(self.m_GangwarChart) end
	if self.m_AreaName then delete(self.m_AreaName) end
	if self.m_AreaOwner then delete(self.m_AreaOwner) end
	if self.m_LastAttack then delete(self.m_LastAttack) end
	if self.m_NextAttack then delete(self.m_NextAttack) end
	if self.m_GangwarChangeOwnerBtn then delete(self.m_GangwarChangeOwnerBtn) end
	if self.m_Map then delete(self.m_Map) end
	if self.m_GangwarChangeOwnerBtn then delete(self.m_GangwarChangeOwnerBtn) end
	if self.m_GangwarResetLastAttack then delete(self.m_GangwarResetLastAttack) end
	if self.m_TimestampArea then delete(self.m_TimestampArea) end 
	if self.m_GangwarSetLastAttack then delete(self.m_GangwarSetLastAttack) end
	if self.m_TitleLabel then delete(self.m_TitleLabel) end
	self.m_GangAreasGrid:clear()
	triggerServerEvent("gangwarGetAreas", localPlayer)	
end

function GangwarDebugGUI:Event_gangwarLoadArea(name, position, owner, lastAttack, id)
	self.m_GangwarAreas[name] = {["name"] = name, ["posX"] = position[1], ["posY"] = position[2], ["posZ"] = posZ, ["owner"] = owner, ["lastAttack"] = lastAttack, ["id"] = id}
	local item = self.m_GangAreasGrid:addItem(name)
	item.onLeftClick = function() self:onGangwarItemSelect(self.m_GangwarAreas[name]) end
end

function GangwarDebugGUI:getIdFromItem( searchItem ) 
	local count = 0 
	for _, item in pairs(self.m_GangwarAreas) do 
		count = count + 1
		if item == searchItem then 
			return item.id
		end
	end
	return false
end
function GangwarDebugGUI:onGangwarItemSelect(item)
	if self.m_GangwarChart then delete(self.m_GangwarChart) end
	if self.m_AreaName then delete(self.m_AreaName) end
	if self.m_AreaOwner then delete(self.m_AreaOwner) end
	if self.m_LastAttack then delete(self.m_LastAttack) end
	if self.m_NextAttack then delete(self.m_NextAttack) end
	if self.m_GangwarChangeOwnerBtn then delete(self.m_GangwarChangeOwnerBtn) end
	if self.m_Map then delete(self.m_Map) end
	if self.m_GangwarChangeOwnerBtn then delete(self.m_GangwarChangeOwnerBtn) end
	if self.m_GangwarResetLastAttack then delete(self.m_GangwarResetLastAttack) end
	if self.m_TimestampArea then delete(self.m_TimestampArea) end
	if self.m_GangwarSetLastAttack then delete(self.m_GangwarSetLastAttack) end
	if self.m_TitleLabel then delete(self.m_TitleLabel) end
	if item then
		self.m_AreaName = GUILabel:new(self.m_Width*0.4, 55, self.m_Width*0.4, self.m_Height*0.08, item.name, self)
		local ownerFaction = FactionManager:getSingleton():getFromId(item.owner)
		self.m_AreaOwner = GUILabel:new(self.m_Width*0.4, 55+self.m_Height*0.1, self.m_Width*0.7, self.m_Height*0.06, _("Besitzer: %s", ownerFaction and ownerFaction:getName() or "-"), self)
		self.m_LastAttack = GUILabel:new(self.m_Width*0.4, 55+self.m_Height*0.2, self.m_Width*0.4, self.m_Height*0.06,_("Letzter Angriff: %s", getOpticalTimestamp(item.lastAttack)), self)
		self.m_NextAttack = GUILabel:new(self.m_Width*0.4, 55+self.m_Height*0.3, self.m_Width*0.4, self.m_Height*0.06,_("Nächster Angriff: %s", getOpticalTimestamp(item.lastAttack+(GANGWAR_ATTACK_PAUSE*UNIX_TIMESTAMP_24HRS))), self)
		self.m_Map = GUIMiniMap:new(self.m_Width*0.4, 55+self.m_Height*0.4, self.m_Width*0.25, self.m_Width*0.225, self	)
		self.m_Map:setPosition(item.posX, item.posY)
		self.m_Map:addBlip("Marker.png", item.posX, item.posY)
		local areaId = self:getIdFromItem( item )
		self.m_GangwarChangeOwnerBtn =  GUIButton:new(self.m_Width*0.4+self.m_Width*0.26, 55+self.m_Height*0.4, self.m_Width*0.3, self.m_Height*0.06, "Umsetzen", self):setBackgroundColor(Color.Blue):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
		self.m_GangwarChangeOwnerBtn.onLeftClick = function()
			local factionTable = FactionManager:getSingleton():getFactionNames()
			ChangerBox:new(_"Fraktion für das Gebiet",
			_"Bitte wähle die gewünschte Fraktion aus:",factionTable,
			function (factionId)
				triggerServerEvent("adminGangwarSetAreaOwner", localPlayer, areaId, factionId)
			end)
		end
		self.m_GangwarResetLastAttack =  GUIButton:new(self.m_Width*0.4+self.m_Width*0.26, 55+self.m_Height*0.5, self.m_Width*0.3, self.m_Height*0.06, "Freigeben", self):setBackgroundColor(Color.Blue):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
		self.m_GangwarResetLastAttack.onLeftClick = function() triggerServerEvent("adminGangwarResetArea", localPlayer, areaId, tonumber(self.m_TimestampArea:getText())) end
		
		self.m_TimestampArea = GUIEdit:new(self.m_Width*0.4+self.m_Width*0.26, 55+self.m_Height*0.57, self.m_Width*0.3, self.m_Height*0.06, self):setCaption("Timestamp")
		self.m_TimestampArea:setNumeric(true, true)
		self.m_TitleLabel = GUILabel:new(self.m_Width*0.4+self.m_Width*0.26, 55+self.m_Height*0.66, self.m_Width*0.3, self.m_Height*0.06, "*Wenn bestimmte Zeit für Freigabe dann im Feld eintragen!", self):setFontSize(0.65)
	end
end

function GangwarDebugGUI:destructor()
	GUIForm.destructor(self)
end