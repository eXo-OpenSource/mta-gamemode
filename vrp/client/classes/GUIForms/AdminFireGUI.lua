-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AdminFireGUI.lua
-- *  PURPOSE:     Admin Ped GUI class
-- *
-- ****************************************************************************

AdminFireGUI = inherit(GUIForm)
inherit(Singleton, AdminFireGUI)

addRemoteEvents{"adminFireReceiveData"}

function AdminFireGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-400, screenHeight/2-540/2, 800, 540)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Admin-Feuer Menü", true, true, self)

	self.m_Window:addBackButton(function ()  delete(self) AdminGUI:getSingleton():show() end)

	self.m_FireGrid = GUIGridList:new(10, 50, self.m_Width-20, 360, self.m_Window)
	self.m_FireGrid:addColumn(_"ID", 0.02)
	self.m_FireGrid:addColumn(_"Name", 0.2)
    self.m_FireGrid:addColumn(_"Ersteller", 0.15)
	self.m_FireGrid:addColumn(_"Nachricht", 0.48)
	self.m_FireGrid:addColumn(_"Status", 0.15)

	self.m_ShowAllFires = GUIButton:new(10, 460, 180, 30, "alle Feuer anzeigen",  self):setFontSize(1):setBackgroundColor(Color.LightBlue)
	self.m_CreateFire = GUIButton:new(10, 500, 180, 30, "neues Feuer erstellen",  self):setFontSize(1):setBackgroundColor(Color.Green)
	self.m_ToggleFire = GUIButton:new(200, 500, 180, 30, "Feuer starten",  self):setFontSize(1):setBackgroundColor(Color.LightBlue)
	self.m_EditFire = GUIButton:new(390, 500, 180, 30, "Feuer editieren",  self):setFontSize(1):setBackgroundColor(Color.LightBlue)
	self.m_DeleteFire = GUIButton:new(580, 500, 180, 30, "Feuer löschen",  self):setFontSize(1):setBackgroundColor(Color.Orange)
	
	self.m_ShowAllFires.onLeftClick = function()
		if not self.m_CurrentFireEditing then -- we use the same table, so dont override it
			if not self.m_FireShowing then
				self.m_ShowAllFires:setText("Markierungen löschen")
				self.m_EditFire:setEnabled(false)
				for i, v in pairs(self.m_Fires) do
					self.m_EditElements["blip_"..i] = Blip:new("Fire.png", v.positionTbl[1] + v.width/2, v.positionTbl[2] + v.height/2, 9999, BLIP_COLOR_CONSTANTS.Orange)
					self.m_EditElements["blip_"..i]:setDisplayText(v.name)
				end
				self.m_FireShowing = true
			else
				self.m_ShowAllFires:setText("alle Feuer anzeigen")
				self.m_EditFire:setEnabled(true)
				self:clearEditElements()
				self.m_FireShowing = nil
			end
		end
	end

	self.m_CreateFire.onLeftClick = function()
		triggerServerEvent("adminCreateFire", localPlayer)
	end

    self.m_ToggleFire.onLeftClick = function()
		if not self.m_SelectedFireId then
			return ErrorBox:new(_"Kein Feuer ausgewählt!")
		end
		triggerServerEvent("adminToggleFire", localPlayer, self.m_SelectedFireId)
	end

    self.m_EditFire.onLeftClick = function()
		if not self.m_SelectedFireId then
			return ErrorBox:new(_"Kein Feuer ausgewählt!")
		end
		if self.m_CurrentFireEditing then
			--TODO: save
			triggerServerEvent("adminEditFire", localPlayer, self.m_SelectedFireId, {
				name = self.m_NameEdit:getText(),
				message = self.m_MessageEdit:getText(),
				enabled = self.m_ActiveCheck:isChecked(),
				position = serialiseVector(self.m_EditSavedVars.pos_bl),
				width = self.m_EditSavedVars.width,
				height = self.m_EditSavedVars.height,
				generateMsg = self.m_MsgGenerateCheck:isChecked()
			})
			self:onEditFire()

		else
			self:onEditFire(self.m_SelectedFireId)
		end
		--triggerServerEvent("adminToggleFire", localPlayer, self.m_SelectedFireId)
	end

    self.m_DeleteFire.onLeftClick = function()
		if not self.m_SelectedFireId then
			return ErrorBox:new(_"Kein Feuer ausgewählt!")
		end
		QuestionBox:new(_"Möchtest du das Feuer wirklich permanent löschen? Du kannst es auch deaktivieren, damit es nicht mehr zufällig ausbricht", function()
			triggerServerEvent("adminDeleteFire", localPlayer, self.m_SelectedFireId)
		end)
	end

	-- fire edit functions
	self.m_FireSize = GUIButton:new(80 + 190, 420, 60, 30, "Größe",  self):setFontSize(1):setBackgroundColor(tocolor(255, 255, 0)):setColor(Color.Black)
	self.m_FirePosBL = GUIButton:new(10 + 190, 460, 60, 30, "unten l.",  self):setFontSize(1):setBackgroundColor(tocolor(255, 0, 255))
	self.m_NameEdit = GUIEdit:new(360, 420, 270, 30, self):setCaption("Name")
	self.m_MessageEdit = GUIEdit:new(360, 460, 270, 30, self):setCaption("Nachricht")
	self.m_ActiveCheck = GUICheckbox:new(640, 425, 200, 20, "aktiviert", self)
	self.m_MsgGenerateCheck = GUICheckbox:new(640, 465, 200, 20, "generieren", self)

	self.m_FireSize.onLeftClick = function()
		local x, y = localPlayer.position.x, localPlayer.position.y
		local bl_x, bl_y = self.m_Fires[self.m_CurrentFireEditing].positionTbl[1], self.m_Fires[self.m_CurrentFireEditing].positionTbl[2]
		if self.m_EditSavedVars.pos_bl then
			bl_x, bl_y = self.m_EditSavedVars.pos_bl.x, self.m_EditSavedVars.pos_bl.y
		end
		self.m_EditSavedVars.width = x - bl_x
		self.m_EditSavedVars.height = y - bl_y
		self:updateEditBoundingBox()
	end
	self.m_FirePosBL.onLeftClick = function()
		self.m_EditSavedVars.pos_bl = localPlayer.position
		self:updateEditBoundingBox()
	end

	self.m_EditElements = {}
	self.m_EditSavedVars = {}
	self:onSelectFire()
	self:onEditFire()
	self.m_FireShowing = nil

	addEventHandler("adminFireReceiveData", root, bind(self.onReceiveData, self))
