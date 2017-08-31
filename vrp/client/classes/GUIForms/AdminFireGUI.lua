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

	self.m_CloseButton = GUIButton:new(self.m_Width-30, 0, 30, 30, FontAwesomeSymbols.Close, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
	self.m_CloseButton.onLeftClick = function() self:delete() end

	self.m_BackButton = GUIButton:new(self.m_Width-60, 0, 30, 30, FontAwesomeSymbols.Left, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.LightBlue):setHoverColor(Color.White):setFontSize(1)
	self.m_BackButton.onLeftClick = function() self:close() AdminGUI:getSingleton():show() Cursor:show() end

	self.m_FireGrid = GUIGridList:new(10, 50, self.m_Width-20, 360, self.m_Window)
	self.m_FireGrid:addColumn(_"ID", 0.02)
	self.m_FireGrid:addColumn(_"Name", 0.2)
    self.m_FireGrid:addColumn(_"Ersteller", 0.15)
	self.m_FireGrid:addColumn(_"Nachricht", 0.48)
	self.m_FireGrid:addColumn(_"Status", 0.15)

	self.m_CreateFire = GUIButton:new(10, 500, 180, 30, "neues Feuer erstellen",  self):setFontSize(1):setBackgroundColor(Color.Green)
	self.m_ToggleFire = GUIButton:new(200, 500, 180, 30, "Feuer starten",  self):setFontSize(1):setBackgroundColor(Color.LightBlue)
	self.m_EditFire = GUIButton:new(390, 500, 180, 30, "Feuer editieren",  self):setFontSize(1):setBackgroundColor(Color.LightBlue)
	self.m_DeleteFire = GUIButton:new(580, 500, 180, 30, "Feuer löschen",  self):setFontSize(1):setBackgroundColor(Color.Orange)
	
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
			outputDebug("saved")
			self:onFireEdit()
		else
			outputDebug("editing")
			self:onFireEdit(self.m_SelectedFireId)
		end
		--triggerServerEvent("adminToggleFire", localPlayer, self.m_SelectedFireId)
	end

    self.m_DeleteFire.onLeftClick = function()
		if not self.m_SelectedFireId then
			return ErrorBox:new(_"Kein Feuer ausgewählt!")
		end
		triggerServerEvent("adminDeleteFire", localPlayer, self.m_SelectedFireId)
	end

	-- fire edit functions
	self.m_FirePosTR = GUIButton:new(80, 420, 60, 30, "oben r.",  self):setFontSize(1):setBackgroundColor(Color.Green)
	self.m_FirePosBL = GUIButton:new(10, 460, 60, 30, "unten l.",  self):setFontSize(1):setBackgroundColor(Color.Green)
	self.m_PosLbl = GUILabel:new(150, 420, 200, 70, "Position: 1337.50;45.34\nHöhe: 30, Breite: 30", self):setFont(VRPFont(25)):setFontSize(1)
	self.m_NameEdit = GUIEdit:new(360, 420, 200, 30, self):setCaption("Name")
	self.m_MessageEdit = GUIEdit:new(360, 460, 400, 30, self):setCaption("Nachricht")
	self.m_ActiveCheck = GUICheckbox:new(570, 425, 200, 20, "aktiviert", self)

	self:onSelectFire()
	self:onFireEdit()

	addEventHandler("adminFireReceiveData", root, bind(self.onReceiveData, self))
end

function AdminFireGUI:onShow()
	SelfGUI:getSingleton():addWindow(self)
	triggerServerEvent("adminFireRequestData", localPlayer)
end

function AdminFireGUI:onHide()
	self.m_SelectedFireId = nil
	self.m_CurrentFireEditing = nil
	SelfGUI:getSingleton():removeWindow(self)
end

function AdminFireGUI:onReceiveData(fires, activeId)

	self.m_Fires = fires
    self.m_CurrentActiveFireId = activeId

	self.m_FireGrid:clear()
    self:onSelectFire()
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

	if self.m_SelectedFireId then
		self:onSelectFire(self.m_SelectedFireId)
	end
end

function AdminFireGUI:onSelectFire(id)
    if id then
        local data = self.m_Fires[id]
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

function AdminFireGUI:onFireEdit(id)
	if id then 
		
		self.m_EditFire:setText("Speichern")
		local data = self.m_Fires[id]
		self.m_PosLbl:setText(("Position: %s;%s\nGröße: %s;%s"):format(data.positionTbl[1], data.positionTbl[2], data.width, data.height))
		self.m_NameEdit:setText(data.name)
		self.m_MessageEdit:setText(data.message)
		self.m_ActiveCheck:setChecked(data.enabled)
	else

		self.m_EditFire:setText("Feuer editieren")

	end

	self.m_FirePosTR:setVisible(id and true)
	self.m_FirePosBL:setVisible(id and true)
	self.m_PosLbl:setVisible(id and true)
	self.m_NameEdit:setVisible(id and true)
	self.m_MessageEdit:setVisible(id and true)
	self.m_ActiveCheck:setVisible(id and true)
	self.m_CreateFire:setEnabled(id and false or true)
	self.m_ToggleFire:setEnabled(id and false or true)
	self.m_DeleteFire:setEnabled(id and false or true)

	self.m_CurrentFireEditing = id
end