end

function AdminFireGUI:onShow()
	SelfGUI:getSingleton():addWindow(self)
	triggerServerEvent("adminFireRequestData", localPlayer)
end

function AdminFireGUI:onHide()
	self:onSelectFire()
	self:onEditFire()
	SelfGUI:getSingleton():removeWindow(self)
end

function AdminFireGUI:clearEditElements()
	for i, ele in pairs(self.m_EditElements) do
		if isElement(ele) then
			ele:destroy()
		else
			ele:delete()
		end
	end
	self.m_EditElements = {}
end

function AdminFireGUI:onReceiveData(fires, activeId)

	self.m_Fires = fires
    self.m_CurrentActiveFireId = activeId

	self.m_FireGrid:clear()
    self:onSelectFire()
    self:onEditFire()
	for id, fireData in pairs(fires) do
        local state = (id == activeId and "aktiv") or (fireData["enabled"] and "geladen") or "deaktiviert"
        local msg = fireData["message"]
        if #msg > 40 then msg = msg:sub(0, 40).."..." end
		item = self.m_FireGrid:addItem(id, fireData["name"], fireData["creator"], msg, state)
		item.id = id
		item.onLeftClick = function()
			self:onSelectFire(id)
		end
	end
end

function AdminFireGUI:onSelectFire(id)
    if id then
        self.m_SelectedFireId = id
        self.m_ToggleFire:setVisible(true)
        self.m_EditFire:setVisible(true)
        self.m_DeleteFire:setVisible(true)

        if self.m_SelectedFireId == self.m_CurrentActiveFireId then
            self.m_ToggleFire:setText(_"Feuer stoppen")
        else
            self.m_ToggleFire:setText(_"Feuer starten")
        end
    else
        self.m_ToggleFire:setVisible(false)
        self.m_EditFire:setVisible(false)
        self.m_DeleteFire:setVisible(false)
    end
end

function AdminFireGUI:onEditFire(id)
	if id then 
		local data = self.m_Fires[id]
		self.m_ShowAllFires:setEnabled(false)
		self.m_CreateFire:setEnabled(false)
		self.m_ToggleFire:setEnabled(false)
		self.m_DeleteFire:setEnabled(false)

		self.m_EditElements["marker_bl"] = createMarker(data.positionTbl[1], data.positionTbl[2], data.positionTbl[3], "checkpoint", 1, 255, 0, 255, 100)
		self.m_EditElements["marker_tr"] = createMarker(data.positionTbl[1] + data.width, data.positionTbl[2] + data.height, data.positionTbl[3], "checkpoint", 1, 255, 255, 0, 100)
		self.m_EditElements["blip_bl"] = Blip:new("Marker.png", 0, 0, 9999, {255, 0, 255})
		self.m_EditElements["blip_tr"] = Blip:new("Marker.png", 0, 0, 9999, {255, 255, 0})
		self.m_EditElements["blip_bl"]:attach(self.m_EditElements["marker_bl"])
		self.m_EditElements["blip_tr"]:attach(self.m_EditElements["marker_tr"])

		self.m_EditFire:setText("Speichern")
		local data = self.m_Fires[id]
		self.m_NameEdit:setText(data.name)
		self.m_MessageEdit:setText(data.message)
		self.m_ActiveCheck:setChecked(data.enabled)
		self.m_MsgGenerateCheck:setChecked(false)

		self.m_EditSavedVars.pos_bl = normaliseVector(data.positionTbl)
		self.m_EditSavedVars.width = data.width
		self.m_EditSavedVars.height = data.height
	else
		self.m_ShowAllFires:setEnabled(true)
		self.m_CreateFire:setEnabled(true)
		self.m_ToggleFire:setEnabled(true)
		self.m_DeleteFire:setEnabled(true)
		self.m_EditFire:setText("Feuer editieren")
		self:clearEditElements()
	end

	self.m_FireSize:setVisible(id and true)
	self.m_FirePosBL:setVisible(id and true)
	self.m_NameEdit:setVisible(id and true)
	self.m_MessageEdit:setVisible(id and true)
	self.m_ActiveCheck:setVisible(id and true)
	self.m_MsgGenerateCheck:setVisible(id and true)
	

	self.m_CurrentFireEditing = id
end

function AdminFireGUI:updateEditBoundingBox()
	local bl = self.m_EditSavedVars.pos_bl
	local w = math.round(self.m_EditSavedVars.width)
	local h = math.round(self.m_EditSavedVars.height)
	if w < 0 or h < 0 then
		WarningBox:new(_"Der gelbe Marker muss die obere rechte Ecke des Feuers markieren (nach Norden orientiert).")
		w, h = 0, 0
	end
	self.m_EditSavedVars.width = w
	self.m_EditSavedVars.height = h

	setElementPosition(self.m_EditElements["marker_bl"], bl.x, bl.y, bl.z)
	setElementPosition(self.m_EditElements["marker_tr"], bl.x + w, bl.y + h, bl.z)
end